import 'dart:ffi';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/layouts/header_layout.dart';
import 'package:flutter_merraland_online_new/layouts/menu_layout.dart';
import 'package:flutter_merraland_online_new/layouts/rules_page.dart';
import 'package:flutter_merraland_online_new/pages/editProfile_page.dart';
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

class editProfileDetail_page extends StatefulWidget {

  final String pageName, username;
  const editProfileDetail_page(this.pageName, this.username);

  @override
  State<editProfileDetail_page> createState() => _editProfileDetail_page_pageState(pageName, username);
}

class _editProfileDetail_page_pageState extends State<editProfileDetail_page> {

  final String pageName;
  final String username;
  _editProfileDetail_page_pageState(this.pageName, this.username);

  // Create storage
  final storage = new FlutterSecureStorage();
  final String _baseUrl = 'https://bukahuni.com';
  final String leadShowUrl = '/api/stikers/leads/show/';
  final String updateUsernameProfileUrl = '/api/stikers/leads/updateUsernameProfile';

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;

  void initState() {
    // TODO: implement initState
    super.initState();
    _usernameController = TextEditingController();
    _usernameController.text =  username;
    CountOfUsername =  username.length.toString();

  }

  String CountOfUsername = '0';

  Future _updateUsernameProfile() async
  {
    String? token = '';
    token = await storage.read(key: 'token');

    final response = await http.post(Uri.parse(_baseUrl+updateUsernameProfileUrl), 
      headers: {
        'Authorization': 'Bearer $token',
      }, 
      body: {
        "lastUsername" : username,
        "username" : _usernameController.text,
      }
    );

    return response.body;
  }

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
     Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => editProfile_page()), (Route<dynamic> route) => false);
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
                                    LengthLimitingTextInputFormatter(20)
                                  ],
                                  autofocus: true,
                                  controller: _usernameController,
                                  onChanged: (text) {
                                    setState(() {
                                       CountOfUsername = _usernameController.text.length.toString();
                                    });
                                  },
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                      hintText: "Username",
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
                          Container(),
                          Text(
                            ' $CountOfUsername / 20',
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
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => editProfile_page()), (Route<dynamic> route) => false);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset('assets/images/back_arrow_black_circle.png', width: 25,)
                          ),
                        ),
                        Text(
                          pageName,
                          style: TextStyleNunitoBoldBlack16,
                        ),
                        InkWell(
                          onTap: () {
                            CountOfUsername != '0' ?
                            _updateUsernameProfile().then((value) {
    
                              storage.write(key: 'username', value: _usernameController.text);
    
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => editProfile_page()), (Route<dynamic> route) => false);
    
                            }) : 
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => editProfile_page()), (Route<dynamic> route) => false);
                          },
                          child: Text(
                            'Save',
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
