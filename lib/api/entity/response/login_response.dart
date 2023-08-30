// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

class LoginResponse {
  final int status;
  final Data data;
  final String accessToken;

  LoginResponse({
    required this.status,
    required this.data,
    required this.accessToken,
  });

  factory LoginResponse.fromRawJson(String str) => LoginResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    status: json["status"],
    data: Data.fromJson(json["data"]),
    accessToken: json["access_token"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.toJson(),
    "access_token": accessToken,
  };

  @override
  String toString() {
    return 'LoginResponse{status: $status, data: $data, accessToken: $accessToken}';
  }
}

class Data {
  final int userId;
  final String role;
  final String username;
  final dynamic avatar;
  final String firstname;
  final String lastname;
  final String brand;
  final String type;
  final String fullname;
  final int groupid;
  final String callData;

  Data({
    required this.userId,
    required this.role,
    required this.username,
    this.avatar,
    required this.firstname,
    required this.lastname,
    required this.brand,
    required this.type,
    required this.fullname,
    required this.groupid,
    required this.callData,
  });

  @override
  String toString() {
    return 'Data{userId: $userId, role: $role, username: $username, avatar: $avatar, firstname: $firstname, lastname: $lastname, brand: $brand, type: $type, fullname: $fullname, groupid: $groupid, callData: $callData}';
  }

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["user_id"],
    role: json["role"],
    username: json["username"],
    avatar: json["avatar"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    brand: json["brand"],
    type: json["type"],
    fullname: json["fullname"],
    groupid: json["groupid"],
    callData: json["call_data"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "role": role,
    "username": username,
    "avatar": avatar,
    "firstname": firstname,
    "lastname": lastname,
    "brand": brand,
    "type": type,
    "fullname": fullname,
    "groupid": groupid,
    "call_data": callData,
  };
}
