class LogoutResponse {
  int code;
  String message;

  LogoutResponse({required this.code, required this.message});

  factory LogoutResponse.fromJson(Map<String, dynamic> json) =>
      LogoutResponse(code: json['code'], message: json['message']);

  Map<String, dynamic> toJson() => {"code": code, "message": message};

  @override
  String toString() {
    return 'LogoutResponse{code: $code, message: $message}';
  }
}
