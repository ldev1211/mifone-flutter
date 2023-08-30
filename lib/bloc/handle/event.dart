import 'package:flutter_webrtc_mifone/sip_ua.dart';

abstract class HandleEvent {}

class InitEvent extends HandleEvent {
  String from;
  InitEvent(this.from);
}

class ReListenSip extends HandleEvent {}

class RegistrationEvent extends HandleEvent {
  final RegistrationStateEnum callStateEnum;

  RegistrationEvent(this.callStateEnum);
}

class UpdateCurrCallEvent extends HandleEvent {
  Call call;

  UpdateCurrCallEvent(this.call);
}

class UpdateCallOutEvent extends HandleEvent {
  Call call;

  UpdateCallOutEvent(this.call);
}

class CallOutEvent extends HandleEvent {}

class CallInEvent extends HandleEvent {
  final Call call;

  CallInEvent(this.call);
}

class UnRegisterSipEvent extends HandleEvent {}

class RegisterSipEvent extends HandleEvent {}

class SwitchTypeContactEvent extends HandleEvent {
  final int type;

  SwitchTypeContactEvent(this.type);
}

class CallingEvent extends HandleEvent {
  final int type;
  final Call? call;
  String? phone;

  CallingEvent(this.type, this.call, this.phone);
}

class SearchContactEvent extends HandleEvent {
  String searchString;

  SearchContactEvent(this.searchString);
}

class GetHistoryEvent extends HandleEvent {}

class SignOutEvent extends HandleEvent {}

class GetDetailHistoryEvent extends HandleEvent {}

class ToggleTurnOnAccountEvent extends HandleEvent {
  bool isTurnOn;

  ToggleTurnOnAccountEvent(this.isTurnOn);
}

class AcceptCallFromFCMEvent extends HandleEvent {
  Call call;

  AcceptCallFromFCMEvent(this.call);
}
