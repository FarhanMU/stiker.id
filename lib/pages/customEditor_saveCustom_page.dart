import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/pages/customEditor_saveStiker_page.dart';
import 'package:flutter_merraland_online_new/pages/editProfile_page.dart';
import 'package:flutter_merraland_online_new/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_crop_plus/image_crop_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_crop_plus/image_crop_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class customEditor_saveCustom_page extends StatefulWidget {

  final File? _sampleTemporary;
  final File? _file;
  const customEditor_saveCustom_page(this._sampleTemporary, this._file);

  @override
  State<customEditor_saveCustom_page> createState() => _customEditor_saveCustom_pageState(_sampleTemporary, _file);
}

class _customEditor_saveCustom_pageState extends State<customEditor_saveCustom_page> {

  final cropKey = GlobalKey<CropState>();
  File? _file;
  File? _sample;
  File? _lastCropped;

  // Create storage
  final storage = new FlutterSecureStorage();
  final String _baseUrl = 'https://bukahuni.com';
  final String updatePhotoProfileUrl = '/api/stikers/leads/updatePhotoProfile';

  _customEditor_saveCustom_pageState(this._sample, this._file);


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
                        Text(
                          'Next',
                          style: Theme.of(context).textTheme.button!.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => customEditor_saveStiker_page(_lastCropped != null ? _lastCropped! : _sample!)));
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
