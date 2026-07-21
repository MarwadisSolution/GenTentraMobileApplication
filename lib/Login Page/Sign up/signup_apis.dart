import 'package:dio/dio.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_modal.dart';

import '../../Reusable Functions/reusable_functions.dart';
import '../Refresh Token/refresh_token.dart';

class SignupApis {
  final Dio _dio = apiClient;

  Future<Response> signUp(
      String verificationToken,
      SignUpModal data,
      ) async {
      final response = await _dio.post(
        "$api/api/v1/auth/phone/complete",

        data: {
          "verificationToken": verificationToken,
          "firstName": data.firstName,
          "surname": data.surname,
          "coverUrl": data.coverUrl,
          "gender": data.gender,
          "country": data.country,
          "state": data.state,
          "city": data.city,
          "area": data.area,
        },
      );
      return response;
  }
}