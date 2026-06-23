import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../Reusable Functions/reusable_functions.dart';
class LoginApi{
  final Dio _dio=Dio(
      BaseOptions(
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      )
  );
//{ "phone": "+919552936422", "purpose": "LOGIN" }
  Future<String>otpRequest(String number)async{
    print("abcd");
    (number.startsWith("+91"))?number=number.substring(3):number;
    print("Number:- $number");
    final response=await _dio.post("$api/api/v1/auth/phone/start",

        options: Options(
            headers: {
              'Content-Type': 'application/json'
            }
        ),
        data: jsonEncode({
          "phone": "+91$number",
        })
      // {
      // "success": true,
      // "data": {
      // "phone": "+919876543210",
      // "expiresInSeconds": 300,
      // "resendInSeconds": 30,
      // "devCode": "466230"
      // },
      // "traceId": "40857c19-8f5f-40e4-9e8f-a31765365518",
      // "ts": "2026-05-24T17:31:43.006365552Z"
      // }
    );
    print(response.data["data"]["devCode"]);
    if(response.data["success"]==false) {
      print(response.data["error"]["message"]);
      throw Exception(response.data["error"]["message"]);
    }
    return response.data["data"]["devCode"];
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
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
      data: jsonEncode({
        "phone": "+91$number",
        "code": intOTP,
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
    };
    }
    on DioException catch(e){
      print("Dio Error: ${e.type}");
      print("Message: ${e.message}");
      print("Response: ${e.response?.data}");
      rethrow;
    }

  }
  Future<Map<String, dynamic>>passwordVerification(String verificationToken, String password)async{
    final response=await _dio.post("$api/api/v1/auth/phone/complete",
        options: Options(
          headers: {
            'Content-Type': 'application/json'
          },
        ),
        data: jsonEncode({
          "verificationToken":verificationToken,
          "password":password,
        })
    );
    if(response.data["success"]==false){

    }
    return response.data["data"];
  }

}