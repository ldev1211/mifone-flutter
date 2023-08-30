abstract class LoginEvent {}

class InitEvent extends LoginEvent {}

class SigningEvent extends LoginEvent {
  final String email;
  final String password;
  final String? key;

  SigningEvent(this.email, this.password, this.key);
}

class ToggleRememberEvent extends LoginEvent {
  final bool val;
  ToggleRememberEvent(this.val);
}

class AuthenticateKeyEvent extends LoginEvent {
  final String key;

  AuthenticateKeyEvent(this.key);
}

class ToggleUseCustomDomainEvent extends LoginEvent {
  final bool isUse;

  ToggleUseCustomDomainEvent(this.isUse);
}

class ToggleHidePasswordEvent extends LoginEvent {
  final bool isHide;

  ToggleHidePasswordEvent(this.isHide);
}
