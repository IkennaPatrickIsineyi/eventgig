// ignore_for_file: avoid_print, library_prefixes, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:experi/BLoC.dart' as BLoC;
import 'package:experi/model.dart';

class NotificationLogic {
  static late final List notifications;
  var result;
  var don = 'notSet';
// int itemid = 0;
  ValueNotifier<int> clicked = ValueNotifier<int>(0);

  int clickedID = 0;
  int i = 0;

  static setter(List notifications) {
    NotificationLogic.notifications = notifications;
  }

  notifClicked(int id) {
    var address = Uri.parse(Model.domain + 'clickedNotification');

    var content = {
      'intro': 'clickedNotification',
      'username': Model.username,
      'sessionid': Model.sessionToken,
      'notifyid': id.toString()
    };

    print('notifClicked called... content passed');

    print(address);
    print(content);
    BLoC.showProgressIndicator();

    //if (clickLocked == false)
    BLoC.sendMsg(content);
    // clickLocked = true;

    liste() {
      Map<String, dynamic> result = Model.socketResult;
      if (result['intro'] == 'clickedNotification') {
        Navigator.pop(Model.currentContext);
        result = result['result'];
        print(result);
        if (result['status'] == 'valid') {
          print('Notification click registered successfully');
          // clickedID = id;
          i++;
          clicked.value = i;
        } else if (result['status'] == 'hacker') {
          print('hack attempt failed');
          BLoC.snackMsg(Model.currentContext, "hack attempt failed");

          Navigator.pushNamedAndRemoveUntil(
                  Model.currentContext, '/loginpage', (route) => false)
              .then((value) {
            //remove/pop dialog's context from stack since the dialog has been popped
            if (Model.contextQueue.isNotEmpty) {
              Model.contextQueue.removeLast();

              //set current context variable to the next context on the stack
              Model.currentContext = Model.contextQueue.last;
            }
          });
        } else if (result['status'] == 'invalid') {
          print('Invalid request');
          BLoC.snackMsg(Model.currentContext, "Invalid request");
        } else {
          print('double clicked');
        }
        Model.socketNotifier.removeListener(liste);
      }
    }

    Model.socketNotifier.addListener(liste);
  }
}
