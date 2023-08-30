import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_webrtc_mifone/bloc/login/bloc.dart';
import 'package:flutter_webrtc_mifone/bloc/login/event.dart';
import 'package:flutter_webrtc_mifone/bloc/login/state.dart';
import 'package:flutter_webrtc_mifone/main.dart';
import 'package:flutter_webrtc_mifone/screen/main_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:just_audio/just_audio.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginBloc()..add(InitEvent()),
      child: Builder(builder: (context) => _buildPage(context)),
    );
  }

  bool isUseCustomDomain = false;
  bool isRemember = false;
  bool isHidePassword = false;
  late AlertDialog alert;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    alert = AlertDialog(
      backgroundColor: null,
      content: Container(
        height: 100,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(200))),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            Container(
                margin: const EdgeInsets.only(top: 24),
                child: const Text("Loading...")),
          ],
        ),
      ),
    );
    if (!Platform.isAndroid) {
      usernameController.text = "testline1995@vnpt.com";
      passwordController.text = "Test_line123456789";
    } else {
      usernameController.text = "testline1996@vnpt.com";
      passwordController.text = "Test_line123456789";
    }
    keyController.text = "2222.def6ad9243ea3d2720fbbf076b492f2d";
    // if (Platform.isAndroid) {
    //   usernameController.text = "testline1996@vnpt.com";
    //   passwordController.text = "Test_line123456789";
    // } else {
    //   usernameController.text = "testline1995@vnpt.com";
    //   passwordController.text = "Test_line123456789";
    // }
  }

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController keyController = TextEditingController();

  Widget _buildPage(BuildContext context) {
    Size size = WidgetsBinding.instance.window.physicalSize;
    double width = size.width;
    double height = size.height;
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (prev, curr) {
        return curr is SigningState || curr is AuthenticateKeyState;
      },
      listener: (context, state) {
        if (state is SigningState) {
          if (state.isSuccess) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MainPage(
                          selfExt: state.selfExt,
                        )));
          } else {
            Navigator.pop(context);
            Fluttertoast.showToast(
                msg: "Đăng nhập thất bại",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 14.0);
          }
        } else if (state is AuthenticateKeyState) {
          if (!state.isSuccess) {
            Navigator.pop(context);
            Fluttertoast.showToast(
                msg: "Xác thực key thất bại",
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
        body: Stack(
          children: [
            Image.asset(
              "assets/images/image_background.webp",
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
            Center(
              child: SingleChildScrollView(
                child: Wrap(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/mipbx.png",
                            width: 100,
                            height: 100,
                          ),
                          const Text(
                            "MIFONE",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          const Text(
                            "POWERED BY MITEK",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          const Padding(padding: EdgeInsets.only(top: 50)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12))),
                            child: TextField(
                              textAlignVertical: TextAlignVertical.center,
                              controller: usernameController,
                              decoration: const InputDecoration(
                                hintText: 'Tài khoản',
                                prefixIcon: Icon(Icons.person),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const Padding(padding: EdgeInsets.only(top: 24)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12))),
                            child: BlocBuilder<LoginBloc, LoginState>(
                              buildWhen: (prev, curr) {
                                return curr is ToggleHidePasswordState;
                              },
                              builder: (context, state) {
                                if (state is ToggleHidePasswordState) {
                                  return TextField(
                                    textAlignVertical: TextAlignVertical.center,
                                    obscureText: state.isHide,
                                    controller: passwordController,
                                    decoration: InputDecoration(
                                        hintText: 'Mật khẩu',
                                        border: InputBorder.none,
                                        prefixIcon: const Icon(Icons.lock),
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            BlocProvider.of<LoginBloc>(context)
                                                .add(ToggleHidePasswordEvent(
                                                    !state.isHide));
                                          },
                                          child: (state.isHide)
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  child: SvgPicture.asset(
                                                    'assets/svg/invisible.svg',
                                                    alignment: Alignment.center,
                                                  ),
                                                )
                                              : const Icon(Icons
                                                  .remove_red_eye_outlined),
                                        )),
                                  );
                                }
                                return TextField(
                                  textAlignVertical: TextAlignVertical.center,
                                  obscureText: true,
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                      hintText: 'Mật khẩu',
                                      border: InputBorder.none,
                                      prefixIcon: const Icon(Icons.lock),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          BlocProvider.of<LoginBloc>(context)
                                              .add(ToggleHidePasswordEvent(
                                                  false));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: SvgPicture.asset(
                                            'assets/svg/invisible.svg',
                                            alignment: Alignment.center,
                                          ),
                                        ),
                                      )),
                                );
                              },
                            ),
                          ),
                          BlocBuilder<LoginBloc, LoginState>(
                            buildWhen: (prev, curr) {
                              return curr is ToggleUseCustomDomainState;
                            },
                            builder: (context, state) {
                              if (state is ToggleUseCustomDomainState) {
                                isUseCustomDomain = state.isUse;
                                if (state.isUse) {
                                  return Container(
                                      margin: const EdgeInsets.only(top: 24),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 4),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12))),
                                      child: TextField(
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        controller: keyController,
                                        decoration: const InputDecoration(
                                          hintText: 'Key',
                                          border: InputBorder.none,
                                          prefixIcon: Icon(Icons.key),
                                        ),
                                      ));
                                } else {
                                  return const SizedBox();
                                }
                              }
                              return const SizedBox();
                            },
                          ),
                          const Padding(padding: EdgeInsets.only(top: 18)),
                          GestureDetector(
                            onTap: () {
                              BlocProvider.of<LoginBloc>(context).add(
                                  ToggleUseCustomDomainEvent(
                                      !isUseCustomDomain));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                BlocBuilder<LoginBloc, LoginState>(
                                  buildWhen: (prev, curr) {
                                    return curr is ToggleUseCustomDomainState;
                                  },
                                  builder: (context, state) {
                                    if (state is ToggleUseCustomDomainState) {
                                      isUseCustomDomain = state.isUse;
                                      return Checkbox(
                                          value: state.isUse,
                                          onChanged: (value) {
                                            BlocProvider.of<LoginBloc>(context)
                                                .add(ToggleUseCustomDomainEvent(
                                                    value!));
                                          });
                                    } else {
                                      return Checkbox(
                                          value: isUseCustomDomain,
                                          onChanged: (value) {
                                            BlocProvider.of<LoginBloc>(context)
                                                .add(ToggleUseCustomDomainEvent(
                                                    value!));
                                          });
                                    }
                                  },
                                ),
                                const Text("Use custom domain"),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              BlocProvider.of<LoginBloc>(context)
                                  .add(ToggleRememberEvent(!isRemember));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                BlocBuilder<LoginBloc, LoginState>(
                                  buildWhen: (prev, curr) {
                                    return curr is ToggleRememberState;
                                  },
                                  builder: (context, state) {
                                    if (state is ToggleRememberState) {
                                      isRemember = state.val;
                                      return Checkbox(
                                          value: state.val,
                                          onChanged: (value) {
                                            BlocProvider.of<LoginBloc>(context)
                                                .add(ToggleRememberEvent(
                                                    value!));
                                          });
                                    } else {
                                      return Checkbox(
                                          value: false,
                                          onChanged: (value) {
                                            BlocProvider.of<LoginBloc>(context)
                                                .add(ToggleRememberEvent(
                                                    value!));
                                          });
                                    }
                                  },
                                ),
                                const Text("Remember"),
                              ],
                            ),
                          ),
                          const Padding(padding: EdgeInsets.only(top: 18)),
                          GestureDetector(
                            onTap: () async {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                              BlocProvider.of<LoginBloc>(context).add(
                                  SigningEvent(
                                      usernameController.text,
                                      passwordController.text,
                                      (isUseCustomDomain)
                                          ? keyController.text
                                          : null));
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(
                                  right: 24, left: 24, bottom: 12),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: const BoxDecoration(
                                  color: colorMain,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              child: const Text(
                                "LOGIN",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
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
}
