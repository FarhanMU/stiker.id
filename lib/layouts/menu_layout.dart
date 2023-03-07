import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_merraland_online_new/pages/beranda_page.dart';
import 'package:flutter_merraland_online_new/pages/customEditor_page.dart';
import 'package:flutter_merraland_online_new/pages/customEditor_saveCustom_page.dart';
import 'package:flutter_merraland_online_new/pages/login_page.dart';
import 'package:flutter_merraland_online_new/pages/notification_page.dart';
import 'package:flutter_merraland_online_new/pages/profile_page.dart';
import 'package:flutter_merraland_online_new/pages/search_page.dart';
import 'package:flutter_merraland_online_new/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_crop_plus/image_crop_plus.dart';
import 'package:image_picker/image_picker.dart';

  
  Widget menu_layout(BuildContext context, String page)
  {

  File? _file;
  File? _sample;

  final storage = new FlutterSecureStorage();
  String? username = '';

  

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

    Navigator.push(context, MaterialPageRoute(builder: (context) => customEditor_saveCustom_page(_sample, _file)));
  }

  Future<void> _checkUser() async {
    username = await storage.read(key: 'username');
  }

  _checkUser();

    return Stack(
      children: [
        Positioned(
          bottom: 0,
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: EdgeInsets.only(bottom: 10, top: 10),
            decoration: BoxDecoration(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    page != 'beranda' ? 
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => beranda_page()), (Route<dynamic> route) => false) : '';
                  },
                  child: page == 'beranda' ? 
                  Column(
                      children: [
                        Icon(Icons.home_outlined, size: 26, ),
                      ],
                  ) :
                  Column(
                    children: [
                      Icon(Icons.home_outlined, size: 26, color: gray5Color,),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    page != 'search' ? 
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => search_page()), (Route<dynamic> route) => false) : '';

                  },
                  child: page == 'search' ? 
                  Column(
                      children: [
                        Icon(Icons.search, size: 26,),
                      ],
                  ) :
                  Column(
                    children: [
                      Icon(Icons.search, size: 26, color: gray5Color,),
                    ],
                  ),
                ),
                Container(),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => notification_page()), (Route<dynamic> route) => false);

                  },
                  child: page == 'notification' ? 
                  Column(
                      children: [
                        Icon(Icons.notifications_none, size: 26,),
                      ],
                  ) :
                  Column(
                    children: [
                      Icon(Icons.notifications_none, size: 26, color: gray5Color,),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {

                    if(page != 'profile')
                    {
                      if(username != '' && username != null)
                      {
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => profile_page()), (Route<dynamic> route) => false);

                      }
                      else
                      {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => login_page('')));
                      }
                    }


                  },
                  child: page == 'profile' ? 
                  Column(
                      children: [
                        Icon(Icons.person_outline, size: 26,),
                      ],
                  ) :
                  Column(
                    children: [
                      Icon(Icons.person_outline, size: 26, color: gray5Color,),
                    ],
                  ),
                ),
              
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 10 ,
          width: MediaQuery.of(context).size.width,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    if(username != '' && username != null)
                    {
                      _openImage();
                    }
                    else
                    {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => login_page('')));
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Primary3,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 1),
                          spreadRadius: -2,
                          blurRadius: 6,
                          color: Color.fromRGBO(0, 0, 0, 0.4),
                        )
                      ],
                    ),
                    child: Icon(Icons.add, size: 45, color: whiteColor,),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
