import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt.dart';
import 'package:flutter_webrtc_mifone/api/entity/model/profile.dart';

class DecodeProfile {
  final String dataHashed;
  final String secret;

  DecodeProfile(this.dataHashed, this.secret);

  Profile decryptAES() {
    String key = 'b6aed9ab7cdf85432c321757b4d48153';
    final dataBytes = base64.decode(dataHashed);
    final iv = dataBytes.sublist(0, 16);
    final encrypted = dataBytes.sublist(16);

    final decrypter =
        Encrypter(AES(encrypt.Key.fromUtf8(key), mode: AESMode.cbc));
    final decrypted = decrypter.decryptBytes(
      Encrypted(encrypted),
      iv: IV(iv),
    );
    String decodedText = utf8.decode(decrypted);
    print("Text decoded: $decodedText");
    Map<String, dynamic> mapData = json.decode(decodedText);
    String domain = mapData['domain'];
    String port = mapData['port'];
    String proxy = mapData['proxy'];
    String extension = mapData['extension'];
    String password = mapData['password'];
    String transport = mapData['transports'];
    Profile profile =
        Profile(domain, '5769', proxy, extension, password, transport);
    return profile;
  }

  Profile decodeProfile() {
    String decoded1 = utf8.decode(base64.decode(dataHashed));
    String decoded2 = utf8.decode(base64.decode(decoded1));
    String decoded3 = utf8.decode(base64.decode(decoded2));
    List<String> arrInf = decoded3.split('b6aed9ab7cdf85432c321757b4d48153');
    String domain = utf8.decode(base64.decode(arrInf[0]));
    String port = utf8.decode(base64.decode(arrInf[1]));
    String proxy = utf8.decode(base64.decode(arrInf[2]));
    String extension = utf8.decode(base64.decode(arrInf[3]));
    String password = utf8.decode(base64.decode(arrInf[4]));
    String transport = utf8.decode(base64.decode(arrInf[5]));
    return Profile(domain, '4533', proxy, extension, password, transport);
  }
}
