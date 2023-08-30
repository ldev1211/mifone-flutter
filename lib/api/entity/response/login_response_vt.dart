// To parse this JSON data, do
//
//     final responseLogin = responseLoginFromJson(jsonString);

import 'dart:convert';

class ResponseLogin {
  final int code;
  final String message;
  final String data;
  final int userLogId;
  final int groupId;
  final List<Privilege> privileges;
  final String secret;
  final String? dataV2;

  ResponseLogin({
    required this.code,
    required this.message,
    required this.data,
    required this.userLogId,
    required this.groupId,
    required this.privileges,
    required this.secret,
    this.dataV2,
  });

  factory ResponseLogin.fromRawJson(String str) => ResponseLogin.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() {
    return 'ResponseLogin{code: $code, message: $message, data: $data, userLogId: $userLogId, groupId: $groupId, privileges: $privileges, secret: $secret, dataV2: $dataV2}';
  }

  factory ResponseLogin.fromJson(Map<String, dynamic> json) => ResponseLogin(
    code: json["code"],
    message: json["message"],
    data: json["data"],
    userLogId: json["user_log_id"],
    groupId: json["groupId"],
    privileges: List<Privilege>.from(json["privileges"].map((x) => Privilege.fromJson(x))),
    secret: json["secret"],
    dataV2: json["datav2"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data,
    "user_log_id": userLogId,
    "groupId": groupId,
    "privileges": List<dynamic>.from(privileges.map((x) => x.toJson())),
    "secret": secret,
    "datav2": dataV2,
  };
}

class Privilege {
  final String page;
  final String permission;

  Privilege({
    required this.page,
    required this.permission,
  });

  factory Privilege.fromRawJson(String str) => Privilege.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Privilege.fromJson(Map<String, dynamic> json) => Privilege(
    page: json["page"],
    permission: json["permission"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "permission": permission,
  };
}
