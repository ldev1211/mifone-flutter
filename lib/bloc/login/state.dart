class LoginState {}

class InitState extends LoginState {}

class SigningState extends LoginState {
  bool isSuccess;
  String selfExt;

  SigningState(this.isSuccess, this.selfExt);
}

class ToggleRememberState extends LoginState {
  final bool val;

  ToggleRememberState(this.val);
}

class AuthenticateKeyState extends LoginState {
  final bool isSuccess;

  AuthenticateKeyState(this.isSuccess);
}

class ToggleUseCustomDomainState extends LoginState {
  bool isUse;

  ToggleUseCustomDomainState(this.isUse);
}

class ToggleHidePasswordState extends LoginState {
  bool isHide;

  ToggleHidePasswordState(this.isHide);
}
