// ignore_for_file: avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables, library_prefixes, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, deprecated_member_use, no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/home/homeLogic.dart';
import 'package:experi/BLoC.dart' as BLoC;
import 'package:experi/create_order/create_order_page.dart';

class HomePage extends StatefulWidget {
  HomePage(this.newAccount, {this.accountDetails = const {}});
  final Map accountDetails;
  final bool newAccount;
  @override
  _HomePageState createState() =>
      _HomePageState(newAccount, accountDetails: accountDetails);
}

class _HomePageState extends State<HomePage> {
  _HomePageState(this.newAccount, {this.accountDetails = const {}});
  final Map accountDetails;
  final bool newAccount;

  @override
  Widget build(BuildContext context) {
    Model.prefs.setString("currentRoute", "homepage");
    Model.currentRoute = "homepage";
    print('welcome home');
    /* if (!kIsWeb) {
      showNotification(0, 'EventGig', 'Login was successful', 'loginSuccess');
    } */
    if (newAccount == false) {
      pendingList = accountDetails['pending'];
      scheduledList = accountDetails['scheduled'];
      completedList = accountDetails['completed'];
      pendingPicList = accountDetails['pendingPics'];
      scheduledPicList = accountDetails['scheduledPics'];
      completedPicList = accountDetails['completedPics'];
    } else {
      Model.emailVerified = false;
      pendingList = [];
      scheduledList = [];
      completedList = [];
      pendingPicList = [];
      scheduledPicList = [];
      completedPicList = [];
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
            reRoute('setting');
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
            reRoute('chat');
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
            reRoute('logout');
          },
          icon: Icon(Icons.logout_rounded),
        ),
        'logout'
      ],
    ];

    return ValueListenableBuilder(
        valueListenable: reloadPage,
        builder: (BuildContext context, int value1, Widget? child) {
          return Material(
              child: (verifyEmail == true)
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
                                otp = input;
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
                                  otp = '';
                                  return "*required";
                                } else if (value.contains(RegExp(r'(\D)'))) {
                                  otp = '';
                                  return "Verification code is a number";
                                } else if (!value
                                    .contains(RegExp(r'(\d{6})'))) {
                                  otp = '';
                                  return "Verification code is 6-digit number";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (otp.isNotEmpty) verifyOTP();
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
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          CreateOrderPage(),
                                    ),
                                  )
                                : BLoC.nullInputDialog(
                                    context,
                                    "email verification required",
                                    "",
                                    sendCode: sendOTP,
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
                                          onPressed: () => getNotifications(),
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
                                        reRoute(way as String);
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
                                  child: buildTable(
                                      "pending", pendingList, pendingPicList),
                                ),
                                onRefresh: () {
                                  BLoC.block(context);
                                  return reload();
                                }),
                            RefreshIndicator(
                                semanticsLabel: 'scheduledTab',
                                child: SingleChildScrollView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: buildTable("scheduled", scheduledList,
                                      scheduledPicList),
                                ),
                                onRefresh: () {
                                  BLoC.block(context);
                                  return reload();
                                }),
                            RefreshIndicator(
                                semanticsLabel: 'completedTab',
                                child: SingleChildScrollView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: buildTable("completed", completedList,
                                      completedPicList),
                                ),
                                onRefresh: () {
                                  BLoC.block(context);
                                  return reload();
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
