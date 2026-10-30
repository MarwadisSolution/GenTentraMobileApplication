import 'package:dio/dio.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Refresh%20Token/refresh_token.dart';

import '../../Reusable Functions/reusable_functions.dart';
import 'favourite_page_modal.dart';
class FavouriteApi {
  final Dio _dio = apiClient;

  Future<bool> postFavourite(int partyId, String type) async {
    try {
      final response = await _dio.post(
        "$api/api/v1/social/favourites",
        data: {
          "targetType": type,
          "targetId": partyId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("postFavourite error: $e");
      if (type == "POLITICIAN") {
        try {
          final res = await _dio.post(
            "$api/api/v1/social/favourites",
            data: {
              "targetType": "MINISTER",
              "targetId": partyId,
            },
          );
          return res.statusCode == 200 || res.statusCode == 201;
        } catch (e2) {
          print("postFavourite MINISTER fallback error: $e2");
          return false;
        }
      }
      if (type == "COUNTRY") {
        try {
          final res = await _dio.post(
            "$api/api/v1/social/favourites",
            data: {
              "targetType": "CIVIC",
              "targetId": partyId,
            },
          );
          return res.statusCode == 200 || res.statusCode == 201;
        } catch (e2) {
          print("postFavourite CIVIC fallback error: $e2");
          return false;
        }
      }
      return false;
    }
  }

  //--------------------------Delete----
  Future<bool> deleteFavourite(int partyId, String type) async {
    try {
      final response = await _dio.delete(
        "$api/api/v1/social/favourites/$type/$partyId",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("deleteFavourite error: $e");
      if (type == "POLITICIAN") {
        try {
          final res = await _dio.delete(
            "$api/api/v1/social/favourites/MINISTER/$partyId",
          );
          return res.statusCode == 200 || res.statusCode == 201;
        } catch (e2) {
          print("deleteFavourite MINISTER fallback error: $e2");
          return false;
        }
      }
      if (type == "COUNTRY") {
        try {
          final res = await _dio.delete(
            "$api/api/v1/social/favourites/CIVIC/$partyId",
          );
          return res.statusCode == 200 || res.statusCode == 201;
        } catch (e2) {
          print("deleteFavourite CIVIC fallback error: $e2");
          return false;
        }
      }
      return false;
    }
  }

  //------------------------------------Ids---
  Future<List<int>> getFavouritePartyIds(String type) async {
    try {
      final response = await _dio.get(
        "$api/api/v1/social/favourites?targetType=$type",
      );

      if (response.data["success"] == true) {
        final List data = response.data["data"];

        return data
            .map<int>((e) => (e["targetId"] as num).toInt())
            .toList();
      }

      return [];
    } catch (e) {
      print("getFavouritePartyIds error: $e");
      return [];
    }
  }
  Future<List<FavouritePageModal>>getDataOfFavourite(String type)async{
    try{
      final response=await _dio.get("$api/api/v1/social/favourites?targetType=$type"
      );
      if(response.data["success"]==true){
        final List data=response.data["data"];
       // print("Printing:- ${response.data}");
        for (final item in data) {
          print(item);
        }
        return data.map<FavouritePageModal>((item){
          return FavouritePageModal(
              id: item["targetId"]??"-",
              name: item["meta"]["title"]??"-",
              partySymbolUrl: item["meta"]["imageUrl"] ?? "",
            partyInitial: item["meta"]["partyInitial"]??"",
          );
        }).toList();
      }
      return [];
    }
        catch(e){
          print(e);
          return [];
        }
  }
}