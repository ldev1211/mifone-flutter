abstract class AudioBlocEvent {}

class InitEvent extends AudioBlocEvent {
  String extTarget;

  InitEvent(this.extTarget);
}

class ToggleRecordHistoryCallEvent extends AudioBlocEvent {
  final String url;
  final int togglePlay;

  ToggleRecordHistoryCallEvent(this.url, this.togglePlay);
}

class ChangePositionEvent extends AudioBlocEvent {
  Duration currPosition;
  int togglePlay;

  ChangePositionEvent(this.currPosition, this.togglePlay);
}

class CompleteAudioEvent extends AudioBlocEvent {}

class GetListDetailHistoryEvent extends AudioBlocEvent {
  String extTarget;

  GetListDetailHistoryEvent(this.extTarget);
}
