import 'dart:ffi';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/StickerPlugin/models/sticker_data.dart';
import 'package:flutter_merraland_online_new/StickerPlugin/screens/stickers_screen.dart';
import 'package:flutter_merraland_online_new/layouts/header_layout.dart';
import 'package:flutter_merraland_online_new/layouts/header_layout_arrow.dart';
import 'package:flutter_merraland_online_new/layouts/menu_layout.dart';
import 'package:flutter_merraland_online_new/pages/detailContent_page.dart';
import 'package:flutter_merraland_online_new/pages/login_page.dart';
import 'package:flutter_merraland_online_new/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:whatsapp_stickers_handler/exceptions.dart';
import 'package:whatsapp_stickers_handler/whatsapp_stickers_handler.dart';

import '../StickerPlugin/constants/constants.dart';



class detailCategory_page extends StatefulWidget {

  @override
  State<detailCategory_page> createState() => _detailCategory_pageState();
}

class _detailCategory_pageState extends State<detailCategory_page> {

  int _currentimgPartner = 0;
  int _currentSliders = 0;
  final CarouselController _controller = CarouselController();

  String convertToAgo(DateTime input)
  {
    Duration diff = DateTime.now().difference(input);
    
    if(diff.inDays >= 1){
      return '${diff.inDays} day(s) ago';
    } else if(diff.inHours >= 1){
      return '${diff.inHours} hour(s) ago';
    } else if(diff.inMinutes >= 1){
      return '${diff.inMinutes} minute(s) ago';
    } else if (diff.inSeconds >= 1){
      return '${diff.inSeconds} second(s) ago';
    } else {
      return 'just now';
    }
  }


  // Create storage
  final storage = new FlutterSecureStorage();
  final String _baseUrl = 'https://bukahuni.com';
  final String stikersDetailStikersCategoryUrl = '/api/stikers/detailStikersCategory/';
  final String stikersDetailStikersCategoryStikerImagesUrl = '/api/stikers/detailStikersCategoryStikerImages/';
  final String stikersDetailSimiliarUrl = '/api/stikers/detailStikersSimiliar?search=';
  final String stikersDetailSimiliarSecondUrl = '/api/stikers/detailStikersSimiliarSecond?search=';
  final String stikersCategorySimiliarUrl = '/api/stikers/categorySimiliar?search=';
  final String stikerCommentCategoryUrl = '/api/stikers/stikerCommentCategory/';
  final String stikersPostCreateCommentUrl = '/api/stikers/stikerCommentCreate';
  final String stikerstikerCommentDeleteUrl = '/api/stikers/stikerCommentDelete/';
  final String stickerUpdateAmountDownloadUrl = '/api/stikers/stickerUpdateAmountDownload/';


  RefreshController refreshController = RefreshController();
  final _scrollController = ScrollController();

  final ValueNotifier<int> _counter = ValueNotifier<int>(0);
  late TextEditingController _commenthController;

  bool commentAvaible = false;
  String? idComment = '';

  int allDataStikers = 0;

  Future _stickerUpdateAmountDownload(String id) async
  {
    String? token = '';
    token = await storage.read(key: 'token');

    final response = await http.post(Uri.parse(_baseUrl+stickerUpdateAmountDownloadUrl+id), 
      headers: {
        'Authorization': 'Bearer $token',
      }, 
      body: {
        "amountDownload" : '1',
      }
    );

    return response.body;
  }



  Future _stikersPostCreateComment() async
  {
    String? token = '';
    token = await storage.read(key: 'token');

    String? idStikersCategory = '';
    idStikersCategory = await storage.read(key: 'idStikersCategory');

    String? idProfil = '';
    idProfil = await storage.read(key: 'idProfil');

    final response = await http.post(Uri.parse(_baseUrl+stikersPostCreateCommentUrl), 
      headers: {
        'Authorization': 'Bearer $token',
      }, 
      body: {
        "rating" : starsRating.toString(),
        "comment" : _commenthController.text,
        "stikers_category_id" : idStikersCategory.toString(),
        "stikers_user_id" : idProfil.toString(),
      }
    );

    return response.body;
  }

  Future _stikerstikerCommentDelete() async
  {
    String? token = '';
    token = await storage.read(key: 'token');

    final response = await http.post(Uri.parse(_baseUrl+stikerstikerCommentDeleteUrl+idComment!), 
      headers: {
        'Authorization': 'Bearer $token',
      }, 
    );

    return response.body;
  }

  Future<List> _stikerCommentCategory() async {

    String? token = '';
    token = await storage.read(key: 'token');

    String? idStikersCategory = '';
    idStikersCategory = await storage.read(key: 'idStikersCategory');

    String? username = '';
    username = await storage.read(key: 'username');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    try {
      // This is an open REST API endpoint for testing purposes
      final http.Response response = await http.get(Uri.parse(_baseUrl+stikerCommentCategoryUrl+idStikersCategory!), headers: {
        'Authorization': 'Bearer $token',
      });
      
      map = json.decode(response.body);
      posts = map["data"];

    } catch (err) {
      print(err);
    }

    for(int i = 0; i < posts.length; i++)
    {
      
      if(username == posts[i]['stikers_user']['username'])
      {
        if(commentAvaible == false)
        {
          commentAvaible = true;
          setState(() {});
        }
        
      }

    }

    return posts;
  }

  
  Future<List> _stikersDetailStikersCategory() async {

    String? token = '';
    token = await storage.read(key: 'token');

    String? idStikersCategory = '';
    idStikersCategory = await storage.read(key: 'idStikersCategory');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    try {
      // This is an open REST API endpoint for testing purposes
      final http.Response response = await http.get(Uri.parse(_baseUrl+stikersDetailStikersCategoryUrl+idStikersCategory!), headers: {
        'Authorization': 'Bearer $token',
      });
      
      map = json.decode(response.body);
      posts = map["data"];

    } catch (err) {
      print(err);
    }

    // print(posts);


    return posts;
  }

  Future<List> _stikersDetailStikersCategoryStikerImages() async {

    String? token = '';
    token = await storage.read(key: 'token');

    String? idStikersCategory = '';
    idStikersCategory = await storage.read(key: 'idStikersCategory');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    try {
      // This is an open REST API endpoint for testing purposes
      final http.Response response = await http.get(Uri.parse(_baseUrl+stikersDetailStikersCategoryStikerImagesUrl+idStikersCategory!), headers: {
        'Authorization': 'Bearer $token',
      });
      
      map = json.decode(response.body);
      posts = map["data"];

    } catch (err) {
      print(err);
    }

    // print(posts);


    return posts;
  }

  Future<List> _stikersAllOtherSimiliar() async {

    String? token = '';
    token = await storage.read(key: 'token');

    String? stikerName = '';
    stikerName = await storage.read(key: 'stikerName');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    try {
      // This is an open REST API endpoint for testing purposes
      final http.Response response = await http.get(Uri.parse(_baseUrl+stikersDetailSimiliarUrl+stikerName!), headers: {
        'Authorization': 'Bearer $token',
      });
      
      map = json.decode(response.body);
      posts = map["data"];

    } catch (err) {
      print(err);
    }

    // print(posts);


    return posts;
  }

  Future<List> _stikersAllOtherSimiliarSecond() async {

    String? token = '';
    token = await storage.read(key: 'token');

    String? stikerName = '';
    stikerName = await storage.read(key: 'stikerName');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    try {
      // This is an open REST API endpoint for testing purposes
      final http.Response response = await http.get(Uri.parse(_baseUrl+stikersDetailSimiliarSecondUrl+stikerName!), headers: {
        'Authorization': 'Bearer $token',
      });
      
      map = json.decode(response.body);
      posts = map["data"];

    } catch (err) {
      print(err);
    }

    allDataStikers = posts.length;

    // print(posts);


    return posts;
  }

  Future<List> _stikersCategorySimiliar() async {

    String? token = '';
    token = await storage.read(key: 'token');

    String? stikerPackName = '';
    stikerPackName = await storage.read(key: 'stikerPackName');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    try {
      // This is an open REST API endpoint for testing purposes
      final http.Response response = await http.get(Uri.parse(_baseUrl+stikersCategorySimiliarUrl+stikerPackName!), headers: {
        'Authorization': 'Bearer $token',
      });
      
      map = json.decode(response.body);
      posts = map["data"];

    } catch (err) {
      print(err);
    }

    // print(posts);


    return posts;
  }


  String? usernameProfile = '';
  String? photoProfileUser = '';


  Future<void> _checkUser() async {
    usernameProfile = await storage.read(key: 'username');
    photoProfileUser = await storage.read(key: 'photoProfile');

  }

  void onRefresh() async{
    await Future.delayed(Duration(seconds: 1));
    _stikersDetailStikersCategory();
    _stikerCommentCategory();
    _stikersDetailStikersCategoryStikerImages();
    _stikersAllOtherSimiliar();
    _stikersAllOtherSimiliarSecond();
    _stikersCategorySimiliar();
    setState(() {});
    refreshController.refreshCompleted();
  }

  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-6717426320595915/4202366632',
    // adUnitId: 'ca-app-pub-3940256099942544/6300978111',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );

  final BannerAdListener listener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
      print('Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => print('Ad closed.'),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) => print('Ad impression.'),
  );
  

  int countOfData = 10;

  void listenScrolling()
  {

    if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent)
    {
        if(countOfData <= allDataStikers)
        {

          countOfData += 10;

          if(countOfData >= allDataStikers)
          {
            countOfData = allDataStikers;
          }

          setState(() {});

        }

    }

  }

  // ##$################################################# sticker


  void _addStickerPack(AsyncSnapshot snapshot , int index) async {

    Map<String, List<String>> stickers = <String, List<String>>{};

    var tryImage = '';

    final dio = Dio();
    final downloads = <Future>[];
    var applicationDocumentsDirectory = await getApplicationDocumentsDirectory();

    var stickersDirectory = Directory(
        //'${applicationDocumentsDirectory.path}/stickers/${stickerPack.identifier}');
        '${applicationDocumentsDirectory.path}/${snapshot.data![index]['id'].toString()}'
    );
    await stickersDirectory.create(recursive: true);

    downloads.add(
      dio.download(
        "${BASE_URL_2}${snapshot.data![index]['stikers'][0]['image']}",
        "${stickersDirectory.path}/${snapshot.data![index]['stikers'][0]['image'].toLowerCase()}",
      ),
    );

    tryImage = WhatsappStickerImageHandler.fromFile(
      "${stickersDirectory.path}/${snapshot.data![index]['stikers'][0]['image'].toLowerCase()}"
    ).path;

    if(snapshot.data![index]['stikers'].length >= 3)
    {
      for(int i = 0; i < snapshot.data![index]['stikers'].length; i++)
      {
        var urlPath = "${BASE_URL_2}${snapshot.data![index]['stikers'][i]['imageWebp']}";
        var savePath = "${stickersDirectory.path}/${snapshot.data![index]['stikers'][i]['imageWebp'].toLowerCase()}";
        downloads.add(
          dio.download(
            urlPath,
            savePath,
          ),
        );

        stickers[
          WhatsappStickerImageHandler.fromFile("${stickersDirectory.path}/${snapshot.data![index]['stikers'][i]['imageWebp'].toLowerCase()}").path
        ] = ['stikers', 'id'] as List<String>;

      }
    }
    else if(snapshot.data![index]['stikers'].length == 2)
    {

        var urlPath = "${BASE_URL_2}${snapshot.data![index]['stikers'][0]['imageWebp']}";
        var savePath = "${stickersDirectory.path}/${snapshot.data![index]['stikers'][0]['imageWebp'].toLowerCase()}";
        downloads.add(
          dio.download(
            urlPath,
            savePath,
          ),
        );

        var urlPath2 = "${BASE_URL_2}${snapshot.data![index]['stikers'][1]['imageWebp']}";
        var savePath2 = "${stickersDirectory.path}/${snapshot.data![index]['stikers'][1]['imageWebp'].toLowerCase()}";
        downloads.add(
          dio.download(
            urlPath2,
            savePath2,
          ),
        );

        String sticker3 = snapshot.data![index]['animatedStickerPack'] == 0 ? 'default_3.webp' : 'default_5.webp';
        var urlPath3 = "${BASE_URL_2}$sticker3";
        var savePath3 = "${stickersDirectory.path}/${sticker3.toLowerCase()}";
        downloads.add(
          dio.download(
            urlPath3,
            savePath3,
          ),
        );

        stickers = 
        {
          
          "${WhatsappStickerImageHandler.fromFile("${stickersDirectory.path}/${snapshot.data![index]['stikers'][0]['imageWebp'].toLowerCase()}").path}": ["stikers", "id"], 
          "${WhatsappStickerImageHandler.fromFile("${stickersDirectory.path}/${snapshot.data![index]['stikers'][1]['imageWebp'].toLowerCase()}").path}": ["stikers", "id"], 
          "${WhatsappStickerImageHandler.fromFile("${stickersDirectory.path}/${sticker3.toLowerCase()}").path}": ["stikers", "id"], 
        };


    }
    else if(snapshot.data![index]['stikers'].length == 1)
    {

        var urlPath = "${BASE_URL_2}${snapshot.data![index]['stikers'][0]['imageWebp']}";
        var savePath = "${stickersDirectory.path}/${snapshot.data![index]['stikers'][0]['imageWebp'].toLowerCase()}";
        downloads.add(
          dio.download(
            urlPath,
            savePath,
          ),
        );

        String sticker2 = snapshot.data![index]['animatedStickerPack'] == 0 ? 'default_2.webp' : 'default_4.webp';
        var urlPath2 = "${BASE_URL_2}$sticker2";
        var savePath2 = "${stickersDirectory.path}/${sticker2.toLowerCase()}";
        downloads.add(
          dio.download(
            urlPath2,
            savePath2,
          ),
        );

        String sticker3 = snapshot.data![index]['animatedStickerPack'] == 0 ? 'default_3.webp' : 'default_5.webp'; 
        var urlPath3 = "${BASE_URL_2}$sticker3";
        var savePath3 = "${stickersDirectory.path}/${sticker3.toLowerCase()}";
        downloads.add(
          dio.download(
            urlPath3,
            savePath3,
          ),
        );

        stickers = 
        {
          
          "${WhatsappStickerImageHandler.fromFile("${stickersDirectory.path}/${snapshot.data![index]['stikers'][0]['imageWebp'].toLowerCase()}").path}": ["stikers", "id"], 
          "${WhatsappStickerImageHandler.fromFile("${stickersDirectory.path}/${sticker2.toLowerCase()}").path}": ["stikers", "id"], 
          "${WhatsappStickerImageHandler.fromFile("${stickersDirectory.path}/${sticker3.toLowerCase()}").path}": ["stikers", "id"], 
        };

    }

    await Future.wait(downloads);

    try {
      final WhatsappStickersHandler _whatsappStickersHandler = WhatsappStickersHandler();
      var result = await _whatsappStickersHandler.addStickerPack(
        snapshot.data![index]['id'].toString(), //stickerPack.identifier
        snapshot.data![index]['stikerPackName'],
        snapshot.data![index]['stikers'][0]['stikers_user']['username'],
        tryImage,
        "", //stickerPack.publisherWebsite
        "", //stickerPack.privacyPolicyWebsite
        "", //stickerPack.licenseAgreementWebsite
        snapshot.data![index]['animatedStickerPack'] == 0 ? false : true,
        stickers,
      );
      print("RESULT $result");
      for(int i = 0; i < snapshot.data![index]['stikers'].length; i++)
      {
        _stickerUpdateAmountDownload(snapshot.data![index]['stikers'][i]['id'].toString()).then((value) {
          print('asuuuuuuuuuuuuuuuu');
          print(value);
        });
      }

    } on WhatsappStickersException catch (e) {
      print("INSIDE WhatsappStickersException ${e.cause}");
      var exceptionMessage = e.cause;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(exceptionMessage.toString())
      ));
    } catch (e) {
      print("Exception ${e.toString()}");
    }
    
  }

  void _addSticker(AsyncSnapshot snapshot, int index) async {

    Map<String, List<String>> stickers = <String, List<String>>{};

    var tryImage = '';

    final dio = Dio();
    final downloads = <Future>[];
    var applicationDocumentsDirectory = await getApplicationDocumentsDirectory();

    var stickersDirectory = Directory(
        //'${applicationDocumentsDirectory.path}/stickers/${stickerPack.identifier}');
        '${applicationDocumentsDirectory.path}/${snapshot.data![index]['id'].toString()}'
    );
    await stickersDirectory.create(recursive: true);

    downloads.add(
      dio.download(
        "${BASE_URL_2}${snapshot.data![index]['image']}",
        "${stickersDirectory.path}/${snapshot.data![index]['image'].toLowerCase()}",
      ),
    );

    tryImage = WhatsappStickerImageHandler.fromFile(
      "${stickersDirectory.path}/${snapshot.data![index]['image'].toLowerCase()}"
    ).path;


    var urlPath = "${BASE_URL_2}${snapshot.data![index]['imageWebp']}";
    var savePath = "${stickersDirectory.path}/${snapshot.data![index]['imageWebp'].toLowerCase()}";
    downloads.add(
      dio.download(
        urlPath,
        savePath,
      ),
    );

    
    String sticker2 = snapshot.data![index]['stikers_category']['animatedStickerPack'] == 0 ? 'default_2.webp' : 'default_4.webp';
    var urlPath2 = "${BASE_URL_2}$sticker2";
    var savePath2 = "${stickersDirectory.path}/${sticker2.toLowerCase()}";
    downloads.add(
      dio.download(
        urlPath2,
        savePath2,
      ),
    );

    String sticker3 = snapshot.data![index]['stikers_category']['animatedStickerPack'] == 0 ? 'default_3.webp' : 'default_5.webp';
    var urlPath3 = "${BASE_URL_2}$sticker3";
    var savePath3 = "${stickersDirectory.path}/${sticker3.toLowerCase()}";
    downloads.add(
      dio.download(
        urlPath3,
        savePath3,
      ),
    );

    stickers = 
    {
      
      "${WhatsappStickerImageHandler.fromFile("${stickersDirectory.path}/${snapshot.data![index]['imageWebp'].toLowerCase()}").path}": ["stikers", "id"], 
      "${WhatsappStickerImageHandler.fromFile("${stickersDirectory.path}/${sticker2.toLowerCase()}").path}": ["stikers", "id"], 
      "${WhatsappStickerImageHandler.fromFile("${stickersDirectory.path}/${sticker3.toLowerCase()}").path}": ["stikers", "id"], 
    };

    print('suuuuuuuuuu');
    print(stickers);

    await Future.wait(downloads);

    try {
      final WhatsappStickersHandler _whatsappStickersHandler = WhatsappStickersHandler();
      var result = await _whatsappStickersHandler.addStickerPack(
        snapshot.data![index]['id'].toString(), //stickerPack.identifier
        snapshot.data![index]['stikers_category']['stikerPackName'],
        snapshot.data![index]['stikers_user']['username'],
        tryImage,
        "", //stickerPack.publisherWebsite
        "", //stickerPack.privacyPolicyWebsite
        "", //stickerPack.licenseAgreementWebsite//stickerPack.licenseAgreementWebsite
        snapshot.data![index]['stikers_category']['animatedStickerPack'] == 0 ? false : true,
        stickers,
      );
      print("RESULT $result");

      _stickerUpdateAmountDownload(snapshot.data![index]['id'].toString()).then((value) {
        print('asiiiiiiiiiii');
        print(value);
      });

    } on WhatsappStickersException catch (e) {
      print("INSIDE WhatsappStickersException ${e.cause}");
      var exceptionMessage = e.cause;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(exceptionMessage.toString())
      ));
    } catch (e) {
      print("Exception ${e.toString()}");

    }
    
  }



  // InterstitialAd
  late InterstitialAd _interstitialAd;
  bool _isLoaded = false;

  AsyncSnapshot? stikersSnapshot_addStickerPack;
  int? stikersIndex_addStickerPack;

  AsyncSnapshot? stikersSnapshot_addSticker;
  int? stikersIndex_addSticker;

  void _initAd() 
  {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-6717426320595915/3512101490', 
      // adUnitId: 'ca-app-pub-3940256099942544/1033173712', 
      request: AdRequest(), 
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded, 
        onAdFailedToLoad: (error) {
          
        }
      )
    );
  }

  void onAdLoaded(InterstitialAd ad) 
  {
    _interstitialAd = ad;
    _isLoaded = true;

    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {

        if(stikersSnapshot_addStickerPack != null)
        {
          _addStickerPack(stikersSnapshot_addStickerPack!, stikersIndex_addStickerPack!);
          stikersSnapshot_addStickerPack = null;
        }

        if(stikersSnapshot_addSticker != null)
        {
          
          _addSticker(stikersSnapshot_addSticker!, stikersIndex_addSticker!);
          stikersSnapshot_addSticker = null;
        }

        _interstitialAd.dispose();
        _initAd();

      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _interstitialAd.dispose();
        _initAd();

      }
    );
  }

  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    _commenthController = TextEditingController();
    _stikersDetailStikersCategory();
    _stikerCommentCategory();
    _stikersDetailStikersCategoryStikerImages();
    _stikersAllOtherSimiliar();
    _stikersAllOtherSimiliarSecond();
    _stikersCategorySimiliar();
    _checkUser();
    _scrollController.addListener(listenScrolling);

    myBanner.load();
    _initAd();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final AdWidget adWidget = AdWidget(ad: myBanner);

    final Container adContainer = Container(
      alignment: Alignment.center,
      child: adWidget,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
    );

    final WhatsappStickersHandler _whatsappStickersHandler = WhatsappStickersHandler();

    // disable rotation
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    SystemChrome.setSystemUIOverlayStyle( SystemUiOverlayStyle(statusBarColor: Colors.black));

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home : Scaffold(
          backgroundColor: whiteColor,
          body: SafeArea(
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 65),
                  child: SmartRefresher(
                      controller: refreshController, 
                      onRefresh: onRefresh,
                      child: ListView(
                        controller: _scrollController,
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              children: [
                              FutureBuilder(
                                  future: _stikersDetailStikersCategory(),
                                  builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                                    snapshot.hasData
                                      ? 
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (BuildContext context, index) => 
                                        detailStikerCategory(snapshot),
                                        
                                      )
                                      
                                      : 
                                      Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.all(Radius.circular(30)),
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: blueDarkColor,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10,),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: MediaQuery.of(context).size.width * 0.4,
                                                              height: 10,
                                                              decoration: BoxDecoration(
                                                                color: blueDarkColor,
                                                              )
                                                            )
                                                          ],
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Container(
                                                          width: MediaQuery.of(context).size.width * 0.4,
                                                          height: 10,
                                                          decoration: BoxDecoration(
                                                            color: blueDarkColor,
                                                          )
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 20,),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 40,
                                                          height: 10,
                                                          decoration: BoxDecoration(
                                                            color: blueDarkColor,
                                                          )
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 25,
                                                          height: 10,
                                                          decoration: BoxDecoration(
                                                            color: blueDarkColor,
                                                          )
                                                        ),
                                                        SizedBox(width: 10,),
                                                        Container(
                                                          width: 25,
                                                          height: 10,
                                                          decoration: BoxDecoration(
                                                            color: blueDarkColor,
                                                          )
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ), 
                                              ],
                                            ),
                                          ),
                                        ],
                                      )   
                                  
                                  ),                  
                              FutureBuilder(
                              future: _stikersDetailStikersCategoryStikerImages(),
                              builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                                snapshot.hasData
                                  ? 
                                  Container(
                                    child: GridView.builder(
                                      //wajib menggunakan 2 baris script di bawah ini, agar dapat digabung dengan widget lain
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        // banyak grid yang ditampilkan dalam satu baris
                                        crossAxisCount: 3
                                      ),
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (BuildContext context, index) => 
                                      WeChooseForYou(
                                        snapshot,
                                        index
                                      ),
                              
                                    ),
                                  )
                                  : 
                                  Container(
                                    child: GridView.builder(
                                      //wajib menggunakan 2 baris script di bawah ini, agar dapat digabung dengan widget lain
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        // banyak grid yang ditampilkan dalam satu baris
                                        crossAxisCount: 2
                                      ),
                                      itemCount: 10,
                                      itemBuilder: (BuildContext context, index) => 
                                      Container(
                                        margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                        decoration: BoxDecoration(
                                          color: whiteColor,
                                          borderRadius: BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(0, 0),
                                              spreadRadius: 0,
                                              blurRadius: 0.8,
                                              color: Color.fromRGBO(0, 0, 0, 0.3),
                                            )
                                          ],
                                        ),
                                        child: ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [  
                                            Stack(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context).size.width * 1,
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                    color: blueDarkColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment : CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 30,
                                                            height: 10,
                                                            decoration: BoxDecoration(
                                                              color: blueDarkColor,
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10,),
                                                          Container(
                                                            width: 100,
                                                            height: 10,
                                                            decoration: BoxDecoration(
                                                              color: blueDarkColor,
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                          ), 
                                                        ],
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Container(
                                                        width: 140,
                                                        height: 10,
                                                        decoration: BoxDecoration(
                                                          color: blueDarkColor,
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),                         
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        )),
                                      )
                              
                                    ),
                                  )
                              ), 
                              SizedBox(height: 10,),
                              adContainer,
                              SizedBox(height: 10,),
                              Container(
                                child: Text(
                                  'More Like This', 
                                  style: TextStyleNunitoBoldBlack15,
                                  overflow : TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 10,),
                              FutureBuilder(
                                future: _stikersAllOtherSimiliar(),
                                builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                                  snapshot.hasData
                                    ? 
                                    Container(
                                      child: GridView.builder(
                                        //wajib menggunakan 2 baris script di bawah ini, agar dapat digabung dengan widget lain
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          // banyak grid yang ditampilkan dalam satu baris
                                          crossAxisCount: 2
                                        ),
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (BuildContext context, index) => 
                                        WeChooseForYouOther(
                                          snapshot,
                                          index
                                        ),
                                
                                      ),
                                    )
                                    : 
                                    Container(
                                      child: GridView.builder(
                                        //wajib menggunakan 2 baris script di bawah ini, agar dapat digabung dengan widget lain
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          // banyak grid yang ditampilkan dalam satu baris
                                          crossAxisCount: 2
                                        ),
                                        itemCount: 10,
                                        itemBuilder: (BuildContext context, index) => 
                                        Container(
                                          margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                          decoration: BoxDecoration(
                                            color: whiteColor,
                                            borderRadius: BorderRadius.circular(5),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: Offset(0, 0),
                                                spreadRadius: 0,
                                                blurRadius: 0.8,
                                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                              )
                                            ],
                                          ),
                                          child: ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [  
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: MediaQuery.of(context).size.width * 1,
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                      color: blueDarkColor,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment : CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 30,
                                                              height: 10,
                                                              decoration: BoxDecoration(
                                                                color: blueDarkColor,
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                            SizedBox(width: 10,),
                                                            Container(
                                                              width: 100,
                                                              height: 10,
                                                              decoration: BoxDecoration(
                                                                color: blueDarkColor,
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                            ), 
                                                          ],
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Container(
                                                          width: 140,
                                                          height: 10,
                                                          decoration: BoxDecoration(
                                                            color: blueDarkColor,
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),                         
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )),
                                        )
                                
                                      ),
                                    )
                                ),                  
                              SizedBox(height: 10,),
                              FutureBuilder(
                                future: _stikersCategorySimiliar(),
                                builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                                  snapshot.hasData
                                    ? 
                                    Container(
                                      child: GridView.builder(
                                        //wajib menggunakan 2 baris script di bawah ini, agar dapat digabung dengan widget lain
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          // banyak grid yang ditampilkan dalam satu baris
                                          crossAxisCount: 2
                                        ),
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (BuildContext context, index) => 
                                        WeChooseForYouCategory(
                                          snapshot,
                                          index
                                        ),
                                
                                      ),
                                    )
                                    : 
                                    Container(
                                      child: GridView.builder(
                                        //wajib menggunakan 2 baris script di bawah ini, agar dapat digabung dengan widget lain
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          // banyak grid yang ditampilkan dalam satu baris
                                          crossAxisCount: 2
                                        ),
                                        itemCount: 10,
                                        itemBuilder: (BuildContext context, index) => 
                                        Container(
                                          margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                          decoration: BoxDecoration(
                                            color: whiteColor,
                                            borderRadius: BorderRadius.circular(5),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: Offset(0, 0),
                                                spreadRadius: 0,
                                                blurRadius: 0.8,
                                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                              )
                                            ],
                                          ),
                                          child: ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [  
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: MediaQuery.of(context).size.width * 1,
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                      color: blueDarkColor,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment : CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 30,
                                                              height: 10,
                                                              decoration: BoxDecoration(
                                                                color: blueDarkColor,
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                            SizedBox(width: 10,),
                                                            Container(
                                                              width: 100,
                                                              height: 10,
                                                              decoration: BoxDecoration(
                                                                color: blueDarkColor,
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                            ), 
                                                          ],
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Container(
                                                          width: 140,
                                                          height: 10,
                                                          decoration: BoxDecoration(
                                                            color: blueDarkColor,
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),                         
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )),
                                        )
                                
                                      ),
                                    )
                                ),                  
                              SizedBox(height: 10,),
                              FutureBuilder(
                                future: _stikersAllOtherSimiliarSecond(),
                                builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                                  snapshot.hasData
                                    ? 
                                    Container(
                                      child: GridView.builder(
                                        //wajib menggunakan 2 baris script di bawah ini, agar dapat digabung dengan widget lain
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          // banyak grid yang ditampilkan dalam satu baris
                                          crossAxisCount: 2
                                        ),
                                        itemCount: countOfData >= snapshot.data!.length ? snapshot.data!.length : countOfData,
                                        itemBuilder: (BuildContext context, index) => 
                                        WeChooseForYouOther(
                                          snapshot,
                                          index
                                        ),
                                
                                      ),
                                    )
                                    : 
                                    Container(
                                      child: GridView.builder(
                                        //wajib menggunakan 2 baris script di bawah ini, agar dapat digabung dengan widget lain
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          // banyak grid yang ditampilkan dalam satu baris
                                          crossAxisCount: 2
                                        ),
                                        itemCount: 10,
                                        itemBuilder: (BuildContext context, index) => 
                                        Container(
                                          margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                          decoration: BoxDecoration(
                                            color: whiteColor,
                                            borderRadius: BorderRadius.circular(5),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: Offset(0, 0),
                                                spreadRadius: 0,
                                                blurRadius: 0.8,
                                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                              )
                                            ],
                                          ),
                                          child: ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [  
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: MediaQuery.of(context).size.width * 1,
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                      color: blueDarkColor,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment : CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 30,
                                                              height: 10,
                                                              decoration: BoxDecoration(
                                                                color: blueDarkColor,
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                            SizedBox(width: 10,),
                                                            Container(
                                                              width: 100,
                                                              height: 10,
                                                              decoration: BoxDecoration(
                                                                color: blueDarkColor,
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                            ), 
                                                          ],
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Container(
                                                          width: 140,
                                                          height: 10,
                                                          decoration: BoxDecoration(
                                                            color: blueDarkColor,
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),                         
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )),
                                        )
                                
                                      ),
                                    )
                                ),                  
                              SizedBox(height: 100,),
                            ],
                                              ),
                          ),
                        ],
                      ),
                  ),
                ),     
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: FutureBuilder(
                    future: _stikersDetailStikersCategory(),
                    builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                      snapshot.hasData
                        ? 
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, index) => 
                          InkWell(
                            onTap: () {
                              // Navigator.of(context).pushNamed(StickersScreen.routeName); 
                              // _addSticker(stickerPack!, snapshot);

                              setState(() {
                                stikersSnapshot_addStickerPack = snapshot;
                                stikersIndex_addStickerPack = index;                                
                              });

                              // if(_isLoaded)
                              // {
                              //   _interstitialAd.show();
                              // }

                              _addStickerPack(snapshot, index);

                              
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color: green2Color,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 1),
                                    spreadRadius: -2,
                                    blurRadius: 6,
                                    color: Color.fromRGBO(0, 0, 0, 0.4),
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/images/ic_whatsapp.png', height: 20,),
                                  SizedBox(width: 10,),
                                  Text(
                                    'Add To Whatsapp', 
                                    style: TextStyleNunitoW600White15,
                                    overflow : TextOverflow.ellipsis,
                                    maxLines: 1
                                  ),
                                ],
                              )
                            ),
                          ),
                          
                        )
                        
                        : 
                        Container()  
                  ),
                ), 
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: header_layout_arrow('', whiteColor, '', context),
                ),
                IgnorePointer(
                  ignoring: IgnoringComment,
                  child: Opacity(
                    opacity: opacityComment,
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              opacityComment = 0;
                              IgnoringComment = true;
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              color: blackButtonTransparentColor,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 170),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 1),
                                spreadRadius: -2,
                                blurRadius: 6,
                                color: Color.fromRGBO(0, 0, 0, 0.4),
                              )
                            ],
                          ),
                          child: Stack(
                            children: [
                              ListView(
                                children: [
                                  SizedBox(height: 10,),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                          Container(),                              
                                          Container(
                                            child: Text(
                                              'Comment', 
                                              style: TextStyleNunitoBoldBlack15,
                                              overflow : TextOverflow.ellipsis,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        Container()
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  FutureBuilder(
                                  future: _stikerCommentCategory(),
                                  builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                                    snapshot.hasData
                                      ? 
                                      Container(
                                        width: 160,
                                        height: commentAvaible == false ? 
                                        MediaQuery.of(context).size.height * 0.5 :
                                        MediaQuery.of(context).size.height * 0.66,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: snapshot.data!.length,
                                          itemBuilder: (BuildContext context, index) => 
                                          Comment(snapshot, index)
                                        ),
                                      )
                                    
                                      : 

                                      Container()
                                  ),
                                ],
                              ),
                              commentAvaible == false ?
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 1),
                                        spreadRadius: -2,
                                        blurRadius: 6,
                                        color: Color.fromRGBO(0, 0, 0, 0.4),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Berikan Rating', 
                                            style: TextStyleNunitoBoldBlack16,
                                          ),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    starsRating = 1;
                                                  });
                                                },
                                                child: starsRating >= 1 ? Icon(Icons.star, size: 25,) : Icon(Icons.star_border, size: 25,)
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    starsRating = 2;
                                                  });
                                                },
                                                child: starsRating >= 2 ? Icon(Icons.star, size: 25,) : Icon(Icons.star_border, size: 25,)
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    starsRating = 3;
                                                  });
                                                },
                                                child: starsRating >= 3 ? Icon(Icons.star, size: 25,) : Icon(Icons.star_border, size: 25,)
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    starsRating = 4;
                                                  });
                                                },
                                                child: starsRating >= 4 ? Icon(Icons.star, size: 25,) : Icon(Icons.star_border, size: 25,)
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    starsRating = 5;
                                                  });
                                                },
                                                child: starsRating >= 5 ? Icon(Icons.star, size: 25,) : Icon(Icons.star_border, size: 25,)
                                              ),
                                              // Icon(Icons.star_border, size: 20,)
                              
                                            ],
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.all(Radius.circular(30)),
                                            child: Image.network('https://bukahuni.com/storage/stikersIdImages/$photoProfileUser', fit: BoxFit.fill, width: 40, height: 40,),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: grayLightColor, width: 2)
                                            ),
                                            width: MediaQuery.of(context).size.width * 0.77,
                                            height: 50,
                                            child: Stack(
                                              children: [
                                                TextField(
                                                  controller: _commenthController,
                                                  onChanged: (text) {
                                                    setState(() {
                                                      String value = _commenthController.text;
                                                    });
                                                  },
                                                  keyboardType: TextInputType.name,
                                                  decoration: InputDecoration(
                                                      hintText: "Add Comment",
                                                      hintStyle: TextStyleNunitoW500Gray14,
                                                      border: InputBorder.none,
                                                  ),
                                                  style: TextStyleNunitoW500Black14,
                                                ),
                                                Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  bottom: 0,
                                                  child: InkWell(
                                                    onTap: () {
                                                      _stikersPostCreateComment().then((value) {
                                                        setState(() {});
                                                      });
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment:MainAxisAlignment.center,
                                                      children: [
                                                        Image.asset('assets/images/ic_sendMessage.png', width: 25, height: 25,)
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                              : Container()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IgnorePointer(
                  ignoring: IgnoringCommentOption,
                  child: Opacity(
                    opacity: opacityCommentOption,
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              opacityCommentOption = 0;
                              IgnoringCommentOption = true;
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              color: blackButtonTransparentColor,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.only(bottom: 10, top: 10),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(0, 1),
                                      spreadRadius: -2,
                                      blurRadius: 6,
                                      color: Color.fromRGBO(0, 0, 0, 0.4),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: gray5Color, width: 0.3)
                                        )
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          if (await confirm(context)) {
                                            _stikerstikerCommentDelete().then((value) {
                                              opacityCommentOption = 0;
                                              IgnoringCommentOption = true;
                                              commentAvaible = false;
                                              setState(() {});
                                            });
                                            return print('pressedOK');
                                          } else {
                                            return print('pressedCancel');
                                          }
                                        },
                                        child: Text(
                                          'Hapus', 
                                          style: TextStyleNunitoBoldBlack15,
                                        ),
                                      ),
                                    ),
                                    // SizedBox(height: 10,),
                                    // Container(
                                    //   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                    //   width: MediaQuery.of(context).size.width,
                                    //   decoration: BoxDecoration(
                                    //     border: Border(
                                    //       bottom: BorderSide(color: gray5Color, width: 0.3)
                                    //     )
                                    //   ),
                                    //   child: InkWell(
                                    //     onTap: (){
                                    //       // setState(() {
                                    //       //   opacityCommentOption = 0;
                                    //       //   IgnoringCommentOption = true;
                                    //       // });
                                    //     },
                                    //     child: Text(
                                    //       'Edit', 
                                    //       style: TextStyleNunitoBoldBlack15,
                                    //     ),
                                    //   ),
                                    // ),
                                    SizedBox(height: 10,),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      ],
                    ),
                  ),
                ),

                
              ],
            ),
          ),
        ),
    );
  
  }

  int starsRating = 0;

  bool IgnoringComment = true;
  double opacityComment = 0;

  bool IgnoringCommentOption = true;
  double opacityCommentOption = 0;

  Widget Comment(AsyncSnapshot snapshot, int index)
  {

    String stikerId = snapshot.data![index]['id'].toString();
    String stikerComment = snapshot.data![index]['comment'];
    String stikerUsername = snapshot.data![index]['stikers_user']['username'];
    String photoProfile = snapshot.data![index]['stikers_user']['photoProfile'];
    String releaseDate = snapshot.data![index]['created_at'];

    DateTime time1 = DateTime.parse(releaseDate);


    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            child: Image.network('https://bukahuni.com/storage/stikersIdImages/$photoProfile', fit: BoxFit.fill, width: 50, height: 50,),
          ),
          SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Text(
                  stikerUsername, 
                  style: TextStyleNunitoBoldBlack15,
                  overflow : TextOverflow.ellipsis,
                  maxLines: 1
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Text(
                  stikerComment, 
                  style: TextStyleNunitoW500Black16,
                ),
              ), 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      convertToAgo(time1).toString(), 
                      style: TextStyleNunitoW600Gray14,
                    ),
                  ),
                  SizedBox(width: 10,),
                  usernameProfile == stikerUsername ?
                  InkWell(
                    onTap: () {
                      setState(() {
                        idComment = stikerId;
                        opacityCommentOption = 1;
                        IgnoringCommentOption = false;
                      });
                    },
                    child: Icon(Icons.more_horiz_rounded, size: 25, color: blackGray,)
                  ) : Container()
                ],
              )
            ],
          )
          
            
        ],
      ),
    );
  }

  Widget detailStikerCategory(AsyncSnapshot snapshot)
  {

    String stikerPackName = snapshot.data![0]['stikerPackName'];
    String amountRating = snapshot.data![0]['ratingAverage'] != null ? snapshot.data![0]['ratingAverage'].toString() : '0';
    String amountComment = snapshot.data![0]['stikers_comment'] != null ? snapshot.data![0]['stikers_comment'].length.toString() : '0';
    String amountStikers = snapshot.data![0]['stikers'].length.toString();
    String photoProfile = snapshot.data![0]['stikers'][0]['stikers_user']['photoProfile'];
    String username = snapshot.data![0]['stikers'][0]['stikers_user']['username'];

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: Image.network('https://bukahuni.com/storage/stikersIdImages/$photoProfile', fit: BoxFit.fill, width: 40, height: 40,),
              ),
              SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                          stikerPackName, 
                          style: TextStyleNunitoW600Black16, 
                          overflow : TextOverflow.ellipsis,
                          maxLines: 2
                        ),
                      ),                      
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      username, 
                      style: TextStyleNunitoW500Black14,
                      overflow : TextOverflow.ellipsis,
                      maxLines: 1
                    ),
                  ),
                  SizedBox(height: 3,),
                  Row(
                    children: [
                      Container(
                        child: Text(
                          amountRating.length >= 4 ?
                          amountRating.substring(0, 3) : amountRating,  
                          style: TextStyleNunitoW500Primary312,
                        ),
                      ),
                      SizedBox(width: 3,),
                      Container(
                        child: Image.asset('assets/images/ic_startsBlue.png', fit: BoxFit.fill, height: 10, width: 13),
                      ),
                    ],
                  )
                ],
              ) 
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text(
                  '$amountStikers Stickers', 
                  style: TextStyleNunitoW500Black14,
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {

                      if(usernameProfile != '' && usernameProfile != null)
                      {
                        setState(() {
                          opacityComment = 1;
                          IgnoringComment = false;
                        });

                      }
                      else
                      {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => login_page('')));
                      }
  
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('assets/images/ic_message.png', width: 15,),
                        SizedBox(width: 10,),
                        Container(
                          child: Text(
                            amountComment, 
                            style: TextStyleNunitoW500Black14,
                          ),
                        ), 
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget WeChooseForYou(AsyncSnapshot snapshot, int index)
  {

    String id = snapshot.data![index]['id'].toString();
    String imageWebp = snapshot.data![index]['imageWebp'].toString();
    String stikerName = snapshot.data![index]['stikerName'].toString();

    return Container(
        margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 1),
              spreadRadius: -2,
              blurRadius: 6,
              color: Color.fromRGBO(0, 0, 0, 0.4),
            )
          ],
        ),
        child: InkWell(
          onTap: (){

            storage.write(key: 'idStikers', value: id.toString());

            double stikerNameLength = stikerName.length / 2;
            storage.write(key: 'stikerName', value: stikerName.substring(0, stikerNameLength.toInt()).toString());

            Navigator.push(context, MaterialPageRoute(builder: (context) => detailContent_page()));

          },
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [  
                Image.network('https://bukahuni.com/storage/stikersIdImages/$imageWebp', fit: BoxFit.fill,),
              ],
            )),
        ),
      );
  }
  
  Widget WeChooseForYouOther(AsyncSnapshot snapshot, int index)
  {

    String id = snapshot.data![index]['id'].toString();
    String imageWebp = snapshot.data![index]['imageWebp'].toString();
    String stikerName = snapshot.data![index]['stikerName'].toString();
    String amountDownload = snapshot.data![index]['stikers_category']['amountDownload'].toString();
    String photoProfile = snapshot.data![index]['stikers_user']['photoProfile'].toString();
    String username = snapshot.data![index]['stikers_user']['username'].toString();

    return Container(
        margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 1),
              spreadRadius: -2,
              blurRadius: 6,
              color: Color.fromRGBO(0, 0, 0, 0.4),
            )
          ],
        ),
        child: InkWell(
          onTap: (){
            storage.write(key: 'idStikers', value: id.toString());

            double stikerNameLength = stikerName.length / 2;
            storage.write(key: 'stikerName', value: stikerName.substring(0, stikerNameLength.toInt()).toString());

            Navigator.push(context, MaterialPageRoute(builder: (context) => detailContent_page()));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Stack(
              children: [  
                Image.network('https://bukahuni.com/storage/stikersIdImages/$imageWebp', fit: BoxFit.fill,),
                // Image.asset('assets/images/patImg.png', fit: BoxFit.fill, height: 150, width: MediaQuery.of(context).size.width),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: whiteColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              child: Image.network('https://bukahuni.com/storage/stikersIdImages/$photoProfile', fit: BoxFit.fill, width: 20, height: 20,),
                            ),
                            // SizedBox(width: 5,),
                            // Container(
                            //   width: MediaQuery.of(context).size.width * 0.3,
                            //   child: Text(
                            //     username, 
                            //     style: TextStyleNunitoW500Black14,
                            //     overflow : TextOverflow.ellipsis,
                            //     maxLines: 1
                            //   ),
                            // ), 
                            
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                             InkWell(
                              onTap: () {
                                // installFromAssets();
                                // installFromRemote();

                                // setState(() {
                                //   stikersSnapshot_addSticker = snapshot;
                                //   stikersIndex_addSticker = index;
                                // });

                                // if(_isLoaded)
                                // {
                                //   _interstitialAd.show();
                                // }

                                _addSticker(snapshot, index);

                              },
                              child: Container(
                                // margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: green2Color,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(0, 1),
                                      spreadRadius: -2,
                                      blurRadius: 6,
                                      color: Color.fromRGBO(0, 0, 0, 0.4),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/ic_whatsapp.png', height: 10,),
                                    SizedBox(width: 5,),
                                    Text(
                                      'Add', 
                                      style: TextStyleNunitoW600White12,
                                    ),
                                  ],
                                )
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )),
        ),
      );
  }
  
  Widget WeChooseForYouCategory(AsyncSnapshot snapshot, int index)
  {

    String id = snapshot.data![index]['id'].toString();
    String imageWebp = snapshot.data![index]['stikers'][0]['imageWebp'].toString();
    String stikerPackName = snapshot.data![index]['stikerPackName'].toString();

    return Container(
        margin: EdgeInsets.only(left: 5, right: 5, top: 10,),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 1),
              spreadRadius: -2,
              blurRadius: 6,
              color: Color.fromRGBO(0, 0, 0, 0.4),
            )
          ],
        ),
        child: InkWell(
          onTap: (){
            storage.write(key: 'idStikersCategory', value: id.toString());

            double stikerPackNameLength = stikerPackName.length / 2;
            storage.write(key: 'stikerPackName', value: stikerPackName.substring(0, stikerPackNameLength.toInt()).toString());
            storage.write(key: 'stikerName', value: stikerPackName.substring(0, stikerPackNameLength.toInt()).toString());

            Navigator.push(context, MaterialPageRoute(builder: (context) => detailCategory_page()));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Stack(
              children: [  
                Image.network('https://bukahuni.com/storage/stikersIdImages/$imageWebp', fit: BoxFit.fill,),
                Positioned(
                  bottom: 0,
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: blackTransparentColor,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Text(
                      stikerPackName, 
                      textAlign: TextAlign.center,
                      style: TextStyleNunitoW600White17,
                      overflow : TextOverflow.ellipsis,
                      maxLines: 3
                    ),
                  ),
                ),
              ],
            )),
        ),
      );
  }
  


}