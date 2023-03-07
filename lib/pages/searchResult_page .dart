import 'dart:io';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/layouts/header_layout_arrow.dart';
import 'package:flutter_merraland_online_new/layouts/menu_layout.dart';
import 'package:flutter_merraland_online_new/pages/ListSearch_page.dart';
import 'package:flutter_merraland_online_new/pages/customEditor_page.dart';
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




class searchResult_page extends StatefulWidget {

  final String searchValue;
  const searchResult_page(this.searchValue);

  @override
  State<searchResult_page> createState() => _searchResult_pageState(searchValue);
}

class _searchResult_pageState extends State<searchResult_page> {

  final String searchValue;
  _searchResult_pageState(this.searchValue);

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

  String _baseUrl = '';
  final String stikersstikerNameSearchUrl = '/api/stikers/stikerNameSearch?search=';
  final String stickerUpdateAmountDownloadUrl = '/api/stikers/stickerUpdateAmountDownload/';


  RefreshController refreshController = RefreshController();
  final _scrollController = ScrollController();

  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  int allDataStikers = 0;
  int countOfData = 10;

  
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

  Future<List> _stikersstikerNameSearch() async {

    String? token = '';
    token = await storage.read(key: 'token');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    _baseUrl = searchValue == '' ? '' : 'https://bukahuni.com';

    try {
      // This is an open REST API endpoint for testing purposes

      final http.Response response =
          await http.get(Uri.parse(_baseUrl + stikersstikerNameSearchUrl + searchValue), headers: {
        'Authorization': 'Bearer $token',
      }) ;

      map = json.decode(response.body);
      posts = map["data"];
    } catch (err) {
      print(err);
    }

    allDataStikers = posts.length;

    print(posts);

    return posts;
    
  }

  void onRefresh() async{
    await Future.delayed(Duration(seconds: 1));
    _stikersstikerNameSearch();
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

  void onAdLoaded(InterstitialAd ad) 
  {
    _interstitialAd = ad;
    _isLoaded = true;

    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {

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
    _stikersstikerNameSearch();
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
                        SizedBox(height: 10,),
                        adContainer,
                        SizedBox(height: 10,),
                        FutureBuilder(
                        future: _stikersstikerNameSearch(),
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
              ),       
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: whiteColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: whiteColor,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset('assets/images/back_arrow_black_circle.png', width: 25,)
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ListSearch_page(searchValue)));
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 15, top: 10, bottom: 15),
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: gray5Color)
                          ),   
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  searchValue != '' ? searchValue : 'Find Sticker Ideas', 
                                  style: TextStyleNunitoW500Black14,
                                  overflow : TextOverflow.ellipsis,
                                  maxLines: 1
                                ),
                              ),
                              Icon(Icons.search, size: 22,)
                            ],
                          )
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

  Widget topBar(int value)
  {
    return Positioned(
      top: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
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
                      Column(
                        children: [
                          Text('Untuk Anda', style: TextStyleNunitoBoldBlack16,),
                          SizedBox(height: 10,),
                          Container(
                            width: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(width: 2, color: blackColor)
                              )
                            ),
                          )
                        ],
                      ),
                      SizedBox(width: 10,),
                      InkWell(
                        onTap: (){
                          // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => berandaTrending_page()), (Route<dynamic> route) => false);
                        },
                        child: Column(
                          children: [
                            Text('Trending', style: TextStyleNunitoW500Black16,),
                            SizedBox(height: 10,),
                            // Container(
                            //   width: 30,
                            //   decoration: BoxDecoration(
                            //     border: Border(
                            //       bottom: BorderSide(width: 2, color: blackColor)
                            //     )
                            //   ),
                            // )
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
    String amountDownload = snapshot.data![index]['stikers_category']['amountDownload'].toString();
    String photoProfile = snapshot.data![index]['stikers_user']['photoProfile'].toString();
    String username = snapshot.data![index]['stikers_user']['username'].toString();
    String stikerPackName = snapshot.data![index]['stikers_category']['stikerPackName'].toString();

    return Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
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
  
}