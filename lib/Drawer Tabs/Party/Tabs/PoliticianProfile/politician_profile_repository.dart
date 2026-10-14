import 'package:dio/dio.dart';
import '../../../../Login Page/Refresh Token/refresh_token.dart';
import '../../../../Reusable Functions/reusable_functions.dart';
import 'politician_model.dart';

class PoliticianProfileRepository {
  final Dio _dio;

  PoliticianProfileRepository({Dio? dio}) : _dio = dio ?? apiClient;

  Future<PoliticianModel> fetchPoliticianProfile(int politicianId) async {
    try {
      final response = await _dio.get(
        "$api/api/v1/profile/politicians/$politicianId/full",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final dynamic rawData = responseData is Map<String, dynamic>
            ? (responseData['data'] ?? responseData)
            : responseData;

        Map<String, dynamic> politicianMap;

        if (rawData is Map<String, dynamic>) {
          if (rawData['politician'] != null && rawData['politician'] is Map) {
            politicianMap = Map<String, dynamic>.from(
              rawData['politician'] as Map,
            );

            // Merge journeys from data if not present inside politician map
            if (politicianMap['journeys'] == null &&
                rawData['journeys'] != null) {
              politicianMap['journeys'] = rawData['journeys'];
            }
            // Merge party from data if not present inside politician map
            if (politicianMap['party'] == null && rawData['party'] != null) {
              politicianMap['party'] = rawData['party'];
            }
          } else {
            politicianMap = Map<String, dynamic>.from(rawData);
          }
        } else {
          throw Exception("Invalid politician profile response format");
        }

        return PoliticianModel.fromJson(politicianMap);
      }

      throw Exception("Error : ${response.statusCode}");
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to fetch politician profile");
    }
  }
}
