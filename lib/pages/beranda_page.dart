import 'dart:io';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/layouts/menu_layout.dart';
import 'package:flutter_merraland_online_new/pages/ListSearch_page.dart';
import 'package:flutter_merraland_online_new/pages/customEditor_page.dart';
import 'package:flutter_merraland_online_new/pages/detailCategory_page.dart';
import 'package:flutter_merraland_online_new/pages/detailContent_page.dart';
import 'package:flutter_merraland_online_new/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:image_crop_plus/image_crop_plus.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_stickers_handler/exceptions.dart';
import 'package:whatsapp_stickers_handler/whatsapp_stickers_handler.dart';

import '../StickerPlugin/constants/constants.dart';




class beranda_page extends StatefulWidget {

  @override
  State<beranda_page> createState() => _beranda_pageState();
}

class _beranda_pageState extends State<beranda_page> {

  PageController? pageController;

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
  final String stikersAllForYouUrl = '/api/stikers/allForYou';
  final String stikersAllTrendingUrl = '/api/stikers/allTrending';
  final String stickerUpdateAmountDownloadUrl = '/api/stikers/stickerUpdateAmountDownload/';



  RefreshController refreshControllerForYou = RefreshController();
  RefreshController refreshControllerTrending = RefreshController();
  final _scrollControllerForYou = ScrollController();
  final _scrollControllerTrending = ScrollController();

  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  int allDataStikersForYou = 0;
  int allDataStikersTrending = 0;

  int countOfDataForYou = 10;
  int countOfDataTrending = 5;

  int pageChange = 0;

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


  Future<List> _stikersAllForYou() async {

    String? token = '';
    token = await storage.read(key: 'token');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    try {
      // This is an open REST API endpoint for testing purposes
      final http.Response response = await http.get(Uri.parse(_baseUrl+stikersAllForYouUrl), headers: {
        'Authorization': 'Bearer $token',
      });
      
      map = json.decode(response.body);
      posts = map["data"];

    } catch (err) {
      print(err);
    }

    allDataStikersForYou = posts.length;


    // print(posts);


    return posts;
  }

  Future<List> _stikersAllTrending() async {

    String? token = '';
    token = await storage.read(key: 'token');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    try {
      // This is an open REST API endpoint for testing purposes
      final http.Response response = await http.get(Uri.parse(_baseUrl+stikersAllTrendingUrl), headers: {
        'Authorization': 'Bearer $token',
      });
      
      map = json.decode(response.body);
      posts = map["data"];

    } catch (err) {
      print(err);
    }

    allDataStikersTrending = posts.length;


    // print(posts);


    return posts;
  }


  void onRefreshForYou() async{
    await Future.delayed(Duration(seconds: 1));
    _stikersAllForYou();
    _stikersAllTrending();
    setState(() {});
    refreshControllerForYou.refreshCompleted();
  }

  void onRefreshTrending() async{
    await Future.delayed(Duration(seconds: 1));
    _stikersAllForYou();
    _stikersAllTrending();
    setState(() {});
    refreshControllerTrending.refreshCompleted();
  }

  //banner
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

  void listenScrollingForYou()
  {

    if(_scrollControllerForYou.position.pixels >= _scrollControllerForYou.position.maxScrollExtent)
    {
        if(countOfDataForYou <= allDataStikersForYou)
        {

          countOfDataForYou += 10;

          if(countOfDataForYou >= allDataStikersForYou)
          {
            countOfDataForYou = allDataStikersForYou;
          }

          setState(() {});

        }

    }

  }

  void listenScrollingTrending()
  {

    if(_scrollControllerTrending.position.pixels >= _scrollControllerTrending.position.maxScrollExtent)
    {
        if(countOfDataTrending <= allDataStikersTrending)
        {

          countOfDataTrending += 10;

          if(countOfDataTrending >= allDataStikersTrending)
          {
            countOfDataTrending = allDataStikersTrending;
          }

          setState(() {});

        }

    }

  }

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) 
    {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Tekan Sekali Lagi Untuk Keluar');
      return Future.value(false);
    }

    SystemNavigator.pop();
    return Future.value(true);
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

  AsyncSnapshot? stikersSnapshot_addSticker;
  int? stikersIndex_addSticker;

  AsyncSnapshot? stikersSnapshot_addStickerPack;
  int? stikersIndex_addStickerPack;

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
    _stikersAllForYou();
    _stikersAllTrending();
    _scrollControllerForYou.addListener(listenScrollingForYou);
    _scrollControllerTrending.addListener(listenScrollingTrending);
    pageController = PageController(initialPage: 0);

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

    // disable rotation
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    SystemChrome.setSystemUIOverlayStyle( SystemUiOverlayStyle(statusBarColor: Colors.black));

    return WillPopScope(
      onWillPop: onWillPop,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home : Scaffold(
          backgroundColor: whiteColor,
          body: SafeArea(
            child: Stack(
              children: [                
                Container(
                  margin: EdgeInsets.only(top: 55),
                  child: PageView(
                    controller: pageController,
                    onPageChanged: (index) {
                      setState(() {
                        pageChange = index;
                      });
                    },
                    children: [
                      SmartRefresher(
                        controller: refreshControllerForYou, 
                        onRefresh: onRefreshForYou,
                        child: ListView(
                          controller: _scrollControllerForYou,
                          children: [
                            SizedBox(height: 10,),
                            adContainer,  
                            SizedBox(height: 10,),
                            FutureBuilder(
                            future: _stikersAllForYou(),
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
                                    itemCount: countOfDataForYou >= snapshot.data!.length ? snapshot.data!.length : countOfDataForYou,
                                    itemBuilder: (BuildContext context, index) => 
                                    stikersAllForYou(
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
                                      margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
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
                      SmartRefresher(
                        controller: refreshControllerTrending, 
                        onRefresh: onRefreshTrending,
                        child: ListView(
                            controller: _scrollControllerTrending,
                            children: [
                              FutureBuilder(
                              future: _stikersAllTrending(),
                              builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                                snapshot.hasData
                                  ? 
                                  Container(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount: countOfDataTrending >= snapshot.data!.length ? snapshot.data!.length : countOfDataTrending,
                                      itemBuilder: (BuildContext context, index) => 
                                      stikersAllTrending(
                                        snapshot,
                                        index
                                      ),
                                    ),
                                  )
                                  : 
                                  Container(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount: 10,
                                      itemBuilder: (BuildContext context, index) => 
                                      Container(
                                        margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                                        width: 280,
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
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
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
                                                        width: 230,
                                                        height: 10,
                                                        decoration: BoxDecoration(
                                                          color: blueDarkColor,
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ), 
                                                      SizedBox(width: 10,),
                                                      Container(
                                                        width: 30,
                                                        height: 10,
                                                        decoration: BoxDecoration(
                                                          color: blueDarkColor,
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ), 
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),  
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 75,
                                                    height: 75,
                                                    decoration: BoxDecoration(
                                                      color: blueDarkColor,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5,),
                                                  Container(
                                                    width: 75,
                                                    height: 75,
                                                    decoration: BoxDecoration(
                                                      color: blueDarkColor,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5,),
                                                  Container(
                                                    width: 75,
                                                    height: 75,
                                                    decoration: BoxDecoration(
                                                      color: blueDarkColor,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5,),
                                                  Container(
                                                    width: 75,
                                                    height: 75,
                                                    decoration: BoxDecoration(
                                                      color: blueDarkColor,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5,),
                                                ],
                                              ),
                                            ),  
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
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
                                                        width: 230,
                                                        height: 10,
                                                        decoration: BoxDecoration(
                                                          color: blueDarkColor,
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ), 
                                                      SizedBox(width: 10,),
                                                      Container(
                                                        width: 30,
                                                        height: 10,
                                                        decoration: BoxDecoration(
                                                          color: blueDarkColor,
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ), 
                                                    ],
                                                  ),
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
                      )
                    
                    ],
                  ),
                ),       
                menu_layout(context, 'beranda'),
                ValueListenableBuilder<int>(
                  builder: (BuildContext context, int value, Widget? child) {
                    // This builder will only get called when the _counter
                    // is updated.
                    return 
                    topBar();
                    // topBar(_counter.value);
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: <Widget>[
                    //     Text('$value'),
                    //     child!,
                    //   ],
                    // );
                  },
                  valueListenable: _counter,
                  // The child parameter is most helpful if the child is
                  // expensive to build and does not depend on the value from
                  // the notifier.
                  // child: goodJob,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  
  }

  Widget topBar()
  {
    return Positioned(
      top: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        height: 56,
        width: MediaQuery.of(context).size.width,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/Logo.png', width: 30,),
                Container(
                  margin: EdgeInsets.only(top: 21),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  height: 35,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(10),
                  ),   
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          pageController!.animateToPage(0, duration: Duration(milliseconds: 250), curve: Curves.bounceInOut);
                        },
                        child: Column(
                          children: [
                            Text('For you', style: pageChange == 0 ? TextStyleNunitoBoldBlack16 : TextStyleNunitoW500Black16),
                            SizedBox(height: 10,),
                            pageChange == 0 ?
                            Container(
                              width: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(width: 2, color: blackColor)
                                )
                              ),
                            ) : Container()
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                      InkWell(
                        onTap: () {
                          pageController!.animateToPage(1, duration: Duration(milliseconds: 250), curve: Curves.bounceInOut);
                        },
                        child: Column(
                          children: [
                            Text('Trending', style: pageChange == 1 ? TextStyleNunitoBoldBlack16 : TextStyleNunitoW500Black16),
                            SizedBox(height: 10,),
                            pageChange == 1 ?
                            Container(
                              width: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(width: 2, color: blackColor)
                                )
                              ),
                            ) : Container()
                          ],
                        ),
                      ),
                    ],
                  )
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ListSearch_page('')));
                  },
                  child: Icon(Icons.search, size: 22,)
                ),

              ],
            )
          ],
        ),
      ),
    );                     
              
  }

  Widget stikersAllForYou(AsyncSnapshot snapshot, int index)
  {

    String id = snapshot.data![index]['id'].toString();
    String imageWebp = snapshot.data![index]['imageWebp'].toString();
    String stikerName = snapshot.data![index]['stikerName'].toString();
    String photoProfile = snapshot.data![index]['stikers_user']['photoProfile'].toString();
    String username = snapshot.data![index]['stikers_user']['username'].toString();
    String stikerPackName = snapshot.data![index]['stikers_category']['stikerPackName'].toString();

    return Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
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
            
            double stikerPackNameLength = stikerPackName.length / 2;
            storage.write(key: 'stikerPackName', value: stikerPackName.substring(0, stikerPackNameLength.toInt()).toString());

            double stikerNameDetailLength = stikerName.length / 1.5;
            storage.write(key: 'stikerNameDetail', value: stikerName.substring(0, stikerNameDetailLength.toInt()).toString());

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
  
  Widget stikersAllTrending(AsyncSnapshot snapshot, int index)
  {

    String id = snapshot.data![index]['id'].toString();
    String image0 = snapshot.data![index]['stikers'].length >= 1 ? snapshot.data![index]['stikers'][0]['imageWebp'] : '';
    String image1 = snapshot.data![index]['stikers'].length >= 2 ? snapshot.data![index]['stikers'][1]['imageWebp'] : '';
    String image2 = snapshot.data![index]['stikers'].length >= 3 ? snapshot.data![index]['stikers'][2]['imageWebp'] : '';
    String image3 = snapshot.data![index]['stikers'].length >= 4 ? snapshot.data![index]['stikers'][3]['imageWebp'] : '';
    String stikerPackName = snapshot.data![index]['stikerPackName'];
    String stikerName = snapshot.data![index]['stikers'][0]['stikerName'];
    String amountRating = snapshot.data![index]['ratingAverage'] != null ? snapshot.data![index]['ratingAverage'].toString() : '0';
    String amountStikers = snapshot.data![index]['stikers'].length.toString();
    String photoProfile = snapshot.data![index]['stikers'][0]['stikers_user']['photoProfile'];
    String username = snapshot.data![index]['stikers'][0]['stikers_user']['username'];

    return Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
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

            double stikerNameLength = stikerName.length / 2;
            storage.write(key: 'stikerName', value: stikerName.substring(0, stikerNameLength.toInt()).toString());
            
            double stikerPackNameLength = stikerPackName.length / 2;
            storage.write(key: 'stikerPackName', value: stikerPackName.substring(0, stikerPackNameLength.toInt()).toString());

            Navigator.push(context, MaterialPageRoute(builder: (context) => detailCategory_page()));

            
          },
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [  
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                          SizedBox(width: 10,),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Text(
                              stikerPackName, 
                              style: TextStyleNunitoW600Black16,
                              overflow : TextOverflow.ellipsis,
                              maxLines: 1
                            ),
                          ),
                        ],
                      ),
                      Container(
                        child: Row(
                          children: [
                            
                            Text(
                              '$amountStikers Stickers', 
                              style: TextStyleNunitoW500Black14,
                              overflow : TextOverflow.ellipsis,
                              maxLines: 1
                            ),
                          ],
                        ),
                      ),
                       
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      image0 != '' ?
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Image.network('https://bukahuni.com/storage/stikersIdImages/$image0', fit: BoxFit.fill, width: 75, height: 75,),
                      ) : Container(),
                      SizedBox(width: 5,),

                      image1 != '' ?
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Image.network('https://bukahuni.com/storage/stikersIdImages/$image1', fit: BoxFit.fill, width: 75, height: 75,),
                      ): Container(),
                      SizedBox(width: 5,),

                      image2 != '' ?
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Image.network('https://bukahuni.com/storage/stikersIdImages/$image2', fit: BoxFit.fill, width: 75, height: 75,),
                      ): Container(),
                      SizedBox(width: 5,),

                      image3 != '' ?
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Image.network('https://bukahuni.com/storage/stikersIdImages/$image3', fit: BoxFit.fill, width: 75, height: 75,),
                      ): Container(),
                      SizedBox(width: 5,),

                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                          SizedBox(width: 5,),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Text(
                              username, 
                              style: TextStyleNunitoW500Black14,
                              overflow : TextOverflow.ellipsis,
                              maxLines: 1
                            ),
                          ), 
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Image.asset('assets/images/ic_download.png', width: 15,),
                          // SizedBox(width: 5,),
                          // Container(
                          //   child: Text(
                          //     amountDownload, 
                          //     style: TextStyleNunitoW500Black14,
                          //   ),
                          // ), 
                          InkWell(
                            onTap: () {
                              // installFromAssets();
                              // installFromRemote();

                              // setState(() {
                              //   stikersSnapshot_addStickerPack = snapshot;
                              //   stikersIndex_addStickerPack = index;
                              // });

                              // if(_isLoaded)
                              // {
                              //   _interstitialAd.show();
                              // }

                              _addStickerPack(snapshot, index);

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
                )
              ],
            )),
        ),
      );
  }
  
}