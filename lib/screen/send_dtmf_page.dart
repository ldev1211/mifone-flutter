import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc_mifone/bloc/call/event.dart';
import 'package:flutter_webrtc_mifone/main.dart';
import 'package:flutter_webrtc_mifone/screen/calling_page.dart';
import 'package:flutter_webrtc_mifone/screen/view/numpad.dart';

class SendDTMFScreen extends StatefulWidget {
  const SendDTMFScreen({super.key});

  @override
  State<SendDTMFScreen> createState() => _SendDTMFScreenState();
}

class _SendDTMFScreenState extends State<SendDTMFScreen> {
  final _myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CallingPageState.callBloc,
      child: Scaffold(
        backgroundColor: colorMain,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 70,
              child: Center(
                  child: TextField(
                decoration: const InputDecoration.collapsed(hintText: ""),
                controller: _myController,
                textAlign: TextAlign.center,
                showCursor: false,
                style: const TextStyle(fontSize: 35, color: Colors.white),
              )),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 24)),
            Dialer(
              onNumberTapped: (numberString) {
                _myController.text += numberString;
                CallingPageState.callBloc.add(SendDTMFEvent(numberString));
              },
              colorButtonDialer: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
