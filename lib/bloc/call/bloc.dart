import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_mifone/api/entity/model/profile.dart';
import 'package:flutter_webrtc_mifone/bloc/handle/bloc.dart';
import 'package:flutter_webrtc_mifone/dart_sip/constants.dart';
import 'package:flutter_webrtc_mifone/dart_sip/sip_ua_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'event.dart';
import 'state.dart';

class CallBloc extends Bloc<CallEvent, BlocCallState>
    implements SipUaHelperListener {
  Call? currCall;
  bool isEnableSpeaker = false;
  bool isMute = false;
  bool isHold = false;
  Timer? _timer;
  int countTime = 0;
  bool isDeclineCall = false;
  bool isCancelCall = false;
  bool isIncomingFlag = false;
  late SharedPreferences pref;
  bool isAnswerCall = false;
  late MediaStream _localStream;

  Future<void> registerSip() async {
    helper ??= SIPUAHelper();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
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
    helper.start(settings);
  }

  Future<void> makeCall({required String phone, bool voiceonly = false}) async {
    final mediaConstraints = <String, dynamic>{'audio': true, 'video': true};

    MediaStream mediaStream;

    if (!voiceonly) {
      mediaStream =
          await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      mediaConstraints['video'] = false;
      MediaStream userStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      mediaStream.addTrack(userStream.getAudioTracks()[0], addToNative: true);
      mediaStream.getAudioTracks().first.enableSpeakerphone(false);
      _localStream = mediaStream;
    } else {
      mediaConstraints['video'] = !voiceonly;
      mediaStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      mediaStream.getAudioTracks().first.enableSpeakerphone(false);
      _localStream = mediaStream;
    }

    helper.call(phone, voiceonly: voiceonly, mediaStream: _localStream);
  }

  CallBloc() : super(BlocCallState()) {
    helper.addSipUaHelperListener(this);
    on<InitEvent>((event, emit) async {
      if (event.isCallOut) {
        await makeCall(phone: event.extension, voiceonly: true);
      } else {
        currCall = event.currCall;
      }
      pref = await SharedPreferences.getInstance();
      if (Platform.isIOS) {
        MethodChannel channel = const MethodChannel("channel_check_flag");
        isIncomingFlag = await channel.invokeMethod("check_flag_incoming");
      } else {
        MethodChannel channel = const MethodChannel("my_channel");
        isAnswerCall = await channel.invokeMethod("checkFlagAnswer");
      }
      isIncomingFromFCM = pref.getBool('isIncomingFromFCM') ?? false;
      if ((Platform.isAndroid && isIncomingFromFCM) ||
          (Platform.isIOS && isIncomingFlag)) {
        registerSip();
      }

      if (Platform.isIOS) {
        CallKeep.instance.onEvent.listen((event) async {
          if (event == null) return;
          switch (event.type) {
            case CallKeepEventType.callAccept:
              if (currCall != null) {
                handleAcceptCall(call: currCall!, voiceonly: true);
              } else {
                isAnswerCall = true;
              }
              break;
            case CallKeepEventType.callDecline:
              MethodChannel channel = const MethodChannel("channel_check_flag");
              bool isEndCallFromPushkit = await channel
                  .invokeMethod("check_flag_end_call_from_pushkit");
              if (isEndCallFromPushkit) {
                disableFlagIncoming();
                bool isCloseAppSuccess =
                    await channel.invokeMethod("close_app");
                if (isCloseAppSuccess) {
                  exit(0);
                }
                return;
              }
              if (currCall != null) {
                currCall!.hangup({"cause": Causes.BUSY, "status_code": 486});
              } else {
                isDeclineCall = true;
              }
              break;
            case CallKeepEventType.callEnded:
              currCall!.hangup();
              break;
            case CallKeepEventType.callTimedOut:
              helper.unregister(true);
              disableFlagIncoming();
              break;
            default:
              break;
          }
        });
      }
    });

    on<AcceptCallEvent>((event, emit) {
      emit(TimerSate("Connecting..."));
      handleAcceptCall(call: currCall!, voiceonly: true);
    });

    on<DeclineCallEvent>((event, emit) {
      isDeclineCall = true;
      currCall!.hangup({"cause": Causes.BUSY, "status_code": 486});
      emit(CallingState(CallingState.END_CALL, currCall!, isEnableSpeaker));
    });

    on<CancelCallEvent>((event, emit) {
      isCancelCall = true;
      if (currCall != null) {
        currCall!.hangup();
      } else {
        helper.terminateSessions({});
      }
      emit(CallingState(CallingState.END_CALL, currCall, isEnableSpeaker));
    });

    on<RemoveListenerSipEvent>((event, emit) {
      helper.removeSipUaHelperListener(this);
    });

    on<ToggleHoldCallEvent>((event, emit) {
      isHold = !isHold;
      if (isHold) {
        currCall!.hold();
      } else {
        currCall!.unhold();
      }
      emit(ToggleHoldState(isHold));
    });

    on<SendDTMFEvent>((event, emit) {
      currCall!.sendDTMF(event.number);
    });

    on<ToggleMuteCallEvent>((event, emit) {
      isMute = !isMute;
      if (isMute) {
        currCall!.mute();
      } else {
        currCall!.unmute();
      }
      emit(ToggleMuteState(isMute));
    });

    on<ToggleSpeakerEvent>((event, emit) async {
      isEnableSpeaker = !isEnableSpeaker;
      _localStream.getAudioTracks()[0].enableSpeakerphone(isEnableSpeaker);
      emit(ToggleSpeakerState(isEnableSpeaker));
    });

    on<StartTimerEvent>((event, emit) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        countTime++;
        int m = countTime ~/ 60;
        int s = countTime % 60;
        String durationString =
            '${(m < 10) ? '0$m' : m}:${(s < 10) ? '0$s' : s}';
        add(OnTimerChangeEvent(durationString));
      });
    });
    on<OnTimerChangeEvent>((event, emit) {
      emit(TimerSate(event.durationString));
    });
  }

  bool isIncomingFromFCM = false;

  void disableFlagIncoming() async {
    if (Platform.isAndroid) {
      await pref.setBool("isIncomingFromFCM", false);
      MethodChannel methodChannel = const MethodChannel("my_channel");
      await methodChannel.invokeMethod("disable_flag_answer");
    } else {
      MethodChannel methodChannel = const MethodChannel("channel_check_flag");
      await methodChannel.invokeMethod("disable_flag_incoming");
    }
  }

  @override
  void callStateChanged(Call call, CallState state) async {
    print("MESSAGEFROMDARTSIPUA CALL STATE (CALL BLOC): ${state.state.name}");
    if (state.state == CallStateEnum.PROGRESS) {
      currCall = call;
      print("isAnswerCall: $isAnswerCall");
      if (isAnswerCall) {
        handleAcceptCall(call: currCall!, voiceonly: true);
      }
      if (isDeclineCall) {
        currCall!.hangup({"cause": Causes.BUSY, "status_code": 486});
      }
    } else if (state.state == CallStateEnum.ENDED ||
        state.state == CallStateEnum.FAILED) {
      print(
          "isIncomingFlag = $isIncomingFlag, isIncomingFromFCM = $isIncomingFromFCM");
      await CallKeep.instance.endAllCalls();
      currCall = null;
      if (_timer != null) _timer!.cancel();
      disableFlagIncoming();
      if (isIncomingFlag || isIncomingFromFCM) {
        helper.unregister(true);
      }

      if (!isIncomingFlag && !isIncomingFromFCM) {
        helper.removeSipUaHelperListener(this);
        if (!isCancelCall && !isDeclineCall) {
          emit(CallingState(CallingState.END_CALL, call, isEnableSpeaker));
        }
      }
    } else if (state.state == CallStateEnum.ACCEPTED) {
      emit(TimerSate("Connecting..."));
      currCall = call;
      emit(CallingState(CallingState.ANSWER_CALL, call, isEnableSpeaker));
      add(StartTimerEvent());
    } else if (state.state == CallStateEnum.HOLD) {
      _timer!.cancel();
    } else if (state.state == CallStateEnum.UNHOLD) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        countTime++;
        int m = countTime ~/ 60;
        int s = countTime % 60;
        String durationString =
            '${(m < 10) ? '0$m' : m}:${(s < 10) ? '0$s' : s}';
        add(OnTimerChangeEvent(durationString));
      });
    }
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    print("MESSAGEFROMDARTSIPUA: $msg");
  }

  @override
  void onNewNotify(Notify ntf) {
    print("MESSAGEFROMDARTSIPUA: $ntf");
  }

  @override
  void registrationStateChanged(RegistrationState state) async {
    // TODO: implement registrationStateChanged
    print("MESSAGEFROMDARTSIPUA: ${state.state}");
    if (state.state == RegistrationStateEnum.UNREGISTERED) {
      if (isIncomingFlag || isIncomingFromFCM) {
        if (Platform.isAndroid) {
          SystemNavigator.pop(animated: true);
        } else {
          MethodChannel channel = const MethodChannel("channel_check_flag");
          bool isCloseAppSuccess = await channel.invokeMethod("close_app");
          if (isCloseAppSuccess) {
            exit(0);
          }
        }
      }
    }
  }

  @override
  void transportStateChanged(TransportState state) {
    print("MESSAGEFROMDARTSIPUA: ${state.state}");
  }

  Future<void> handleAcceptCall(
      {required Call call, bool voiceonly = false}) async {
    final mediaConstraints = <String, dynamic>{'audio': true, 'video': false};
    MediaStream mediaStream;
    mediaStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    mediaStream.getAudioTracks().first.enableSpeakerphone(false);
    _localStream = mediaStream;
    call.answer(helper.buildCallOptions(true), mediaStream: _localStream);
  }

  void handleAccept({required Call call}) async {
    final mediaConstraints = <String, dynamic>{'audio': true, 'video': false};
    MediaStream mediaStream;
    mediaStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    mediaStream.getAudioTracks().first.enableSpeakerphone(false);
    _localStream = mediaStream;
    call.answer(helper.buildCallOptions(true), mediaStream: _localStream);
  }
}
