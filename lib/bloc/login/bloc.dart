import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc_mifone/api/entity/model/profile.dart';
import 'package:flutter_webrtc_mifone/api/entity/response/login_response_vt.dart';
import 'package:flutter_webrtc_mifone/api/service/authen_service.dart';
import 'package:flutter_webrtc_mifone/api/service/internal_service.dart';
import 'package:flutter_webrtc_mifone/util/decode_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'event.dart';
import 'state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  late InternalService authService;
  late SharedPreferences preferences;
  bool isRemember = false;
  bool isCustomDomain = false;
  AuthenService authenKeyService = AuthenService(dio: Dio());

  LoginBloc() : super(InitState()) {
    on<InitEvent>((event, emit) async {
      preferences = await SharedPreferences.getInstance();
      String? url = preferences.getString("customDomain");
      print("URL Signing: $url");
      if (url == null)
        isCustomDomain = false;
      else
        isCustomDomain = true;
    });

    on<AuthenticateKeyEvent>((even, emit) async {});

    on<SigningEvent>((event, emit) async {
      bool? isAuthenticateDomainSuccess;
      print('isCustomDomain: $isCustomDomain');
      if (isCustomDomain) {
        isAuthenticateDomainSuccess =
            await authenticateCustomDomain(event.key!);
      }
      print('isAuthenticateDomainSuccess: $isAuthenticateDomainSuccess');
      if (isAuthenticateDomainSuccess == null || isAuthenticateDomainSuccess) {
        final responseLogin = await login(event.email, event.password);
        if (responseLogin.code == 200) {
          print("Data response: ${responseLogin.toString()}");
          DecodeProfile decodeProfile = DecodeProfile(responseLogin.data, '');
          Profile profile = decodeProfile.decodeProfile();
          // DecodeProfile decodeProfile =
          //     DecodeProfile(responseLogin.dataV2!, '');
          // Profile profile = decodeProfile.decryptAES();
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          print("Data profile: ${json.encode(profile.toJson())}");
          sharedPreferences.setString("profile", json.encode(profile.toJson()));
          sharedPreferences.setInt("grId", responseLogin.groupId);
          sharedPreferences.setInt("userLogId", responseLogin.userLogId);
          sharedPreferences.setString("secret", responseLogin.secret);
          sharedPreferences.setString("extension", profile.extension);
          emit(SigningState(true, profile.extension));
        } else {
          emit(SigningState(false, ""));
        }
      } else {
        emit(AuthenticateKeyState(false));
      }
    });

    on<ToggleRememberEvent>((event, emit) {
      isRemember = event.val;
      emit(ToggleRememberState(isRemember));
    });

    on<ToggleHidePasswordEvent>((event, emit) {
      emit(ToggleHidePasswordState(event.isHide));
    });

    on<ToggleUseCustomDomainEvent>((event, emit) {
      isCustomDomain = event.isUse;
      emit(ToggleUseCustomDomainState(isCustomDomain));
    });
  }

  Future<bool> authenticateCustomDomain(String key) async {
    print('key: $key');
    Map<String, String> mapData = {"key": key};
    try {
      final responseAuth = await authenKeyService.authenKey(mapData);
      print('response authen key: $responseAuth');
      if (responseAuth.status!) {
        String url = responseAuth.data!.url!;
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString("customDomain", url);
        authService = InternalService(dio: Dio(), baseUrl: url);
        print("URL Signing: $url");
        isCustomDomain = true;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<ResponseLogin> login(String email, String password) async {
    String? url = preferences.getString("customDomain");
    print("URL Signing: $url");
    authService =
        InternalService(dio: Dio(), baseUrl: url ?? dotenv.env['BASE_URL']!);
    Map<String, String> body = {
      "email": email,
      "password": password,
      "type": "sf"
    };
    try {
      final response = await authService.login(body);
      return response;
    } catch (e) {
      print('error post login: $e');
      return ResponseLogin(
          code: 406,
          message: 'message',
          data: 'data',
          userLogId: 0,
          groupId: 0,
          privileges: [],
          secret: 'secret');
    }
  }
}
