import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../Login Page/Refresh Token/refresh_token.dart';
import '../../../../Reusable Functions/reusable_functions.dart';
import 'feed_model.dart';

class FeedApis {
  final Dio _dio = apiClient;

  /// POST Feed
  Future<FeedModel> postTheFeed({
    required FeedModel feed,
    required List<File> mediaFiles,
  }) async {
    try {
      FormData formData = FormData();

      /// JSON Data
      formData.fields.add(
        MapEntry(
          "data",
          jsonEncode(feed.toJson()),
        ),
      );

      /// Media Files
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
        "$api/api/v1/feed/posts",
        data: formData,
      );

      return FeedModel.fromJson(response.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  /// GET Feed List
  Future<List<FeedModel>> getFeeds({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        "$api/api/v1/feed/posts",
        queryParameters: {
          "page": page,
          "size": size,
        },
      );

      final List data = response.data["data"]["items"];

      return data.map((e) => FeedModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }
}