import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc_mifone/api/entity/model/contact.dart';
import 'package:flutter_webrtc_mifone/bloc/handle/bloc.dart';
import 'package:flutter_webrtc_mifone/bloc/handle/event.dart';
import 'package:flutter_webrtc_mifone/bloc/handle/state.dart';
import 'package:flutter_webrtc_mifone/main.dart';
import 'package:flutter_webrtc_mifone/screen/calling_page.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  TextEditingController searchFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double sizeAvt = 20;
    double sizeExt = 15;
    double sizeDisplayName = 16;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 40,
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(12))),
              child: TextField(
                onChanged: (value) {
                  BlocProvider.of<HandleBloc>(context)
                      .add(SearchContactEvent(searchFieldController.text));
                },
                textAlignVertical: TextAlignVertical.center,
                controller: searchFieldController,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search_sharp,
                    size: 20,
                  ),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 12)),
            BlocBuilder<HandleBloc, HandleState>(
              buildWhen: (prev, curr) {
                return curr is LoadingContactState;
              },
              builder: (context, state) {
                if (state is InitState) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            BlocProvider.of<HandleBloc>(context).add(
                                SwitchTypeContactEvent(
                                    SwitchTypeContactState.TYPE_PHONE_CONTACT));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 12),
                            child: const Text(
                              "Phone Contacts",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            BlocProvider.of<HandleBloc>(context).add(
                                SwitchTypeContactEvent(SwitchTypeContactState
                                    .TYPE_OFFICE_CONTACT));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 12),
                            child: const Text(
                              "Office Contacts",
                              style: TextStyle(color: colorMain, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  LoadingContactState stateSwitched =
                      state as LoadingContactState;
                  int currType = stateSwitched.type;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            BlocProvider.of<HandleBloc>(context).add(
                                SwitchTypeContactEvent(
                                    SwitchTypeContactState.TYPE_PHONE_CONTACT));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 12),
                            child: Text(
                              "Phone Contacts",
                              style: TextStyle(
                                  color: (currType ==
                                          SwitchTypeContactState
                                              .TYPE_PHONE_CONTACT)
                                      ? colorMain
                                      : Colors.grey,
                                  fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            BlocProvider.of<HandleBloc>(context).add(
                                SwitchTypeContactEvent(SwitchTypeContactState
                                    .TYPE_OFFICE_CONTACT));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 12),
                            child: Text(
                              "Office Contacts",
                              style: TextStyle(
                                  color: (currType ==
                                          SwitchTypeContactState
                                              .TYPE_OFFICE_CONTACT)
                                      ? colorMain
                                      : Colors.grey,
                                  fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            BlocBuilder<HandleBloc, HandleState>(buildWhen: (prev, curr) {
              return curr is LoadingContactState ||
                  curr is SwitchTypeContactState;
            }, builder: (context, state) {
              if (state is LoadingContactState) {
                return const CircularProgressIndicator();
              } else if (state is SwitchTypeContactState) {
                if (state.type == SwitchTypeContactState.TYPE_PHONE_CONTACT) {
                  List<ContactDisplay> contacts = state.contacts;
                  return Expanded(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          bool? isEqualFirstChar;
                          if (index == 0) {
                            isEqualFirstChar = false;
                          } else {
                            String fCharPrev =
                                (contacts[index - 1].displayName[0]);
                            String fCharCurr = (contacts[index].displayName[0]);
                            if (fCharPrev == fCharCurr) {
                              isEqualFirstChar = true;
                            } else {
                              isEqualFirstChar = false;
                            }
                          }
                          if (isEqualFirstChar) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CallingPage(
                                            callingState: CallingState.CALL_OUT,
                                            isCallOut: true,
                                            extension:
                                                contacts[index].number)));
                                BlocProvider.of<HandleBloc>(context)
                                    .add(CallOutEvent());
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade200)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        decoration: const BoxDecoration(
                                            color: colorTheme,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30))),
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.person,
                                          size: sizeAvt,
                                          color: Colors.white,
                                        )),
                                    const Padding(
                                        padding: EdgeInsets.only(right: 12)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            contacts[index].displayName,
                                            style: TextStyle(
                                                fontSize: sizeDisplayName,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Column(
                              children: [
                                const Padding(
                                    padding: EdgeInsets.only(top: 12)),
                                Text(
                                  (contacts[index].displayName[0]),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: sizeDisplayName),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CallingPage(
                                                callingState:
                                                    CallingState.CALL_OUT,
                                                isCallOut: true,
                                                extension:
                                                    contacts[index].number)));
                                    BlocProvider.of<HandleBloc>(context)
                                        .add(CallOutEvent());
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey.shade200)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            decoration: const BoxDecoration(
                                                color: colorTheme,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.person,
                                              size: sizeAvt,
                                              color: Colors.white,
                                            )),
                                        const Padding(
                                            padding:
                                                EdgeInsets.only(right: 12)),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                contacts[index].displayName,
                                                style: TextStyle(
                                                    fontSize: sizeDisplayName,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                  );
                } else {
                  List<ContactDisplay> contacts = state.contacts;
                  return Expanded(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          bool? isEqualFirstChar;
                          if (index == 0) {
                            isEqualFirstChar = false;
                          } else {
                            String fCharPrev =
                                (contacts[index - 1].displayName[0]);
                            String fCharCurr = (contacts[index].displayName[0]);
                            if (fCharPrev == fCharCurr) {
                              isEqualFirstChar = true;
                            } else {
                              isEqualFirstChar = false;
                            }
                          }
                          if (isEqualFirstChar) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CallingPage(
                                            callingState: CallingState.CALL_OUT,
                                            isCallOut: true,
                                            extension:
                                                contacts[index].number)));
                                BlocProvider.of<HandleBloc>(context)
                                    .add(CallOutEvent());
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade200)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        decoration: const BoxDecoration(
                                            color: colorTheme,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30))),
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.person,
                                          size: sizeAvt,
                                          color: Colors.white,
                                        )),
                                    const Padding(
                                        padding: EdgeInsets.only(right: 12)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            contacts[index].displayName,
                                            style: TextStyle(
                                                fontSize: sizeDisplayName,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const Padding(
                                              padding: EdgeInsets.only(top: 8)),
                                          Text(
                                            contacts[index].number,
                                            style: TextStyle(
                                                fontSize: sizeExt,
                                                color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Column(
                              children: [
                                const Padding(
                                    padding: EdgeInsets.only(top: 12)),
                                Text(
                                  (contacts[index].displayName[0]),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: sizeDisplayName),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CallingPage(
                                                callingState:
                                                    CallingState.CALL_OUT,
                                                isCallOut: true,
                                                extension:
                                                    contacts[index].number)));
                                    BlocProvider.of<HandleBloc>(context)
                                        .add(CallOutEvent());
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey.shade200)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            decoration: const BoxDecoration(
                                                color: colorTheme,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.person,
                                              size: sizeAvt,
                                              color: Colors.white,
                                            )),
                                        const Padding(
                                            padding:
                                                EdgeInsets.only(right: 12)),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                contacts[index].displayName,
                                                style: TextStyle(
                                                    fontSize: sizeDisplayName,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 8)),
                                              Text(
                                                contacts[index].number,
                                                style: TextStyle(
                                                    fontSize: sizeExt,
                                                    color:
                                                        Colors.grey.shade600),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                  );
                }
              } else {
                return const Placeholder();
              }
            }),
          ],
        ),
      ),
    );
  }
}
