import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Privilege {
  final String page;
  final String permission;


  factory Privilege.fromJson(Map<String,dynamic> json) => Privilege(
    json['page'] as String,
    json['permission'] as String,
  );

  Privilege(this.page, this.permission);

  Map<String,dynamic> toJson() => <String, dynamic>{
    'page': page,
    'permission': permission,
  };
}