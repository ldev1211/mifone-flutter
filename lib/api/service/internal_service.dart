import 'package:dio/dio.dart';
import 'package:flutter_webrtc_mifone/api/entity/response/login_response_vt.dart';
import 'package:flutter_webrtc_mifone/api/entity/response/logout_response.dart';
import 'package:retrofit/http.dart';

import '../entity/response/contact_response.dart';
import '../entity/response/history_response.dart';

part 'internal_service.g.dart';

@RestApi()
abstract class InternalService {
  factory InternalService({required Dio dio, required String baseUrl}) {
    dio.options = BaseOptions(
        baseUrl: baseUrl,
        receiveTimeout: const Duration(seconds: 10),
        connectTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
        headers: {
          'Content-Type': 'application/json',
        });
    return _InternalService(dio, baseUrl: baseUrl);
  }

  @POST('/users/login')
  Future<ResponseLogin> login(@Body() Map<String, dynamic> body);

  @POST('/logout')
  Future<LogoutResponse> logout(@Body() Map<String, dynamic> body);

  @GET('/getListUserByMiFone/{groupId}')
  Future<ContactResponse> getContacts(@Path("groupId") int groundId);

  @POST('/cdr/getCallsLog')
  Future<List<ResponseHistory>> getHistory(@Body() Map<String, dynamic> body);
}
