import 'dart:ffi';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/layouts/header_layout.dart';
import 'package:flutter_merraland_online_new/layouts/menu_layout.dart';
import 'package:flutter_merraland_online_new/layouts/rules_page.dart';
import 'package:flutter_merraland_online_new/pages/customEditor_page.dart';
import 'package:flutter_merraland_online_new/pages/editProfileDetail_page.dart';
import 'package:flutter_merraland_online_new/pages/login_page.dart';
import 'package:flutter_merraland_online_new/pages/profile_page.dart';
import 'package:flutter_merraland_online_new/pages/settings_page.dart';
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
import 'package:image_picker/image_picker.dart';


class editProfile_page extends StatefulWidget {
  @override
  State<editProfile_page> createState() => _editProfile_page_pageState();
}

class _editProfile_page_pageState extends State<editProfile_page> {
  // Create storage
  final storage = new FlutterSecureStorage();
  final String _baseUrl = 'https://bukahuni.com';
  final String leadShowUrl = '/api/stikers/leads/show/';

  String? email = '';

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


    // print(posts);

    return posts;
  }

  
  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
     Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => settings_page()), (Route<dynamic> route) => false);
    return Future.value(true);

  }

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
                    SizedBox(height: 60,),
                    FutureBuilder(
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
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => settings_page()), (Route<dynamic> route) => false);
    
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset('assets/images/back_arrow_black_circle.png', width: 25,)
                          ),
                        ),
                        Text(
                          'Change Account',
                          style: TextStyleNunitoBoldBlack16,
                        ),
                        Container()
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

  File? _file;
  File? _sample;
  final cropKey = GlobalKey<CropState>();


  Future<void> _openImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    final file = File(pickedFile!.path);
    final sample = await ImageCrop.sampleImage(
      file: file,
      preferredSize: context.size!.longestSide.toInt() * 2,
    );

    _sample?.delete();
    _file?.delete();

    _sample = sample;
    _file = file;

    Navigator.push(context, MaterialPageRoute(builder: (context) => customEditor_page(_sample, _file)));
  }

  Widget detailProfile(AsyncSnapshot snapshot, int index)
  {

    String photoProfile = snapshot.data![index]['photoProfile'];
    storage.write(key: 'photoProfile', value: photoProfile);

    String username = snapshot.data![index]['username'];
    String email = snapshot.data![index]['email'];

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
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                    child: Image.network('https://bukahuni.com/storage/stikersIdImages/$photoProfile', fit: BoxFit.fill, width: 80, height: 80,),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap : () {
                        _openImage();
                      },
                      child : Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
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
                        child: Icon(Icons.edit, size: 20,)
                      )
                    )
                  )
                ],
              ),
            ],
          ),
          SizedBox(height: 20,),
          InkWell(
            onTap: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => editProfileDetail_page('Username', username)));
            },
            child: marked('Username', username , false),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: grayLight2Color, width: 1)
              )
            ),
          ),
          SizedBox(height: 20,),
          InkWell(
            onTap: () async {

            },
            child: marked('Email', email , true),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: grayLight2Color, width: 1)
              )
            ),
          ),
          SizedBox(height: 20,),
          
        ],
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
