// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, no_logic_in_create_state, deprecated_member_use, avoid_print

import 'package:experi/notification/notification_logic.dart';
import 'package:flutter/material.dart';
import 'package:experi/model.dart';

class Notifications extends StatefulWidget {
  @override
  State<Notifications> createState() => _Notifications();
}

class _Notifications extends State<Notifications> {
  final notificationObj = NotificationLogic();
  @override
  void dispose() {
    notificationObj.clicked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Model.currentRoute = "Notifications";
    Model.prefs.setString("currentRoute", "Notifications");
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Column(
          children: [
            Text(
              "eventGig",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Notifications",
              style: TextStyle(fontSize: 12),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
      body: ListView.builder(
          itemCount: NotificationLogic.notifications.length,
          itemBuilder: (context, index) {
            return (NotificationLogic.notifications.isEmpty)
                ? Center(child: Text('No notifications'))
                : ValueListenableBuilder(
                    valueListenable: notificationObj.clicked,
                    builder: (BuildContext context, int value, Widget? child) {
                      print('clicked changed to $value');

                      //for (List item in notifications) {
                      print(NotificationLogic.notifications[index][6]);
                      print('clickedID: ${notificationObj.clickedID}');
                      if (NotificationLogic.notifications[index][0] ==
                          notificationObj.clickedID) {
                        NotificationLogic.notifications[index][6] = 1;
                      }

                      return Container(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 5,
                        ),
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(
                                NotificationLogic.notifications[index][5],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ), //title
                              Text(
                                NotificationLogic.notifications[index][1] +
                                    ', ' +
                                    NotificationLogic.notifications[index][2] +
                                    NotificationLogic.notifications[index][6]
                                        .toString(),
                                style: TextStyle(fontSize: 10),
                              ), //time+date
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            //crossAxisAlignment: CrossAxisAlignment.baseline,
                          ),

                          isThreeLine: false,
                          contentPadding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 0,
                          ),
                          //dense: true,

                          subtitle: Text(
                            NotificationLogic.notifications[index][4],
                          ), //body
                          onTap: () {
                            notificationObj.clickedID =
                                NotificationLogic.notifications[index][0];
                            notificationObj.notifClicked(
                                NotificationLogic.notifications[index][0]);
                          }, //notifyid

                          tileColor:
                              (NotificationLogic.notifications[index][6] == 0)
                                  ? Colors.grey[350]
                                  : Colors.white,
                        ),
                      );
                    }
                    //    return Container();

                    // return Text('$value');
                    //     },
                    );
          }),
    );
  }
}
