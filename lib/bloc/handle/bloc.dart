import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:contacts_service/contacts_service.dart' as contactService;
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc_mifone/api/entity/response/contact_response.dart';
import 'package:flutter_webrtc_mifone/api/entity/response/history_response.dart';
import 'package:flutter_webrtc_mifone/api/entity/response/logout_response.dart';
import 'package:flutter_webrtc_mifone/dart_sip/constants.dart';
import 'package:flutter_webrtc_mifone/firebase_options.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiengviet/tiengviet.dart';
import 'package:uuid/uuid.dart';

import '../../api/entity/model/contact.dart';
import '../../api/entity/model/profile.dart';
import '../../api/service/internal_service.dart';
import '../../sip_ua.dart';
import 'event.dart';
import 'state.dart';

SIPUAHelper helper = SIPUAHelper();

class ListenRejectCallSip implements SipUaHelperListener {
  @override
  void callStateChanged(Call call, CallState state) {
    print(
        "MESSAGEFROMDARTSIPUA: ${state.state}, id_call: ${call.id},ext: ${call.remote_identity}");
    if (state.state == CallStateEnum.PROGRESS) {
      call.hangup({"cause": Causes.BUSY, "status_code": 486});
    } else if (state.state == CallStateEnum.FAILED) {
      helper.unregister(true);
    }
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    print("MESSAGEFROMDARTSIPUA: ${state.state}");
    if (state.state == RegistrationStateEnum.UNREGISTERED) {
      helper.removeSipUaHelperListener(this);
    }
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    // TODO: implement onNewMessage
  }

  @override
  void onNewNotify(Notify ntf) {
    // TODO: implement onNewNotify
  }

  @override
  void transportStateChanged(TransportState state) {
    // TODO: implement transportStateChanged
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  bool isInitialFirebaseAppFromBg = pref.getBool("isInitialFbFromBg") ?? false;
  print("BACKGROUND HANDLE, isInitialFbFromBg: $isInitialFirebaseAppFromBg");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  Map<String, dynamic> data = message.data;
  Map<String, dynamic> dataMessageRaw = message.toMap();
  String type = data['type'];
  String uuidFcm = data['uuid'];
  print("Data from fcm: $data");
  print("DataRaw from fcm: $dataMessageRaw");
  if ((pref.getString('rejectUuidCall') ?? "") == uuidFcm ||
      (pref.getString('acceptUuidCall') ?? "") == uuidFcm) {
    await pref.setString('rejectUuidCall', "");
    await pref.setString('acceptUuidCall', "");
    return;
  }
  if (type == "endcall") {
    await pref.setBool("isEndCallFromFCM", true);
    await CallKeep.instance.endAllCalls();
    return;
  }
  var messageMap = message.toMap();
  final callKeepBaseConfig = CallKeepBaseConfig(
    appName: 'Done',
    androidConfig: CallKeepAndroidConfig(
      logo: 'mipmap/ic_launcher',
      notificationIcon: 'mipmap/ic_launcher',
    ),
    iosConfig: CallKeepIosConfig(
        iconName: 'Icon',
        maximumCallGroups: 1,
        handleType: CallKitHandleType.generic),
  );
  var uuid = const Uuid().v4();
  final config = CallKeepIncomingConfig.fromBaseConfig(
    config: callKeepBaseConfig,
    uuid: uuid,
    contentTitle: 'Incoming call',
    hasVideo: false,
    handle: 'Mifone',
    callerName: "Display name",
    extra: {"data1": "ddwwd", "data2": 'dwqddddd'},
  );
  await CallKeep.instance.displayIncomingCall(config);
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setBool("isIncomingFromFCM", true);
  CallKeep.instance.onEvent.listen((event) async {
    print("EVENT CALL KEEP: ${event!.type.toString()}");
    if (event == null) return;
    switch (event.type) {
      case CallKeepEventType.callAccept:
        await pref.setString("acceptUuidCall", uuidFcm);
        final data = event.data as CallKeepCallData;
        break;
      case CallKeepEventType.callDecline:
        if (pref.getBool("isEndCallFromFCM") ?? false) {
          await pref.setBool("isEndCallFromFCM", false);
          await pref.setBool('isIncomingFromFCM', false);
          print("Have set isEndCallFromFCM, isIncomingFromFCM = false");
          exit(0);
        }
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        await sharedPreferences.setBool('isIncomingFromFCM', false);
        await sharedPreferences.setString("rejectUuidCall", uuidFcm);
        helper ??= SIPUAHelper();
        UaSettings settings = UaSettings();
        Map<String, dynamic> mapJsonProfile =
            json.decode(pref.getString("profile")!);
        Profile profile = Profile.fromJson(mapJsonProfile);
        String ext = profile.extension;
        String password = profile.password;
        String domain = profile.domain;
        String sipProxy = profile.proxy;
        String port = profile.port;
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String appId = packageInfo.packageName;
        settings.webSocketUrl = "wss://$sipProxy:$port/wss";
        final Map<String, String> _wsExtraHeaders = {
          'Origin': 'https://$sipProxy',
          'Host': '$sipProxy:$port'
        };
        String token = "";
        String pnProvider = "fcm";
        if (Platform.isAndroid) {
          token = (await messaging.getToken())!;
        } else {
          pnProvider = "apns";
          MethodChannel channel = const MethodChannel('channel_check_flag');
          token = await channel.invokeMethod('getTokenVoip');
        }
        settings.registerParams.extraContactUriParams = <String, String>{
          'pn-provider': pnProvider,
          'pn-param': appId,
          'pn-prid': token
        };
        settings.domain = domain;
        settings.webSocketSettings.extraHeaders = _wsExtraHeaders;
        settings.webSocketSettings.allowBadCertificate = true;
        settings.uri = "sip:$ext@$domain";
        settings.authorizationUser = ext;
        settings.password = password;
        settings.displayName = ext;
        settings.userAgent = 'Mifone Flutter';
        settings.dtmfMode = DtmfMode.RFC2833;
        helper.addSipUaHelperListener(ListenRejectCallSip());
        helper.start(settings);
      case CallKeepEventType.callTimedOut:
      case CallKeepEventType.callEnded:
        final data = event.data as CallKeepCallData;
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        await sharedPreferences.setBool('isIncomingFromFCM', false);
        print("Have disable flag");
        break;
      default:
        break;
    }
  });
}

class HandleBloc extends Bloc<HandleEvent, HandleState>
    implements SipUaHelperListener {
  static Call? currCall;
  bool isCallOut = false;
  late InternalService service;
  static late List<ResponseHistory> histories;
  late List<ContactDisplay> contactPhone;
  late List<ContactDisplay> contactOfficeBloc;
  int currType = 0;
  String from = "";
  bool isLogout = false;

  HandleBloc() : super(InitState()) {
    on<InitEvent>((event, emit) async {
      from = event.from;
      SharedPreferences pref = await SharedPreferences.getInstance();
      service = InternalService(
          dio: Dio(),
          baseUrl: pref.getString("customDomain") ?? dotenv.env['BASE_URL']!);
      await initFirebase();
      await registerSip();
      bool isTurnOnAccount = pref.getBool('isTurnOn') ?? true;
      add(SwitchTypeContactEvent(SwitchTypeContactState.TYPE_OFFICE_CONTACT));
      add(GetHistoryEvent());
      emit(ToggleTurnOnAccountState(isTurnOnAccount));
    });

    on<ReListenSip>((event, emit) {
      helper.addSipUaHelperListener(this);
    });

    on<AcceptCallFromFCMEvent>((event, emit) async {
      emit(AcceptCallFromFCMState(currCall!));
    });

    on<RegistrationEvent>((event, emit) async {
      emit(HandleRegistrationState(event.callStateEnum));
    });

    on<SignOutEvent>((event, emit) async {
      isLogout = true;
      SharedPreferences pref = await SharedPreferences.getInstance();
      Map<String, dynamic> bodyLogout = {
        "id": pref.getInt("userLogId"),
        "token_device": token,
        "type": "sf"
      };
      try {
        // final responseLogout = await service.logout(bodyLogout);
        final responseLogout = LogoutResponse(code: 200, message: "Success");
        print("data logout api: $responseLogout");
        if (responseLogout.code != 200) {
          emit(SignOutState(false, responseLogout.message));
          return;
        }
      } catch (e) {
        print("Error post logout: $e");
        emit(SignOutState(false, "Have just error occurred"));
        return;
      }
      await pref.clear();
      helper.unregister(true);
    });

    on<CallInEvent>((event, emit) {
      isCallOut = false;
      currCall = event.call;
      emit(CallInState(currCall!));
    });

    on<CallOutEvent>((event, emit) async {
      isOpenCallingScreen = true;
      isCallOut = true;
    });

    on<CallingEvent>((event, emit) {
      if (event.type == CallingState.INCOMING_CALL ||
          event.type == CallingState.END_CALL) {
        isCallOut = false;
      } else if (event.type == CallingState.CALL_OUT) {
        isCallOut = true;
        helper.call(event.phone!);
        return;
      }
      emit(CallingState(event.type, event.call!));
    });

    on<UpdateCallOutEvent>((event, emit) {
      emit(CallOutState(currCall!));
    });

    on<UnRegisterSipEvent>((event, emit) {
      helper.unregister(true);
    });

    on<RegisterSipEvent>((event, emit) async {
      await registerSip();
    });

    on<SearchContactEvent>((event, emit) {
      List<ContactDisplay> tmp = [];
      if (currType == SwitchTypeContactState.TYPE_PHONE_CONTACT) {
        for (int i = 0; i < contactPhone.length; ++i) {
          if (contactPhone[i]
              .displayName
              .toLowerCase()
              .contains(TiengViet.parse(event.searchString.toLowerCase()))) {
            tmp.add(contactPhone[i]);
          }
        }
      } else {
        for (int i = 0; i < contactOfficeBloc.length; ++i) {
          if (TiengViet.parse(contactOfficeBloc[i].displayName.toLowerCase())
              .contains(TiengViet.parse(event.searchString.toLowerCase()))) {
            tmp.add(contactOfficeBloc[i]);
          }
        }
      }
      emit(SwitchTypeContactState(currType, tmp));
    });

    on<ToggleTurnOnAccountEvent>((event, emit) async {
      if (event.isTurnOn) {
        await registerSip();
      } else {
        helper.unregister();
      }
      emit(ToggleTurnOnAccountState(event.isTurnOn));
    });

    on<GetHistoryEvent>((event, emit) async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      DateTime endDateObj = DateTime.now();
      DateTime startDateObj = DateTime.fromMillisecondsSinceEpoch(
          endDateObj.millisecondsSinceEpoch - (6 * 86400000));
      int millisecondStartDate =
          ((startDateObj.millisecond / 1000) * 60).toInt();
      int millisecondEndDate = ((endDateObj.millisecond / 1000) * 60).toInt();
      String startDateString =
          "${startDateObj.year}-${(startDateObj.month <= 9) ? ("0${startDateObj.month}") : startDateObj.month}-${(startDateObj.day <= 9) ? ("0${startDateObj.day}") : startDateObj.day} ${(startDateObj.hour <= 9) ? ("0${startDateObj.hour}") : startDateObj.hour}:${(startDateObj.minute <= 9) ? ("0${startDateObj.minute}") : startDateObj.minute}:${(millisecondStartDate <= 9) ? "0$millisecondStartDate" : millisecondStartDate}";
      String endDateString =
          "${endDateObj.year}-${(endDateObj.month <= 9) ? ("0${endDateObj.month}") : endDateObj.month}-${(endDateObj.day <= 9) ? ("0${endDateObj.day}") : endDateObj.day} ${(endDateObj.hour <= 9) ? ("0${endDateObj.hour}") : endDateObj.hour}:${(endDateObj.minute <= 9) ? ("0${endDateObj.minute}") : endDateObj.minute}:${(millisecondEndDate <= 9) ? "0$millisecondEndDate" : millisecondEndDate}";
      print("Start date: $startDateString");
      print("End date: $endDateString");
      String extSelf = pref.getString("extension")!;
      Map<String, dynamic> body = {
        "secret": pref.getString("secret")!,
        "startDate": startDateString,
        "endDate": endDateString,
        "extensions": [extSelf],
      };
      histories = await service.getHistory(body);
      print('data request: $body');
      print('data histories: $histories');
      emit(GotHistoryState(histories, extSelf));
    });
    on<SwitchTypeContactEvent>((event, emit) async {
      emit(LoadingContactState(event.type));
      currType = event.type;
      if (currType == SwitchTypeContactState.TYPE_PHONE_CONTACT) {
        var status = await Permission.contacts.status;
        if (!status.isGranted) {
          await Permission.contacts.request().isGranted;
        }
        status = await Permission.contacts.status;
        if (!(status.isGranted)) {
          return;
        }
        List<contactService.Contact> contacts =
            await contactService.ContactsService.getContacts(
                withThumbnails: false);
        List<ContactDisplay> contactDisplayed = [];
        for (int i = 0; i < contacts.length; ++i) {
          if (contacts[i].phones!.isEmpty) continue;
          contactDisplayed.add(ContactDisplay(
              null,
              contacts[i].displayName ?? contacts[i].phones![0].value!,
              contacts[i].phones![0].value!));
        }
        contactDisplayed.sort((a, b) => TiengViet.parse(a.displayName[0])
            .compareTo(TiengViet.parse(b.displayName[0])));
        contactPhone = contactDisplayed;
        emit(SwitchTypeContactState(
            SwitchTypeContactState.TYPE_PHONE_CONTACT, contactDisplayed));
      } else {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        final responseContact =
            await service.getContacts(sharedPreferences.getInt("grId")!);
        List<ContactOffice> contactOffice = responseContact.data;
        List<ContactDisplay> contactDisplayed = [];
        for (int i = 0; i < contactOffice.length; ++i) {
          contactDisplayed.add(ContactDisplay(contactOffice[i].userAvatar,
              contactOffice[i].lastName, contactOffice[i].extension));
        }
        contactDisplayed.sort((a, b) => TiengViet.parse(a.displayName[0])
            .compareTo(TiengViet.parse(b.displayName[0])));
        contactOfficeBloc = contactDisplayed;
        emit(SwitchTypeContactState(
            SwitchTypeContactState.TYPE_OFFICE_CONTACT, contactDisplayed));
      }
    });
  }

  bool isOpenCallingScreen = false;
  bool isDeclineCall = false;

  @override
  void callStateChanged(Call call, CallState state) async {
    print(
        "MESSAGEFROMDARTSIPUA CALL STATE (HANDLE BLOC) ${state.state.name}, ${call.remote_identity}");
    if (state.state == CallStateEnum.PROGRESS) {
      if (!isOpenCallingScreen) {
        currCall = call;
        add(CallInEvent(call));
        isOpenCallingScreen = true;
      }
    } else if (state.state == CallStateEnum.ENDED ||
        state.state == CallStateEnum.FAILED) {
      isCallOut = false;
      currCall = null;
      isOpenCallingScreen = false;
      emit(CallingState(CallingState.END_CALL, call));
    } else if (state.state == CallStateEnum.ACCEPTED) {
      emit(CallingState(CallingState.ANSWER_CALL, call));
    }
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    print("MESSAGEFROMDARTSIPUA: " + msg.toString());
  }

  @override
  void onNewNotify(Notify ntf) {
    print("MESSAGEFROMDARTSIPUA: " + ntf.toString());
  }

  @override
  void registrationStateChanged(RegistrationState state) async {
    // TODO: implement registrationStateChanged
    print("MESSAGEFROMDARTSIPUA: ${state.state}");
    if (state.state == RegistrationStateEnum.REGISTERED) {
      add(RegistrationEvent(state.state!));
    } else if (state.state == RegistrationStateEnum.UNREGISTERED) {
      if (isLogout) {
        helper.removeSipUaHelperListener(this);
        emit(SignOutState(true, "Sign out success"));
      }
      add(RegistrationEvent(RegistrationStateEnum.NONE));
    } else {
      add(RegistrationEvent(RegistrationStateEnum.NONE));
    }
  }

  @override
  void transportStateChanged(TransportState state) {
    print("MESSAGEFROMDARTSIPUA: ${state.state}");
  }

  Future<void> initFirebase() async {
    helper.addSipUaHelperListener(this);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (Platform.isAndroid) {
      token = (await messaging.getToken())!;
    } else {
      MethodChannel channel = const MethodChannel('channel_check_flag');
      token = await channel.invokeMethod('getTokenVoip');
      print('token voip: $token');
    }
    NotificationSettings settingsFCM = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('DEBUGNOTIFY: Notify opened app: ${event.toMap()}');
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('DEBUGNOTIFY: Notify foreground: ${message.toMap()}');
    });
  }

  late String token;

  Future<void> registerSip() async {
    UaSettings settings = UaSettings();
    SharedPreferences pref = await SharedPreferences.getInstance();
    Map<String, dynamic> mapJsonProfile =
        json.decode(pref.getString("profile")!);
    Profile profile = Profile.fromJson(mapJsonProfile);
    String ext = profile.extension;
    String password = profile.password;
    String domain = profile.domain;
    String sipProxy = profile.proxy;
    String port = profile.port;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appId = packageInfo.packageName;
    settings.webSocketUrl = "wss://$sipProxy:$port/wss";
    final Map<String, String> _wsExtraHeaders = {
      'Origin': 'https://$sipProxy',
      'Host': '$sipProxy:$port'
    };
    print("Token: $token");
    settings.registerParams.extraContactUriParams = <String, String>{
      'pn-provider': (Platform.isAndroid) ? 'fcm' : 'apns',
      'pn-param': appId,
      'pn-prid': token
    };
    settings.domain = domain;
    settings.webSocketSettings.extraHeaders = _wsExtraHeaders;
    settings.webSocketSettings.allowBadCertificate = true;
    settings.uri = "sip:$ext@$domain";
    settings.authorizationUser = ext;
    settings.password = password;
    settings.displayName = ext;
    settings.userAgent = 'Mifone Flutter';
    settings.dtmfMode = DtmfMode.RFC8599;
    helper.start(settings);
  }
}
