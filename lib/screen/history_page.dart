import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc_mifone/bloc/handle/bloc.dart';
import 'package:flutter_webrtc_mifone/bloc/handle/event.dart';
import 'package:flutter_webrtc_mifone/bloc/handle/state.dart';
import 'package:flutter_webrtc_mifone/screen/calling_page.dart';
import 'package:flutter_webrtc_mifone/screen/history_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime nowDateTime = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BlocBuilder<HandleBloc, HandleState>(buildWhen: (prev, curr) {
              return curr is GotHistoryState || curr is LoadingHistoryState;
            }, builder: (context, state) {
              if (state is GotHistoryState) {
                return Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: state.histories.length,
                      itemBuilder: (context, i) {
                        String extSelf = state.extSelf;
                        String extDisplayed =
                            (extSelf == state.histories[i].called)
                                ? state.histories[i].caller!
                                : state.histories[i].called!;
                        String extTarget =
                            !(extSelf == state.histories[i].called)
                                ? state.histories[i].caller!
                                : state.histories[i].called!;
                        bool isCallOut = (extSelf == state.histories[i].called)
                            ? false
                            : true;
                        bool isAnswer =
                            (state.histories[i].callstatus == "ANSWERED"
                                ? true
                                : false);
                        String stringTimeRaw =
                            (state.histories[i].calldate!.split(' ')[1]);
                        List<String> arrTimeDisplayed =
                            stringTimeRaw.split(':');
                        String timeDisplayed =
                            "${arrTimeDisplayed[0]}:${arrTimeDisplayed[1]}";
                        DateTime dateTimeDataCurrItem =
                            DateTime.parse(state.histories[i].calldate!);
                        DateTime? dateTimeDataPrevItem;
                        bool? isEqualDate;
                        if (i == 0) {
                          isEqualDate = false;
                        } else {
                          dateTimeDataPrevItem =
                              DateTime.parse(state.histories[i - 1].calldate!);
                          isEqualDate = this.isEqualDate(
                              dateTimeDataCurrItem, dateTimeDataPrevItem);
                        }
                        if (isEqualDate) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CallingPage(
                                          callingState: CallingState.CALL_OUT,
                                          isCallOut: true,
                                          extension: extDisplayed)));
                              BlocProvider.of<HandleBloc>(context)
                                  .add(CallOutEvent());
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  border: Border.symmetric(
                                      horizontal: BorderSide(
                                          color: Colors.grey, width: 0.1)),
                                  color: Colors.white),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    (isCallOut)
                                        ? Icons.phone_forwarded
                                        : Icons.phone_callback_rounded,
                                    color:
                                        (isAnswer) ? Colors.green : Colors.red,
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(right: 12)),
                                  Text(
                                    extDisplayed,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                  const Spacer(),
                                  Text(
                                    timeDisplayed,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(right: 8)),
                                  const Padding(
                                      padding: EdgeInsets.only(right: 8)),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailHistoryPage(
                                                      history:
                                                          state.histories[i],
                                                      displayedName:
                                                          extDisplayed,
                                                      extTarget: extTarget,
                                                    )));
                                      },
                                      child: const Icon(Icons.info_outline,
                                          color: Colors.blue))
                                ],
                              ),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CallingPage(
                                          callingState: CallingState.CALL_OUT,
                                          isCallOut: true,
                                          extension: extDisplayed)));
                              BlocProvider.of<HandleBloc>(context)
                                  .add(CallOutEvent());
                            },
                            child: Container(
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                              padding: const EdgeInsets.all(12),
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        getNameDayFromEnum(
                                            dateTimeDataCurrItem),
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      )
                                    ],
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 24)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        (isCallOut)
                                            ? Icons.phone_forwarded
                                            : Icons.phone_callback_rounded,
                                        color: (isAnswer)
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const Padding(
                                          padding: EdgeInsets.only(right: 12)),
                                      Text(
                                        extDisplayed,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                      const Spacer(),
                                      Text(
                                        timeDisplayed,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 15),
                                      ),
                                      const Padding(
                                          padding: EdgeInsets.only(right: 8)),
                                      const Padding(
                                          padding: EdgeInsets.only(right: 8)),
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailHistoryPage(
                                                          history: state
                                                              .histories[i],
                                                          displayedName:
                                                              extDisplayed,
                                                          extTarget: extTarget,
                                                        )));
                                          },
                                          child: const Icon(Icons.info_outline,
                                              color: Colors.blue))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }),
                );
              } else {
                return const CircularProgressIndicator();
              }
            })
          ],
        ),
      ),
    );
  }

  bool isEqualDate(DateTime a, DateTime b) {
    return a.day == b.day && a.month == b.month && a.year == b.year;
  }

  String getNameDayFromEnum(DateTime dateTimeCheck) {
    if (isEqualDate(nowDateTime, dateTimeCheck)) {
      return 'HÔM NAY';
    } else if (isEqualDate(
        DateTime.fromMillisecondsSinceEpoch(
            nowDateTime.millisecondsSinceEpoch - Duration.millisecondsPerDay),
        dateTimeCheck)) {
      return "HÔM QUA";
    } else {
      String weekDayString = "";
      switch (dateTimeCheck.weekday) {
        case 1:
          weekDayString = "THỨ HAI";
          break;
        case 2:
          weekDayString = "THỨ BA";
          break;
        case 3:
          weekDayString = "THỨ TƯ";
          break;
        case 4:
          weekDayString = "THỨ NĂM";
          break;
        case 5:
          weekDayString = "THỨ SÁU";
          break;
        case 6:
          weekDayString = "THỨ BẢY";
          break;
        case 7:
          weekDayString = "CHỦ NHẬT";
          break;
      }
      return '$weekDayString,${dateTimeCheck.day} tháng ${dateTimeCheck.month} năm ${dateTimeCheck.year}';
    }
    return "";
  }
}
