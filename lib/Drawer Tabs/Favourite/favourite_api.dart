import 'package:dio/dio.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Favourite/favourite_page_modal.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Refresh%20Token/refresh_token.dart';

import '../../Reusable Functions/reusable_functions.dart';
class FavouriteApi {
  final Dio _dio = apiClient;

  Future<void> postFavourite(int partyId) async {
    try {
      await _dio.post(
        "$api/api/v1/social/favourites",
        data: {
          "targetType": "PARTY",
          "targetId": partyId,
        },
      );
    } catch (e) {
      print(e);
    }
  }
  //--------------------------Delete----
  Future<void> deleteFavourite(int partyId) async {
    try {
      await _dio.delete(
        "$api/api/v1/social/favourites/PARTY/$partyId",
      );
    } catch (e) {
      print(e);
    }
  }
  //------------------------------------Ids---
  Future<List<int>> getFavouritePartyIds() async {
    try {
      final response = await _dio.get(
        "$api/api/v1/social/favourites?targetType=PARTY",
      );

      if (response.data["success"] == true) {
        final List data = response.data["data"];

        return data
            .map<int>((e) => e["targetId"] as int)
            .toList();
      }

      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }
  Future<List<FavouritePageModal>>getDataOfFavourite()async{
    try{
      final response=await _dio.get("$api/api/v1/social/favourites?targetType=PARTY"
      );
      if(response.data["success"]==true){
        final List data=response.data["data"];
        print("Printing:- ${response.data}");
        for (final item in data) {
          print(item);
        }
        return data.map<FavouritePageModal>((item){
          return FavouritePageModal(
              id: item["targetId"]??"-",
              name: item["meta"]["title"]??"-",
              partySymbolUrl: item["meta"]["imageUrl"] ?? "",
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