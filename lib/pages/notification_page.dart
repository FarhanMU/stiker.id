import 'dart:ffi';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';


class notification_page extends StatefulWidget {

  @override
  State<notification_page> createState() => _notification_pageState();
}

class _notification_pageState extends State<notification_page> {

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

  RefreshController refreshController = RefreshController();
  final _scrollController = ScrollController();

  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  void onRefresh() async{
    await Future.delayed(Duration(seconds: 1));

    setState(() {});
    refreshController.refreshCompleted();
  }

  @override
  void initState() {


    // TODO: implement initState
    super.initState();
    
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
                Container(
                  margin: EdgeInsets.only(top: 130),
                  child: SmartRefresher(
                      controller: refreshController, 
                      onRefresh: onRefresh,
                      child: ListView(
                        children: [
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  child: Text(
                                    'There are no notifications at this time', 
                                    style: TextStyleNunitoW600Gray16,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 100,),
                      ],
                    ),
                  ),
                ), 
                menu_layout(context, 'notification'),
                
              ],
            ),
          ),
        ),
    );
  
  }


}