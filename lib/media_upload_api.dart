
import 'package:dio/dio.dart';

import 'Login Page/Refresh Token/refresh_token.dart';
import 'Reusable Functions/reusable_functions.dart';

class MediaUploadApi {
  final Dio _dio = apiClient;
  Future<List<String>> uploadMedia({
    required List<String> filePaths,
    required String category,
  }) async {
    FormData formData=FormData.fromMap({
      "category":"banner",
    });
    for(String path in filePaths){
      formData.files.add(
          MapEntry("files",
            await MultipartFile.fromFile(path),
          )
      );
    }

    print("Here come1");
    final response=await  _dio.post("$api/api/v1/media/upload-multi",
      data: formData,
      // options: Options(
      //   headers: {
      //     "Authorization": "Bearer $token",
      //   },
      // ),
    );
    print("Here come2");
    print(response.data);
    final uploaded = response.data["data"]["uploaded"] as List;

    return uploaded
        .map((e) => e["url"] as String)
        .toList();
  }
}