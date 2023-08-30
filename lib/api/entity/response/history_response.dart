// To parse this JSON data, do
//
//     final responseHistory = responseHistoryFromJson(jsonString);

import 'dart:convert';

class ResponseHistory {
  final int? recid;
  final String? calldate;
  final String? callrefid;
  final String? caller;
  final String? called;
  final String? agentid;
  final String? did;
  final String? calltype;
  final String? callstatus;
  final int? billsec;
  final int? duration;
  final String? recordingfile;

  ResponseHistory({
    this.recid,
    this.calldate,
    this.callrefid,
    this.caller,
    this.called,
    this.agentid,
    this.did,
    this.calltype,
    this.callstatus,
    this.billsec,
    this.duration,
    this.recordingfile,
  });

  factory ResponseHistory.fromRawJson(String str) => ResponseHistory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ResponseHistory.fromJson(Map<String, dynamic> json) => ResponseHistory(
    recid: json["recid"],
    calldate: json["calldate"],
    callrefid: json["callrefid"],
    caller: json["caller"],
    called: json["called"],
    agentid: json["agentid"],
    did: json["did"],
    calltype: json["calltype"],
    callstatus: json["callstatus"],
    billsec: json["billsec"],
    duration: json["duration"],
    recordingfile: json["recordingfile"],
  );

  Map<String, dynamic> toJson() => {
    "recid": recid,
    "calldate": calldate,
    "callrefid": callrefid,
    "caller": caller,
    "called": called,
    "agentid": agentid,
    "did": did,
    "calltype": calltype,
    "callstatus": callstatus,
    "billsec": billsec,
    "duration": duration,
    "recordingfile": recordingfile,
  };

  @override
  String toString() {
    return 'ResponseHistory{recid: $recid, calldate: $calldate, callrefid: $callrefid, caller: $caller, called: $called, agentid: $agentid, did: $did, calltype: $calltype, callstatus: $callstatus, billsec: $billsec, duration: $duration, recordingfile: $recordingfile}';
  }
}
