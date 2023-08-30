import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc_mifone/bloc/handle/bloc.dart';
import 'package:flutter_webrtc_mifone/bloc/handle/event.dart';
import 'package:flutter_webrtc_mifone/screen/calling_page.dart';
import 'package:flutter_webrtc_mifone/screen/view/numpad.dart';

import '../bloc/call/state.dart';

class NumpadScreen extends StatefulWidget {
  const NumpadScreen({super.key});

  @override
  State<NumpadScreen> createState() => _NumpadScreenState();
}

class _NumpadScreenState extends State<NumpadScreen> {
  final TextEditingController _myController = TextEditingController();
  bool isIncomingCall = false;
  String token = "";
  double sizeButtonNumber = 70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(padding: EdgeInsets.only(top: 36)),
            SizedBox(
              height: 70,
              child: Center(
                  child: TextField(
                decoration: const InputDecoration.collapsed(hintText: ""),
                controller: _myController,
                textAlign: TextAlign.center,
                showCursor: false,
                style: const TextStyle(fontSize: 35),
              )),
            ),
            const Spacer(),
            Dialer(onNumberTapped: (numberString) {
              setState(() {
                _myController.text += numberString;
              });
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    color: Colors.white,
                    width: sizeButtonNumber,
                    height: sizeButtonNumber,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_myController.text.isEmpty) return;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CallingPage(
                                    callingState: CallingState.CALL_OUT,
                                    isCallOut: true,
                                    extension: _myController.text,
                                  )));
                      BlocProvider.of<HandleBloc>(context).add(CallOutEvent());
                    },
                    child: Container(
                      width: sizeButtonNumber,
                      height: sizeButtonNumber,
                      decoration: const BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                  (_myController.text.isNotEmpty)
                      ? GestureDetector(
                          onTap: () {
                            if (_myController.text.isEmpty) return;
                            setState(() {
                              _myController.text = _myController.text
                                  .substring(0, _myController.text.length - 1);
                            });
                          },
                          onLongPress: () {
                            setState(() {
                              _myController.text = "";
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  color: Colors.white,
                                  width: sizeButtonNumber,
                                  height: sizeButtonNumber,
                                ),
                                const Positioned(
                                  top: 0,
                                  child: Icon(
                                    Icons.backspace_outlined,
                                    size: 35,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Container(
                            color: Colors.white,
                            width: sizeButtonNumber,
                            height: sizeButtonNumber,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
