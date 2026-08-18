import 'dart:convert';

import 'package:dio/dio.dart';


import '../Reusable Functions/Drawer/profile_data_cache.dart';
import '../Reusable Functions/reusable_functions.dart';
import 'Refresh Token/refresh_token.dart';
class LoginApi{
  final Dio _dio = apiClient;

  Future<void>otpRequest(String number)async{
    print("abcd");
    print("Number:- $number");
    final response=await _dio.post("$api/api/v1/auth/phone/start",

        data: jsonEncode({
          "phone": number,
        })
    );
    print("Yes");
    print(response.data);
    print(response.statusCode);
    print(response.data["data"]["devCode"]);
    if(response.data["success"]==false) {
      print(response.data["error"]["message"]);
      throw Exception(response.data["error"]["message"]);
    }
    print("Full log data");
    print(jsonEncode(response.data));
    print(response.data);
    print(response.statusCode);
  }
  Future<Map<String, dynamic>> otpVerify(
      String number,
      String otp,
      ) async {
    print("Number: $number");

    int intOTP=int.parse(otp);

    try{
      final response = await _dio.post(
      "${api}/api/v1/auth/phone/verify",

      data: jsonEncode({
        "phone": number,
        "code": otp,
      }),
    );
    print("I am here");
    print("Response:- ${response.data}");
    if (response.data["success"] == false) {
      final message =
          response.data["error"]?["message"] ?? "Unknown error";
      throw Exception(message);
    }

    return {
      "verificationToken":
      response.data["data"]["verificationToken"],
      "isNewUser":
      response.data["data"]["isNewUser"],
      "requirePassword":response.data["data"]["requiresPassword"],
    };
    }
    on DioException catch(e){
      print("Dio Error: ${e.type}");
      rethrow;
    }
  }
  Future<Map<String, dynamic>>passwordVerification(String verificationToken, String? password)async{
    final Map<String, dynamic> body = {
      "verificationToken": verificationToken,
    };

    if (password != null && password.isNotEmpty) {
      body["password"] = password;
    }
    final response=await _dio.post("$api/api/v1/auth/phone/complete",

        data: jsonEncode(body)
    );
    print("Response Of Login: ${response.data}");
    print("Admin:- ${response.data["data"]["partyId"].toString()}");
    if(response.data["success"]==false){
      print(response.statusCode);
    }
    return response.data["data"];
  }

  ///------------------------Profile Data---------------
  final ProfileCache profileCache = ProfileCache();

  Future<Map<String, dynamic>> profileData({
    bool forceRefresh = false,
  }) async {

    try {

      // Return cached data first
      if(!forceRefresh){
        final cached = await profileCache.getProfile();
        if(cached != null){
          return cached;
        }
      }

      final response = await _dio.get(
        "$api/api/v1/profile/me",
      );

      if(response.statusCode == 200 || response.statusCode == 201){

        final data = Map<String,dynamic>.from(response.data["data"]);

        // Save latest profile
        await profileCache.saveProfile(data);

        return data;
      }

      return {"Error":"Failed"};

    }catch(e){

      print(e);

      // If API fails return cache
     final cached = await profileCache.getProfile();

      if(cached != null){
        return cached;
      }

      return {"Error":"Failed"};
    }
  }
}