// ignore_for_file: prefer_const_constructors, avoid_print, file_names, prefer_typing_uninitialized_variables, unused_local_variable, library_prefixes

import 'package:experi/model.dart';
import 'package:experi/BLoC.dart' as BLoC;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:experi/home/homepage.dart';
import 'package:experi/login/loginpage.dart';
import 'package:intl/intl.dart' as intl;

class LoginLogic {
  static String password = "";
  static bool nullSignal = false;
  static bool registerSignal = false;
  static bool loadHome = false;
  static var homeParam;
  static var result;

  static bool resetPassword = false;
  static String otp = '';
  static String password1 = '';
  static String password2 = '';
  static bool mismatch = false;
  static bool invalidOTP = false;
  static bool usernameOnly = false;
  static bool validating = false;
  static Set formInputText = {};

  //TextEditingController control = TextEditingController();
  static late final ValueNotifier textValidator;
  static late final ValueNotifier<Set> pwdResetValidator;

  static Set currentField = {};

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
        Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => HomePage(
                false,
                accountDetails: result,
              ),
            ),
            (route) => false);
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
        Navigator.push(
          Model.currentContext,
          MaterialPageRoute(
            builder: (BuildContext context) => LoginPage(
              resetpassword: true,
            ),
          ),
        );
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

        Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
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

    /* liste() {
      print('login called');
      Map<String, dynamic> res = Model.socketResult;
      if (res['intro'] == 'login') {
        res = res['result'];
        print(res);

        loginResultSock(res);
        print("rmoving listener...");
        Model.socketNotifier.removeListener(liste);
        print('listener removed');
      }
    } */

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

      /* liste() async {
        print('savesession called');
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
          if (Model.testMode = false) Navigator.pop(Model.currentContext);
          //  setState(() {});
          if (Model.testMode = false) {
            Navigator.pushAndRemoveUntil(
                Model.currentContext,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                      /*  false,
                  accountDetails: result, */
                      ),
                ),
                (route) => false);
          }
          Model.socketNotifier.removeListener(liste);
        } 
      }*/

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

      BLoC.nullInputDialog(Model.currentContext,
          "The password and username do not match", "Invalid");
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
    BLoC.showProgressIndicator(Model.currentContext);

    BLoC.sendMsg(content);
/* 
    liste() {
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
          Navigator.push(
            Model.currentContext,
            MaterialPageRoute(
              builder: (BuildContext context) => LoginPage(
                resetpassword: true,
              ),
            ),
          );
        } else if (result['status'] == 'invalid') {
          print('Invalid username');
          BLoC.snackMsg(Model.currentContext, "Invalid username");
        }
        Model.socketNotifier.removeListener(liste);
      }
    }
 */

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
    BLoC.showProgressIndicator(
      Model.currentContext,
    );

    BLoC.sendMsg(content);
/* 
    liste() {
      Map<String, dynamic> result = Model.socketResult;
      if (result['intro'] == 'resetpassword') {
        Navigator.pop(
          Model.currentContext,
        );
        result = result['result'];
        print(result);
        if (result['status'] == 'changed') {
          print('Password Changed');

          Navigator.pushAndRemoveUntil(
              Model.currentContext,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
          BLoC.snackMsg(Model.currentContext, "Password Reset Successful");
        } else if (result['status'] == 'hacker') {
          print('hack attempt failed');
          BLoC.snackMsg(Model.currentContext, "hack attempt failed");
        } else if (result['status'] == 'invalid') {
          print('invalid otp');
          BLoC.snackMsg(Model.currentContext, "Invalid OTP");
        }
        Model.socketNotifier.removeListener(liste);
      }
    }
 */

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
