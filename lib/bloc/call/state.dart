import '../../sip_ua.dart';

class BlocCallState {}

class CallingState extends BlocCallState {
  static int INCOMING_CALL = 0;
  static int CALL_OUT = 1;
  static int END_CALL = 2;
  static int ANSWER_CALL = 3;
  static int ACCEPT_CALL = 4;
  static int DECLINE_CALL = 5;
  static int DISABLE_BUTTON = 6;
  final int callingState;
  final bool isEnableSpeaker;
  final Call? call;

  CallingState(this.callingState, this.call, this.isEnableSpeaker);
}

class HandleRegistrationState extends BlocCallState {
  RegistrationStateEnum registrationStateEnum;

  HandleRegistrationState(this.registrationStateEnum);
}

class UpdateNetworkStrengthState extends BlocCallState {
  static int LOW = 0;
  static int NORMAL = 1;
  static int STRONG = 2;
  int level;
  String speedString;

  UpdateNetworkStrengthState(this.level, this.speedString);
}

class DisableHangupButton extends BlocCallState {}

class TimerSate extends BlocCallState {
  final String durationString;

  TimerSate(this.durationString);
}

class ToggleSpeakerState extends BlocCallState {
  bool isEnable;

  ToggleSpeakerState(this.isEnable);
}

class ToggleMuteState extends BlocCallState {
  bool isMute;

  ToggleMuteState(this.isMute);
}

class ToggleHoldState extends BlocCallState {
  bool isHold;

  ToggleHoldState(this.isHold);
}
