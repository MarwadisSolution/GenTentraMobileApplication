import 'dart:convert';
import 'dart:io';
import 'dart:math';

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

      eventJson["authorPartyId"] = partyId;

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
      print("DATA: ${formData}");
      print("Media files: ${mediaFiles?.length}");
      print("BG image: ${bgImage?.path}");

      final response = await _dio.post(
        "$api/api/v1/events",
        data: formData,
      );
      print("----------------------");
      print(response.statusCode);
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
  Future<AttendeePaginationResponse> attendanceData(
      int eventId,
      int page,
      int size,
      ) async {
    try {
      final response = await _dio.get(
        "$api/api/v1/events/$eventId/attendees",
        queryParameters: {
          "page": page,
          "size": size,
        },
      );

      final responseData = response.data;

      final data = responseData["data"] as Map<String, dynamic>;

      // ----------------------------------------------------------
      // ITEMS
      // ----------------------------------------------------------

      final List<AttendeePreview> attendees =
      (data["items"] as List? ?? [])
          .map(
            (item) => AttendeePreview.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList();

      // ----------------------------------------------------------
      // COUNTS
      // ----------------------------------------------------------

      final counts =
          data["counts"] as Map<String, dynamic>? ?? {};

      final int goingCount =
          (counts["GOING"] as num?)?.toInt() ?? 0;

      final int interestedCount =
          (counts["INTERESTED"] as num?)?.toInt() ?? 0;

      final int declinedCount =
          (counts["DECLINED"] as num?)?.toInt() ?? 0;

      // ----------------------------------------------------------
      // META
      // ----------------------------------------------------------

      final meta =
          data["meta"] as Map<String, dynamic>? ?? {};

      final int currentPage =
          (meta["page"] as num?)?.toInt() ?? page;

      final int currentSize =
          (meta["size"] as num?)?.toInt() ?? size;

      final int totalElements =
          (meta["totalElements"] as num?)?.toInt() ?? 0;

      final int totalPages =
          (meta["totalPages"] as num?)?.toInt() ?? 0;

      // ----------------------------------------------------------
      // HAS NEXT
      // ----------------------------------------------------------

      final bool hasNext =
          currentPage + 1 < totalPages;

      return AttendeePaginationResponse(
        items: attendees,
        page: currentPage,
        size: currentSize,
        totalItems: totalElements,
        totalPages: totalPages,
        hasNext: hasNext,
        goingCount: goingCount,
        interestedCount: interestedCount,
        declinedCount: declinedCount,
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?["message"] ??
              e.message ??
              "Failed to fetch attendees";

      throw Exception(message);
    } catch (e) {
      throw Exception(
        "Failed to fetch attendees: $e",
      );
    }
  }
  Future<String> deleteEvent(int eventId) async {
    try {
      final response = await _dio.delete(
        "$api/api/v1/events/$eventId",
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        return response.data?["message"] ??
            "Event deleted successfully";
      }

      return "Unable to delete event, please try again";
    } on DioException catch (e) {
      print("========== DELETE EVENT ERROR ==========");
      print("STATUS CODE: ${e.response?.statusCode}");
      print("RESPONSE DATA: ${e.response?.data}");
      print("REQUEST URL: ${e.requestOptions.uri}");

      final message =
          e.response?.data?["message"] ??
              e.message ??
              "Failed to delete event";

      throw Exception(message);
    } catch (e) {
      throw Exception("Failed to delete event: $e");
    }
  }
  Future<EventModel> updateTheEvent({
    required int eventId,
    required EventModel event,
    List<File>? mediaFiles,
    File? bgImage,
    List<int>? deletedMediaIds,
    List<Tagged>? removeTags,
    bool removeBackgroundImage = false,
  }) async {
    print("========== updateTheEvent() HIT ==========");

    try {
      final FormData formData = FormData();

      // ----------------------------------------------------------
      // EVENT JSON
      // ----------------------------------------------------------

      final Map<String, dynamic> eventJson = event.toJson();

      // ----------------------------------------------------------
      // REMOVED MEDIA
      // ----------------------------------------------------------

      eventJson["removeMediaIds"] = deletedMediaIds ?? [];

      // ----------------------------------------------------------
      // REMOVED TAGS
      // ----------------------------------------------------------

      eventJson["removeTags"] =
          removeTags?.map((tag) => tag.toJson()).toList() ?? [];

      // ----------------------------------------------------------
      // REMOVED BACKGROUND IMAGE
      // ----------------------------------------------------------

      eventJson["removeBackgroundImage"] = removeBackgroundImage;

      // ----------------------------------------------------------
      // DEBUG
      // ----------------------------------------------------------

      print("========== UPDATE EVENT DATA ==========");
      print("Event ID: $eventId");
      print("removeMediaIds: ${eventJson["removeMediaIds"]}");
      print("removeTags: ${eventJson["removeTags"]}");
      print(
        "removeBackgroundImage: "
            "${eventJson["removeBackgroundImage"]}",
      );
      print("======================================");

      // ----------------------------------------------------------
      // DATA FIELD
      // ----------------------------------------------------------

      formData.fields.add(
        MapEntry(
          "data",
          jsonEncode(eventJson),
        ),
      );

      // ----------------------------------------------------------
      // NEW MEDIA
      // ----------------------------------------------------------

      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        for (final File file in mediaFiles) {
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
      }

      // ----------------------------------------------------------
      // NEW BACKGROUND IMAGE
      // ----------------------------------------------------------

      if (bgImage != null) {
        formData.files.add(
          MapEntry(
            "bgImage",
            await MultipartFile.fromFile(
              bgImage.path,
              filename: bgImage.path.split('/').last,
            ),
          ),
        );
      }

      print("New media count: ${mediaFiles?.length ?? 0}");
      print("Deleted media IDs: ${deletedMediaIds ?? []}");
      print("New background: ${bgImage?.path}");
      print("Remove background: $removeBackgroundImage");

      // ----------------------------------------------------------
      // PATCH REQUEST
      // ----------------------------------------------------------

      final response = await _dio.patch(
        "$api/api/v1/events/$eventId",
        data: formData,
      );

      print("Update status: ${response.statusCode}");
      print("Update response: ${response.data}");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return EventModel.fromJson(
          response.data["data"],
        );
      }

      throw Exception(
        response.data?["message"] ??
            "Failed to update event",
      );
    } on DioException catch (e) {
      print("========== UPDATE EVENT DIO ERROR ==========");
      print("STATUS CODE: ${e.response?.statusCode}");
      print("RESPONSE DATA: ${e.response?.data}");
      print("REQUEST URL: ${e.requestOptions.uri}");
      print("REQUEST DATA: ${e.requestOptions.data}");

      final message =
          e.response?.data?["message"] ??
              e.message ??
              "Failed to update event";

      throw Exception(message);
    } catch (e) {
      print("========== UPDATE EVENT ERROR ==========");
      print(e);

      throw Exception(
        e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }
}