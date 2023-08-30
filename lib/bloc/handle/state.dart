import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_webrtc_mifone/api/entity/model/contact.dart';
import 'package:flutter_webrtc_mifone/sip_ua.dart';

import '../../api/entity/response/history_response.dart';

abstract class HandleState {}

class InitState extends HandleState {}

class HandleRegistrationState extends HandleState {
  RegistrationStateEnum registrationStateEnum;

  HandleRegistrationState(this.registrationStateEnum);
}

class CallInState extends HandleState {
  final Call call;

  CallInState(this.call);
}

class GetContactState extends HandleState {
  List<Contact> contacts;

  GetContactState(this.contacts);
}

class SwitchTypeContactState extends HandleState {
  static int TYPE_OFFICE_CONTACT = 0;
  static int TYPE_PHONE_CONTACT = 1;
  final int type;
  final List<ContactDisplay> contacts;

  SwitchTypeContactState(this.type, this.contacts);
}

class LoadingContactState extends HandleState {
  final int type;

  LoadingContactState(this.type);
}

class CallingState extends HandleState {
  static int INCOMING_CALL = 0;
  static int CALL_OUT = 1;
  static int END_CALL = 2;
  static int ANSWER_CALL = 3;
  static int ACCEPT_CALL = 4;
  static int DECLINE_CALL = 5;
  final int callingState;
  final Call call;

  CallingState(this.callingState, this.call);
}

class LoadingHistoryState extends HandleState {}

class GotHistoryState extends HandleState {
  List<ResponseHistory> histories;
  String extSelf;

  GotHistoryState(this.histories, this.extSelf);
}

class CallOutState extends HandleState {
  final Call call;

  CallOutState(this.call);
}

class SignOutState extends HandleState {
  bool isSuccess;
  String message;

  SignOutState(this.isSuccess, this.message);
}

class ToggleTurnOnAccountState extends HandleState {
  bool isTurnOn;

  ToggleTurnOnAccountState(this.isTurnOn);
}

class AcceptCallFromFCMState extends HandleState {
  Call call;

  AcceptCallFromFCMState(this.call);
}
