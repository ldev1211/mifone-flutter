import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc_mifone/bloc/call/bloc.dart';
import 'package:flutter_webrtc_mifone/bloc/call/event.dart';
import 'package:flutter_webrtc_mifone/bloc/call/state.dart';
import 'package:flutter_webrtc_mifone/dart_sip/sip_ua_helper.dart';
import 'package:flutter_webrtc_mifone/main.dart';
import 'package:flutter_webrtc_mifone/screen/send_dtmf_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CallingPage extends StatefulWidget {
  const CallingPage(
      {Key? key,
      required this.callingState,
      required this.isCallOut,
      required this.extension,
      this.currCall})
      : super(key: key);
  final int callingState;
  final bool isCallOut;
  final Call? currCall;
  final String extension;

  @override
  State<CallingPage> createState() => CallingPageState();
}

class CallingPageState extends State<CallingPage> {
  late int callingState;
  static late CallBloc callBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callingState = widget.callingState;
    callBloc = CallBloc()
      ..add(InitEvent(widget.extension, widget.isCallOut, widget.currCall));
  }

  @override
  void dispose() async {
    super.dispose();
    await callBloc.close();
  }

  @override
  Widget build(BuildContext contextScreen) {
    double icSize = 18;
    double fontSizeText = 12;
    return BlocProvider(
      create: (context) => callBloc,
      child: Builder(builder: (context) {
        return BlocListener<CallBloc, BlocCallState>(
          listenWhen: (prev, curr) {
            return curr is CallingState;
          },
          listener: (context, state) {
            if (state is CallingState) {
              if (state.callingState == CallingState.END_CALL) {
                Navigator.pop(context);
              }
            }
          },
          child: Scaffold(
            backgroundColor: colorMain,
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(padding: EdgeInsets.only(top: 60)),
                  BlocBuilder<CallBloc, BlocCallState>(
                    buildWhen: (prev, curr) {
                      return curr is HandleRegistrationState;
                    },
                    builder: (context, state) {
                      if (state is HandleRegistrationState) {
                        if (state.registrationStateEnum ==
                            RegistrationStateEnum.REGISTERED) {
                          return Container(
                            margin: const EdgeInsets.only(left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: Colors.greenAccent,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50)),
                                      border: Border.all(
                                          width: 1.5, color: Colors.white)),
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(right: 12)),
                                Text(
                                  "Online",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fontSizeText),
                                )
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            margin: const EdgeInsets.only(left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50)),
                                      border: Border.all(
                                          width: 1.5, color: Colors.white)),
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(right: 12)),
                                Text(
                                  "Offline",
                                  style: TextStyle(
                                      color: Colors.red[400],
                                      fontSize: fontSizeText),
                                )
                              ],
                            ),
                          );
                        }
                      } else {
                        return Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50)),
                                    border: Border.all(
                                        width: 1.5, color: Colors.white)),
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(right: 12)),
                              Text(
                                "Registering",
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: fontSizeText),
                              )
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8)),
                  BlocBuilder<CallBloc, BlocCallState>(buildWhen: (prev, curr) {
                    return curr is UpdateNetworkStrengthState;
                  }, builder: (context, state) {
                    if (state is UpdateNetworkStrengthState) {
                      Icon ic;
                      Text text;
                      if (state.level == UpdateNetworkStrengthState.LOW) {
                        ic = Icon(
                          Icons.wifi_2_bar,
                          color: Colors.redAccent,
                          size: icSize,
                        );
                        text = Text(state.speedString,
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: fontSizeText));
                      } else if (state.level ==
                          UpdateNetworkStrengthState.NORMAL) {
                        ic = Icon(
                          Icons.wifi_2_bar,
                          color: Colors.white,
                          size: icSize,
                        );
                        text = Text(state.speedString,
                            style: TextStyle(
                                color: Colors.white, fontSize: fontSizeText));
                      } else {
                        ic = Icon(
                          Icons.wifi,
                          color: Colors.white,
                          size: icSize,
                        );
                        text = Text(state.speedString,
                            style: TextStyle(
                                color: Colors.white, fontSize: fontSizeText));
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ic,
                            const Padding(padding: EdgeInsets.only(right: 8)),
                            text
                          ],
                        ),
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Đang đo tốc độ mạng",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 50),
                      width: 150,
                      height: 150,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(100))),
                      child: const Icon(
                        Icons.person,
                        size: 80,
                        color: Color.fromARGB(255, 196, 196, 196),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 18)),
                  Text(
                    widget.extension,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 12)),
                  BlocBuilder<CallBloc, BlocCallState>(
                    buildWhen: (prev, curr) {
                      return curr is TimerSate;
                    },
                    builder: (context, state) {
                      if (state is TimerSate) {
                        return buildDuration(context, state.durationString);
                      }
                      return buildDuration(
                          context,
                          (callingState == CallingState.CALL_OUT &&
                                  !widget.isCallOut)
                              ? "Connecting..."
                              : (callingState == CallingState.INCOMING_CALL &&
                                      !widget.isCallOut)
                                  ? "Incoming call..."
                                  : "Calling...");
                    },
                  ),
                  BlocBuilder<CallBloc, BlocCallState>(
                    buildWhen: (prev, curr) {
                      return curr is CallingState;
                    },
                    builder: (context, state) {
                      if (state is CallingState) {
                        return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 40),
                            child: buildOptionAction(contextScreen,
                                state.callingState, state.isEnableSpeaker));
                      } else {
                        return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 40),
                            child: buildOptionAction(
                                contextScreen, callingState, false));
                      }
                    },
                  ),
                  const Spacer(),
                  BlocBuilder<CallBloc, BlocCallState>(
                    buildWhen: (prev, curr) {
                      return curr is CallingState ||
                          curr is DisableHangupButton;
                    },
                    builder: (context, state) {
                      if (state is CallingState) {
                        int type = state.callingState;
                        return buildAnswerDecline(context, type);
                      } else {
                        return buildAnswerDecline(context, callingState);
                      }
                    },
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 36))
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildDuration(BuildContext context, String stringDuration) {
    return Text(
      stringDuration,
      style: const TextStyle(color: Colors.white, fontSize: 20),
    );
  }

  Widget buildOptionAction(
      BuildContext context, int stateCalling, bool isEnableSpeaker) {
    bool isAnswerCall = stateCalling == CallingState.ANSWER_CALL ||
        stateCalling == CallingState.DISABLE_BUTTON;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SendDTMFScreen()));
              },
              child: buildButtonAction(
                  context,
                  const Icon(
                    Icons.dialpad,
                    color: Colors.white,
                  ),
                  "Numpad",
                  false),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                callBloc.add((isAnswerCall)
                    ? ToggleHoldCallEvent()
                    : ToggleSpeakerEvent());
              },
              child: BlocBuilder<CallBloc, BlocCallState>(
                buildWhen: (prev, curr) {
                  return curr is ToggleSpeakerState || curr is ToggleHoldState;
                },
                builder: (context, state) {
                  if (isAnswerCall) {
                    if (state is ToggleHoldState) {
                      return buildButtonAction(
                          context,
                          Icon(
                            (!isAnswerCall) ? Icons.volume_up : Icons.pause,
                            color: (state.isHold) ? Colors.black : Colors.white,
                          ),
                          (!isAnswerCall) ? "Speaker" : "Hold",
                          state.isHold);
                    }
                  } else {
                    if (state is ToggleSpeakerState) {
                      return buildButtonAction(
                          context,
                          Icon(
                            (!isAnswerCall) ? Icons.volume_up : Icons.pause,
                            color:
                                (state.isEnable) ? Colors.black : Colors.white,
                          ),
                          (!isAnswerCall) ? "Speaker" : "Hold",
                          state.isEnable);
                    }
                  }
                  return buildButtonAction(
                      context,
                      Icon(
                        (!isAnswerCall) ? Icons.volume_up : Icons.pause,
                        color: Colors.white,
                      ),
                      (!isAnswerCall) ? "Speaker" : "Hold",
                      false);
                },
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                callBloc.add(ToggleMuteCallEvent());
              },
              child: BlocBuilder<CallBloc, BlocCallState>(
                buildWhen: (prev, curr) {
                  return curr is ToggleMuteState;
                },
                builder: (context, state) {
                  if (state is ToggleMuteState) {
                    return buildButtonAction(
                        context,
                        Icon(
                          Icons.keyboard_voice_outlined,
                          color: (state.isMute) ? Colors.black : Colors.white,
                        ),
                        "Mute",
                        state.isMute);
                  }
                  return buildButtonAction(
                      context,
                      const Icon(
                        Icons.keyboard_voice_outlined,
                        color: Colors.white,
                      ),
                      "Mute",
                      false);
                },
              ),
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.only(top: 24)),
        if (isAnswerCall)
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  callBloc.add(ToggleSpeakerEvent());
                },
                child: BlocBuilder<CallBloc, BlocCallState>(
                  buildWhen: (prev, curr) {
                    return curr is ToggleSpeakerState;
                  },
                  builder: (context, state) {
                    if (state is ToggleSpeakerState) {
                      return buildButtonAction(
                          context,
                          Icon(
                            Icons.volume_up,
                            color:
                                (state.isEnable) ? Colors.black : Colors.white,
                          ),
                          "Speaker",
                          state.isEnable);
                    }
                    return buildButtonAction(
                        context,
                        Icon(
                          Icons.volume_up,
                          color:
                              (isEnableSpeaker) ? Colors.black : Colors.white,
                        ),
                        "Speaker",
                        isEnableSpeaker);
                  },
                ),
              ),
            ],
          )
      ],
    );
  }

  Widget buildButtonAction(
      BuildContext context, Icon icon, String actionName, bool isTapped) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 70,
          height: 70,
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
              color: (isTapped) ? Colors.white : Colors.white24,
              borderRadius: const BorderRadius.all(Radius.circular(50))),
          child: icon,
        ),
        Text(
          actionName,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        )
      ],
    );
  }

  Widget buildAnswerDecline(BuildContext context, int stateCalling) {
    double size = 70;
    if (stateCalling == CallingState.DISABLE_BUTTON) {
      Fluttertoast.showToast(
          msg: "Đang xử lý...",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 20.0);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (stateCalling == CallingState.DISABLE_BUTTON) return;
            if (stateCalling == CallingState.INCOMING_CALL) {
              callBloc.add(DeclineCallEvent());
            } else {
              callBloc.add(CancelCallEvent());
            }
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                color: (stateCalling == CallingState.DISABLE_BUTTON)
                    ? Colors.red[200]
                    : Colors.red,
                borderRadius: const BorderRadius.all(Radius.circular(100))),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        if (stateCalling == CallingState.INCOMING_CALL)
          GestureDetector(
            onTap: () {
              callBloc.add(AcceptCallEvent());
            },
            child: Container(
              margin: const EdgeInsets.only(left: 50),
              width: size,
              height: size,
              decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(100))),
              child: const Icon(
                Icons.phone,
                color: Colors.white,
                size: 30,
              ),
            ),
          )
      ],
    );
  }
}
