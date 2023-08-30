// To parse this JSON data, do
//
//     final responseContact = responseContactFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class ContactResponse {
  final int code;
  final List<ContactOffice> data;

  ContactResponse({
    required this.code,
    required this.data,
  });

  factory ContactResponse.fromRawJson(String str) => ContactResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ContactResponse.fromJson(Map<String, dynamic> json) => ContactResponse(
    code: json["code"],
    data: List<ContactOffice>.from(json["data"].map((x) => ContactOffice.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class ContactOffice {
  final String firstName;
  final String lastName;
  final String extension;
  final String userAvatar;

  ContactOffice({
    required this.firstName,
    required this.lastName,
    required this.extension,
    required this.userAvatar,
  });

  factory ContactOffice.fromRawJson(String str) => ContactOffice.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ContactOffice.fromJson(Map<String, dynamic> json) => ContactOffice(
    firstName: json["firstName"],
    lastName: json["lastName"],
    extension: json["extension"],
    userAvatar: json["user_avatar"],
  );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "extension": extension,
    "user_avatar": userAvatar,
  };
}
