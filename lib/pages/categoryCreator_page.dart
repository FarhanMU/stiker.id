import 'dart:ffi';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/layouts/header_layout_arrow.dart';
import 'package:flutter_merraland_online_new/layouts/menu_layout.dart';
import 'package:flutter_merraland_online_new/pages/beranda_page.dart';
import 'package:flutter_merraland_online_new/pages/detailCategory_page.dart';
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


class categoryCreator_page extends StatefulWidget {

  final String usernameCreator;
  const categoryCreator_page(this.usernameCreator);

  @override
  State<categoryCreator_page> createState() => _categoryCreator_pageState(usernameCreator);
}

class _categoryCreator_pageState extends State<categoryCreator_page> {

  final String usernameCreator;
  _categoryCreator_pageState(this.usernameCreator);

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
  final String stickerUpdateAmountDownloadUrl = '/api/stikers/stickerUpdateAmountDownload/';


  RefreshController refreshController = RefreshController();

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

  void onRefresh() async{
    await Future.delayed(Duration(seconds: 1));
    _stikersAllTrending();
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
    myBanner.load();
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home : Scaffold(
        backgroundColor: whiteColor,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 55),
                child: SmartRefresher(
                    controller: refreshController, 
                    onRefresh: onRefresh,
                    child: ListView(
                      children: [
                        adContainer,
                        FutureBuilder(
                        future: _stikersAllTrending(),
                        builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                          snapshot.hasData
                            ? 
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (BuildContext context, index) => 
                                snapshot.data![index]['stikers'][0]['stikers_user']['username'] == usernameCreator ? 
                                stikersAllTrending(
                                  snapshot,
                                  index
                                ) : Container()
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
                ),
              ),       
              menu_layout(context, 'search'),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: header_layout_arrow('', whiteColor, '', context),
              ),
            ],
          ),
        ),
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