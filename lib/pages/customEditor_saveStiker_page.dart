import 'dart:ffi';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/layouts/header_layout.dart';
import 'package:flutter_merraland_online_new/layouts/menu_layout.dart';
import 'package:flutter_merraland_online_new/layouts/rules_page.dart';
import 'package:flutter_merraland_online_new/pages/beranda_page.dart';
import 'package:flutter_merraland_online_new/pages/customEditor_saveToPack_page.dart';
import 'package:flutter_merraland_online_new/pages/editProfile_page.dart';
import 'package:flutter_merraland_online_new/pages/login_page.dart';
import 'package:flutter_merraland_online_new/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_crop_plus/image_crop_plus.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

class customEditor_saveStiker_page extends StatefulWidget {

  final File? _file;
  const customEditor_saveStiker_page(this._file);

  @override
  State<customEditor_saveStiker_page> createState() => _customEditor_saveStiker_page_pageState(_file);
}

class _customEditor_saveStiker_page_pageState extends State<customEditor_saveStiker_page> {
  
  final File? _file;
  _customEditor_saveStiker_page_pageState(this._file);

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;

  void initState() {
    // TODO: implement initState
    super.initState();
    _usernameController = TextEditingController();
  }

  String CountOfStickerName = '0';
  bool warning = false;

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
     Navigator.pop(context);
    return Future.value(true);

  }


  @override
  Widget build(BuildContext context) {


    // disable rotation
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.black));

    return WillPopScope(
      onWillPop: onWillPop,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: whiteColor,
          body: SafeArea(
            child: Stack(
              children: [
                ListView(
                  children: [
                    SizedBox(height: 80,),
                    Container(
                      width: 150,
                      height: 150,
                      child: Image.file(
                       _file!
                      )
                    ),
                    Container(
                      child: Form(
                        key: _formKey,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                border: Border(
                                bottom: BorderSide(color: grayLight2Color, width: 1)
                              )
                            ),
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            child: Stack(
                              children: [
                                TextField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(60)
                                  ],
                                  autofocus: true,
                                  controller: _usernameController,
                                  onChanged: (text) {
                                    setState(() {
                                       CountOfStickerName = _usernameController.text.length.toString();
                                    });
                                  },
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                      hintText: "Sticker name",
                                      hintStyle: TextStyleNunitoW500Gray12,
                                      border: InputBorder.none,
                                  ),
                                  style: TextStyleNunitoW500Black14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          warning == true ?
                          Text(
                            'Masukan Nama Stiker',
                            style: TextStyleNunitoW500Red14,
                          ) : Container(),
                          Text(
                            ' $CountOfStickerName / 60',
                            style: TextStyleNunitoW500Gray14,
                          ),
                        ],
                      ),
                    )
                  ]
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset('assets/images/back_arrow_black_circle.png', width: 25,)
                          ),
                        ),
                        Text(
                          'Create Stickers',
                          style: TextStyleNunitoBoldBlack16,
                        ),
                        InkWell(
                          onTap: () {
                            CountOfStickerName != '0' ?
                              Navigator.push(context, MaterialPageRoute(builder: (context) => customEditor_saveToPack_page(_file, _usernameController.text)))
                              : 
                              setState(() {
                                warning = true;
                              });                
                          },
                          child: Text(
                            'Next',
                            style: TextStyleNunitoBoldPrimary15,
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
      ),
    );
  }


  Widget marked(String title, String content, bool disableClick) {

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyleNunitoBoldBlack16,
                textAlign: TextAlign.start,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                content,
                style: TextStyleNunitoW500Black15,
                textAlign: TextAlign.start,
              ),
              SizedBox(width: 20,),
              disableClick == false ? Icon(Icons.arrow_forward_ios_rounded, size: 10,) : Container()

            ],
          ),
        ],
      ),
    );
  }
}
