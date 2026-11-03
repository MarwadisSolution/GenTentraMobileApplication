import 'package:dio/dio.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Development/development_model.dart';

import '../../../../Login Page/Refresh Token/refresh_token.dart';
import '../../../../Reusable Functions/reusable_functions.dart';

class DevelopmentApis {
  final Dio _dio = apiClient;

  // --------------------------------------------------
  // GET DEVELOPMENT LIST
  // --------------------------------------------------

  Future<List<DevelopmentModel>> getTheDevelopment({
    required int id,
    int page = 0,
    int size = 20,
    required String fromWhichPage,
  }) async {
    try {
      final response = await _dio.get(
        fromWhichPage == "Party"
            ? "$api/api/v1/developments/parties/$id"
            : "$api/api/v1/developments/politicians/$id",
        queryParameters: {
          "page": page,
          "size": size,
        },
      );

      final List data = response.data["data"]["items"];

      return data
          .map((e) => DevelopmentModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }
}