import 'package:dio/dio.dart';
import 'package:flutter_webrtc_mifone/api/entity/response/authen_key_response.dart';
import 'package:retrofit/http.dart';

part 'authen_service.g.dart';

@RestApi()
abstract class AuthenService {
  factory AuthenService({required Dio dio}) {
    String baseUrl = 'https://webapp-api-dev.micxm.vn';
    dio.options = BaseOptions(
        baseUrl: baseUrl,
        receiveTimeout: const Duration(seconds: 10),
        connectTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
        headers: {
          'Content-Type': 'application/json',
        });
    return _AuthenService(dio, baseUrl: baseUrl);
  }

  @POST('/user/middleware/auth')
  Future<ResponseAuthenKey> authenKey(@Body() Map<String, dynamic> body);
}
