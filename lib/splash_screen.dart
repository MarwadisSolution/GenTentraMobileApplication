import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Home%20Page/home_page.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_bloc.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_modal.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Refresh%20Token/refresh_token.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/login_apis.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/otp_page.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Sign%20up/signup_page.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/verify_otp_page.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Login Page/password_verification_page.dart';
import 'Reusable Functions/Bottom Navigation/bloc_conde_in_one_navigation.dart';
import 'Reusable Functions/Bottom Navigation/main_page.dart';
import 'Reusable Functions/Drawer/bloc_code_in_one.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isUserInDatabase = false;
  bool isUserLogOut = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();

    ///------------for is user present in database call the api and check
    // Future.delayed(const Duration(seconds: 5), () {
    //   if (mounted) {
    //     isUserInDatabase ?
    //     isUserLogOut == false ?
    //     //HomePage():OtpPage():LoginPage()
    //     Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) =>
    //                 BlocProvider(create: (context) =>
    //                     LoginBloc(LoginRepository(LoginApi())),
    //                   child: const OtpPage(),)
    //         )) :
    //     Navigator.pushReplacement(
    //         context, MaterialPageRoute(builder: (context) => const OtpPage())) :
    //     // Navigator.pushReplacement(
    //     //   context,
    //     //   MaterialPageRoute(
    //     //     builder: (_) => BlocProvider(
    //     //       create: (_) => LoginBloc(
    //     //         LoginRepository(LoginApi()),
    //     //       ),
    //     //       child: const SignupPage(),
    //     //     ),
    //     //   ),
    //     // );
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (_) =>
    //             BlocProvider(
    //               create: (_) =>
    //                   LoginBloc(
    //                     LoginRepository(LoginApi()),
    //                   ),
    //               child: const OtpPage(),
    //             ),
    //       ),
    //     );
    //     // Navigator.pushReplacement(
    //     //   context,
    //     //   MaterialPageRoute(builder: (_)=>HomePage())
    //     // MaterialPageRoute(
    //     //   builder: (context) => BlocProvider(
    //     //     create: (context) => LoginBloc(
    //     //       LoginRepository(LoginApi()),
    //     //     ),
    //     //     child: const SignupPage(),
    //     //   ),
    //     // ),
    //     // Navigator.pushReplacement(
    //     //   context,
    //     //   MaterialPageRoute(
    //     //     builder: (_) => MultiBlocProvider(
    //     //       providers: [
    //     //         BlocProvider(
    //     //           create: (_) => BottomNavBloc(),
    //     //         ),
    //     //         BlocProvider(
    //     //           create: (_) => DrawerBloc(),
    //     //         ),
    //     //       ],
    //     //       child: MainPage(),
    //     //     ),
    //     //   ),
    //     // );
    //
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: GradientColors.primaryGradient,
        ),
        child: Center(
          child: SvgPicture.asset("Assets/GenTantraLogo.svg"),
        ),
      ),
    );
  }
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    print("refreshToken = ${prefs.getString("refreshToken")}");
    print("accessToken = ${prefs.getString("accessToken")}");
    print("isLogged = ${prefs.getBool("isLogged")}");

    await Future.delayed(const Duration(seconds: 2));
    if(!mounted)return;
    //final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString("refreshToken");
    if (refreshToken == null || refreshToken.isEmpty) {
      goToLogin();
      return;
    }
    final success = await authService.refreshAccessToken();
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>
          MultiBlocProvider(providers: [
            BlocProvider(create: (_) => BottomNavBloc(),
            ),
            BlocProvider(create: (_) => DrawerBloc(),
            )
          ],
            child: MainPage(),
          )
      )
      );
    }
    else {
      await logoutUser();
      goToLogin();
    }
  }

  void goToLogin() {
    if(!mounted)return;
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => PasswordVerificationPage(verificationToken: ""),
    //   ),
    // );
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>
        BlocProvider(create: (_) => LoginBloc(LoginRepository(LoginApi()),
        ),
          child: const SignupPage(),
        )
    )
    );
  }
}

