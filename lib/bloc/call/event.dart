import 'package:flutter_webrtc_mifone/sip_ua.dart';

abstract class CallEvent {}

class InitEvent extends CallEvent {
  String extension;
  bool isCallOut;
  Call? currCall;

  InitEvent(this.extension, this.isCallOut, this.currCall);
}

class CallingEvent extends CallEvent {
  static int INCOMING_CALL = 0;
  static int CALL_OUT = 1;
  static int END_CALL = 2;
  static int ANSWER_CALL = 3;
  static int ACCEPT_CALL = 4;
  static int DECLINE_CALL = 5;
  final int type;
  final Call call;

  CallingEvent(this.type, this.call);
}

class RemoveListenerSipEvent extends CallEvent {}

class AcceptCallEvent extends CallEvent {}

class DeclineCallEvent extends CallEvent {}

class CancelCallEvent extends CallEvent {}

class StartTimerEvent extends CallEvent {}

class OnTimerChangeEvent extends CallEvent {
  final String durationString;

  OnTimerChangeEvent(this.durationString);
}

class ToggleMuteCallEvent extends CallEvent {}

class ToggleSpeakerEvent extends CallEvent {}

class ToggleHoldCallEvent extends CallEvent {}

class SendDTMFEvent extends CallEvent {
  String number;

  SendDTMFEvent(this.number);
}
