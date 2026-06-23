import 'package:flutter/material.dart';
import 'package:gen_tentra_mobile_application/splash_screen.dart';

import 'Home Page/home_page.dart';
import 'Login Page/otp_page.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
       home: SplashScreen()

    );
  }
}
