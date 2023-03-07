import 'dart:ffi';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/layouts/header_layout.dart';
import 'package:flutter_merraland_online_new/layouts/menu_layout.dart';
import 'package:flutter_merraland_online_new/pages/login_page.dart';
import 'package:flutter_merraland_online_new/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter_html/flutter_html.dart';


class rules_page extends StatefulWidget {

  final String pageName;
  final String htmlData;
  const rules_page(this.pageName, this.htmlData);

  @override
  State<rules_page> createState() => _rules_page_pageState(pageName,htmlData);
}

class _rules_page_pageState extends State<rules_page> {

  final String pageName;
  final String htmlData;
  _rules_page_pageState(this.pageName, this.htmlData);

  @override
  Widget build(BuildContext context) {
    

    void initState() {
      // TODO: implement initState
      super.initState();
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
              ListView(
                children: [
                  SizedBox(height: 20,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        SizedBox(height: 60,),
                        Container(
                          child: Html(
                            data: htmlData,
                          )
                        ),
                      ],
                    ),
                  ),   
                ]
              ),
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                        color: whiteColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset('assets/images/back_arrow_black_circle.png', width: 25,)
                          ),
                          Text(
                            pageName,
                            style: TextStyleNunitoBoldBlack16,
                          ),
                          Container()
                        ],
                      ),
                    ),
                  ),
                ),
  
            ],
          ),
        ),
      ),
    );
  }

}
