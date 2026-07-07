import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Reusable Functions/reusable_functions.dart';

final dio=Dio();
final authService=AuthService(dio);
final dioClient=DioClient(authService);
final Dio apiClient=dioClient.dio;

class AuthService{
  final Dio _dio;
  AuthService(this._dio);
  Future<bool>refreshAccessToken()async{
    try{
      final prefs=await SharedPreferences.getInstance();
      final refreshToken=prefs.getString('refreshToken');
      if(refreshToken==null){
        return false;
      }
      final response=await _dio.post("$api/api/v1/auth/refresh",
      data: {
        "refreshToken":refreshToken,
      }
      );
      if(response.statusCode==200 || response.statusCode==201){
        final auth=response.data["data"]["auth"];
        await prefs.setString("accessToken", auth["accessToken"]);
        await prefs.setString("refreshToken", auth["refreshToken"]);
        await prefs.setString("userUuid", auth["userUuid"]);
        await prefs.setInt("loginTime", DateTime.now().millisecondsSinceEpoch,);
        await prefs.setBool("isLogged", true);
        return true;
      }
      return false;
    }
    catch(e){
      return false;
    }
  }
}
///-----Dio Client
class DioClient{
  late Dio dio;
  final AuthService authService;
  DioClient(this.authService){
    dio=Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler)async{
        final prefs=await SharedPreferences.getInstance();
        final token=prefs.getString("accessToken");
        if(token!=null){
          options.headers["Authorization"]="Bearer $token";
        }
        options.headers["Content-Type"]="application/json";
        handler.next(options);
      },
      onError: (DioException error, handler)async{
        if(error.requestOptions.path.contains("/auth/refresh")){
          return handler.next(error);
        }
        if(error.response?.statusCode==403){
          print("Refreshing Token...");
          final success=await authService.refreshAccessToken();
          if(success){
            final prefs=await SharedPreferences.getInstance();
            final newToken=prefs.getString("accessToken");
            final request=error.requestOptions;
            request.headers["Authorization"]="Bearer $newToken";

            try {
             final response=await dio.fetch(request);
             return handler.resolve(response);
            }
            catch(e){
              return handler.next(error);
            }
          }
        }
        handler.next(error);
    }
    ));
  }

}
