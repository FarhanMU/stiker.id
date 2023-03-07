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
import 'package:flutter_merraland_online_new/pages/customEditor_saveToPackNew_page.dart';
import 'package:flutter_merraland_online_new/pages/editProfile_page.dart';
import 'package:flutter_merraland_online_new/pages/login_page.dart';
import 'package:flutter_merraland_online_new/pages/profile_page.dart';
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

class customEditor_saveToPack_page extends StatefulWidget {

  final File? _file;
  final String stickerName;
  const customEditor_saveToPack_page(this._file, this.stickerName);

  @override
  State<customEditor_saveToPack_page> createState() => _customEditor_saveToPack_page_pageState(_file, stickerName);
}

class _customEditor_saveToPack_page_pageState extends State<customEditor_saveToPack_page> {
  
  final File? _file;
  String stickerName;
  _customEditor_saveToPack_page_pageState(this._file, this.stickerName);

    // Create storage
  final storage = new FlutterSecureStorage();
  final String _baseUrl = 'https://bukahuni.com';
  final String stikersAllTrendingUrl = '/api/stikers/categoryCreatorDetail';
  final String stikers_pack_profileUrl = '/api/stikers/stikers_pack_profile/';
  final String leadShowUrl = '/api/stikers/leads/show/';
  final String createStikerUrl = '/api/stikers/create';


  String? stickerPack = '0';
  String? emailCreator = '';
  String? stikers_user_id = '';
  bool firstReload = false;

  Future<List> _stikers_pack_profile() async {

    String? token = '';
    token = await storage.read(key: 'token');

    stikers_user_id = await storage.read(key: 'idUser');
    emailCreator = await storage.read(key: 'email');

    Map<String, dynamic> map;
    List<dynamic> posts = [];

    try {
      // This is an open REST API endpoint for testing purposes
      final http.Response response = await http.get(Uri.parse(_baseUrl+stikers_pack_profileUrl+stikers_user_id!), headers: {
        'Authorization': 'Bearer $token',
      });
      
      map = json.decode(response.body);
      posts = map["data"];

    } catch (err) {
      print(err);
    }

    stickerPack = posts.length.toString();

    return posts;
  }

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

    if(firstReload == false)
    {
      firstReload = true;
      storage.write(key: 'idUser', value: posts[0]['id'].toString());
      
      setState(() {});
    }


    return posts;
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

  Future _createSticker(String stikers_category_id) async
  {
    String? token = '';
    token = await storage.read(key: 'token');

    String? idUser = '';
    idUser = await storage.read(key: 'idUser');

    String? image = '';
    image = base64Encode(_file!.readAsBytesSync());

    String? image_Webp = '';
    image_Webp = base64Encode(_file!.readAsBytesSync());

    final response = await http.post(Uri.parse(_baseUrl+createStikerUrl), 
      headers: {
        'Authorization': 'Bearer $token',
      }, 
      body: {
        "stikers_user_id" : idUser,
        "stikers_category_id" : stikers_category_id,
        "stikerName" : stickerName,
        "image" : image,
        "imageWebp" : image_Webp,
      }
    );

    return response.body;
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    _stikersAllTrending();
    _stikers_pack_profile();
    _leadShow();
  }

  String CountOfStickerName = '0';

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
                    FutureBuilder(
                    future: _stikers_pack_profile(),
                    builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                      snapshot.hasData
                        ? 
                        Container()
                        : 
                        Container()
                    ),
                    FutureBuilder(
                    future: _leadShow(),
                    builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                      snapshot.hasData
                        ? 
                        Container()
                        : 
                        Container()
                    ),
                    SizedBox(height: 80,),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => customEditor_saveToPackNew_page(_file, stickerName)));
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: blueDarkColor
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 20,),
                            SizedBox(width: 5,),
                            Text(
                              'Create a New Sticker Pack',
                              style: TextStyleNunitoBoldBlack16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    FutureBuilder(
                        future: _stikersAllTrending(),
                        builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) =>
                          snapshot.hasData
                            ? 
                            Container(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemCount: stickerPack != '0' ? snapshot.data!.length : 1 ,
                                itemBuilder: (BuildContext context, index) => 
                                stickerPack != '0' ?
                                  snapshot.data![index]['stikers'][0]['stikers_user']['email'] == emailCreator ?
                                    stikerPack(
                                      snapshot,
                                      index
                                    )
                                  :
                                  Container() 
                                :
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.7,
                                          child: Text(
                                            'Kamu Belum Memiliki Stiker', 
                                            style: TextStyleNunitoW600Gray16,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.7,
                                          child: Text(
                                            'Jadilah creator dan bagikan stiker kamu ke banyak orang.', 
                                            style: TextStyleNunitoW500Gray14,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.symmetric(vertical: 10),
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: blueDarkColor,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: blueDarkColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            SizedBox(height: 10,),
                                            Container(
                                              width: 100,
                                              height: 25,
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
                                      width: 100,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: blueDarkColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                              )
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
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => editProfile_page()), (Route<dynamic> route) => false);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset('assets/images/back_arrow_black_circle.png', width: 25,)
                          ),
                        ),
                        Text(
                          'Select Sticker Pack',
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

  Widget stikerPack(AsyncSnapshot snapshot, int index)
  {

    String id = snapshot.data![index]['id'].toString();
    String image0 = snapshot.data![index]['stikers'].length >= 1 ? snapshot.data![index]['stikers'][0]['imageWebp'] : '';
    String stikerPackName = snapshot.data![index]['stikerPackName'];
    String animatedStickerPack = snapshot.data![index]['animatedStickerPack'].toString();
    String stikers_category_id = snapshot.data![index]['id'].toString();
    String stikerName = snapshot.data![index]['stikers'][0]['stikerName'];
    String amountDownload = snapshot.data![index]['amountDownload'].toString();
    String amountRating = snapshot.data![index]['ratingAverage'] != null ? snapshot.data![index]['ratingAverage'].toString() : '0';
    String photoProfile = snapshot.data![index]['stikers'][0]['stikers_user']['photoProfile'];
    String amountStikers = snapshot.data![index]['stikers'].length.toString();
    String username = snapshot.data![index]['stikers'][0]['stikers_user']['username'];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(vertical: 10),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.network('https://bukahuni.com/storage/stikersIdImages/$image0', fit: BoxFit.fill, width: 50, height: 50,),
              SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stikerPackName,
                    style: TextStyleNunitoBoldBlack15,
                  ),
                  Text(
                    animatedStickerPack == '0' ? 'Gambar TIdak Bergerak' : 'Gambar Animasi',
                    style: TextStyleNunitoW500Black13,
                  ),
                ],
              )
            ],
          ),
          InkWell(
            onTap: () {
              _createSticker(stikers_category_id).then((value) {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => profile_page()), (Route<dynamic> route) => false);
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              decoration: BoxDecoration(
                color: Primary2,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Add',
                style: TextStyleNunitoW600White14,
              ),
            ),
          ),
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
