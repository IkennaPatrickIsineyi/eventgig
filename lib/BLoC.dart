// ignore_for_file: prefer_const_constructors, file_names, avoid_print, camel_case_types, unused_local_variable

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart' as socket;
import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/login/loginpage.dart';
import 'package:experi/home/homepage.dart';

sendMsgEvent(event) {
  Map<String, dynamic> res = jsonDecode(event);
  Model.code++;
  print("secondary ${Model.code}");

  if (res['intro'] == 'ping') {
    Model.socketResult = res;
    Model.socketCount++;
    Model.pingNotifier.value = Model.socketCount;
    Model.webSock.sink.add(jsonEncode(
      {
        'intro': 'alive',
        'username': Model.username,
      },
    ));
  } else {
    Model.socketResult = res;
    Model.socketCount++;
    Model.socketNotifier.value = Model.socketCount;
  }
}

logoutEvent() async {
  Map<String, dynamic> res = Model.socketResult;
  if (res['intro'] == 'logout') {
    res = res['result'];
    await Model.prefs.remove('firebase');
    await Model.prefs.remove('sessionToken');

    Model.sessionLogin = false;
    Model.tokenSet = false;
    Model.username = "";
    if (res['status'] == 'hacker') {
      print('Already logged out');
      // webSock.sink.close(1000);

      snackMsg(Model.currentContext, "Already logged out");
      Navigator.pushAndRemoveUntil(
          Model.currentContext,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } else if (res['status'] == 'valid') {
      print('Logged out');

      snackMsg(Model.currentContext, "Logged out");

      Navigator.pushAndRemoveUntil(
          Model.currentContext,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    }
  }
}

reloadHomeEvent() {
  Map res = Model.socketResult;
  if (res['intro'] == 'homeproc') {
    res = res['result'];

    print(res);
    if (res['login'] == 'valid') {
      print('Secondary login successful');
      Model.emailVerified = (res['personal'][0][3] == 1) ? true : false;

      Navigator.pushAndRemoveUntil(
          Model.currentContext,
          MaterialPageRoute(
            builder: (context) => HomePage(
              false,
              accountDetails: Model.socketResult['result'],
            ),
          ),
          (route) => false);
    } else if (res['login'] == 'hacker') {
      print('hack attempt failed');
      snackMsg(Model.currentContext, "hack attempt failed");
      Navigator.pushAndRemoveUntil(
          Model.currentContext,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } else {
      print('dead end');
      Navigator.pop(Model.currentContext);
    }
    Model.socketNotifier.removeListener(reloadHomeEvent);
  }
}

sendMsg(Map<String, dynamic> payload) {
  print('sendMsg BLoC called');
  if (Model.webSock.closeCode != null) {
    print('socket closed... reconnecting');
    Model.webSock = socket.WebSocketChannel.connect(Uri.parse(Model.addr));
    //int code = 0;

    Model.webSock.stream.listen(sendMsgEvent);
  }
  print('socket sending...');
  Model.webSock.sink.add(jsonEncode(payload));
}

Size getTextSize(String text, TextStyle style, BuildContext context) {
  final TextPainter txtPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: style,
    ),
    maxLines: 1,
    textScaleFactor: MediaQuery.of(context).textScaleFactor,
    textDirection: TextDirection.ltr,
  )..layout();
  return txtPainter.size;
}

nullInputDialog(BuildContext context, String alertMsg, String alertTitle,
    {bool timed = false,
    int time = 0,
    void Function()? sendCode,
    bool email = false}) {
  showDialog(
    context: context,
    builder: (BuildContext contxt) {
      print('object');
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            titlePadding: EdgeInsets.only(top: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            contentPadding: EdgeInsets.only(top: 10, bottom: 5),
            title: Center(
              child: Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide())),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.red,
                    ),
                    Text('  ' + alertTitle),
                  ],
                ),
              ),
            ),
            content: SingleChildScrollView(
              child: Center(
                child: Text(alertMsg, style: TextStyle(fontSize: 14)),
              ),
            ),
            actions: [
              if (email == true)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(contxt).pop();
                      sendCode!();
                    },
                    child: Text("Verify email"),
                  ),
                ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(contxt).pop();
                  },
                  child: Text("Dismiss"),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

toast(
  BuildContext context,
  String alertMsg, {
  bool timed = false,
  int time = 0,
  void Function()? sendCode,
  bool email = false,
  bool dismissButton = false,
}) {
  showDialog(
    barrierColor: Colors.transparent,
    barrierDismissible: (dismissButton == true) ? false : true,
    context: context,
    builder: (BuildContext contxt) {
      if (timed == true && time != 0) {
        Timer(Duration(seconds: time), () {
          Navigator.pop(context);
        });
      }
      return Row(
        //scrollDirection: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 5),
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      bottom: (dismissButton == true) ? 6 : 0,
                      right: (dismissButton == true) ? 20 : 0),
                  child: Text(
                    alertMsg,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (dismissButton == true)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Dismiss"),
                  )
              ],
            ),
          )
        ],
      );
    },
  );
}

showProgressIndicator(BuildContext context) {
  showDialog(
      barrierDismissible: false,
      useRootNavigator: false,
      context: context,
      builder: (BuildContext contxt) {
        print('object');

        //return StatefulBuilder(builder: (context, setState) {
        return Center(
          child: CircularProgressIndicator(),
          heightFactor: 0.1,
          widthFactor: 0.1,
        );
        //});
      });
}

block(BuildContext context) {
  showDialog(
      barrierDismissible: false,
      useRootNavigator: false,
      context: context,
      builder: (BuildContext contxt) {
        print('blocked');

        //return StatefulBuilder(builder: (context, setState) {
        return Text('');
        //});
      });
}

Future<dynamic> sendRequest(
    http.Client http1, Uri address, Map<String, dynamic> content) async {
  //bool flag = false;
  bool networkErr = false;
  final value = await http1.post(address, body: content).catchError((error) {
    networkErr = true;
    return http.Response(jsonEncode({'value': 'error'}), 400);
  });

  if (value.statusCode == 200) {
    //print(value);
    //return jsonDecode(value.body);
    return {'result': jsonDecode(value.body), 'value': 'OK'};
  } else {
    print('error');
    //print(error);
    return {'value': 'error', 'network': networkErr ? 'true' : 'false'};
  }
}

logout(BuildContext context) {
  print("logout called");

  Uri address = Uri.parse(Model.domain + "logout");
  var content = {
    'intro': 'logout',
    "username": Model.username,
    "sessionid": Model.sessionToken,
  };

  showProgressIndicator(context);

  sendMsg(content);

  Model.socketNotifier.addListener(logoutEvent);
}

snackMsg(BuildContext context, String msg, {int timeout = 2}) {
  var theBar =
      SnackBar(content: Text(msg), duration: Duration(seconds: timeout));
  ScaffoldMessenger.of(context).showSnackBar(theBar);
}

reloadHome() {
  showDialog(
      barrierDismissible: false,
      useRootNavigator: false,
      context: Model.currentContext,
      builder: (BuildContext contxt) {
        print('dialog');

        //return StatefulBuilder(builder: (context, setState) {
        return LinearProgressIndicator();
        //});
      });

  Model.deviceWidth = MediaQuery.of(Model.currentContext).size.width;
  Model.deviceHeight = MediaQuery.of(Model.currentContext).size.height;
  if (Model.sessionLogin == true) {
    Model.username = Model.prefs.getString('username') as String;
    Model.sessionToken = Model.prefs.getString('sessionToken') as String;
  }

  print('Refresh');
  var address = Uri.parse(Model.domain + 'homeproc');

  var content = {
    'intro': 'homeproc',
    'username': Model.username,
    'sessionid': Model.sessionToken,
  };

  print(address);
  print(content);

  //showProgressIndicator(context);
  sendMsg(content);

  Model.socketNotifier.addListener(reloadHomeEvent);
}

class provider {
  static ValueNotifier<String> blocEars = ValueNotifier("f");
  static check() {
    //x.value = Model.name;
    blocEars.addListener(() {
      print("new name: ${Model.name}");
    });
  }
}
