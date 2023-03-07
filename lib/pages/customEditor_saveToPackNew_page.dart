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

class customEditor_saveToPackNew_page extends StatefulWidget {

  final File? _file;
  final String stickerName;
  const customEditor_saveToPackNew_page(this._file, this.stickerName);

  @override
  State<customEditor_saveToPackNew_page> createState() => _customEditor_saveToPackNew_page_pageState(_file, stickerName);
}

class _customEditor_saveToPackNew_page_pageState extends State<customEditor_saveToPackNew_page> {
  
  final File? _file;
  String stickerName;
  _customEditor_saveToPackNew_page_pageState(this._file, this.stickerName);

  // Create storage
  final storage = new FlutterSecureStorage();
  final String _baseUrl = 'https://bukahuni.com';
  final String createStikerCategoryUrl = '/api/stikers/createStikerCategory';
  final String createStikerUrl = '/api/stikers/create';

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _stickerPackController;

  void initState() {
    // TODO: implement initState
    super.initState();
    _stickerPackController = TextEditingController();
  }

  String CountOfStickerName = '0';
  String stikers_category_id = '0';
  String stikers_warning = '';

  bool warning = false;

  DateTime? currentBackPressTime;

  Future _createStickerPack() async
  {
    String? token = '';
    token = await storage.read(key: 'token');

    final response = await http.post(Uri.parse(_baseUrl+createStikerCategoryUrl), 
      headers: {
        'Authorization': 'Bearer $token',
      }, 
      body: {
        "stikerPackName" : _stickerPackController.text,
      }
    );

    return response.body;
  }

  Future _createSticker() async
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
                                  controller: _stickerPackController,
                                  onChanged: (text) {
                                    setState(() {
                                       CountOfStickerName = _stickerPackController.text.length.toString();
                                    });
                                  },
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                      hintText: "Sticker pack name",
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
                            'Masukan Nama Stiker Pack',
                            style: TextStyleNunitoW500Red14,
                          ) : 
                          Text(
                            stikers_warning,
                            style: TextStyleNunitoW500Red14,
                          ),
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
                          'Create Sticker Packs',
                          style: TextStyleNunitoBoldBlack16,
                        ),
                        InkWell(
                          onTap: () {
                            CountOfStickerName != '0' ?
                              _createStickerPack().then((value) {

                                if(value == 'stiker pack sudah tersedia')
                                {
                                  setState(() {
                                    warning = false;
                                    stikers_warning = value + ' find another name';
                                  });
                                }
                                else
                                {
                                  setState(() {
                                    stikers_category_id = value.toString();
                                    _createSticker().then((value) {
                                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => profile_page()), (Route<dynamic> route) => false);
                                        print(value);
                                    });
                                  });
                                }

                              })
                              : 
                              setState(() {
                                warning = true;
                              });                
                          },
                          child: Text(
                            'Create',
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
