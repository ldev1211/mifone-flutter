// To parse this JSON data, do
//
//     final responseAuthenKey = responseAuthenKeyFromJson(jsonString);

import 'dart:convert';

class ResponseAuthenKey {
  final String? message;
  final bool? status;
  final Data? data;
  final int? count;

  ResponseAuthenKey({
    this.message,
    this.status,
    this.data,
    this.count,
  });

  factory ResponseAuthenKey.fromRawJson(String str) =>
      ResponseAuthenKey.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ResponseAuthenKey.fromJson(Map<String, dynamic> json) =>
      ResponseAuthenKey(
        message: json["message"],
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "data": data?.toJson(),
        "count": count,
      };
}

class Data {
  final String? url;
  final String? typeSystem;

  Data({
    this.url,
    this.typeSystem,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        url: json["url"],
        typeSystem: json["type_system"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "type_system": typeSystem,
      };
}
