import 'dart:ffi';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/layouts/header_layout.dart';
import 'package:flutter_merraland_online_new/layouts/header_layout_arrow.dart';
import 'package:flutter_merraland_online_new/layouts/menu_layout.dart';
import 'package:flutter_merraland_online_new/pages/detailCategory_page.dart';
import 'package:flutter_merraland_online_new/pages/detailContent_page.dart';
import 'package:flutter_merraland_online_new/pages/settings_page.dart';
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
import 'package:whatsapp_stickers_handler/exceptions.dart';
import 'package:whatsapp_stickers_handler/whatsapp_stickers_handler.dart';

import '../StickerPlugin/constants/constants.dart';


class profile_page extends StatefulWidget {

  @override
  State<profile_page> createState() => _profile_pageState();
}

class _profile_pageState extends State<profile_page> {

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
  final String stikersAllTrendingUrl = '/api/stikers/categoryCreatorDetail';
  final String stikers_pack_profileUrl = '/api/stikers/stikers_pack_profile/';
  final String leadShowUrl = '/api/stikers/leads/show/';
  final String stikerCommentDeleteUrl = '/api/stikers/deleteStikerCategory/';
  final String stikerDeleteUrl = '/api/stikers/delete/';
  final String stickerUpdateAmountDownloadUrl = '/api/stikers/stickerUpdateAmountDownload/';



  RefreshController refreshController = RefreshController();
  final _scrollController = ScrollController();

  final ValueNotifier<int> _counter = ValueNotifier<int>(0);
  late TextEditingController _searchController;

  String? stickerPack = '0';
  String? emailCreator = '';
  String? stikers_user_id = '';
  bool firstReload = false;

  String? idCategories = '';
  List<dynamic> idStikers = [];

  
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


  Future<List> _stikers_pack_profile() async {

    String? token = '';
    token = await storage.read(key: 'token');

    stikers_user_id = await storage.read(key: 'idUser');
    emailCreator = await storage.read(key: 'email');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    try {
      // This is an open REST API endpoint for testing purposes
      final http.Response response = await http.get(Uri.parse(_baseUrl+stikers_pack_profileUrl+stikers_user_id!), headers: {
        'Authorization': 'Bearer $token',
      });
      
      map = json.decode(response.body);
      posts = map["data"];

    } catch (err) {
      print(err);
    }

    stickerPack = posts.length.toString();

    return posts;
  }

  Future<List> _leadShow() async {

    String? token = '';
    token = await storage.read(key: 'token');

    String? email = '';
    email = await storage.read(key: 'email');

    Map<String, dynamic> map;
    List<dynamic> posts = [];
    
    try {
      // This is an open REST API endpoint for testing purposes
      final http.Response response = await http.get(Uri.parse(_baseUrl+leadShowUrl+email!), headers: {
        'Authorization': 'Bearer $token',
      });
      
      map = json.decode(response.body);
      posts = map["data"];

    } catch (err) {
      print(err);
    }

    if(firstReload == false)
    {
      firstReload = true;
      storage.write(key: 'idUser', value: posts[0]['id'].toString());
      
      setState(() {});
    }

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

    // print(posts);

    return posts;
  }

  Future _stikerCategoriesDelete() async
  {
    String? token = '';
    token = await storage.read(key: 'token');

    final response = await http.post(Uri.parse(_baseUrl+stikerCommentDeleteUrl+idCategories!), 
      headers: {
        'Authorization': 'Bearer $token',
      }, 
    );

    return response.body;
  }

  Future _stikerDelete(String i) async
  {
    String? token = '';
    token = await storage.read(key: 'token');

    final response = await http.post(Uri.parse(_baseUrl+stikerDeleteUrl+i), 
      headers: {
        'Authorization': 'Bearer $token',
      }, 
    );

    return response.body;
  }

  void onRefresh() async{
    await Future.delayed(Duration(seconds: 1));
    _stikersAllTrending();
    _stikers_pack_profile();
    _leadShow();

    setState(() {});
    refreshController.refreshCompleted();
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
    _stikersAllTrending();
    _stikers_pack_profile();
    _leadShow();
    _searchController = TextEditingController();
    _initAd();
    
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

  @override
  Widget build(BuildContext context) {


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
                FutureBuilder(
                future: _stikers_pack_profile(),
                builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                  snapshot.hasData
                    ? 
                    Container()
                    : 
                    Container()
                ),
                Container(
                  margin: EdgeInsets.only(top: 130),
                  child: SmartRefresher(
                      controller: refreshController, 
                      onRefresh: onRefresh,
                      child: ListView(
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
                                itemCount: stickerPack != '0' ? snapshot.data!.length : 1 ,
                                itemBuilder: (BuildContext context, index) => 

                                stickerPack != '0' ?

                                    snapshot.data![index]['stikers'][0]['stikers_user']['email'] == emailCreator ?
                                      stikersAllTrending(
                                        snapshot,
                                        index
                                      )
                                    :
                                    Container() 
                                :
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.7,
                                          child: Text(
                                            'You Dont Have a Stickers Yet', 
                                            style: TextStyleNunitoW600Gray16,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.7,
                                          child: Text(
                                            'Be a creator and share your Stickers with many people.', 
                                            style: TextStyleNunitoW500Gray14,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                  margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
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
                  ),
                ), 
                menu_layout(context, 'profile'),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: FutureBuilder(
                  future: _leadShow(),
                  builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                  snapshot.hasData
                    ? 
                    Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, index) => 
                        detailProfile(
                          snapshot,
                          index
                        ) 
                      ),
                    )
                    : 
                    Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: 1,
                        itemBuilder: (BuildContext context, index) => 
                        Container(
                          decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: blueDarkColor,
                                          borderRadius: BorderRadius.circular(60),
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.6,
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
                                            width: MediaQuery.of(context).size.width * 0.3,
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
                                  Container(
                                    width: 20,
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
                      ),
                    )
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
                                            
                                            _stikerCategoriesDelete().then((value) {

                                              for(int i = 0; i < idStikers.length; i++)
                                              {
                                                _stikerDelete(idStikers[i]['id'].toString()).then((value) {});
                                              }

                                              opacityCommentOption = 0;
                                              IgnoringCommentOption = true;
                                              setState(() {});
                                              
                                            });
                                            
                                            return print('pressedOK');
                                          } else {
                                            return print('pressedCancel');
                                          }
                                        },
                                        child: Text(
                                          'Delete', 
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

  bool IgnoringCommentOption = true;
  double opacityCommentOption = 0;

  Widget detailProfile(AsyncSnapshot snapshot, int index)
  {

    String photoProfile = snapshot.data![index]['photoProfile'];
    String username = snapshot.data![index]['username'];

    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                    child: Image.network('https://bukahuni.com/storage/stikersIdImages/$photoProfile', fit: BoxFit.fill, width: 80, height: 80,),
                  ),
                  SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                              username, 
                              style: TextStyleNunitoW600Black19,
                              overflow : TextOverflow.ellipsis,
                              maxLines: 1
                            ),
                          ),
                        ],
                      ),
                      Container(
                        child: Text(
                          '$stickerPack Stickers Pack', 
                          style: TextStyleNunitoW500Black14,
                          overflow : TextOverflow.ellipsis,
                          maxLines: 1
                        ),
                      ),
                    ],
                  ) 
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => settings_page()));
                },
                child: Icon(Icons.settings, size: 25,)
              ),
            ],
          ),
          SizedBox(height: 10,),
          Container(
            decoration: BoxDecoration(
              color: whiteColor,
              border: Border(
                bottom: BorderSide(width: 0.3, color: blackColor)
              )
            ),
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'Your Stickers Pack', 
                  style: TextStyleNunitoW600Black16,
                  overflow : TextOverflow.ellipsis,
                  maxLines: 1
                ),
              ),
            ],
          ),
        ],
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
    String amountDownload = snapshot.data![index]['amountDownload'].toString();
    String amountRating = snapshot.data![index]['ratingAverage'] != null ? snapshot.data![index]['ratingAverage'].toString() : '0';
    String photoProfile = snapshot.data![index]['stikers'][0]['stikers_user']['photoProfile'];
    String amountStikers = snapshot.data![index]['stikers'].length.toString();
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
                              '$amountStikers Sticker', 
                              style: TextStyleNunitoW500Black14,
                              overflow : TextOverflow.ellipsis,
                              maxLines: 1
                            ),
                            SizedBox(width: 10,),
                            InkWell(
                              onTap: () {
                                setState(() {

                                  idStikers = snapshot.data![index]['stikers'];
                                  idCategories = id;
                                  opacityCommentOption = 1;
                                  IgnoringCommentOption = false;

                                });
                              },
                              child: Icon(Icons.more_vert_outlined, size: 25, color: blackGray,)
                            )
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
                              username!, 
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