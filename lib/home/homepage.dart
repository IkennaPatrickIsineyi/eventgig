// ignore_for_file: avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables, library_prefixes, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, deprecated_member_use, no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/home/homeLogic.dart';
import 'package:experi/BLoC.dart' as BLoC;
//import 'package:experi/create_order/create_order_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homePageLogic = HomeLogic();

  @override
  Widget build(BuildContext context) {
    Model.contextQueue.addLast(context);
    Model.currentContext = context;
    Model.prefs.setString("currentRoute", "homepage");
    Model.currentRoute = "homepage";
    print('welcome home');
    /* if (!kIsWeb) {
      showNotification(0, 'EventGig', 'Login was successful', 'loginSuccess');
    } */
    if (HomeLogic.newAccount == false) {
      homePageLogic.pendingList = HomeLogic.accountDetails['pending'];
      homePageLogic.scheduledList = HomeLogic.accountDetails['scheduled'];
      homePageLogic.completedList = HomeLogic.accountDetails['completed'];
      homePageLogic.pendingPicList = HomeLogic.accountDetails['pendingPics'];
      homePageLogic.scheduledPicList =
          HomeLogic.accountDetails['scheduledPics'];
      homePageLogic.completedPicList =
          HomeLogic.accountDetails['completedPics'];
    } else {
      Model.emailVerified = false;
      homePageLogic.pendingList = [];
      homePageLogic.scheduledList = [];
      homePageLogic.completedList = [];
      homePageLogic.pendingPicList = [];
      homePageLogic.scheduledPicList = [];
      homePageLogic.completedPicList = [];
    }

    List menuItems = [
      [
        TextButton.icon(
          label: Text(
            'Setting',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            homePageLogic.reRoute('setting');
          },
          icon: Icon(Icons.settings),
        ),
        'setting'
      ],
      [
        TextButton.icon(
          label: Text(
            'Chats',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            homePageLogic.reRoute('chat');
          },
          icon: Icon(Icons.chat),
        ),
        'chat'
      ],
      [
        TextButton.icon(
          label: Text(
            'Log Out',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            homePageLogic.reRoute('logout');
          },
          icon: Icon(Icons.logout_rounded),
        ),
        'logout'
      ],
    ];

    return ValueListenableBuilder(
        valueListenable: homePageLogic.reloadPage,
        builder: (BuildContext context, int value1, Widget? child) {
          return Material(
              child: (homePageLogic.verifyEmail == true)
                  ? Scaffold(
                      appBar: AppBar(
                        brightness: Brightness.dark,
                        title: Text("Email verification"),
                      ),
                      body: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            '''We have sent a 6-digit code to the 
            email you registered with. 
            Enter that OTP code in the field below''',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[300],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: TextFormField(
                              onChanged: (input) {
                                homePageLogic.otp = input;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "OTP Code",
                                hintText: "Enter the OTP code here",
                                border: OutlineInputBorder(),
                              ),
                              autovalidateMode: AutovalidateMode.always,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  homePageLogic.otp = '';
                                  return "*required";
                                } else if (value.contains(RegExp(r'(\D)'))) {
                                  homePageLogic.otp = '';
                                  return "Verification code is a number";
                                } else if (!value
                                    .contains(RegExp(r'(\d{6})'))) {
                                  homePageLogic.otp = '';
                                  return "Verification code is 6-digit number";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (homePageLogic.otp.isNotEmpty) {
                                homePageLogic.verifyOTP();
                              }
                            },
                            child: Text("Submit Code"),
                          )
                        ],
                      ),
                    )
                  : DefaultTabController(
                      length: 3,
                      child: Scaffold(
                        floatingActionButton: FloatingActionButton(
                          onPressed: () {
                            (Model.emailVerified == true)
                                ? Navigator.pushNamed(context, '/create_order')
                                    .then((value) {
                                    //remove/pop dialog's context from stack since the dialog has been popped
                                    if (Model.contextQueue.isNotEmpty) {
                                      Model.contextQueue.removeLast();

                                      //set current context variable to the next context on the stack
                                      Model.currentContext =
                                          Model.contextQueue.last;
                                    }
                                  })
                                : BLoC.nullInputDialog(
                                    "email verification required",
                                    "",
                                    sendCode: homePageLogic.sendOTP,
                                    email: true,
                                  );
                          },
                          child: Icon(Icons.shopping_cart),
                        ),
                        appBar: AppBar(
                            brightness: Brightness.dark,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("eventGig",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Stack(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () =>
                                              homePageLogic.getNotifications(),
                                          child: Icon(Icons.notifications,
                                              size: 28),
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<
                                                OutlinedBorder>(
                                              CircleBorder(),
                                            ),
                                          ),
                                        ),
                                        ValueListenableBuilder(
                                          valueListenable: Model.unSeen,
                                          builder: (BuildContext context,
                                              int value, Widget? child) {
                                            print('changed to $value');
                                            if (value > 0) {
                                              return Positioned(
                                                child: ClipOval(
                                                  child: CircleAvatar(
                                                    child:
                                                        ValueListenableBuilder(
                                                      valueListenable:
                                                          Model.unSeen,
                                                      builder:
                                                          (BuildContext context,
                                                              int value,
                                                              Widget? child) {
                                                        print(
                                                            'changed to $value');
                                                        return Text(
                                                          '$value',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        Colors.black,
                                                    radius: 10,
                                                  ),
                                                ),
                                                right: 6,
                                                top: 5,
                                              );
                                            }
                                            return Positioned(
                                              child: CircleAvatar(
                                                child: Text(''),
                                                backgroundColor: Colors.red,
                                                radius: 1,
                                              ),
                                              right: 0,
                                              top: 0,
                                            );
                                            // return Text('$value');
                                          },
                                        ),
                                        //if (unSeen.value > 0)
                                      ],
                                      alignment: Alignment.topRight,
                                    ),

                                    //display setting, chat, and logout
                                    PopupMenuButton(
                                      itemBuilder: (BuildContext context) {
                                        return menuItems.map((item) {
                                          return PopupMenuItem(
                                            child: item[0],
                                            value: item[1],
                                            padding: EdgeInsets.zero,
                                          );
                                        }).toList();
                                      },
                                      onSelected: (way) {
                                        print('selected');
                                        homePageLogic.reRoute(way as String);
                                      },
                                      icon: Icon(Icons.list),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            bottom: PreferredSize(
                              child: TabBar(
                                labelPadding: EdgeInsets.zero,
                                tabs: [
                                  Tab(
                                    text: "Pending",
                                    icon: Icon(Icons.pending_actions_outlined,
                                        size: 16),
                                    iconMargin: EdgeInsets.only(bottom: 0),
                                    height: 48,
                                  ),
                                  Tab(
                                    text: "Scheduled",
                                    icon: Icon(Icons.call_received, size: 16),
                                    iconMargin: EdgeInsets.only(bottom: 0),
                                    height: 48,
                                  ),
                                  Tab(
                                    text: "Completed",
                                    icon:
                                        Icon(Icons.verified_outlined, size: 16),
                                    iconMargin: EdgeInsets.only(bottom: 0),
                                    height: 48,
                                  ),
                                ],
                              ),
                              preferredSize: Size.fromHeight(30),
                            )),
                        body: TabBarView(
                          children: [
                            RefreshIndicator(
                                child: SingleChildScrollView(
                                  //reverse: true,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: homePageLogic.buildTable(
                                      "pending",
                                      homePageLogic.pendingList,
                                      homePageLogic.pendingPicList),
                                ),
                                onRefresh: () {
                                  BLoC.block();
                                  return homePageLogic.reload();
                                }),
                            RefreshIndicator(
                                semanticsLabel: 'scheduledTab',
                                child: SingleChildScrollView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: homePageLogic.buildTable(
                                      "scheduled",
                                      homePageLogic.scheduledList,
                                      homePageLogic.scheduledPicList),
                                ),
                                onRefresh: () {
                                  BLoC.block();
                                  return homePageLogic.reload();
                                }),
                            RefreshIndicator(
                                semanticsLabel: 'completedTab',
                                child: SingleChildScrollView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: homePageLogic.buildTable(
                                      "completed",
                                      homePageLogic.completedList,
                                      homePageLogic.completedPicList),
                                ),
                                onRefresh: () {
                                  BLoC.block();
                                  return homePageLogic.reload();
                                }),
                          ],
                        ),
                      ),
                    ));
          /* },
    ); */
        });
    /*   return Scaffold(
      appBar: AppBar(
        title: const Text('Hello'),
      ),
      body: Center(
        child: Container(),
      ),
    ); */
  }
}
