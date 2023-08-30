import 'package:flutter_webrtc_mifone/api/entity/response/history_response.dart';

abstract class AudioState {}

class InitState extends AudioState {}

class NewPositionState extends AudioState {
  final Duration newPosition;
  final int togglePlay;

  NewPositionState(this.newPosition, this.togglePlay);
}

class CompleteAudioState extends AudioState {}

class CallTypeState extends AudioState {
  String selfExt;

  CallTypeState(this.selfExt);
}

class GetListDetailHistoryState extends AudioState {
  List<ResponseHistory> historiesDetail;
  String selfExt;

  GetListDetailHistoryState(this.historiesDetail, this.selfExt);
}
