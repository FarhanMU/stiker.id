import 'dart:ffi';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/layouts/header_layout.dart';
import 'package:flutter_merraland_online_new/layouts/menu_layout.dart';
import 'package:flutter_merraland_online_new/pages/beranda_page.dart';
import 'package:flutter_merraland_online_new/pages/detailCategory_page.dart';
import 'package:flutter_merraland_online_new/pages/searchResult_page%20.dart';
import 'package:flutter_merraland_online_new/pages/search_page.dart';
import 'package:flutter_merraland_online_new/theme.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

class ListSearch_page extends StatefulWidget {

  final String searchValue;
  const ListSearch_page(this.searchValue);

  @override
  State<ListSearch_page> createState() => _ListSearch_pageState(searchValue);
}

class _ListSearch_pageState extends State<ListSearch_page> {

  String searchValue;
  _ListSearch_pageState(this.searchValue);

  // Create storage
  final storage = new FlutterSecureStorage();

  String _baseUrl = '';

  final String stikerNameSearchUrl = '/api/stikers/stikerNameSearch?search=';


  String? title = '';
  String? type = '';
  String? developerName = '';


  final _formKey = GlobalKey<FormState>();
  double opacitysearchResult = 0;

  RefreshController refreshController = RefreshController();

  final _scrollController = ScrollController();
  int allDataStikers = 0;
  int countOfData = 10;


  Future<List> _stikerNameSearch() async {

    String? token = '';
    token = await storage.read(key: 'token');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    _baseUrl = searchValue == '' ? '' : 'https://bukahuni.com';
    print('_baseUrl' + _baseUrl + stikerNameSearchUrl + searchValue);

    try {
      // This is an open REST API endpoint for testing purposes

      final http.Response response =
          await http.get(Uri.parse(_baseUrl + stikerNameSearchUrl + searchValue), headers: {
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

  late TextEditingController _searchController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchController = TextEditingController();
    _searchController.text =  searchValue != '' ? searchValue : '';
    if(searchValue != '')
    {
      opacitysearchResult = 1;
    }
    else
    {
      opacitysearchResult = 0;
    }
    _scrollController.addListener(listenScrolling);

  }

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

  @override
  Widget build(BuildContext context) {

    void onRefresh() async {
      await Future.delayed(Duration(seconds: 1));
      _stikerNameSearch();
      setState(() {});
      refreshController.refreshCompleted();
    }

    // disable rotation
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.black));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: whiteColor,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                child: SmartRefresher(
                  controller: refreshController,
                  onRefresh: onRefresh,
                  child: ListView(
                    controller: _scrollController,
                    children: [
                      Container(
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
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
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          margin: EdgeInsets.only(right: 15),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: grayLightColor, width: 2)
                                          ),
                                          width: MediaQuery.of(context).size.width * 0.8,
                                          height: 40,
                                          child: Stack(
                                            children: [
                                              TextField(
                                                autofocus: true,
                                                controller: _searchController,
                                                onChanged: (text) {
                                                  setState(() {
                                                    String value = _searchController.text;
                                                    searchValue = '$value';
                                                    if(value == '')
                                                    {
                                                      opacitysearchResult = 0;
                                                    }
                                                    else
                                                    {
                                                      opacitysearchResult = 1;
                                                    }
                                                  });
                                                },
                                                keyboardType: TextInputType.name,
                                                decoration: InputDecoration(
                                                    hintText: "Find Sticker Ideas",
                                                    hintStyle: TextStyleNunitoW500Gray12,
                                                    border: InputBorder.none,
                                                ),
                                                style: TextStyleNunitoW500Black14,
                                              ),
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                bottom: 0,
                                                child: Column(
                                                  mainAxisAlignment:MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.search, size: 22,)
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          )
                        ),
                      ),
                      opacitysearchResult != 0 ?
                      InkWell(
                        onTap: () {
                          Navigator.push(context,MaterialPageRoute(builder: (context) => searchResult_page(searchValue)));
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: whiteColor,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.search, size: 20, color: gray5Color,),
                                          SizedBox(width: 5,),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.75,
                                            child: Text(_searchController.text,
                                                style: TextStyleNunitoW500Gray12,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.north_west_rounded, size: 20, color: gray5Color,),
                                    ],
                                  )
                                ),
                            ],
                          )
                        ),
                      ) 
                      : 
                      Container(),
                      FutureBuilder(
                        future: _stikerNameSearch(),
                        builder: (BuildContext ctx,
                                AsyncSnapshot<List> snapshot) => snapshot.hasData
                                ? 
                                Container(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemCount: countOfData >= snapshot.data!.length ? snapshot.data!.length : countOfData,
                                    itemBuilder: (BuildContext context, index) => 
                                    Column(
                                      children: [
                                        unitList(snapshot, index),
                                      ],
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
                                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              color: blueDarkColor,
                                              boxShadow: [
                                                BoxShadow(
                                                  offset: Offset(0, 0),
                                                  spreadRadius: 0,
                                                  blurRadius: 0.8,
                                                  color: Color.fromRGBO(0, 0, 0, 0.05),
                                                )
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                                    child: Column(crossAxisAlignment:CrossAxisAlignment.start,
                                                      mainAxisSize:MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          height: 30,
                                                          decoration:BoxDecoration(
                                                            color: blueDark3Color,
                                                            borderRadius:BorderRadius.circular(15),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                offset:Offset(0, 0),
                                                                spreadRadius: 0,
                                                                blurRadius: 0.8,
                                                                color: Color.fromRGBO(0,0,0,0.05),
                                                              )
                                                            ],
                                                          ),
                                                          width: MediaQuery.of(context).size.width,
                                                        ),
                                                      ],
                                                    )),
                                              ],
                                            )),
                                      
                                    ),
                                  )
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

  Widget unitList(AsyncSnapshot snapshot, int index) {

    String stikerName = snapshot.data![index]['stikerName'].toString();

    return InkWell(
      onTap: () {
        Navigator.push(context,MaterialPageRoute(builder: (context) => searchResult_page(stikerName)));
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: whiteColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.search, size: 20, color: blackColor,),
                          SizedBox(width: 5,),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: Text(stikerName,
                                style: TextStyleNunitoW500Black12,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.north_west_rounded, size: 20, color: blackColor,),
                    ],
                  )
                ),
            ],
          )),
    );
  }


}
