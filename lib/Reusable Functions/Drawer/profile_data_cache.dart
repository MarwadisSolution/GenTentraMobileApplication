import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileCache {
  static const String _profileKey = "cached_profile";

  Future<void>saveProfile(Map<String,dynamic> profile) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_profileKey, jsonEncode(profile));
  }

  Future<Map<String,dynamic>?>getProfile() async {
    final pref = await SharedPreferences.getInstance();

    final data = pref.getString(_profileKey);

    if(data == null) return null;

    return Map<String,dynamic>.from(jsonDecode(data));
  }

  Future<void>clearProfile() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(_profileKey);
  }
}