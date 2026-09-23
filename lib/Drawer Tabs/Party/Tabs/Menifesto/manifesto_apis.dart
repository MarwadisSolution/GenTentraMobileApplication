import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../../../Login Page/Refresh Token/refresh_token.dart';
import '../../../../Reusable Functions/reusable_functions.dart';
import '../../../../media_upload_api.dart';
import 'manifesto_model.dart';

class ManifestoApis {
  final Dio _dio = apiClient;

  final MediaUploadApi _mediaUploadApi = MediaUploadApi();

  // ============================================================
  // POST MANIFESTO
  // ============================================================

  Future<ManifestoModel> postManifesto({
    required ManifestoModel manifesto,
    String? filePath,
  }) async {
    try {
      String? uploadedFileUrl;

      // ========================================================
      // STEP 1: UPLOAD FILE
      // ========================================================

      if (filePath != null && filePath.trim().isNotEmpty) {
        debugPrint("STEP 1: Uploading manifesto file...");

        final List<String> uploadedUrls =
        await _mediaUploadApi.uploadMedia(
          filePaths: [filePath],
          category: "manifesto",
        );

        if (uploadedUrls.isEmpty) {
          throw Exception(
            "File upload failed. No URL returned.",
          );
        }

        uploadedFileUrl = uploadedUrls.first;

        debugPrint(
          "Uploaded manifesto URL: $uploadedFileUrl",
        );
      }

      // ========================================================
      // STEP 2: CREATE MANIFESTO JSON
      // ========================================================

      final Map<String, dynamic> data = manifesto.toJson();

      // Put uploaded URL into fileUrl
      if (uploadedFileUrl != null) {
        data["fileUrl"] = uploadedFileUrl;
      }

      debugPrint("STEP 2: Manifesto JSON:");
      debugPrint(jsonEncode(data));

      // ========================================================
      // STEP 3: POST MANIFESTO
      // ========================================================

      final FormData formData = FormData();

      formData.fields.add(
        MapEntry(
          "data",
          jsonEncode(data),
        ),
      );

      debugPrint("STEP 3: Creating manifesto...");

      final response = await _dio.post(
        "$api/api/v1/manifestos",
        data: formData,
      );

      debugPrint("MANIFESTO RESPONSE:");
      debugPrint(response.data.toString());

      return ManifestoModel.fromJson(
        response.data["data"],
      );
    } on DioException catch (e) {
      debugPrint(
        "POST MANIFESTO API ERROR: ${e.response?.data}",
      );

      throw Exception(
        e.response?.data ?? e.message,
      );
    } catch (e) {
      debugPrint(
        "POST MANIFESTO ERROR: $e",
      );

      throw Exception(e.toString());
    }
  }

  // ============================================================
  // GET MANIFESTOS
  // ============================================================

  Future<List<ManifestoModel>> getManifestos({
    int? partyId,
    int? politicianId,
    int? year,
    String? kind,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        "$api/api/v1/manifestos",
        queryParameters: {
          if (partyId != null)
            "partyId": partyId,

          if (politicianId != null)
            "politicianId": politicianId,

          if (year != null)
            "year": year,

          if (kind != null &&
              kind.trim().isNotEmpty)
            "kind": kind,

          if (search != null &&
              search.trim().isNotEmpty)
            "search": search,

          "page": page,
          "size": size,
        },
      );

      debugPrint(
        "GET MANIFESTOS RESPONSE:",
      );

      debugPrint(
        response.data.toString(),
      );

      final List data =
      response.data["data"]["items"] as List;

      return data
          .map(
            (e) => ManifestoModel.fromJson(e),
      )
          .toList();
    } on DioException catch (e) {
      debugPrint(
        "GET MANIFESTOS API ERROR: "
            "${e.response?.data}",
      );

      throw Exception(
        e.response?.data ?? e.message,
      );
    }
  }

  // ============================================================
  // GET MANIFESTOS - PAGINATION
  // ============================================================

  Future<ManifestoPaginationResponse>
  getManifestosPaginated({
    int? partyId,
    int? politicianId,
    int? year,
    String? kind,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        "$api/api/v1/manifestos",
        queryParameters: {
          if (partyId != null)
            "partyId": partyId,

          if (politicianId != null)
            "politicianId": politicianId,

          if (year != null)
            "year": year,

          if (kind != null &&
              kind.trim().isNotEmpty)
            "kind": kind,

          if (search != null &&
              search.trim().isNotEmpty)
            "search": search,

          "page": page,
          "size": size,
        },
      );

      return ManifestoPaginationResponse.fromJson(
        response.data["data"],
      );
    } on DioException catch (e) {
      debugPrint(
        "GET MANIFESTOS PAGINATION ERROR: "
            "${e.response?.data}",
      );

      throw Exception(
        e.response?.data ?? e.message,
      );
    }
  }
  // ============================================================
// DELETE MANIFESTO
// ============================================================

  Future<void> deleteManifesto({
    required int manifestoId,
  }) async {
    try {
      debugPrint(
        "DELETE MANIFESTO: $api/api/v1/manifestos/$manifestoId",
      );

      final response = await _dio.delete(
        "$api/api/v1/manifestos/$manifestoId",
      );

      debugPrint("DELETE MANIFESTO RESPONSE:");
      debugPrint(response.data.toString());

      // Usually DELETE returns 200 or 204
      if (response.statusCode != 200 &&
          response.statusCode != 204) {
        throw Exception(
          "Failed to delete manifesto.",
        );
      }
    } on DioException catch (e) {
      debugPrint(
        "DELETE MANIFESTO API ERROR: ${e.response?.data}",
      );

      throw Exception(
        e.response?.data ?? e.message,
      );
    } catch (e) {
      debugPrint(
        "DELETE MANIFESTO ERROR: $e",
      );

      throw Exception(e.toString());
    }
  }
  // ============================================================
// UPDATE MANIFESTO
// ============================================================

// ============================================================
// UPDATE MANIFESTO
// ============================================================

  Future<ManifestoModel> updateManifesto({
    required ManifestoModel manifesto,
    String? filePath,
  }) async {
    try {
      String? uploadedFileUrl;

      // ========================================================
      // STEP 1: UPLOAD NEW PDF ONLY IF SELECTED
      // ========================================================

      if (filePath != null &&
          filePath.trim().isNotEmpty) {
        debugPrint(
          "STEP 1: Uploading new manifesto file...",
        );

        final List<String> uploadedUrls =
        await _mediaUploadApi.uploadMedia(
          filePaths: [filePath],
          category: "manifesto",
        );

        if (uploadedUrls.isEmpty) {
          throw Exception(
            "File upload failed. No URL returned.",
          );
        }

        uploadedFileUrl = uploadedUrls.first;

        debugPrint(
          "New manifesto URL: $uploadedFileUrl",
        );
      } else {
        debugPrint(
          "STEP 1: No new PDF selected. Keeping existing PDF.",
        );
      }

      // ========================================================
      // STEP 2: CREATE UPDATE JSON
      // ========================================================

      final Map<String, dynamic> data = {
        "title": manifesto.title,
        "year": manifesto.year,

        // If a new PDF was selected:
        //     use new uploaded URL
        //
        // Otherwise:
        //     keep existing backend URL
        "fileUrl": uploadedFileUrl ?? manifesto.fileUrl,

        "kind": "ELECT",
      };

      debugPrint(
        "UPDATE MANIFESTO DATA:",
      );

      debugPrint(
        jsonEncode(data),
      );

      // ========================================================
      // STEP 3: CREATE MULTIPART FORM DATA
      // ========================================================

      final FormData formData = FormData();

      formData.fields.add(
        MapEntry(
          "data",
          jsonEncode(data),
        ),
      );

      debugPrint(
        "UPDATE MANIFESTO REQUEST: multipart/form-data",
      );

      // ========================================================
      // STEP 4: PATCH MANIFESTO
      // ========================================================

      final response = await _dio.patch(
        "$api/api/v1/manifestos/${manifesto.id}",
        data: formData,
      );

      debugPrint(
        "UPDATE MANIFESTO RESPONSE:",
      );

      debugPrint(
        response.data.toString(),
      );

      return ManifestoModel.fromJson(
        response.data["data"],
      );
    } on DioException catch (e) {
      debugPrint(
        "UPDATE MANIFESTO API ERROR: "
            "${e.response?.data}",
      );

      throw Exception(
        e.response?.data ?? e.message,
      );
    } catch (e) {
      debugPrint(
        "UPDATE MANIFESTO ERROR: $e",
      );

      throw Exception(
        e.toString(),
      );
    }
  }
}