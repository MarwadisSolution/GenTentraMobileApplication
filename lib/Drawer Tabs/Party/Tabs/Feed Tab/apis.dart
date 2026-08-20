import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

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
  required int partyId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        "$api/api/v1/feed/parties/${partyId}/posts",
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
  ///--------------React
  Future<bool>likeThePost(int feedId)async{
    final response=await _dio.post("$api/api/v1/feed/posts/$feedId/like");
    if(response.statusCode==200 || response.statusCode==201){
      return true;
    }
    return false;
  }
  ///----------Search of political leaders
  Future<List<LeaderModel>>searchBarData(String? query,int? id)async{

    final response=await _dio.get("$api/api/v1/profile/politicians?&",
        queryParameters: {
          if(id!=null)
            "partyId":id,
          if(query!=null)
            "q":query,
          // "designation":query,
          // "region":query,
          // "partyId":query,
        }
    );
    final items=response.data["data"]["items"] as List;
    return items
        .map((e)=>LeaderModel.fromJson(e)).toList();
  }
  Future<String>deletePost(int id)async{
    final response=await _dio.delete("$api/api/v1/feed/posts/$id",
    );
    if(response.statusCode==200 || response.statusCode==201){
      if(response.data["success"]==true) return "Successfully post deleted";
    }
     return "Unable to delete post, try again";
  }
  /// UPDATE Feed / Quote
  Future<FeedModel> updateThePost({
    required FeedModel feed,
    required List<int> deletedMediaIds,
  }) async {
    try {
      final Map<String, dynamic> data = feed.toJson();

      // Add deleted media IDs only if there are any
      if (deletedMediaIds.isNotEmpty) {
        data["deletedMediaIds"] = deletedMediaIds;
      }

      debugPrint("PATCH DATA:");
      debugPrint(jsonEncode(data));

      final response = await _dio.patch(
        "$api/api/v1/feed/posts/${feed.id}",
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      return FeedModel.fromJson(
        response.data["data"],
      );
    } on DioException catch (e) {
      debugPrint("PATCH API ERROR: ${e.response?.data}");

      throw Exception(
        e.response?.data ?? e.message,
      );
    }
  }

}

