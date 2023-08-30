import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc_mifone/bloc/handle/event.dart';
import 'package:flutter_webrtc_mifone/bloc/handle/state.dart';
import 'package:flutter_webrtc_mifone/main.dart';
import 'package:flutter_webrtc_mifone/screen/about_page.dart';
import 'package:flutter_webrtc_mifone/screen/calling_page.dart';
import 'package:flutter_webrtc_mifone/screen/contact_page.dart';
import 'package:flutter_webrtc_mifone/screen/history_page.dart';
import 'package:flutter_webrtc_mifone/screen/login_page.dart';
import 'package:flutter_webrtc_mifone/screen/numpad_page.dart';
import 'package:flutter_webrtc_mifone/sip_ua.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/handle/bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.selfExt}) : super(key: key);

  final String selfExt;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // TODO: implement didChangeAppLifecycleState
    print("State app curr: $state");
    if (Platform.isAndroid) {
      if (state == AppLifecycleState.inactive) {
        handleBloc.add(UnRegisterSipEvent());
      } else if (state == AppLifecycleState.resumed) {
        handleBloc.add(RegisterSipEvent());
      } else if (state == AppLifecycleState.paused) {
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setBool("isInitialFbFromBg", false);
        SystemNavigator.pop(animated: true);
      }
    } else {
      if (state == AppLifecycleState.resumed) {
        handleBloc.add(RegisterSipEvent());
      } else if (state == AppLifecycleState.paused) {
        handleBloc.add(UnRegisterSipEvent());
        MethodChannel channel = const MethodChannel("channel_check_flag");
        bool isCloseAppSuccess = await channel.invokeMethod("close_app");
        if (isCloseAppSuccess) {
          exit(0);
        }
      }
    }
  }

  int pageIndex = 2;
  PageController? pageController;
  late String selfExt;
  final pages = [
    const HistoryPage(),
    const ContactScreen(),
    const NumpadScreen(),
  ];

  late HandleBloc handleBloc;

  Future<void> checkMicroPermission() async {
    var isStatusMicGranted = await Permission.microphone.isGranted;
    print("status mic: $isStatusMicGranted");
    if (!isStatusMicGranted) {
      PermissionStatus permission = await Permission.microphone.request();
      print("Permission after request: $permission");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    handleBloc = HandleBloc()..add(InitEvent("MAIN PAGE"));
    WidgetsBinding.instance.addObserver(this);
    pageController = PageController(initialPage: pageIndex);
    checkMicroPermission();
  }

  bool isTurnOnAccount = true;

  @override
  Widget build(BuildContext context) {
    double sizeIcon = 30;
    return BlocProvider(
      create: (context) => handleBloc,
      child: Builder(builder: (context) {
        return BlocListener<HandleBloc, HandleState>(
          listenWhen: (prev, curr) {
            return curr is CallOutState ||
                curr is CallInState ||
                curr is SignOutState ||
                curr is AcceptCallFromFCMState ||
                curr is HandleRegistrationState;
          },
          listener: (context, state) {
            if (state is CallInState) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CallingPage(
                            callingState: CallingState.INCOMING_CALL,
                            isCallOut: false,
                            extension: state.call.remote_identity!,
                            currCall: state.call,
                          )));
            } else if (state is SignOutState) {
              if (state.isSuccess) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              } else {
                Fluttertoast.showToast(
                    msg: state.message,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 14.0);
              }
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: colorMain,
              leadingWidth: 120,
              leading: BlocBuilder<HandleBloc, HandleState>(
                buildWhen: (prev, curr) {
                  return curr is HandleRegistrationState;
                },
                builder: (context, state) {
                  if (state is HandleRegistrationState) {
                    if (state.registrationStateEnum ==
                        RegistrationStateEnum.REGISTERED) {
                      return Container(
                        margin: const EdgeInsets.only(left: 12),
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
                            const Padding(padding: EdgeInsets.only(right: 10)),
                            const Text(
                              "Online",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            )
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.only(left: 12),
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
                            const Padding(padding: EdgeInsets.only(right: 4)),
                            Text(
                              "Offline",
                              style: TextStyle(
                                  color: Colors.red[400], fontSize: 15),
                            )
                          ],
                        ),
                      );
                    }
                  } else {
                    return Container(
                      margin: const EdgeInsets.only(left: 12),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check,
                            color: Colors.orange,
                          ),
                          Padding(padding: EdgeInsets.only(right: 4)),
                          Text(
                            "Registering",
                            style:
                                TextStyle(color: Colors.orange, fontSize: 15),
                          )
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            endDrawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.contact_phone_outlined,
                          weight: 1,
                        ),
                        const Padding(padding: EdgeInsets.only(right: 12)),
                        Text(
                          widget.selfExt,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        BlocBuilder<HandleBloc, HandleState>(
                          buildWhen: (prev, curr) {
                            return curr is ToggleTurnOnAccountState ||
                                curr is HandleRegistrationState;
                          },
                          builder: (context, state) {
                            if (state is ToggleTurnOnAccountState) {
                              isTurnOnAccount = state.isTurnOn;
                              return Switch(
                                  activeColor: colorMain,
                                  value: isTurnOnAccount,
                                  onChanged: (val) {
                                    BlocProvider.of<HandleBloc>(context)
                                        .add(ToggleTurnOnAccountEvent(val));
                                  });
                            } else if (state is HandleRegistrationState) {
                              isTurnOnAccount = (state.registrationStateEnum ==
                                      RegistrationStateEnum.REGISTERED)
                                  ? true
                                  : false;
                              return Switch(
                                  activeColor: colorMain,
                                  value: isTurnOnAccount,
                                  onChanged: (val) {
                                    BlocProvider.of<HandleBloc>(context)
                                        .add(ToggleTurnOnAccountEvent(val));
                                  });
                            }
                            return Switch(
                                activeColor: colorMain,
                                value: isTurnOnAccount,
                                onChanged: (val) {
                                  BlocProvider.of<HandleBloc>(context)
                                      .add(ToggleTurnOnAccountEvent(val));
                                });
                          },
                        ),
                      ],
                    ),
                  ),
                  // ListTile(
                  //   title: const Row(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [
                  //       Icon(Icons.settings),
                  //       Padding(padding: EdgeInsets.only(right: 12)),
                  //       Text(
                  //         "Setting",
                  //         style: TextStyle(fontSize: 16),
                  //       )
                  //     ],
                  //   ),
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  // const Divider(
                  //   height: 1,
                  //   color: Colors.grey,
                  // ),
                  ListTile(
                    title: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline_rounded),
                        Padding(padding: EdgeInsets.only(right: 12)),
                        Text(
                          "About",
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutPage()));
                    },
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                  ListTile(
                    title: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.logout),
                        Padding(padding: EdgeInsets.only(right: 12)),
                        Text(
                          "Log out",
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                    onTap: () {
                      BlocProvider.of<HandleBloc>(context).add(SignOutEvent());
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            body: Column(children: [
              Expanded(
                  child: IndexedStack(
                index: pageIndex,
                children: pages,
              ))
            ]),
            bottomNavigationBar: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 0.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        pageIndex = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            color: (pageIndex == 0) ? colorMain : Colors.grey,
                            size: sizeIcon,
                          ),
                          const Padding(padding: EdgeInsets.only(top: 4)),
                          Text(
                            "Recent",
                            style: TextStyle(
                                color:
                                    (pageIndex == 0) ? colorMain : Colors.grey),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        pageIndex = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.perm_contact_cal,
                            color: (pageIndex == 1) ? colorMain : Colors.grey,
                            size: sizeIcon,
                          ),
                          const Padding(padding: EdgeInsets.only(top: 4)),
                          Text(
                            "Contact",
                            style: TextStyle(
                                color:
                                    (pageIndex == 1) ? colorMain : Colors.grey),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        pageIndex = 2;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.dialpad,
                            color: (pageIndex == 2) ? colorMain : Colors.grey,
                            size: sizeIcon,
                          ),
                          const Padding(padding: EdgeInsets.only(top: 4)),
                          Text(
                            "Numpad",
                            style: TextStyle(
                                color:
                                    (pageIndex == 2) ? colorMain : Colors.grey),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
