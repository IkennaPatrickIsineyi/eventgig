// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, no_logic_in_create_state, deprecated_member_use, avoid_print

import 'package:experi/notification/notification_logic.dart';
import 'package:flutter/material.dart';
import 'package:experi/model.dart';

class Notifications extends StatefulWidget {
  Notifications(this.notifications);
  final List notifications;
  @override
  _Notifications createState() => _Notifications(notifications);
}

class _Notifications extends State<Notifications> {
  _Notifications(this.notifications);
  final List notifications;

  @override
  void dispose() {
    clicked.dispose();
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
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return (notifications.isEmpty)
                ? Center(child: Text('No notifications'))
                : ValueListenableBuilder(
                    valueListenable: clicked,
                    builder: (BuildContext context, int value, Widget? child) {
                      print('clicked changed to $value');

                      //for (List item in notifications) {
                      print(notifications[index][6]);
                      print('clickedID: $clickedID');
                      if (notifications[index][0] == clickedID) {
                        notifications[index][6] = 1;
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
                                notifications[index][5],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ), //title
                              Text(
                                notifications[index][1] +
                                    ', ' +
                                    notifications[index][2] +
                                    notifications[index][6].toString(),
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
                            notifications[index][4],
                          ), //body
                          onTap: () {
                            clickedID = notifications[index][0];
                            notifClicked(notifications[index][0]);
                          }, //notifyid

                          tileColor: (notifications[index][6] == 0)
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
