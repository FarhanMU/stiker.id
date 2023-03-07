import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/layouts/header_layout.dart';
import 'package:flutter_merraland_online_new/layouts/header_layout_arrow.dart';
import 'package:flutter_merraland_online_new/layouts/menu_layout.dart';
import 'package:flutter_merraland_online_new/pages/ListSearch_page.dart';
import 'package:flutter_merraland_online_new/pages/categoryCreator_page.dart';
import 'package:flutter_merraland_online_new/pages/detailCategory_page.dart';
import 'package:flutter_merraland_online_new/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class search_page extends StatefulWidget {

  @override
  State<search_page> createState() => _search_pageState();
}

class _search_pageState extends State<search_page> {

  int _currentSliders = 0;
  final CarouselController _controller = CarouselController();

  // Create storage
  final storage = new FlutterSecureStorage();
  final String _baseUrl = 'https://bukahuni.com';
  final String stikersProfileUrl = '/api/stikers/stikers_profile';
  final String stikersAllCategoryUrl = '/api/stikers/allCategory';
  final String stikersStikerAdvertisementAllUrl = '/api/stikers/stikerAdvertisementAll';

  String? token = '';
  String? idPublication = '';

  RefreshController refreshController = RefreshController();

  
  Future<List> _stikersProfile() async {

    String? token = '';
    token = await storage.read(key: 'token');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    try {
      // This is an open REST API endpoint for testing purposes
      final http.Response response = await http.get(Uri.parse(_baseUrl+stikersProfileUrl), headers: {
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
  
  Future<List> _stikersAllCategory() async {

    String? token = '';
    token = await storage.read(key: 'token');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    try {
      // This is an open REST API endpoint for testing purposes
      final http.Response response = await http.get(Uri.parse(_baseUrl+stikersAllCategoryUrl), headers: {
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
  
  Future<List> _stikersStikerAdvertisementAll() async {

    String? token = '';
    token = await storage.read(key: 'token');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    try {
      // This is an open REST API endpoint for testing purposes
      final http.Response response = await http.get(Uri.parse(_baseUrl+stikersStikerAdvertisementAllUrl), headers: {
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
    _stikersProfile();
    _stikersAllCategory();
    _stikersStikerAdvertisementAll();

    setState(() {});
    refreshController.refreshCompleted();
  }

  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-6717426320595915/4202366632',
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
  

  @override
  void initState() {
    _stikersProfile();
    _stikersAllCategory();
    _stikersStikerAdvertisementAll();

    // TODO: implement initState
    super.initState();
    myBanner.load();

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

  @override
  Widget build(BuildContext context) {

    final AdWidget adWidget = AdWidget(ad: myBanner);

    final Container adContainer = Container(
      alignment: Alignment.center,
      child: adWidget,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
    );

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
                  child: SmartRefresher(
                    controller: refreshController, 
                    onRefresh: onRefresh,
                    child: ListView(
                      children: [
                        SizedBox(height: 65,),
                        FutureBuilder(
                        future: _stikersStikerAdvertisementAll(),
                        builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                          snapshot.hasData
                            ? 
                            slider(    
                              snapshot
                            )
                                                      
                            : 
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:MediaQuery.of(context).size.height * 0.27,
                                  decoration: BoxDecoration(
                                    color: blueDarkColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                )
                            )
                        ),
                        SizedBox(height: 10,),
                        Container(
                            child: Text(
                              'Ideas From Creators', 
                              style: TextStyleNunitoBoldBlack15,
                              overflow : TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SizedBox(height: 10,),
                        FutureBuilder(
                          future: _stikersProfile(),
                          builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                            snapshot.hasData
                              ? 
                              Container(
                                width: 160,
                                height: 200,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (BuildContext context, index) => 
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        WeChooseForYou(
                                          snapshot,
                                          index
                                        ), 
                                      ],
                                    )
                                  ),
                                ),
                              )
                            
                              : 
     
                              Container(
                                width: 160,
                                height: 200,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 5,
                                  itemBuilder: (BuildContext context, index) => 
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                          width: 160,
                                          height: 200,
                                          child: ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                          child: Stack(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context).size.width * 1,
                                                  height: 180,
                                                  decoration: BoxDecoration(
                                                    color: blueDarkColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  left: 60,
                                                  child: Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: blueDark3Color,
                                                      borderRadius: BorderRadius.circular(25),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ) 
                                      ],
                                    )
                                  ),
                                ),
                              )
                        ),
                        SizedBox(height: 20,),
                        adContainer,
                        SizedBox(height: 20,),
                        Container(
                          child: Text(
                            'Ideas for you', 
                            style: TextStyleNunitoBoldBlack15,
                            overflow : TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 10,),
                        FutureBuilder(
                        future: _stikersAllCategory(),
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
                                itemCount: snapshot.data!.length >= 6 ? 6 : snapshot.data!.length,
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
                        SizedBox(height: 100,),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: whiteColor,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ListSearch_page('')));
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 15),
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: gray5Color)
                            ),   
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Find Sticker Ideas', style: TextStyleNunitoW500Black14,),
                                Icon(Icons.search, size: 22,)
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ), 
                menu_layout(context, 'search'),
     
              ],
            ),
          ),
        ),
         ),
     );
  
  }

  bool IgnoringSimiliarSearch = true;
  double opacitysimiliarSearch = 0;

  Widget slider(AsyncSnapshot<List> snapshot)
  {

    final List<Widget> imageSliders = snapshot.data!.asMap().entries.map((entry) {  
      return Container(
          child: Container(
            child: ClipRRect(
              child: Image.network("https://bukahuni.com/storage/stikersIdImages/"+snapshot.data![entry.key]['image'], fit: BoxFit.fill, width: MediaQuery.of(context).size.width),
            ),
          ),
        );
    }).toList();

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Stack(
          children: [
            CarouselSlider(
              items: imageSliders,
              carouselController: _controller,
              options: CarouselOptions(
                autoPlay: true,
                height: MediaQuery.of(context).size.width * 0.6,
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentSliders = index;
                  });
                }),
            ),   
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.04,
                decoration: BoxDecoration(
                  color: blackButtonTransparentColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding( 
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: imageSliders.asMap().entries.map((entry) {
                            return GestureDetector(
                              onTap: () => _controller.animateToPage(entry.key),
                              child: 
                              _currentSliders == entry.key ?
                              Padding( 
                                padding: const EdgeInsets.only(right: 5),
                                child: Image.asset('assets/images/Ellipse-fill.png', width: 8,),
                              ) :
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Image.asset('assets/images/Ellipse-outer.png', width: 8,),
                              ),
                            );
                          }).toList(),
                        ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  
  }

  
  Widget WeChooseForYou(AsyncSnapshot snapshot, int index)
  {

    String id = snapshot.data![index]['stikers'][0]['stikers_user']['id'].toString();
    String imageWebp = snapshot.data![index]['stikers'][0]['imageWebp'];
    String photoProfile = snapshot.data![index]['stikers'][0]['stikers_user']['photoProfile'];
    String username = snapshot.data![index]['stikers'][0]['stikers_user']['username'];

    return Container(
        width: 160,
        height: 200,
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 5),
        child: InkWell(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => categoryCreator_page(username)));
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [  
                      Image.network('https://bukahuni.com/storage/stikersIdImages/$imageWebp', fit: BoxFit.fill,),
                    ],
                  )
                ),
              ),
              Positioned(
                bottom: 0,
                left: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  child: Image.network('https://bukahuni.com/storage/stikersIdImages/$photoProfile', fit: BoxFit.fill, height: 40, width: 40,),
                ),
              )
            ],
          ),
        ),
      );
  }
  
  Widget WeChooseForYouCategory(AsyncSnapshot snapshot, int index)
  {

    String id = snapshot.data![index]['id'].toString();
    String imageWebp = snapshot.data![index]['stikers'][0]['imageWebp'];
    String stikerPackName = snapshot.data![index]['stikerPackName'];

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