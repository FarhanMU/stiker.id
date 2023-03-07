import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/pages/editProfile_page.dart';
import 'package:flutter_merraland_online_new/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_crop_plus/image_crop_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_crop_plus/image_crop_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class customEditor_page extends StatefulWidget {

  final File? _sampleTemporary;
  final File? _file;
  const customEditor_page(this._sampleTemporary, this._file);

  @override
  State<customEditor_page> createState() => _customEditor_pageState(_sampleTemporary, _file);
}

class _customEditor_pageState extends State<customEditor_page> {

  final cropKey = GlobalKey<CropState>();
  File? _file;
  File? _sample;
  File? _lastCropped;

  // Create storage
  final storage = new FlutterSecureStorage();
  final String _baseUrl = 'https://bukahuni.com';
  final String updatePhotoProfileUrl = '/api/stikers/leads/updatePhotoProfile';

  _customEditor_pageState(this._sample, this._file);

  Future _updatePhotoProfile() async
  {

    String? token = '';
    token = await storage.read(key: 'token');

    String? email = '';
    email = await storage.read(key: 'email');

    String? oldimage = '';
    oldimage = await storage.read(key: 'photoProfile');

    String? photoSource = '';
    photoSource = _lastCropped != null ? base64Encode(_lastCropped!.readAsBytesSync()) : base64Encode(_sample!.readAsBytesSync());

    final response = await http.post(Uri.parse(_baseUrl+updatePhotoProfileUrl), 
      headers: {
        'Authorization': 'Bearer $token',
      }, 
      body: {
        "email" : email,
        "photoProfile" : photoSource,
        "oldimage" : oldimage,
      }
    );

    return response.body;
  }


  @override
  void initState() {

    // TODO: implement initState
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
    _file?.delete();
    _sample?.delete();
    _lastCropped?.delete();
  }

@override
  Widget build(BuildContext context) {

    print('last cropped $_lastCropped');

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Stack(
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
              child: _sample == null ? _buildOpeningImage() : _buildCroppingImage(),
            ),
            Positioned(
              top: 10,
              left: 0,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  TextButton(
                    child: Row(
                      children: [
                        Icon(Icons.check_rounded, size: 20, color: whiteColor,),
                        SizedBox(width: 5,),
                        Text(
                          'Save',
                          style: Theme.of(context).textTheme.button!.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    onPressed: () {
                      _updatePhotoProfile().then((value) {
                        print(value);
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => editProfile_page()), (Route<dynamic> route) => false);

                      });
                    },
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpeningImage() {
    return Center(child: _buildOpenImage());
  }

  Widget _buildCroppingImage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Crop.file(
             _lastCropped != null ? _lastCropped! : _sample!,
            key: cropKey,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20.0),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton(
                child: Text(
                  'Crop Image',
                  style: Theme.of(context).textTheme.button!.copyWith(color: Colors.white),
                ),
                onPressed: () => _cropImage(),
              ),
              _buildOpenImage(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOpenImage() {
    return TextButton(
      child: Text(
        'Open Image',
        style: Theme.of(context).textTheme.button!.copyWith(color: Colors.white),
      ),
      onPressed: () => _openImage(),
    );
  }

  Future<void> _openImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    final file = File(pickedFile!.path);
    final sample = await ImageCrop.sampleImage(
      file: file,
      preferredSize: context.size!.longestSide.toInt() * 2,
    );

    _sample?.delete();
    _file?.delete();

    setState(() {
      _lastCropped = null;
      _sample = sample;
      _file = file;
    });
  }

  Future<void> _cropImage() async {
    final scale = cropKey.currentState!.scale;
    final area = cropKey.currentState!.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return;
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: _file!,
      preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    setState(() {
      sample.delete();
      _lastCropped?.delete();
      _lastCropped = file;
    });

    debugPrint('$file');
  }
}
