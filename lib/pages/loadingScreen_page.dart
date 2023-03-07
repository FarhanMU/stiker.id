import 'dart:ffi';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/layouts/menu_layout.dart';
import 'package:flutter_merraland_online_new/pages/beranda_page.dart';
import 'package:flutter_merraland_online_new/pages/loadingScreen_page.dart';
import 'package:flutter_merraland_online_new/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class loadingScreen_page extends StatefulWidget {

  @override
  State<loadingScreen_page> createState() => _loadingScreen_pageState();
}

class _loadingScreen_pageState extends State<loadingScreen_page> {

  @override
  Widget build(BuildContext context) {

  // disable rotation
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  SystemChrome.setSystemUIOverlayStyle( SystemUiOverlayStyle(statusBarColor: Colors.black));

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home : Scaffold(
      // backgroundColor: whiteColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Primary,
                Primary2,
              ],
            )
          ),
          child: Align(
            alignment: Alignment.center,
            child: Image.asset('assets/images/Logo_User.png', fit: BoxFit.fill, width: 100,)
          ),
        ),
        ),
      ),
    );
  }

}