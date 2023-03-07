import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_merraland_online_new/pages/beranda_page.dart';
import 'package:flutter_merraland_online_new/pages/loadingScreen_page.dart';
import 'package:flutter_merraland_online_new/pages/login_page.dart';
import 'package:flutter_merraland_online_new/pages/search_page.dart';
import 'package:flutter_merraland_online_new/StickerPlugin//screens/information_screen.dart';
import 'package:flutter_merraland_online_new/StickerPlugin//screens/sticker_pack_info.dart';
import 'package:flutter_merraland_online_new/StickerPlugin//screens/stickers_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(Main());
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {

  final storage = new FlutterSecureStorage();
  final String _baseUrl = 'https://bukahuni.com';
  final String loginUrl = '/api/login';

  Future _login() async
  {
    
    final response = await http.post(Uri.parse(_baseUrl+loginUrl), body: {
      "username" : 'admin',
      "password" : 'BVNcmx123@',
    });

    return json.decode(response.body);
  }

  void storeToken() async {
    String? token = '';
    token = await storage.read(key: 'token');

    // await storage.deleteAll();

    Future.delayed(Duration(seconds: 3), () {

      if(token == '' || token == null)
      {
        _login().then((value) {
            storage.write(key: 'token', value: value['token']);
            NavigationService().navigateToScreen(beranda_page());
        });

      }
      else
      {
        NavigationService().navigateToScreen(beranda_page());
      }

    });

    // Future.delayed(Duration(seconds: 3), () {
    //   // storage.write(key: 'token', value: '');

    //   if (token != '' && token != null) {
    //     NavigationService().navigateToScreen(beranda_page());
    //   } else {
    //     NavigationService().navigateToScreen(login_page(''));
    //   }
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    storeToken();

  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      //Over here
      navigatorKey: NavigationService().navigationKey,
      initialRoute: 'loadingScreen',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        StickersScreen.routeName: (ctx) => const StickersScreen(),
        StickerPackInfoScreen.routeName: (ctx) => const StickerPackInfoScreen(),
        InformationScreen.routeName: (ctx) => const InformationScreen(),
        'loadingScreen': (context) => loadingScreen_page(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class NavigationService {
  /// Creating the first instance
  static final NavigationService _instance = NavigationService._internal();
  NavigationService._internal();

  /// With this factory setup, any time  NavigationService() is called
  /// within the appication _instance will be returned and not a new instance
  factory NavigationService() => _instance;

  ///This would allow the app to monitor the current screen state during navigation.
  ///
  ///This is where the singleton setup we did
  ///would help as the state is internally maintained
  final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  /// For navigating back to the previous screen
  dynamic goBack([dynamic popValue]) {
    return navigationKey.currentState?.pop(popValue);
  }

  /// This allows you to naviagte to the next screen by passing the screen widget
  Future<dynamic> navigateToScreen(Widget page, {arguments}) async =>
      navigationKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => page,
        ),
      );

  /// This allows you to naviagte to the next screen and
  /// also replace the current screen by passing the screen widget
  Future<dynamic> replaceScreen(Widget page, {arguments}) async =>
      navigationKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (_) => page,
        ),
      );

  /// Allows you to pop to the first screen to when the app first launched.
  /// This is useful when you need to log out a user,
  /// and also remove all the screens on the navigation stack.
  /// I find this very useful
  void popToFirst() =>
      navigationKey.currentState?.popUntil((route) => route.isFirst);
}


// flutter pub run change_app_package_name:main com.bukahuni.hunipro
// flutter pub run flutter_launcher_icons:main
// flutter pub run flutter_app_name 
// Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => discover_page()), (Route<dynamic> route) => false);
// Navigator.push(context, MaterialPageRoute(builder: (context) => discover_page_genre()));
// Navigator.pop(context);
// -keep class com.xraph.plugin.** {*;}

// final List<Widget> imageSliders = imgSliders.asMap().entries.map((entry) {  
    // return  
// }).toList();

// Container(
//   margin: EdgeInsets.symmetric(horizontal: 10),
//   child: Container(
//       width: 120,
//       height: 120,
//       decoration: BoxDecoration(
//         color: blueDarkColor,
//         borderRadius: BorderRadius.circular(10),
//       ),
//     )
// )
