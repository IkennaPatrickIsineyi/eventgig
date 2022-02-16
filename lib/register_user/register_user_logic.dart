// ignore_for_file: avoid_print, library_prefixes, prefer_typing_uninitialized_variables

import 'package:experi/home/homeLogic.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart' as BLoC;
import 'package:flutter/material.dart';

class RegisterLogic {
  String password = "";
  String password2 = "";
  String gender = "Select gender";
  bool nullSignal = false;
  bool loginSignal = false;
  bool homeSignal = false;
  final ValueNotifier<Set> textValidator = ValueNotifier<Set>({});
  Set currentField = {};

  validateInput() {
    textValidator.value = {};
    if (Model.username.isEmpty) textValidator.value.add(1);
    if (Model.email.isEmpty) textValidator.value.add(2);
    if (password.isEmpty) textValidator.value.add(3);
    if (password2.isEmpty) textValidator.value.add(4);

    if (gender == "Select gender") {
      BLoC.nullInputDialog("Select your gender", "Gender missing");
    }

    if (Model.username.isNotEmpty &&
        Model.email.isNotEmpty &&
        password.isNotEmpty &&
        gender != "Select your gender" &&
        password == password2) sendInput();
  }

  sendInput() {
    var addr;
    Map<String, String> param = {};
    //var result;

    addr = Uri.parse(Model.domain + "regproc");
    param = {
      'intro': 'regproc',
      "username": Model.username,
      "password": password,
      "email": Model.email,
      "gender": gender
    };

    print(param);
    print(addr);
    BLoC.showProgressIndicator();

    BLoC.sendMsg(param);
    //socketNotifier.addListener(() { })

    liste() {
      print('new event');
      // Map<String, dynamic> result = jsonDecode(event);
      Map<String, dynamic> result = Model.socketResult;
      if (result['intro'] == 'regproc') {
        Navigator.pop(Model.currentContext);
        result = result['result'];
        print(result);

        if (result['valid'] == 'no') {
          if (result['username'] == 'taken' &&
              result['name'] == 'taken' &&
              result['email'] == 'taken') {
            BLoC.nullInputDialog(
                "Username and email are not available", 'Oops');
          } else if (result['username'] == 'taken' &&
              result['email'] == 'taken') {
            BLoC.nullInputDialog(
                "Username and email are not available", 'Oops');
          } else if (result['username'] == 'taken') {
            BLoC.nullInputDialog("Username is not available", 'Oops');
          } else if (result['email'] == 'taken') {
            BLoC.nullInputDialog("Email is not available", 'Oops');
          }
        } else if (result['valid'] == 'yes') {
          //user = result['usertype'];
          print("Registered and Logged in...");
          Model.sessionToken = result['sessID'];
          Model.emailVerified = false;
          Model.prefs.setString('sessionToken', Model.sessionToken);
          Model.prefs.setString('username', Model.username);
          Model.sessionLogin = false;
          /* setState(() {
            homeSignal = true;
          }); */
          HomeLogic.setter(true);
          Navigator.pushNamedAndRemoveUntil(
                  Model.currentContext, '/home_page', (route) => false)
              .then((value) {
            //remove/pop dialog's context from stack since the dialog has been popped
            if (Model.contextQueue.isNotEmpty) {
              Model.contextQueue.removeLast();

              //set current context variable to the next context on the stack
              Model.currentContext = Model.contextQueue.last;
            }
          });
        }
        Model.socketNotifier.removeListener(liste);
      } else if (result['intro'] == 'regprocError') {
        Navigator.pop(Model.currentContext);
        BLoC.snackMsg(Model.currentContext, "network error");
        Model.socketNotifier.removeListener(liste);
      }
    }

    Model.socketNotifier.addListener(liste);
  }
}
