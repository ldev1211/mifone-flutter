import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Profile {
  final String domain;
  final String port;
  final String proxy;
  final String extension;
  final String password;
  final String transport;

  Profile(this.domain, this.port, this.proxy, this.extension, this.password,
      this.transport);

  @override
  String toString() {
    return 'Profile{domain: $domain, port: $port, proxy: $proxy, extension: $extension, password: $password, transport: $transport}';
  }

  factory Profile.fromJson(Map<String,dynamic> json) => Profile(
    json['domain'] as String,
    json['port'] as String,
    json['proxy'] as String,
    json['extension'] as String,
    json['password'] as String,
    json['transport'] as String,
  );

  Map<String,dynamic> toJson() => <String, dynamic>{
    'domain': domain,
    'port': port,
    'proxy': proxy,
    'extension': extension,
    'password': password,
    'transport': transport,
  };
}