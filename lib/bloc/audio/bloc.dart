import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter_webrtc_mifone/api/entity/response/history_response.dart';
import 'package:flutter_webrtc_mifone/bloc/handle/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'event.dart';
import 'state.dart';

class AudioBloc extends Bloc<AudioBlocEvent, AudioState> {
  AudioPlayer player = AudioPlayer();
  bool isComplete = false;
  bool isPause = false;
  late Duration currDuration;

  AudioBloc() : super(InitState()) {
    on<InitEvent>((event, emit) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      player.onPositionChanged.listen((newPosition) {
        if (isComplete) return;
        if (isPause) return;
        currDuration = newPosition;
        add(ChangePositionEvent(currDuration, 1));
        print("on change");
      });
      player.onPlayerComplete.listen((event) {
        isComplete = true;
        add(ChangePositionEvent(const Duration(), 0));
        print("on complete");
      });
      add(GetListDetailHistoryEvent(event.extTarget));
    });

    on<ChangePositionEvent>((event, emit) async {
      print('return state: ${event.togglePlay}');
      emit(NewPositionState(event.currPosition, event.togglePlay));
    });

    on<CompleteAudioEvent>((event, emit) {
      emit(CompleteAudioState());
    });

    on<ToggleRecordHistoryCallEvent>((event, emit) async {
      if (event.togglePlay == 1) {
        emit(NewPositionState(const Duration(), -1));
        isComplete = false;
        isPause = false;
        if (Platform.isAndroid) {
          await player.play(UrlSource(event.url));
        } else {
          convertOggToWav(event.url);
        }
      } else {
        isPause = true;
        await player.pause();
        add(ChangePositionEvent(Duration(seconds: currDuration.inSeconds), 0));
      }
    });

    on<GetListDetailHistoryEvent>((event, emit) async {
      String extTarget = event.extTarget;
      String selfExt =
          (await SharedPreferences.getInstance()).getString('extension') ?? "";
      List<ResponseHistory> tmp = [];

      HandleBloc.histories.forEach((element) {
        if ((element.caller == extTarget || element.called == extTarget)) {
          tmp.add(element);
        }
      });
      emit(GetListDetailHistoryState(tmp, selfExt));
    });
  }

  void convertOggToWav(String oggUrl) async {
    final Directory tempDir = Directory.systemTemp;
    final String oggFilePath = '${tempDir.path}/temp_audio.ogg';
    final String wavFilePath = '${tempDir.path}/temp_audio.wav';
    await FFmpegKit.execute('-i $oggUrl $oggFilePath');
    FFmpegKit.execute('-y -i $oggFilePath -c:a pcm_s16le $wavFilePath')
        .then((session) async {
      final returnCode = await session.getReturnCode();
      await player.play(DeviceFileSource(wavFilePath));
      print('played');
      if (ReturnCode.isSuccess(returnCode)) {
      } else if (ReturnCode.isCancel(returnCode)) {
        print('wav path cancel: $wavFilePath');
        // CANCEL
      } else {
        print('wav path error: $wavFilePath');
        // ERROR
      }
    });
  }
}
