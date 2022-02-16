// ignore_for_file: prefer_const_constructors, file_names, avoid_print, camel_case_types, unused_local_variable

import 'dart:async';
import 'dart:convert';

import 'package:experi/home/homeLogic.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart' as socket;
import 'package:flutter/material.dart';
import 'package:experi/model.dart';

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

      Navigator.pushNamedAndRemoveUntil(
          Model.currentContext, '/loginpage', (route) => false).then((value) {
        //remove/pop dialog's context from stack since the dialog has been popped
        if (Model.contextQueue.isNotEmpty) {
          Model.contextQueue.removeLast();

          //set current context variable to the next context on the stack
          Model.currentContext = Model.contextQueue.last;
        }
      });
    } else if (res['status'] == 'valid') {
      print('Logged out');

      snackMsg(Model.currentContext, "Logged out");

      Navigator.pushNamedAndRemoveUntil(
          Model.currentContext, '/loginpage', (route) => false).then((value) {
        //remove/pop dialog's context from stack since the dialog has been popped
        if (Model.contextQueue.isNotEmpty) {
          Model.contextQueue.removeLast();

          //set current context variable to the next context on the stack
          Model.currentContext = Model.contextQueue.last;
        }
      });
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

      HomeLogic.setter(
        false,
        accountDetails: Model.socketResult['result'],
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
    } else if (res['login'] == 'hacker') {
      print('hack attempt failed');
      snackMsg(Model.currentContext, "hack attempt failed");

      Navigator.pushNamedAndRemoveUntil(
          Model.currentContext, '/loginpage', (route) => false).then((value) {
        //remove/pop dialog's context from stack since the dialog has been popped
        if (Model.contextQueue.isNotEmpty) {
          Model.contextQueue.removeLast();

          //set current context variable to the next context on the stack
          Model.currentContext = Model.contextQueue.last;
        }
      });
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

nullInputDialog(String alertMsg, String alertTitle,
    {bool timed = false,
    int time = 0,
    void Function()? sendCode,
    bool email = false}) {
  showDialog(
    context: Model.currentContext,
    builder: (BuildContext contxt) {
      Model.contextQueue.addLast(contxt);
      Model.currentContext = contxt;
      print('nullInputDialog');
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
  ).then((value) {
    //remove/pop dialog's context from stack since the dialog has been popped
    if (Model.contextQueue.isNotEmpty) {
      Model.contextQueue.removeLast();

      //set current context variable to the next context on the stack
      Model.currentContext = Model.contextQueue.last;
    }
  });
}

showProgressIndicator() {
  showDialog(
      barrierDismissible: false,
      useRootNavigator: false,
      context: Model.currentContext,
      builder: (BuildContext contxt) {
        Model.contextQueue.addLast(contxt);
        Model.currentContext = contxt;
        print('showProgressIndicator');

        //return StatefulBuilder(builder: (context, setState) {
        return Center(
          child: CircularProgressIndicator(),
          heightFactor: 0.1,
          widthFactor: 0.1,
        );
        //});
      }).then((value) {
    //remove/pop dialog's context from stack since the dialog has been popped
    if (Model.contextQueue.isNotEmpty) {
      Model.contextQueue.removeLast();

      //set current context variable to the next context on the stack
      Model.currentContext = Model.contextQueue.last;
    }
  });
}

block() {
  showDialog(
      barrierDismissible: false,
      useRootNavigator: false,
      context: Model.currentContext,
      builder: (BuildContext contxt) {
        Model.contextQueue.addLast(contxt);
        Model.currentContext = contxt;
        print('blocked');

        //return StatefulBuilder(builder: (context, setState) {
        return Text('');
        //});
      }).then((value) {
    //remove/pop dialog's context from stack since the dialog has been popped
    if (Model.contextQueue.isNotEmpty) {
      Model.contextQueue.removeLast();

      //set current context variable to the next context on the stack
      Model.currentContext = Model.contextQueue.last;
    }
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

logout() {
  print("logout called");

  Uri address = Uri.parse(Model.domain + "logout");
  var content = {
    'intro': 'logout',
    "username": Model.username,
    "sessionid": Model.sessionToken,
  };

  showProgressIndicator();

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
        Model.contextQueue.addLast(contxt);
        Model.currentContext = contxt;
        print('dialog');

        //return StatefulBuilder(builder: (context, setState) {
        return LinearProgressIndicator();
        //});
      }).then((value) {
    //remove/pop dialog's context from stack since the dialog has been popped
    if (Model.contextQueue.isNotEmpty) {
      Model.contextQueue.removeLast();

      //set current context variable to the next context on the stack
      Model.currentContext = Model.contextQueue.last;
    }
  });

  //Model.deviceWidth = MediaQuery.of(Model.currentContext).size.width;
  // Model.deviceHeight = MediaQuery.of(Model.currentContext).size.height;
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
