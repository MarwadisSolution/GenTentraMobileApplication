import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_modal.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Refresh%20Token/refresh_token.dart';

import '../../../../Reusable Functions/reusable_functions.dart';


class EventApis{
  final Dio _dio= apiClient;
  Future<EventModel> postTheEvent({
    required EventModel event,
    required int partyId,
    List<File>?mediaFiles,
    File? bgImage,
})async{
    print("========== postTheEvent() HIT ==========");
    try{
      FormData formData=FormData();
      final eventJson = event.toJson();

      eventJson["partyId"] = partyId;

      formData.fields.add(
        MapEntry(
          "data",
          jsonEncode(eventJson),
        ),
      );
      ///--------MediaFiles
      if (mediaFiles!=null) {
        for (File file in mediaFiles) {
          formData.files.add(
            MapEntry("media",
              await MultipartFile.fromFile(
                file.path,
                filename: file.path
                    .split('/')
                    .last,
              ),
            ),
          );
        }
      }
      if(bgImage!=null) {
        formData.files.add(
          MapEntry(
            "bgImage",
            await MultipartFile.fromFile(
              bgImage.path,
              filename: bgImage.path
                  .split('/')
                  .last,
            ),
          ),
        );
      }
      print("========== ABOUT TO SEND POST REQUEST ==========");
      print("URL: $api/events");
      print("DATA: ${jsonEncode(eventJson)}");
      print("Media files: ${mediaFiles?.length}");
      print("BG image: ${bgImage?.path}");

      final response = await _dio.post(
        "$api/api/v1/events",
        data: formData,
      );
      print("----------------------");
      print(response);
      return EventModel.fromJson(response.data["data"]);
    }
    on DioException catch (e) {
      print("========== DIO ERROR ==========");
      print("STATUS CODE: ${e.response?.statusCode}");
      print("RESPONSE DATA: ${e.response?.data}");
      print("RESPONSE HEADERS: ${e.response?.headers}");
      print("REQUEST URL: ${e.requestOptions.uri}");
      print("REQUEST METHOD: ${e.requestOptions.method}");
      print("REQUEST DATA: ${e.requestOptions.data}");
      print("ERROR MESSAGE: ${e.message}");

      final message =
          e.response?.data?["message"] ??
              e.message ??
              "Failed to create event";

      throw Exception(message);
    } catch (e) {
      throw Exception("Failed to create event: $e");
    }
  }
  Future<EventModel> getTheEvent({
    required int partyId,
  }) async {
    try {
      final response = await _dio.get(
        "$api/events?partyId=$partyId",
      );

      return EventModel.fromJson(
        response.data["data"],
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?["message"] ??
              e.message ??
              "Failed to fetch event";

      throw Exception(message);
    } catch (e) {
      throw Exception(
        "Failed to fetch event: $e",
      );
    }
  }
}