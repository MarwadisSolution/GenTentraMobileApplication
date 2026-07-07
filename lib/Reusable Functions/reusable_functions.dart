import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gal/gal.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

String api = "https://visibility-justify-annual-maine.trycloudflare.com";

Future<String?> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("accessToken");
}
///--------------For background color----------------
class GradientColors {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [ Color(0xFFFE3A31),Color(0xFFFD8454),],
  );
}
class GradientColorsForBellowAppbar {
  static const LinearGradient gradientBelowAppbar = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [ Color(0xFFFE3A31),Color(0xFFFD8454)],
  );
}
//------------------------------------------------------
const SizedBox h10 = SizedBox(height: 10);
const SizedBox h20 = SizedBox(height: 20);
const SizedBox w10 = SizedBox(width: 10);
const SizedBox w5 = SizedBox(width: 5);
const SizedBox w30 = SizedBox(width: 30);
///----------------App bar
Future<void> logoutUser() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove("accessToken");
  await prefs.remove("refreshToken");
  await prefs.remove("userUuid");
  await prefs.remove("loginTime");
  await prefs.setBool("isLogged", false);
}
//----------------------------------------------
class AppbarPage extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  const AppbarPage({
    super.key,
    required this.title,
    this.leading,
    this.automaticallyImplyLeading = false,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // centerTitle: true,
      automaticallyImplyLeading: automaticallyImplyLeading,
      iconTheme: IconThemeData(color: ColorScheme.of(context).surface),

      leadingWidth: 60,
      //-------------------------------------------------------------------------------------
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: GradientColors.primaryGradient,
        ),
      ),
      title:
      Padding(
        padding: EdgeInsets.only(top: 12,bottom: 20),
        child: Text(
          title,
          style: TextStyle(
            color: ColorScheme.of(context).surface,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      leading: leading!=null?
      Padding(padding: EdgeInsets.only(left: 20,bottom: 20),child: leading,):null,
      actions:[
        IconButton(
          onPressed: (){},
          icon: SvgPicture.asset("Assets/appBar&NavBar/plusIcon.svg"),
        ),
        IconButton(
          onPressed: (){},
          icon: SvgPicture.asset("Assets/appBar&NavBar/bellIcon.svg"),
        )
      ]
    );
  }
}
///----------Text Field-----
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isRequired;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final TextStyle? textStyle;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.isRequired = false,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.textStyle,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,

  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      cursorColor: ColorScheme.of(context).onSurface,
      style: textStyle ??
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
      maxLength: maxLength,
      decoration: InputDecoration(
        counterText: "",
        label: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: labelText,
                style: TextStyle(
                  color: ColorScheme.of(context).onSurface.withOpacity(0.3),
                ),
              ),
              if (isRequired)
                const TextSpan(
                  text: " *",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(
          color: ColorScheme.of(context).onSurface.withOpacity(0.3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ColorScheme.of(context).onSurface.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ColorScheme.of(context).onSurface.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
}
///---------------Image Download----
Future<void> downloadImage(String imageUrl) async {
  try {
    final response = await Dio().get(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    await Gal.putImageBytes(
      response.data,
      name: "logo_${DateTime.now().millisecondsSinceEpoch}",
    );

    print("Image saved successfully");
  } catch (e) {
    print("Error: $e");
  }
}