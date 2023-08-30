import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc_mifone/bloc/call/state.dart';
import 'package:flutter_webrtc_mifone/screen/calling_page.dart';
import 'package:flutter_webrtc_mifone/screen/login_page.dart';
import 'package:flutter_webrtc_mifone/screen/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const Color colorTheme = Colors.lightBlueAccent;
const Color colorMain = Color(0xFF0277BD);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await PreferenceUtils.init();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String selfExt = sharedPreferences.getString("extension") ?? '';
  MethodChannel channel = const MethodChannel("channel_check_flag");
  bool isIncomingFlag = false;
  if (Platform.isIOS) {
    isIncomingFlag = await channel.invokeMethod("check_flag_incoming");
  }
  print(
      'IS ANSWER CALL WHEN CHECK FLAG FROM MAIN FUNC= ${sharedPreferences.getBool("isAnswerCall")}');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Flutter Demo',
    home: (sharedPreferences.getString("profile") == null ||
            sharedPreferences.getString("profile") == "")
        ? const LoginPage()
        : ((sharedPreferences.getBool('isIncomingFromFCM') ?? false) ||
                isIncomingFlag)
            ? CallingPage(
                extension: "Incoming call",
                callingState: CallingState.CALL_OUT,
                isCallOut: false,
              )
            : MainPage(
                selfExt: selfExt,
              ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const LoginPage(),
    );
  }
}
