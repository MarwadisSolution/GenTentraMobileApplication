import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_modal.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Refresh%20Token/refresh_token.dart';

import '../../../../Reusable Functions/reusable_functions.dart';

class EventPaginationResponse {
  final List<EventModel> items;
  final int page;
  final int size;
  final int totalItems;
  final int totalPages;
  final bool hasNext;

  EventPaginationResponse({
    required this.items,
    required this.page,
    required this.size,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
  });
}

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
  ///--------------------------------
  Future<EventPaginationResponse> getTheEvents({
    required int partyId,
    required int page,
    required int size,
  }) async {
    try {
      final response = await _dio.get(
        "$api/api/v1/events",

        queryParameters: {
          "partyId": partyId,
          "page": page,
          "size": size,
        },
      );

      final data = response.data["data"];

      final List<EventModel> events =
      (data["items"] as List)
          .map(
            (item) => EventModel.fromJson(item),
      )
          .toList();

      return EventPaginationResponse(
        items: events,
        page: data["page"],
        size: data["size"],
        totalItems: data["totalItems"],
        totalPages: data["totalPages"],
        hasNext: data["hasNext"],
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?["message"] ??
              e.message ??
              "Failed to fetch events";

      throw Exception(message);
    } catch (e) {
      throw Exception(
        "Failed to fetch events: $e",
      );
    }
  }
  Future<String>joinUnJoinEvent(int eventId)async{
    final response= await _dio.post("$api/api/v1/events/$eventId/join",
    );
    if(response.statusCode==200 || response.statusCode==201){
      return "Successfully joined the event";
    }
    return "Unable to join, please try again";
  }

}