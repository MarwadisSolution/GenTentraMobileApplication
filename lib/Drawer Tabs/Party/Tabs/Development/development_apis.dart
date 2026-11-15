import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Development/development_model.dart';

import '../../../../Login Page/Refresh Token/refresh_token.dart';
import '../../../../Reusable Functions/reusable_functions.dart';
import '../../party_page_modal.dart';

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
        queryParameters: {"page": page, "size": size},
      );

      final List data = response.data["data"]["items"];
      return data.map((e) => DevelopmentModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }


  Future<DevelopmentModel> postTheDevelopment({
    required DevelopmentModel development,
    required List<File> mediaFiles,
  }) async {
    try {
      FormData formData = FormData();

      // JSON Data
      formData.fields.add(
        MapEntry(
          "data",
          jsonEncode(development.toJson()),
        ),
      );

      // Media Files
      for (File file in mediaFiles) {
        formData.files.add(
          MapEntry(
            "media",
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post(
        "$api/api/v1/developments",
        data: formData,
      );

      return DevelopmentModel.fromJson(
        Map<String, dynamic>.from(response.data["data"]),
      );

    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }
  Future<List<LeaderModel>>searchBarData(String? query,int? id)async{

    final response=await _dio.get("$api/api/v1/profile/politicians?&",
        queryParameters: {
          "partyId":?id,
          "q":?query,

        }
    );
    final items=response.data["data"]["items"] as List;
    return items
        .map((e)=>LeaderModel.fromJson(e)).toList();
  }
  Future<String>deleteDevelopment(int? id)async{
    final response=await _dio.delete("$api/api/v1/developments/$id"
    );
    if(response.statusCode==200 || response.statusCode==201){
      if(response.data["success"]==true) return "Successfully post deleted";
    }
    return "Unable to delete post, try again";
  }
}
