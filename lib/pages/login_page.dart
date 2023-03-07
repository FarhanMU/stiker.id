import 'dart:ffi';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_merraland_online_new/pages/beranda_page.dart';
import 'package:flutter_merraland_online_new/pages/profile_page.dart';
import 'package:flutter_merraland_online_new/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class login_page extends StatefulWidget {
  final String loginKey;
  const login_page(this.loginKey);

  @override
  State<login_page> createState() => _login_pageState(loginKey);
}

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],
);

class _login_pageState extends State<login_page> {
  final String loginKey;
  _login_pageState(this.loginKey);

  // Create storage
  final storage = new FlutterSecureStorage();
  final String _baseUrl = 'https://bukahuni.com/';
  final String loginUrl = 'api/stikers/leads/create';
  final String loginIosUrl = 'api/stikers/leads/create/ios';
  final String loginAdminUrl = 'api/login';
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
    // TODO: implement initState
    super.initState();
  }

  void storeTokenIos(String token, String? username) async {
    storage.write(key: 'username', value: username);
    storage.write(key: 'token', value: token);

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => profile_page()), (Route<dynamic> route) => false);
  }

  void storeToken(String token) async {
    storage.write(key: 'token', value: token);
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => profile_page()), (Route<dynamic> route) => false);
  }

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) 
    {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Tekan Sekali Lagi Untuk Keluar');
      return Future.value(false);
    }

    SystemNavigator.pop();
    return Future.value(true);
  }

  Future _login() async
  {
    
    final response = await http.post(Uri.parse(_baseUrl+loginAdminUrl), body: {
      "username" : 'admin',
      "password" : 'BVNcmx123@',
    });

    return json.decode(response.body);
  }

  void storeTokenAutomatic() async {
    _login().then((value) {
        storage.write(key: 'token', value: value['token']);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => beranda_page()), (Route<dynamic> route) => false);

    });
  }

  @override
  Widget build(BuildContext context) {
    if (loginKey == 'logout') {
      _googleSignIn.disconnect();
      
    }

    GoogleSignInAccount? user = _currentUser;

    Future _loginGoogle() async {
      storage.write(key: 'username', value: user?.displayName);
      storage.write(key: 'email', value: user?.email);

      final response = await http.post(Uri.parse(_baseUrl + loginUrl), body: {
        "username": user?.displayName,
        "photoProfile": 'default.png',
        "email": user?.email,
        "appleId": '-',
      });

      return json.decode(response.body);
    }

    Future _loginApple(String? appleId) async {

      // if (email == null) {
      //   username = await storage.read(key: 'username');
      //   photoProfile = await storage.read(key: 'photoProfile');
      //   email = await storage.read(key: 'email');
      // }

      final response = await http.post(Uri.parse(_baseUrl + loginIosUrl), body: {
        "username": user?.displayName,
        "photoProfile": 'default.png',
        "email": user?.email,
        "appleId": appleId,
      });

      return json.decode(response.body);
    }

    if (user != null ) {
      _loginGoogle().then((value) {

        storage.write(key: 'idProfil', value: value['data']['id'].toString());
        storage.write(key: 'photoProfile', value: value['data']['photoProfile'].toString());
        storeToken(value['token']);
      });
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
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/images/Logo_User.png', fit: BoxFit.fill, width: 100,)
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 100,
                          ),
                          InkWell(
                            onTap: (() {
                              signIn();
                            }),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 1),
                                    spreadRadius: -2,
                                    blurRadius: 6,
                                    color: Color.fromRGBO(0, 0, 0, 0.4),
                                  )
                                ],
                                color: whiteColor,
                                borderRadius:BorderRadius.all(Radius.circular(6))
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/google_login.png',
                                    fit: BoxFit.fill,
                                    width: 20,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    'Login dengan Google',
                                    style: TextStyleNunitoBoldBlack18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          // SignInWithAppleButton(
                          //   onPressed: () async {
                          //     final credential =
                          //         await SignInWithApple.getAppleIDCredential(
                          //       scopes: [
                          //         AppleIDAuthorizationScopes.email,
                          //         AppleIDAuthorizationScopes.fullName,
                          //       ],
                          //     );

                          //     String? firstName = credential.givenName;
                          //     String? lastName = credential.familyName;

                          //     // _loginApple('$firstName $lastName', '',
                          //     //         credential.email, credential.userIdentifier)
                          //     //     .then((value) {
                          //     //   storeTokenIos(
                          //     //       value['token'],
                          //     //       value['data']['username'],
                          //     //       '',
                          //     //       value['data']['email'],
                          //     //       value['data']['appleId']);
                          //     // });
                          //     _loginApple(credential.userIdentifier).then((value) {
                          //       storage.write(key: 'idProfil', value: value['data']['id'].toString());
                          //       storage.write(key: 'photoProfile', value: value['data']['photoProfile'].toString());

                          //       storeTokenIos(value['token'],value['data']['username']);
                          //     });

                          //     // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
                          //     // after they have been validated with Apple (see `Integration` section for more information on how to do this)
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        if (loginKey == 'logout') {
                          storeTokenAutomatic();
                        }
                        else
                        {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.asset('assets/images/back_arrow_black_circle.png', width: 25,)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (e) {
      print("error signin in $e");
    }
  }
}
