import 'package:flutter/material.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/add_feed.dart';
import 'package:gen_tentra_mobile_application/Services/deep_link_service.dart';
import 'package:gen_tentra_mobile_application/splash_screen.dart';
import 'package:gen_tentra_mobile_application/temp_screen_for_url.dart';

import 'Home Page/home_page.dart';
import 'Login Page/otp_page.dart';
final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();
void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DeepLinkService.instance.initialize(navigatorKey: navigatorKey,);
  }
  @override
  void dispose() {
    DeepLinkService.instance.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF666666).withOpacity(0.6),
          onPrimary: Color(0xFFFF5875),
          secondary: Color(0xFFDDDDDD),
          onSecondary: Color(0xFF0C0C0C),
          error: Colors.red,
          onError: Color(0xFF0C0C0C),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF000000),
        ),
      ),
       home:
       //AddFeed()
       SplashScreen()

    );
  }
}
