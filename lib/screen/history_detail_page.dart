import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc_mifone/api/entity/response/history_response.dart';
import 'package:flutter_webrtc_mifone/bloc/audio/event.dart';
import 'package:flutter_webrtc_mifone/bloc/audio/state.dart';
import 'package:flutter_webrtc_mifone/main.dart';

import '../bloc/audio/bloc.dart';

class DetailHistoryPage extends StatefulWidget {
  const DetailHistoryPage(
      {Key? key,
      required this.history,
      required this.displayedName,
      required this.extTarget})
      : super(key: key);

  final ResponseHistory history;
  final String displayedName; //HVBV500
  final String extTarget;

  @override
  State<DetailHistoryPage> createState() => _DetailHistoryPageState();
}

class _DetailHistoryPageState extends State<DetailHistoryPage> {
  late ResponseHistory history;

  late AudioBloc audioBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    history = widget.history;
    audioBloc = AudioBloc()..add(InitEvent(widget.extTarget));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => audioBloc,
      child: Builder(builder: (context) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.only(top: 36)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                              color: colorMain,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          )),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 12)),
                  Text(
                    widget.displayedName,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 30),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // BlocProvider.of<AudioBloc>(context).add(CallOutEvent(widget.displayedName));
                        },
                        child: Container(
                            width: 50,
                            height: 50,
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            child: const Icon(
                              Icons.phone,
                              color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 24)),
                  if (history.recordingfile != null)
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: BlocBuilder<AudioBloc, AudioState>(
                        builder: (context, state) {
                          if (state is NewPositionState) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Padding(
                                    padding: EdgeInsets.only(right: 12)),
                                GestureDetector(
                                    onTap: () {
                                      BlocProvider.of<AudioBloc>(context).add(
                                          ToggleRecordHistoryCallEvent(
                                              history.recordingfile!,
                                              (state.togglePlay == 1) ? 0 : 1));
                                    },
                                    child: (state.togglePlay == -1)
                                        ? const SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ))
                                        : Icon(
                                            (state.togglePlay == 1)
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.black,
                                          )),
                                const Padding(
                                    padding: EdgeInsets.only(right: 8)),
                                Text(
                                  '${(state.newPosition.inMinutes < 10) ? '0${state.newPosition.inMinutes}' : state.newPosition.inMinutes}:${(state.newPosition.inSeconds < 10) ? '0${state.newPosition.inSeconds}' : state.newPosition.inSeconds}',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                                Expanded(
                                  child: Slider(
                                      min: 0,
                                      max: history.billsec!.toDouble(),
                                      value: state.newPosition.inSeconds
                                          .toDouble(),
                                      onChanged: (val) {}),
                                ),
                                Text(
                                  '${((history.billsec! ~/ 60) < 10) ? '0${history.billsec! ~/ 60}' : (history.billsec! ~/ 60)}:${((history.billsec! % 60) < 10) ? '0${(history.billsec! % 60)}' : (history.billsec! % 60)}',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(right: 12)),
                              ],
                            );
                          } else {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Padding(
                                    padding: EdgeInsets.only(right: 12)),
                                GestureDetector(
                                    onTap: () {
                                      BlocProvider.of<AudioBloc>(context).add(
                                          ToggleRecordHistoryCallEvent(
                                              history.recordingfile!, 1));
                                    },
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.black,
                                    )),
                                const Padding(
                                    padding: EdgeInsets.only(right: 8)),
                                const Text(
                                  '00:00',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                                Expanded(
                                  child: Slider(
                                      min: 0,
                                      max: history.billsec!.toDouble(),
                                      value: 0,
                                      onChanged: (val) {}),
                                ),
                                Text(
                                  '${((history.billsec! ~/ 60) < 10) ? '0${history.billsec! ~/ 60}' : (history.billsec! ~/ 60)}:${((history.billsec! % 60) < 10) ? '0${(history.billsec! % 60)}' : (history.billsec! % 60)}',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(right: 12)),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  const Padding(padding: EdgeInsets.only(top: 12)),
                  BlocBuilder<AudioBloc, AudioState>(buildWhen: (prev, curr) {
                    return curr is GetListDetailHistoryState;
                  }, builder: (context, state) {
                    if (state is GetListDetailHistoryState) {
                      List<ResponseHistory> histories = state.historiesDetail;
                      return Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: histories.length,
                            itemBuilder: (context, i) {
                              bool isCallBack =
                                  state.selfExt == histories[i].called;
                              bool isAnswered =
                                  histories[i].callstatus! == 'ANSWERED';
                              return Container(
                                height: 60,
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 24),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12))),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isCallBack
                                          ? Icons.phone_callback
                                          : Icons.phone_forwarded,
                                      color: isAnswered
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(right: 12)),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            histories[i].calldate!,
                                            style: const TextStyle(
                                              color: colorMain,
                                            ),
                                          ),
                                          const Padding(
                                              padding: EdgeInsets.only(top: 4)),
                                          Text(
                                            histories[i].callstatus!,
                                            style: const TextStyle(
                                              color: Colors.black,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                      );
                    }
                    return Container();
                  }),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
