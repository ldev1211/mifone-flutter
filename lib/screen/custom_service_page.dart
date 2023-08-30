import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc_mifone/bloc/login/bloc.dart';
import 'package:flutter_webrtc_mifone/bloc/login/event.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../bloc/login/state.dart';
import '../main.dart';

class CustomServicePage extends StatefulWidget {
  const CustomServicePage({Key? key}) : super(key: key);

  @override
  State<CustomServicePage> createState() => _CustomServicePageState();
}

class _CustomServicePageState extends State<CustomServicePage> {

  TextEditingController keyFieldController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    keyFieldController.text = "2222.def6ad9243ea3d2720fbbf076b492f2d";
  }

  @override
  Widget build(BuildContext context) {
    Size size = WidgetsBinding.instance.window.physicalSize;
    double width = size.width;
    double height = size.height;
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: Builder(
        builder: (context) {
          return BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              AuthenticateKeyState authenticateKeyState = state as AuthenticateKeyState;
              if(authenticateKeyState.isSuccess){
                Fluttertoast.showToast(
                    msg: "Xác thực key thành công",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 14.0
                );
                Navigator.pop(context);
              } else {
                Fluttertoast.showToast(
                    msg: "Xác thực key thất bại. Vui lòng kiểm tra lại thông tin key",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 14.0
                );
              }
            },
            child: Scaffold(
                        body: Stack(
                          children: [
                            Image.asset("assets/images/image_background.webp",width: width,height: height,fit: BoxFit.cover,),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 8),
                                height: 450,
                                margin: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(12))
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/mipbx.png",width: 100,height: 100,),
                                    const Text(
                                      "MIFONE",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20
                                      ),
                                    ),
                                    const Text(
                                      "POWER BY MITEK",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.only(top: 50)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 4),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black),
                                          borderRadius: const BorderRadius.all(Radius.circular(12))
                                      ),
                                      child: TextField(
                                        controller: keyFieldController,
                                        decoration: const InputDecoration(
                                          hintText: 'Key',
                                          prefixIcon: Icon(Icons.key),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.only(top: 40)),
                                    GestureDetector(
                                      onTap: () async {
                                        BlocProvider.of<LoginBloc>(context).add(AuthenticateKeyEvent(keyFieldController.text));
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.symmetric(horizontal: 50),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: colorMain),
                                            borderRadius: const BorderRadius.all(Radius.circular(30))
                                        ),
                                        child: const Text(
                                          "Authenticate",
                                          style: TextStyle(
                                              color: colorMain,
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
          );
        }
      ),
    );
  }
}
