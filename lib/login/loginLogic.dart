// ignore_for_file: prefer_const_constructors, avoid_print, file_names, prefer_typing_uninitialized_variables, unused_local_variable, library_prefixes

import 'package:experi/home/homeLogic.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart' as BLoC;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class LoginLogic {
  static bool resetPassword = false;
  String password = "";
  bool nullSignal = false;
  bool registerSignal = false;
  bool loadHome = false;
  var homeParam;
  var result;

//  static bool resetPassword = false;
  String otp = '';
  String password1 = '';
  String password2 = '';
  bool mismatch = false;
  bool invalidOTP = false;
  bool usernameOnly = false;
  bool validating = false;
  Set formInputText = {};

  //TextEditingController control = TextEditingController();
  late final ValueNotifier textValidator;
  late final ValueNotifier<Set> pwdResetValidator;

  Set currentField = {};

  static setter(bool resetpassword) {
    LoginLogic.resetPassword = resetpassword;
  }

  loginSockEvent() {
    print('login Event called');
    Map<String, dynamic> res = Model.socketResult;
    if (res['intro'] == 'login') {
      res = res['result'];
      print(res);

      loginResultSock(res);
      print("rmoving listener...");
      if (Model.testMode == false) {
        Model.socketNotifier.removeListener(loginSockEvent);
      }
      print('listener removed');
    }
  }

  loginResultSockEvent() async {
    print('loginResultSock Event called');
    Map<String, dynamic> res = Model.socketResult;
    if (res["intro"] == "savesession") {
      print("login complete...");
      print('logging into pythonanywhere');
      Map<String, dynamic> result = res['result'];
      Model.sessionToken = result['sessionID'];
      Model.emailVerified = (result['personal'][0][3] == 1) ? true : false;
      print('so');
      await Model.prefs.setString('sessionModel.token', Model.sessionToken);
      await Model.prefs.setString('username', Model.username);
      print('kno');
      if (Model.tokenSet == false && !kIsWeb) {
        //Model.token = await FirebaseMessaging.instance.getModel.token() as String;

        Model.prefs.setString('firebase', Model.token);
      }

      Model.sessionLogin = false;

      print("homepage being called... next");
      Model.diableLogin = false;
      if (Model.testMode == false) Navigator.pop(Model.currentContext);
      //  setState(() {});
      if (Model.testMode == false) {
        HomeLogic.setter(
          false,
          accountDetails: result,
        );
        Navigator.pushNamedAndRemoveUntil(
            Model.currentContext, '/home_page', (route) => false).then((value) {
          //remove/pop dialog's context from stack since the dialog has been popped
          if (Model.contextQueue.isNotEmpty) {
            Model.contextQueue.removeLast();

            //set current context variable to the next context on the stack
            Model.currentContext = Model.contextQueue.last;
          }
        });
      }
      if (Model.testMode == false) {
        Model.socketNotifier.removeListener(loginResultSockEvent);
      }
    }
  }

  sendOTPEvent() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'passwordotp') {
      Navigator.pop(Model.currentContext);
      result = result['result'];
      print(result);
      if (result['status'] == 'sent') {
        print('Email Sent');
        BLoC.snackMsg(Model.currentContext, "Email Sent");
        //  setState(() {
        usernameOnly = false;
        //  });
        LoginLogic.setter(true);
        Navigator.pushNamed(Model.currentContext, '/loginpage').then((value) {
          //remove/pop dialog's context from stack since the dialog has been popped
          if (Model.contextQueue.isNotEmpty) {
            Model.contextQueue.removeLast();

            //set current context variable to the next context on the stack
            Model.currentContext = Model.contextQueue.last;
          }
        });
      } else if (result['status'] == 'invalid') {
        print('Invalid username');
        BLoC.snackMsg(Model.currentContext, "Invalid username");
      }
      if (Model.testMode == false) {
        Model.socketNotifier.removeListener(sendOTPEvent);
      }
    }
  }

  verifyOTPEvent() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'resetpassword') {
      Navigator.pop(
        Model.currentContext,
      );
      result = result['result'];
      print(result);
      if (result['status'] == 'changed') {
        print('Password Changed');

        Navigator.pushNamedAndRemoveUntil(
            Model.currentContext, '/loginpage', (route) => false).then((value) {
          //remove/pop dialog's context from stack since the dialog has been popped
          if (Model.contextQueue.isNotEmpty) {
            Model.contextQueue.removeLast();

            //set current context variable to the next context on the stack
            Model.currentContext = Model.contextQueue.last;
          }
        });
        BLoC.snackMsg(Model.currentContext, "Password Reset Successful");
      } else if (result['status'] == 'hacker') {
        print('hack attempt failed');
        BLoC.snackMsg(Model.currentContext, "hack attempt failed");
      } else if (result['status'] == 'invalid') {
        print('invalid otp');
        BLoC.snackMsg(Model.currentContext, "Invalid OTP");
      }
      if (Model.testMode == false) {
        Model.socketNotifier.removeListener(verifyOTPEvent);
      }
    }
  }

  loginSock() async {
    print("login called");

    //Uri address = Uri.parse(Model.domain + "loginproc.cgi");

    Uri address = Uri.parse(Model.domain + "login");
    Map<String, dynamic> content = {
      "intro": "login",
      "username": Model.username,
      "password": password,
    };

    BLoC.sendMsg(content);

    print(Model.testMode);
    if (Model.testMode == true) {
      loginSockEvent();
    } else {
      Model.socketNotifier.addListener(loginSockEvent);
    }
  }

  loginResultSock(Map result) async {
    print('loginResult called...');
    //Uri address = Uri.parse(Model.domain + "loginproc.cgi");
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri address = Uri.parse(Model.domain + "savesession");
    if (kIsWeb) {
      Model.token = "joke";
    }

    Map<String, dynamic> content = {
      "intro": "savesession",
      "username": Model.username,
      "password": password,
      "deviceid": 'dev',
      "deviceToken": Model.token,
    };

    if (result['login'] == 'valid') {
      BLoC.sendMsg(content);

      print(Model.testMode);
      if (Model.testMode == true) {
        loginResultSockEvent();
      } else {
        Model.socketNotifier.addListener(loginResultSockEvent);
      }
    } else if (result['login'] == 'invalid') {
      if (Model.testMode == false) Navigator.pop(Model.currentContext);
      print("Invalid login credentials...");
      //setState(() {
      Model.diableLogin = false;
      //  });

      BLoC.nullInputDialog("The password and username do not match", "Invalid");
    } else {
      if (Model.testMode == false) Navigator.pop(Model.currentContext);
      print("unknown error...");
      //setState(() {
      Model.diableLogin = false;
      //});
    }

    // print(content);
  }

  sendOPT1() {
    // setState(() {
    usernameOnly = true;
    textValidator.value = 0;
    // });
  }

  sendOTP() {
    if (Model.username.isEmpty) {
      textValidator.value = 1;
      return;
    }

    var address = Uri.parse(Model.domain + 'passwordotp');

    Map<String, dynamic> content = {
      "intro": "passwordotp",
      'subject': 'Password Reset Code',
      'username': Model.username,
    };

    print('sendOTP called... content passed');

    print(address);
    print(content);
    BLoC.showProgressIndicator();

    BLoC.sendMsg(content);

    if (Model.testMode == true) {
      sendOTPEvent();
    } else {
      Model.socketNotifier.addListener(sendOTPEvent);
    }
  }

  verifyOTP() {
    var address = Uri.parse(Model.domain + 'resetpassword');

    Map<String, dynamic> content = {
      "intro": 'resetpassword',
      'otp': otp,
      'password': password1,
      'username': Model.username,
    };

    print('verifyOTP called... content passed');

    print(address);
    print(content);
    BLoC.showProgressIndicator();

    BLoC.sendMsg(content);
    if (Model.testMode == true) {
      verifyOTPEvent();
    } else {
      Model.socketNotifier.addListener(verifyOTPEvent);
    }
  }

  timeStuff(date) {
    DateTime currTime = DateTime.now();

    DateTime x = intl.DateFormat('dd-MMM-yyyy  h:mm:ss a').parse(date);

    String g = (currTime.difference(x).inSeconds <= 59)
        ? "${currTime.difference(x).inSeconds} seconds"
        : (currTime.difference(x).inMinutes <= 59)
            ? "${currTime.difference(x).inMinutes} minutes"
            : (currTime.difference(x).inHours <= 23)
                ? "${currTime.difference(x).inHours} hours"
                : "${currTime.difference(x).inDays} days";

    print(g);
  }

  timeStuffMsg(date) {
    DateTime currTime = DateTime.now();

    DateTime x = intl.DateFormat('dd-MMM-yyyy  h:mm a').parse(date);

    String g = (currTime.difference(x).inSeconds <= 59)
        ? "${currTime.difference(x).inSeconds} seconds"
        : (currTime.difference(x).inMinutes <= 59)
            ? "${currTime.difference(x).inMinutes} minutes"
            : (currTime.difference(x).inHours <= 23)
                ? "${currTime.difference(x).inHours} hours"
                : "${currTime.difference(x).inDays} days";

    print(g);
  }

  bool validateInput() {
    if (Model.username.isEmpty && password.isEmpty) {
      textValidator.value = 3;
      return true;
    } else if (Model.username.isEmpty) {
      textValidator.value = 1;
      return true;
    } else if (password.isEmpty) {
      textValidator.value = 2;
      return true;
    } else {
      return false;
    }
  }
}
