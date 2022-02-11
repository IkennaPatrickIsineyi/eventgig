//import 'dart:html';
import 'dart:async';
//import 'dart:html' as html;
import 'dart:io';
//import 'package:socket_io_client/socket_io_client.dart' as socket;
import 'package:web_socket_channel/web_socket_channel.dart' as socket;
//import 'package:web_socket_channel/status.dart' as status;
import 'dart:math';
import 'dart:typed_data';
//import 'dart:developer' as developer;
/* import 'dart:isolate';
import 'dart:ui'; */
//import 'dart:math';

import 'package:intl/intl.dart' as intl;
//import 'package:image_crop/image_crop.dart';
import 'package:image_cropper/image_cropper.dart' as imgCrop;

/* import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as notif;
 */
/* import 'package:flutter_background_service/flutter_background_service.dart'
    as backService; */

//import 'package:workmanager/workmanager.dart' as backwork;

/* import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart'
    as backmanger; */

import 'package:shared_preferences/shared_preferences.dart';

/* import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';

var domain = (kIsWeb)
    ? "http://ikp120.pythonanywhere.com/"
    : "http://ikp120.pythonanywhere.com/";
String username = "";
String email = "";
String sessionToken = "";
bool emailVerified = false;
bool diableLogin = false;
var orderDetailList;
http.Client httpC = http.Client();
late SharedPreferences prefs;
String payload = "login";
bool sessionLogin = true;
bool blocked = false;
String currentRoute = "";
final ValueNotifier<int> selected = ValueNotifier<int>(0);
bool tokenSet = false;
int socketCount = 0;
List chatBuddies = [];
List members = [];
Map<String, List> memberOnlineStatus = {};
final ValueNotifier<int> allChatOnlineStatus = ValueNotifier<int>(0);
final ValueNotifier<int> posoNot = ValueNotifier<int>(0);
List chats = [];
bool modif = false;
/*memberOnlineStatus= {'user':[int onlinestatus,
String last_seen,List last_messages]} */
//last_messages= [[get, ik, 11:06 PM, 03-Feb-2022, saeea]]

late socket.WebSocketChannel webSock;

Stream socketStream = webSock.stream;
//int unSeen = 0;
final ValueNotifier<int> unSeen = ValueNotifier<int>(0);
final ValueNotifier<int> newRespondentLner = ValueNotifier<int>(0);

final ValueNotifier<int> socketNotifier = ValueNotifier<int>(0);
Map<String, dynamic> socketResult = {};

bool singleChats = false;
bool multiChats = false;

final ValueNotifier<int> pingNotifier = ValueNotifier<int>(0);

//final ValueNotifier<Map> chatData = ValueNotifier<Map>({});
Map chatData = {};
int numOfRespondents = 0;
int code = 1;

Map respondents = {};
int notifID = 2;
double mobileWidth = 500;
double deviceWidth = 0;
double deviceHeight = 0;

//Locks for different listeners
//Can also be implemented with Map

bool listener1Added = false;
bool listener2Added = false;

//late notif.AndroidNotificationChannel channel;
const String countKey = 'count';
const String isolateName = 'isolate';
//final ReceivePort port = ReceivePort();

//late SendPort uiSendPort;
int deb = 1;
String addr = "wss://eflask-app-ikp120.herokuapp.com/ws";
//String addr = "ws://127.0.0.1:5000/ws";

String token = '';
/* notif.FlutterLocalNotificationsPlugin notificationPlug =
    notif.FlutterLocalNotificationsPlugin(); */

//final service = backService.FlutterBackgroundService();

sendMsg(Map<String, dynamic> payload) {
  if (webSock.closeCode != null) {
    print('socket closed... reconnecting');
    webSock = socket.WebSocketChannel.connect(Uri.parse(addr));
    //int code = 0;

    webSock.stream.listen((event) {
      Map<String, dynamic> res = jsonDecode(event);
      code++;
      print("secondary $code");

      if (res['intro'] == 'ping') {
        socketResult = res;
        socketCount++;
        pingNotifier.value = socketCount;
        webSock.sink.add(jsonEncode(
          {
            'intro': 'alive',
            'username': username,
          },
        ));
      } else {
        socketResult = res;
        socketCount++;
        socketNotifier.value = socketCount;
      }
    });
  }
  webSock.sink.add(jsonEncode(payload));
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
      if (timed == true && time != 0)
        Timer(Duration(seconds: time), () {
          Navigator.pop(context);
        });
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

/* showNotification(
    int notifID, String notifTitle, var notifBody, String notifPayload) async {
  notif.AndroidNotificationDetails androidNotif =
      notif.AndroidNotificationDetails(
          'high_important_channel', 'High Important Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          priority: notif.Priority.high,
          importance: notif.Importance.max);

  notif.NotificationDetails notifDetails =
      notif.NotificationDetails(android: androidNotif);

  await notificationPlug.show(notifID, notifTitle, notifBody, notifDetails,
      payload: notifPayload);
}
 */
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

/* Future<dynamic> sendRequest(
    http.Client http, Uri address, Map<String, dynamic> content) async {
  await http.post(address, body: content).then(
    (value) {
      if (value.statusCode == 200) {
        print(value);
        return jsonDecode(value.body);
      }
    },
    onError: (error) {
      print('error');
      print(error);
      return 'error';
    },
  );
} */

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

  Uri address = Uri.parse(domain + "logout");
  var content = {
    'intro': 'logout',
    "username": username,
    "sessionid": sessionToken,
  };

  showProgressIndicator(context);

  sendMsg(content);

  socketNotifier.addListener(() async {
    Map<String, dynamic> res = socketResult;
    if (res['intro'] == 'logout') {
      res = res['result'];
      await prefs.remove('firebase');
      await prefs.remove('sessionToken');

      sessionLogin = false;
      tokenSet = false;
      username = "";
      if (res['status'] == 'hacker') {
        print('Already logged out');
        // webSock.sink.close(1000);

        snackMsg(context, "Already logged out");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      } else if (res['status'] == 'valid') {
        print('Logged out');

        snackMsg(context, "Logged out");

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      }
    }
  });

/*   sendRequest(httpC, address, content).then((value) async {
    res = value;
    //Navigator.pop(context);
    if (res['value'] == 'error') {
      print('network error...');
      snackMsg(context, "Network Error");
      diableLogin = false;
      Navigator.pop(context);
    } else if (res['value'] == 'OK') {
      res = res['result'];
      await prefs.remove('firebase');
      await prefs.remove('sessionToken');
      sessionLogin = false;
      tokenSet = false;
      if (res['status'] == 'hacker') {
        print('Already logged out');
        snackMsg(context, "Already logged out");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      } else if (res['status'] == 'valid') {
        print('Logged out');

        snackMsg(context, "Logged out");

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      }
    }
  });
 */
}

snackMsg(BuildContext context, String msg, {int timeout: 2}) {
  var theBar =
      SnackBar(content: Text(msg), duration: Duration(seconds: timeout));
  ScaffoldMessenger.of(context).showSnackBar(theBar);
}

Future<void> main() async {
  //print((deb++).toString());
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  if (!kIsWeb) {
    //await Firebase.initializeApp();

    print((deb++).toString());

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.red,
    ));

    print((deb++).toString());
    //FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    print((deb++).toString());
    if (prefs.containsKey('firebase') == false) {
      print((deb++).toString());
      //token = await FirebaseMessaging.instance.getToken() as String;
      token = 'Devicetoken';
      print((deb++).toString());
      prefs.setString('firebase', token);
      print((deb++).toString());
    } else {
      print((deb++).toString());
      token = prefs.getString('firebase') as String;
      print((deb++).toString());
    }
    if (prefs.containsKey('currentRoute') == false) {
      print((deb++).toString());
      prefs.setString('currentRoute', "");
      print((deb++).toString());
    } else {
      print((deb++).toString());
      currentRoute = prefs.getString('currentRoute') as String;
      print((deb++).toString());
    }
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    //int code = 0;

    try {
      webSock = socket.WebSocketChannel.connect(Uri.parse(addr));

      webSock.stream.listen((event) {
        Map<String, dynamic> res = jsonDecode(event);
        code++;
        print("primary $code");

        if (res['intro'] == 'ping') {
          socketResult = res;
          socketCount++;
          pingNotifier.value = socketCount;
          webSock.sink.add(jsonEncode(
            {
              'intro': 'alive',
              'username': username,
            },
          ));
        } else {
          socketResult = res;
          socketCount++;
          socketNotifier.value = socketCount;
        }
      });
    } catch (e) {
      print('dead socket');
    }
    return MaterialApp(
      title: 'eventGig',
      theme: ThemeData(
          primarySwatch: Colors.red,
          appBarTheme: AppBarTheme(
            color: Colors.red,
            elevation: 0,
            //brightness: Brightness.dark,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            textTheme: TextTheme(),
          )),
      home: (!kIsWeb)
          ? (prefs.containsKey('sessionToken') == false)
              ? LoginPage()
              : ReloadHomePage()
          : LoginPage(),
    );
  }
}

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class ChatShapeRight extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    Path path = Path();
    path.lineTo(width, 0);
    path.lineTo(width - 10, ((height * 0.2) <= 10) ? height * 0.2 : 10);
    path.lineTo(width - 10, height);
    path.lineTo(0, height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class ChatShapeLeft extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    Path path = Path();
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(10, height);
    path.lineTo(10, ((height * 0.2) <= 10) ? height * 0.2 : 10);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class CircleShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    Path path = Path();
    path.moveTo(0, height / 2);
    path.quadraticBezierTo(0, 0, width / 2, 0);
    path.quadraticBezierTo(width, 0, width, height / 2);
    path.quadraticBezierTo(width, height, width / 2, height);
    path.quadraticBezierTo(0, height, 0, height / 2);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class Testing extends StatefulWidget {
  @override
  _Testing createState() => _Testing();
}

//Allows a prospective user to create an account
class _Testing extends State<Testing> {
  //late html.WebSocket sock;
  final sock =
      socket.WebSocketChannel.connect(Uri.parse("ws://127.0.0.1:5000/ws"));

  /* late socket.Socket socketclient;
  connectSocket() {
  
    int x = 0;
    socketclient = socket.io(
        "http://localhost:3535",
        socket.OptionBuilder()
            .disableAutoConnect()
            .setExtraHeaders({'bh': x}).build());


    socketclient.connect();
  } */

  @override
  void initState() {
    super.initState();
    // connectSocket();
    //sock = html.WebSocket("ws://127.0.0.1:5000/ws");
    // sock.send("connect");
  }

  @override
  void dispose() {
    print("disposing");
    //socketclient.disconnect();
    super.dispose();
  }

  /*  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print("disposing");
      socketclient.disconnect();
    }
  } */

  @override
  build(BuildContext context) {
    /* if (sock.readyState == html.WebSocket.OPEN) {
      sock.send("connect");
    } else {
      print('not connected');
    }
    print(html.WebSocket.supported); */
    /*  socketclient.onConnect((_) {
      print("Connection establifdshed");
      print("id: ${socketclient.id}");

      // print("id: ${socketclient.id}");
      socketclient.emit("hello");
    });

    socketclient.onDisconnect((data) {
      print("server disconnected");
    });

    socketclient.on("connection reply", (data) {
      print(data);
    }); */

    /* socket.Server io = socket.Server();
    final nsp = io.of("/");
    nsp.on("connection", (client) {}); */
    //streamSource.call();
    return Scaffold(
      appBar: AppBar(
        title: Text("Testing"),
      ),
      body: Center(
        child: Container(
            child: Column(children: [
          StreamBuilder(
            stream: sock.stream,
            builder: (context, AsyncSnapshot snapshot) {
              Map data = {};
              int ig = 0;

              username = 'john'; //testing only

              if (snapshot.hasData) {
                print('change detected');
                data = jsonDecode(snapshot.data);
                // print(snapshot.data);
                print(data);
                if (data['status'] == 'ping') {
                  print('ping received');
                  sock.sink.add(jsonEncode({'data': 'alive'}));
                }
                if (data['status'] == 'connected') {
                  print('Connection established');
                  sock.sink.add(
                      jsonEncode({'username': username, 'data': 'identity'}));
                }
              } else
                print('coming');
              return (snapshot.hasData)
                  ? Column(children: [
                      for (var key in data.keys) Text("${data[key]} ig${ig++}")
                    ])
                  : LinearProgressIndicator();
            },
          ),
          ElevatedButton(
            onPressed: () {
              sock.sink
                  .add(jsonEncode({'username': username, 'data': 'sucker'}));
            },
            /* onPressed: () => socketclient.emit(
              "hello2",
              {
                "data1": "junk",
                "data2": "pig",
              },
            ), */
            child: Text("send data"),
          ),
        ])),
      ),
      //  ),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({this.resetpassword = false});
  final bool resetpassword;
  @override
  _LoginPage createState() => _LoginPage(this.resetpassword);
}

//Login page and class of the application

class _LoginPage extends State<LoginPage> {
  _LoginPage(this.resetpwd);
  final bool resetpwd;

  String password = "";
  bool nullSignal = false;
  bool registerSignal = false;
  bool loadHome = false;
  var homeParam;
  var result;

  bool resetPassword = false;
  String otp = '';
  String password1 = '';
  String password2 = '';
  bool mismatch = false;
  bool invalidOTP = false;
  bool usernameOnly = false;
  bool validating = false;
  Set formInputText = Set();

  //TextEditingController control = TextEditingController();
  final ValueNotifier textValidator = ValueNotifier(0);
  final ValueNotifier<Set> pwdResetValidator = ValueNotifier<Set>({});
  Set currentField = {};

  //Login processor of the application
  loginSock(BuildContext context) async {
    print("login called");

    //Uri address = Uri.parse(domain + "loginproc.cgi");

    Uri address = Uri.parse(domain + "login");
    Map<String, dynamic> content = {
      "intro": "login",
      "username": username,
      "password": password,
    };

    sendMsg(content);

    showProgressIndicator(context);

    liste() {
      print('login called');
      Map<String, dynamic> res = socketResult;
      if (res['intro'] == 'login') {
        res = res['result'];
        print(res);

        loginResultSock(context, res);
        print("rmoving listener...");
        socketNotifier.removeListener(liste);
        print('listener removed');
      }
    }

    socketNotifier.addListener(liste);
  }

  loginResultSock(BuildContext context, Map result) async {
    print('loginResult called...');
    //Uri address = Uri.parse(domain + "loginproc.cgi");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri address = Uri.parse(domain + "savesession");
    if (kIsWeb) {
      token = "joke";
    }

    Map<String, dynamic> content = {
      "intro": "savesession",
      "username": username,
      "password": password,
      "deviceid": 'dev',
      "deviceToken": token,
    };

    if (result['login'] == 'valid') {
      sendMsg(content);

      liste() async {
        print('savesession called');
        Map<String, dynamic> res = socketResult;
        if (res["intro"] == "savesession") {
          print("login complete...");
          print('logging into pythonanywhere');
          Map<String, dynamic> result = res['result'];
          sessionToken = result['sessionID'];
          emailVerified = (result['personal'][0][3] == 1) ? true : false;
          print('so');
          await prefs.setString('sessionToken', sessionToken);
          await prefs.setString('username', username);
          print('kno');
          if (tokenSet == false && !kIsWeb) {
            //token = await FirebaseMessaging.instance.getToken() as String;

            prefs.setString('firebase', token);
          }

          sessionLogin = false;

          print("homepage being called... next");
          diableLogin = false;
          Navigator.pop(context);
          //  setState(() {});

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  false,
                  accountDetails: result,
                ),
              ),
              (route) => false);
          socketNotifier.removeListener(liste);
        }
      }

      socketNotifier.addListener(liste);
    } else if (result['login'] == 'invalid') {
      Navigator.pop(context);
      print("Invalid login credentials...");
      setState(() {
        diableLogin = false;
      });

      nullInputDialog(
          context, "The password and username do not match", "Invalid");
    } else {
      Navigator.pop(context);
      print("unknown error...");
      setState(() {
        diableLogin = false;
      });
    }

    // print(content);
  }

  sendOPT1() {
    setState(() {
      usernameOnly = true;
      textValidator.value = 0;
    });
  }

  sendOTP() {
    if (username.isEmpty) {
      textValidator.value = 1;
      return;
    }

    var address = Uri.parse(domain + 'passwordotp');

    Map<String, dynamic> content = {
      "intro": "passwordotp",
      'subject': 'Password Reset Code',
      'username': username,
    };

    print('sendOTP called... content passed');

    print(address);
    print(content);
    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> res = socketResult;
      if (result['intro'] == 'passwordotp') {
        Navigator.pop(context);
        result = result['result'];
        print(result);
        if (result['status'] == 'sent') {
          print('Email Sent');
          snackMsg(context, "Email Sent");
          setState(() {
            usernameOnly = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => LoginPage(
                resetpassword: true,
              ),
            ),
          );
        } else if (result['status'] == 'invalid') {
          print('Invalid username');
          snackMsg(context, "Invalid username");
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  verifyOTP() {
    var address = Uri.parse(domain + 'resetpassword');

    Map<String, dynamic> content = {
      "intro": 'resetpassword',
      'otp': otp,
      'password': password1,
      'username': username,
    };

    print('verifyOTP called... content passed');

    print(address);
    print(content);
    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'resetpassword') {
        Navigator.pop(context);
        result = result['result'];
        print(result);
        if (result['status'] == 'changed') {
          print('Password Changed');

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
          snackMsg(context, "Password Reset Successful");
        } else if (result['status'] == 'hacker') {
          print('hack attempt failed');
          snackMsg(context, "hack attempt failed");
        } else if (result['status'] == 'invalid') {
          print('invalid otp');
          snackMsg(context, "Invalid OTP");
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
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

  // Input validator of the login page
  validateInput() async {
    if (username.isEmpty && password.isEmpty)
      textValidator.value = 3;
    else if (username.isEmpty)
      textValidator.value = 1;
    else if (password.isEmpty)
      textValidator.value = 2;
    else {
      setState(() {
        diableLogin = true;
      });
      await loginSock(context);
    }
  }

  /* notificationClick(String payload) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return LoginPage();
    }));
  }

  initNotif() async {
    print('initialising notif');
    notif.AndroidInitializationSettings initSettingAndroid =
        notif.AndroidInitializationSettings('@mipmap/ic_launcher');

    notif.InitializationSettings initSettings =
        notif.InitializationSettings(android: initSettingAndroid);

    await notificationPlug.initialize(initSettings,
        onSelectNotification: (payload) async {
      if (payload != null) notificationClick(payload);
    });
  } */

  //Renderer of the login page

  @override
  void dispose() {
    textValidator.dispose();
    pwdResetValidator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    currentRoute = "login";
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    prefs.setString("currentRoute", "login");
    resetPassword = resetpwd;

    if (resetPassword == true)
      return Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                "eventGig",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Password Reset",
                style: TextStyle(fontSize: 12),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: (deviceWidth > mobileWidth)
                  ? deviceWidth * 0.6
                  : deviceWidth * 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Divider(),
                  Text(
                    '''A 6-digit code has been sent to the email you registered with.\n\nEnter that OTP code in the field below''',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Divider(),
                  ValueListenableBuilder(
                    valueListenable: pwdResetValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          maxLength: 6,
                          onChanged: (input) {
                            otp = input;
                            pwdResetValidator.value.remove(4);
                            currentField.add(4);
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "OTP Code",
                            hintText: "Enter the OTP code here",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.security,
                              color: Colors.red,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value1.contains(4)) {
                              otp = '';
                              return "*required";
                            } else if (value!.contains(RegExp(r'(\D)')) &&
                                currentField.contains(4)) {
                              //otp = '';
                              return "Verification code is a number";
                            } else if (!value.contains(RegExp(r'(\d{6})')) &&
                                currentField.contains(4)) {
                              //otp = '';
                              return "Verification code is 6-digit number";
                            } else
                              return null;
                          },
                        ),
                      );
                    },
                  ),
                  Divider(),
                  ValueListenableBuilder(
                    valueListenable: pwdResetValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      return Container(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: TextFormField(
                            onChanged: (input) {
                              password1 = input;
                              pwdResetValidator.value.remove(5);
                              currentField.add(5);
                            },
                            decoration: InputDecoration(
                              labelText: "New Password",
                              hintText: "Choose a new password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.password,
                                color: Colors.red,
                              ),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            autovalidateMode: AutovalidateMode.always,
                            validator: (value) {
                              if (value1.contains(5)) {
                                password1 = '';
                                return "Password is required";
                              } else if (!value!
                                      .contains(RegExp(r'([\w\W]{8,})')) &&
                                  currentField.contains(5)) {
                                //password1 = '';
                                return "Must be at least 8 character long";
                              } else
                                return null;
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(),
                  ValueListenableBuilder(
                    valueListenable: pwdResetValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      print(value1);
                      return Container(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: TextFormField(
                            onChanged: (input) {
                              password2 = input;
                              pwdResetValidator.value.remove(6);
                              currentField.add(6);
                            },
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              hintText: "Enter the password again",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.password,
                                color: Colors.red,
                              ),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            autovalidateMode: AutovalidateMode.always,
                            validator: (value) {
                              if (value1.contains(6)) {
                                password2 = '';
                                return "Password is required";
                              } else if (!value!
                                      .contains(RegExp(r'([\w\W]{8,})')) &&
                                  currentField.contains(6)) {
                                //password2 = '';
                                return "Must be at least 8 character long";
                              } else if (value != password1 &&
                                  currentField.contains(6)) {
                                //password2 = '';
                                return "Passwords must match";
                              } else
                                return null;
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(),
                  Divider(),
                  ElevatedButton(
                    onPressed: () {
                      pwdResetValidator.value = {};
                      if (otp.isEmpty) pwdResetValidator.value.add(4);

                      if (password1.isEmpty) pwdResetValidator.value.add(5);
                      if (password2.isEmpty) pwdResetValidator.value.add(6);
                      if (otp.isNotEmpty &&
                          password1.isNotEmpty &&
                          password2.isNotEmpty &&
                          password1 == password2) verifyOTP();
                    },
                    child: Text("Submit Code"),
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size.fromWidth(
                          (deviceWidth > mobileWidth)
                              ? deviceWidth * 0.5
                              : deviceWidth * 0.7,
                        ),
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );

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
              "Login",
              style: TextStyle(fontSize: 12),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(),
                alignment: Alignment.center,
                child: IconButton(
                  alignment: Alignment.center,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => RegisterPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.account_circle_sharp),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            //alignment: Alignment.center,
            constraints: BoxConstraints(
              minWidth: 0,
              maxWidth: (deviceWidth > mobileWidth)
                  ? deviceWidth * 0.6
                  : deviceWidth * 0.9,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Divider(),
                ValueListenableBuilder(
                    valueListenable: textValidator,
                    builder: (BuildContext context, value1, Widget? child) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (input) {
                            username = input;
                            textValidator.value = 0;
                          },
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            labelText: "Username",
                            hintText: "username",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.red,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value2) {
                            if (value1 == 1 || value1 == 3) {
                              username = "";
                              return "*required";
                            } else
                              return null;
                          },
                        ),
                      );
                    }),
                if (usernameOnly == false) Divider(),
                if (usernameOnly == false)
                  ValueListenableBuilder(
                      valueListenable: textValidator,
                      builder: (BuildContext context, value1, Widget? child) {
                        return Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: TextFormField(
                            onChanged: (input) {
                              password = input;
                              textValidator.value = 0;
                            },
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              hintText: "Enter your password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.password,
                                color: Colors.red,
                              ),
                            ),
                            autovalidateMode: AutovalidateMode.always,
                            validator: (value2) {
                              if (value1 == 2 || value1 == 3) {
                                password = "";
                                return "*required";
                              } else
                                return null;
                            },
                          ),
                        );
                      }),
                Divider(),
                Divider(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // if (usernameOnly == false)
                    ElevatedButton(
                      onPressed: (diableLogin == false)
                          ? (usernameOnly == false)
                              ? validateInput
                              : () => setState(() {
                                    usernameOnly = false;
                                  })
                          : null,
                      child: Text("Login"),
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(
                          Size.fromWidth(
                            (deviceWidth > mobileWidth)
                                ? deviceWidth * 0.4
                                : deviceWidth * 0.7,
                          ),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // if (usernameOnly == false)
                    Divider(), Divider(),
                    ElevatedButton(
                      onPressed: (usernameOnly == false)
                          ? sendOPT1
                          : (usernameOnly == true)
                              ? sendOTP
                              : null,
                      child: Text("Reset Password"),
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(
                          Size.fromWidth(
                            (deviceWidth > mobileWidth)
                                ? deviceWidth * 0.4
                                : deviceWidth * 0.7,
                          ),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPage createState() => _RegisterPage();
}

//Allows a prospective user to create an account
class _RegisterPage extends State<RegisterPage> {
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
    if (username.isEmpty) textValidator.value.add(1);
    if (email.isEmpty) textValidator.value.add(2);
    if (password.isEmpty) textValidator.value.add(3);
    if (password2.isEmpty) textValidator.value.add(4);

    if (gender == "Select gender")
      nullInputDialog(context, "Select your gender", "Gender missing");

    if (username.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        gender != "Select your gender" &&
        password == password2) sendInput();
  }

  sendInput() {
    var addr;
    Map<String, String> param = {};
    //var result;

    addr = Uri.parse(domain + "regproc");
    param = {
      'intro': 'regproc',
      "username": username,
      "password": password,
      "email": email,
      "gender": gender
    };

    print(param);
    print(addr);
    showProgressIndicator(context);

    sendMsg(param);
    //socketNotifier.addListener(() { })

    liste() {
      print('new event');
      // Map<String, dynamic> result = jsonDecode(event);
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'regproc') {
        Navigator.pop(context);
        result = result['result'];
        print(result);

        if (result['valid'] == 'no') {
          if (result['username'] == 'taken' &&
              result['name'] == 'taken' &&
              result['email'] == 'taken')
            nullInputDialog(
                context, "Username and email are not available", 'Oops');
          else if (result['username'] == 'taken' && result['email'] == 'taken')
            nullInputDialog(
                context, "Username and email are not available", 'Oops');
          else if (result['username'] == 'taken')
            nullInputDialog(context, "Username is not available", 'Oops');
          else if (result['email'] == 'taken')
            nullInputDialog(context, "Email is not available", 'Oops');
        } else if (result['valid'] == 'yes') {
          //user = result['usertype'];
          print("Registered and Logged in...");
          sessionToken = result['sessID'];
          emailVerified = false;
          prefs.setString('sessionToken', sessionToken);
          prefs.setString('username', username);
          sessionLogin = false;
          /* setState(() {
            homeSignal = true;
          }); */
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  true,
                ),
              ),
              (route) => false);
        }
        socketNotifier.removeListener(liste);
      } else if (result['intro'] == 'regprocError') {
        Navigator.pop(context);
        snackMsg(context, "network error");
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  @override
  Widget build(BuildContext context) {
    currentRoute = "register";
    prefs.setString("currentRoute", "register");
    var genderItems = [
      "Select gender",
      "Male",
      "Female",
    ];

    if (loginSignal == true) {
      return LoginPage();
    } else if (homeSignal == true) {
      return HomePage(true);
    }
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
              "Registration",
              style: TextStyle(fontSize: 12),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                alignment: Alignment.center,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                      (route) => false);
                },
                icon: Icon(Icons.login),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: (deviceWidth > mobileWidth)
                ? deviceWidth * 0.6
                : deviceWidth * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Divider(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          color: Colors.grey[300],
                        ),
                        padding: EdgeInsets.only(left: 30),
                        child: DropdownButton(
                          value: gender,
                          onChanged: (var input) {
                            setState(() {
                              gender = input as String;
                            });
                          },

                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          isDense: true,
                          alignment: Alignment.center,
                          //icon: Icon(Icons.face_outlined),
                          items: genderItems.map((var item) {
                            return DropdownMenuItem(
                              alignment: Alignment.center,
                              child: Container(
                                decoration: (item != "Select gender")
                                    ? BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                      )
                                    : BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                        color: Colors.white,
                                      ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: Colors.red,
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                        left: 15,
                                        right: 5,
                                      ),
                                      child: Text(item),
                                    )
                                  ],
                                ),
                              ),
                              value: item,
                            );
                          }).toList(),
                        ),
                      ),
                      Divider(),
                      ValueListenableBuilder(
                        valueListenable: textValidator,
                        builder:
                            (BuildContext context, Set value1, Widget? child) {
                          return Container(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                onChanged: (input) {
                                  username = input;
                                  value1.remove(1);
                                  currentField.add(1);
                                },
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  labelText: "Username",
                                  hintText: "Choose a username",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.red,
                                  ),
                                ),
                                autovalidateMode: AutovalidateMode.always,
                                validator: (value) {
                                  if (value1.contains(1)) {
                                    username = '';
                                    return "* required";
                                  } else
                                    return null;
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      Divider(),
                      ValueListenableBuilder(
                        valueListenable: textValidator,
                        builder:
                            (BuildContext context, Set value1, Widget? child) {
                          return Container(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                onChanged: (input) {
                                  email = input;
                                  value1.remove(2);
                                  currentField.add(2);
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  hintText: "email",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Colors.red,
                                  ),
                                ),
                                autovalidateMode: AutovalidateMode.always,
                                validator: (value) {
                                  if (value1.contains(2)) {
                                    email = '';
                                    return "* required";
                                  } else
                                    return null;
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      Divider(),
                      ValueListenableBuilder(
                        valueListenable: textValidator,
                        builder:
                            (BuildContext context, Set value1, Widget? child) {
                          return Container(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                onChanged: (input) {
                                  password = input;
                                  value1.remove(3);
                                  currentField.add(3);
                                },
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  hintText: "Choose a password",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.password,
                                    color: Colors.red,
                                  ),
                                ),
                                keyboardType: TextInputType.visiblePassword,
                                autovalidateMode: AutovalidateMode.always,
                                validator: (value) {
                                  if (value1.contains(3)) {
                                    password = '';
                                    return "* required";
                                  } else
                                    return null;
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      Divider(),
                      ValueListenableBuilder(
                        valueListenable: textValidator,
                        builder:
                            (BuildContext context, Set value1, Widget? child) {
                          return Container(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                onChanged: (input) {
                                  password2 = input;
                                  value1.remove(4);
                                  currentField.add(4);
                                },
                                decoration: InputDecoration(
                                  labelText: "Confirm Password",
                                  hintText: "Confirm password",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.password,
                                    color: Colors.red,
                                  ),
                                ),
                                keyboardType: TextInputType.visiblePassword,
                                autovalidateMode: AutovalidateMode.always,
                                validator: (value) {
                                  if (value1.contains(4)) {
                                    password2 = '';
                                    return "* required";
                                  } else if (value != password &&
                                      currentField.contains(4))
                                    return "Passwords must match";
                                  else
                                    return null;
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      Divider(),
                      Divider(),
                      ElevatedButton(
                        //submit button segment
                        child: Text("Submit"),
                        onPressed: validateInput,
                        style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all<Size>(
                            Size.fromWidth(
                              (deviceWidth > mobileWidth)
                                  ? deviceWidth * 0.4
                                  : deviceWidth * 0.7,
                            ),
                          ),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LogOutTool extends StatefulWidget {
  @override
  _LogOutTool createState() => _LogOutTool();
}

//logs out the user
class _LogOutTool extends State<LogOutTool> {
  bool loggedOut = false;

  /* logout() {
    print("logout called");

    Uri address = Uri.parse(domain + "logout");
    var content = {"username": username, "sessionid": sessionToken};

    var res;

    sendRequest(httpC,address, content).then((value) {
      res = value;
      //Navigator.pop(context);
      if (res == 'error') {
        print('network error...');
        snackMsg(context, "Network Error");
        diableLogin = false;
      } else if (res != 'error') {
        if (res['status'] == 'hacker') {
          print('Sorry, you could not hack us');
        } else if (res['status'] == 'valid') {
          print('Logged out');
          snackMsg(context, "Logged out");
          setState(() {
            loggedOut = true;
          });
          /* Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false); */
        }
      }
    });
  }
 */
  @override
  Widget build(BuildContext context) {
    currentRoute = "logout";
    prefs.setString("currentRoute", "logout");

    return LoginPage();
  }
}

class ReloadHomePage extends StatefulWidget {
  @override
  _ReloadHomePage createState() => _ReloadHomePage();
}

//refreshes dashboard
class _ReloadHomePage extends State<ReloadHomePage> {
  var callHome = false;
  var dataRetrieved = false;
  var result;

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    if (sessionLogin == true) {
      username = prefs.getString('username') as String;
      sessionToken = prefs.getString('sessionToken') as String;
    }

    if (dataRetrieved == false) {
      print('Refresh');
      var address = Uri.parse(domain + 'homeproc');

      var content = {
        'intro': 'homeproc',
        'username': username,
        'sessionid': sessionToken,
      };

      print(address);
      print(content);

      //showProgressIndicator(context);
      sendMsg(content);

      liste() {
        Map res = socketResult;
        if (res['intro'] == 'homeproc') {
          res = res['result'];

          print(res);
          if (res['login'] == 'valid') {
            print('Secondary login successful');
            emailVerified = (res['personal'][0][3] == 1) ? true : false;
            //snackMsg(context, "Order placed successfully");
            setState(() {
              callHome = true;
              dataRetrieved = true;
              result = socketResult;
            });
          } else if (res['login'] == 'hacker') {
            print('hack attempt failed');
            snackMsg(context, "hack attempt failed");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
                (route) => false);
          } else {
            print('dead end');
          }
          socketNotifier.removeListener(liste);
        }
      }

      socketNotifier.addListener(liste);
    }

    if (callHome == true) {
      return MaterialApp(
        home: HomePage(
          false,
          accountDetails: result['result'],
        ),
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
      );
    } else
      return Center(
        child: Image.asset(
          "assets/images/imgloading.gif",
          width: MediaQuery.of(context).size.height * 0.3,
          height: MediaQuery.of(context).size.height * 0.3,
        ),
        /* Text(
          'Loading...',
          style: TextStyle(
            fontSize: 12,
          ),
        ), */
      );
  }
}

class HomePage extends StatefulWidget {
  HomePage(this.newAccount, {this.accountDetails: const {}});
  final Map accountDetails;
  final bool newAccount;
  @override
  _HomePage createState() =>
      _HomePage(newAccount, accountDetails: accountDetails);
}

class _HomePage extends State<HomePage> /* with WidgetsBindingObserver */ {
  _HomePage(this.newAccount, {this.accountDetails: const {}});
  final Map accountDetails;
  final bool newAccount;

  bool logoutSignal = false;
  bool viewDetails = false;
  var result;

  //late Timer updateLastSeenTimer;

  List pendingList = [];
  List scheduledList = [];
  List completedList = [];
  List pendingPicList = [];
  List scheduledPicList = [];
  List completedPicList = [];
  List<Widget> contentList = [];
  int trnxid = 0;
  bool verifyEmail = false;
  String otp = '';
  bool invalidOtp = false;

  //late Timer homeTimer;

  getNotifications() {
    var address = Uri.parse(domain + 'getunclicked');

    var content = {
      "intro": "getunclicked",
      'username': username,
      'sessionid': sessionToken,
    };

    print('getunclicked called... content passed');

    print(address);
    print(content);
    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'getunclicked') {
        Navigator.pop(context);
        result = result['result'];
        print(result);
        if (result['status'] == 'valid') {
          print('Notifications retrieved successfully');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  Notifications(result['unclicked']),
            ),
          );
        } else if (result['status'] == 'hacker') {
          print('hack attempt failed');
          snackMsg(context, "hack attempt failed");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (result['status'] == 'invalid') {
          print('Invalid request');
          snackMsg(context, "Invalid request");
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  reload() {
    return Future.delayed(
        Duration(
          seconds: 1,
        ), () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ReloadHomePage(),
          ),
          (route) => false);
    });
  }

  getDetails(var trnxid) {
    var address = Uri.parse(domain + 'detailproc');

    var content = {
      "intro": "detailproc",
      'trnxid': trnxid.toString(),
      'username': username,
      'sessionid': sessionToken,
    };

    print('detailproc called... content passed');

    print(address);
    print(content);
    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'detailproc') {
        Navigator.pop(context);
        result = result['result'];
        print(result);
        if (result['status'] == 'valid') {
          print('Orders retrieved successfully');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ExixtingOrderDetailPage(
                result['details'][0],
                result['details'][1],
                result['personal'][2],
                result['details'][2],
                result['details'][3],
                result['details'][4],
                result['details'][5],
                result['details'][6].toString(),
                result['details'][7],
                result['details'][8].toString(),
                result['details'][9],
                result['details'][10].toString(),
                result['details'][11],
                result['details'][12],
                result['details'][13],
                result['details'][14],
                result['details'][15],
              ),
            ),
          );
        } else if (result['status'] == 'hacker') {
          print('hack attempt failed');
          snackMsg(context, "hack attempt failed");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (result['status'] == 'invalid') {
          print('Invalid request');
          snackMsg(context, "Invalid request");
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  getSettings() {
    var address = Uri.parse(domain + 'getsettings');

    var content = {
      'intro': 'getsettings',
      'username': username,
      'sessionid': sessionToken,
    };

    print('getsettings called... content passed');

    print(address);
    print(content);
    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'getsettings') {
        Navigator.pop(context);
        result = result['result'];
        print(result);
        if (result['status'] == 'valid') {
          print('Settings retrieved successfully');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  ProfileSetting(result['settings'], result['planner']),
            ),
          );
        } else if (result['status'] == 'hacker') {
          print('hack attempt failed');
          snackMsg(context, "hack attempt failed");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (result['status'] == 'invalid') {
          print('Invalid request');
          snackMsg(context, "Invalid request");
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  chatHistory() {
    var address = Uri.parse(domain + 'chathistory');

    var content = {
      'intro': 'chathistory',
      'username': username,
      'sessionid': sessionToken,
    };

    print('chathistory called... content passed');

    print(address);
    print(content);
    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'chathistory') {
        Navigator.pop(context);
        result = result['result'];
        print(result);
        if (result['status'] == 'valid') {
          print('Chat History retrieved');

          chatData = result;
          chatBuddies = result['profiles'];
          int i = 0;
          members = [];
          memberOnlineStatus = {};
          for (var user in result['profiles']) {
            memberOnlineStatus[user[0]] = [
              result['onlineStatus'][i],
              result['last_seen'][i],
              result['last_messages'][i]
            ];
            members.add(user[0]);
            /*memberOnlineStatus= {'user':[result['online'][i],
            result['last_seen'][i],result['last_message'][i]]} */
            //last_messages= [[get, ik, 11:06 PM, 03-Feb-2022, saeea]]
            i++;
          }
          numOfRespondents = (chatData['profiles']).length;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => Chatroom(
                [],
                [],
                false,
                "ChatroomMulti",
                multipleProfiles: result['profiles'],
              ),
            ),
          );
        } else if (result['status'] == 'hacker') {
          print('hack attempt failed');
          snackMsg(context, "hack attempt failed");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (result['status'] == 'invalid') {
          print('Invalid request');
          snackMsg(context, "Invalid request");
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  reRoute(String direction) {
    print('reroute called');
    if (direction == 'setting')
      getSettings();
    else if (direction == 'chat')
      chatHistory();
    else if (direction == 'logout') logout(context);
  }

  sendOTP() {
    var address = Uri.parse(domain + 'genOtp');

    var content = {
      'intro': 'genOtp',
      'subject': 'Email Verification Code',
      'username': username,
      'sessionid': sessionToken,
    };

    print('sendOTP called... content passed');

    print(address);
    print(content);
    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'genOtp') {
        Navigator.pop(context);

        print(result);
        result = result['result'];
        if (result['status'] == 'sent') {
          print('Email Sent');
          snackMsg(context, "Email Sent");
          setState(() {
            verifyEmail = true;
          });
        } else if (result['status'] == 'hacker') {
          print('hack attempt failed');
          snackMsg(context, "hack attempt failed");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  verifyOTP() {
    var address = Uri.parse(domain + 'verifyOtp');

    var content = {
      'intro': 'verifyOtp',
      'otp': otp,
      'username': username,
      'sessionid': sessionToken,
    };

    print('verifyOTP called... content passed');

    print(address);
    print(content);
    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'verifyOtp') {
        Navigator.pop(context);
        print(result);
        result = result['result'];
        if (result['status'] == 'verified') {
          print('Email Sent');
          snackMsg(context, "Verification successfull");
          emailVerified = true;
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ReloadHomePage(),
              ),
              (route) => false);
        } else if (result['status'] == 'hacker') {
          print('hack attempt failed');
          snackMsg(context, "hack attempt failed");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (result['status'] == 'invalid') {
          print('invalid otp');
          snackMsg(context, "Invalid OTP");
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  updateLastSeen() {
    var result;
    var address = Uri.parse(domain + 'updateLastSeen');
    var content = {
      'intro': 'updateLastSeen',
      'username': username,
      'sessionid': sessionToken,
    };

    sendMsg(content);

    liste() {
      print('updated last seen');
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'updateLastSeen') {
        result = result['result'];
        if (result['status'] == 'hacker') {
          print('Sorry, you could not hack us');
        } else if (result['status'] == 'valid') {
          print('Last Seen updated');
        } //socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  starBuilder(star) {
    print('starBuilder called');
    List<Widget> starList = [];

    for (var i = 1; i <= star; i++) {
      starList.add(Icon(
        Icons.star_outlined,
        color: Colors.orange,
        size: 16,
      ));
    }
    for (var j = star; j < 5; j++) {
      starList.add(
        Icon(
          Icons.star_outline,
          color: Colors.grey,
          size: 16,
        ),
      );
    }

    return Row(
      children: starList,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
    );
  }

//Build pending,scheduled, completed tabs
  buildTable(var tableType, List itemList, List picsList) {
    if (itemList.isNotEmpty) {
      contentList = [];
      int count = -1;
      //create tab body

      for (var item in itemList) {
        int indx = itemList.indexWhere((element) => element[4] == item[4]);
        count++;
        contentList.add(
          GestureDetector(
            onTapUp: (value) {
              trnxid = item[4];
              print('trnxid $trnxid');
              getDetails(trnxid);
            },
            child: Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                /* border: Border(
                    top: BorderSide(),
                    bottom: BorderSide(),
                    left: BorderSide(),
                    right: BorderSide(),
                  ) */
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: ClipOval(
                      child: GestureDetector(
                        onTap: () => showDialog(
                            context: context,
                            builder: (BuildContext contxt) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Container(
                                      child: Image.network(
                                        //reviewer's profile picture

                                        (picsList[indx].isNotEmpty)
                                            ? domain +
                                                'img/' +
                                                picsList[indx][0][0]
                                            : domain + 'img/' + 'default.png',
                                        height: (deviceWidth > mobileWidth)
                                            ? deviceHeight * 0.8
                                            : deviceWidth * 0.8,
                                        width: (deviceWidth > mobileWidth)
                                            ? deviceHeight * 0.7
                                            : deviceWidth * 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                        //padding: EdgeInsets.only(left: 5, top: 5),
                        child: FadeInImage.assetNetwork(
                          placeholder: "assets/images/imgloading.gif",
                          image: (picsList[count].isNotEmpty)
                              ? domain + 'img/' + picsList[count][0][0]
                              : domain + 'img/' + 'default.png',
                          height: (deviceWidth > mobileWidth)
                              ? deviceHeight * 0.1
                              : deviceWidth * 0.1,
                          width: (deviceWidth > mobileWidth)
                              ? deviceHeight * 0.1
                              : deviceWidth * 0.1,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          //event_type
                          Container(
                            constraints:
                                BoxConstraints(minWidth: deviceWidth * 0.4),
                            padding: EdgeInsets.only(bottom: 2),
                            child: Text(
                              item[1],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          //time_created or event_date or time_completed
                          Text(
                            item[0],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                      (tableType == 'completed')
                          ? Container(
                              child: starBuilder(item[2]),
                            )
                          : Text(
                              //event_date or budget or rating
                              (tableType == "scheduled")
                                  ? item[2].toString() + " Naira"
                                  : item[2].toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                      Container(
                        constraints:
                            BoxConstraints(maxWidth: deviceWidth * 0.6),
                        child: Text(
                          //budget or fee or comment
                          (tableType == "pending" || tableType == 'scheduled')
                              ? item[3].toString() + " Naira"
                              : item[3].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }

      return Container(
        color: Colors.red[100],
        child: Column(
          children: contentList,
        ),
      );
    } else if (itemList.isEmpty)
      return Center(
        heightFactor: 10,
        child: Text(
          "No events",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      );
  }

  /* @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  } */

  /*  @override
  void dispose() {
    //WidgetsBinding.instance!.removeObserver(this);
    //homeTimer.cancel();
    super.dispose();
  } */

/*
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("current state: $state");
    if (state == AppLifecycleState.detached) {
      //SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      //SystemNavigator.pop();
      //Process.killPid(pid);
    }
  }
 */
  @override
  void initState() {
    super.initState();
    socketNotifier.addListener(() {
      Map res = socketResult;
      if (res['intro'] == 'newOrder') {
        print('new order received');
        nullInputDialog(
          context,
          "You have a new event planning gig",
          "New Order",
        );
      }
    });

    /* if (!kIsWeb) {
      backService.FlutterBackgroundService.initialize(onStart,
          foreground: false);

      backService.FlutterBackgroundService().onDataReceived.listen((event) {
        print('processing new received message from ui to service');
        if (event!['action'] == 'unSeen') {
          unSeen.value = event['unSeen'];
          return;
        }
      });

      backService.FlutterBackgroundService().sendData({
        'action': "loggedIn",
        'username': username,
        'sessionToken': sessionToken,
      });
    }
 */
    /*  updateLastSeenTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      updateLastSeen();
    });
 */
    //WidgetsBinding.instance!.addObserver(this);

    /* notif.AndroidInitializationSettings initSettingAndroid =
        notif.AndroidInitializationSettings('@mipmap/ic_launcher');

    notif.InitializationSettings initSettings =
        notif.InitializationSettings(android: initSettingAndroid);

    notificationPlug.initialize(initSettings, onSelectNotification: (payload) {
      print(payload);
    });
    if (!kIsWeb) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('onMessage');
        //RemoteNotification? notificationContent = message.notification;
        if (message.notification == null)
          print('not a notification');
        else if (message.notification != null &&
            message.notification?.android != null &&
            !kIsWeb) print('new notification received');

        showNotification(
            message.notification.hashCode,
            message.notification?.title as String,
            message.notification?.body,
            'notify');
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(true),
            ),
            (route) => false);
      });

      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null)
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(true),
              ),
              (route) => false);
      });
    } */
  }

  //Renderer of the home page

  @override
  Widget build(BuildContext context) {
    prefs.setString("currentRoute", "homepage");
    currentRoute = "homepage";
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
      emailVerified = false;
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

    if (logoutSignal == true) {
      return LogOutTool();
    } else if (verifyEmail == true)
      return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text("Email verification"),
        ),
        body: Container(
          child: Column(
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
                    } else if (!value.contains(RegExp(r'(\d{6})'))) {
                      otp = '';
                      return "Verification code is 6-digit number";
                    } else
                      return null;
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
        ),
      );
    else
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              (emailVerified == true)
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => CreateOrderPage(),
                      ),
                    )
                  : nullInputDialog(
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
                            child: Icon(Icons.notifications, size: 28),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                CircleBorder(),
                              ),
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: unSeen,
                            builder: (BuildContext context, int value,
                                Widget? child) {
                              print('changed to $value');
                              if (value > 0)
                                return Positioned(
                                  child: ClipOval(
                                    child: CircleAvatar(
                                      child: ValueListenableBuilder(
                                        valueListenable: unSeen,
                                        builder: (BuildContext context,
                                            int value, Widget? child) {
                                          print('changed to $value');
                                          return Text(
                                            '$value',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          );
                                        },
                                      ),
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      radius: 10,
                                    ),
                                  ),
                                  right: 6,
                                  top: 5,
                                );
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
                      icon: Icon(Icons.pending_actions_outlined, size: 16),
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
                      icon: Icon(Icons.verified_outlined, size: 16),
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
                    child: buildTable("pending", pendingList, pendingPicList),
                  ),
                  onRefresh: () {
                    block(context);
                    return reload();
                  }),
              RefreshIndicator(
                  semanticsLabel: 'scheduledTab',
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: buildTable(
                        "scheduled", scheduledList, scheduledPicList),
                  ),
                  onRefresh: () {
                    block(context);
                    return reload();
                  }),
              RefreshIndicator(
                  semanticsLabel: 'completedTab',
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: buildTable(
                        "completed", completedList, completedPicList),
                  ),
                  onRefresh: () {
                    block(context);
                    return reload();
                  }),
            ],
          ),
        ),
      );
  }
}

class ExixtingOrderDetailPage extends StatefulWidget {
  ExixtingOrderDetailPage(
    this.client,
    this.planner,
    this.rGender,
    this.timeCreated,
    this.eventDate,
    this.street,
    this.eventType,
    this.budget,
    this.status,
    this.fee,
    this.note,
    this.trnxid,
    this.rating,
    this.comment,
    this.city,
    this.state,
    this.country,
  );

  final String client;
  final String planner;
  final String rGender;
  final String timeCreated;
  final String eventDate;
  final String street;
  final String eventType;
  final String budget;
  final String status;
  final String fee;
  final String note;
  final String trnxid;
  final int rating;
  final String comment;
  final String city;
  final String state;
  final String country;

  @override
  _ExixtingOrderDetailPage createState() => _ExixtingOrderDetailPage(
      client,
      planner,
      rGender,
      timeCreated,
      eventDate,
      street,
      eventType,
      budget,
      status,
      fee,
      note,
      trnxid,
      rating,
      comment,
      city,
      state,
      country);
}

//Displays the details of an exixting order
class _ExixtingOrderDetailPage extends State<ExixtingOrderDetailPage> {
  _ExixtingOrderDetailPage(
    this.client,
    this.planner,
    this.rGender,
    this.timeCreated,
    this.eventDate,
    this.street,
    this.eventType,
    this.budget,
    this.status,
    this.fee,
    this.note,
    this.trnxid,
    this.rating,
    this.comment,
    this.city,
    this.state,
    this.country,
  );

  final String client;
  final String planner;
  final String rGender;
  final String timeCreated;
  final String eventDate;
  final String street;
  final String eventType;
  final String budget;
  final String status;
  final String fee;
  final String note;
  final String trnxid;
  final int rating;
  final String comment;
  final String city;
  final String state;
  final String country;

  ValueNotifier<int> textValidator = ValueNotifier<int>(0);

  bool confirmed = false;
  bool userRated = false;
  String theReport = "";

  bool ratePlanner = false;

  int pos = 0;
  String review = '';

  starBuilder(star) {
    print('starBuilder called');
    List<Widget> starList = [];

    for (var i = 1; i <= star; i++) {
      starList.add(Icon(
        Icons.star_outlined,
        color: Colors.orange,
        size: 16,
      ));
    }
    for (var j = star; j < 5; j++) {
      starList.add(
        Icon(
          Icons.star_outline,
          color: Colors.grey,
          size: 16,
        ),
      );
    }

    return Row(
      children: starList,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
    );
  }

  rateUser() {
    setState(() {
      ratePlanner = true;
    });
  }

  submitRating(String review, int rating) {
    var result;
    var address = Uri.parse(domain + 'finish');
    var content = {
      'intro': 'finish',
      'username': username,
      'rating': rating.toString(),
      'comment': review,
      'trnxid': trnxid,
      'sessionid': sessionToken,
    };

    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'finish') {
        Navigator.pop(context);
        result = result['result'];
        if (result['status'] == 'hacker') {
          print('Sorry, you could not hack us');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (result['status'] == 'valid') {
          print('Review successful');
          snackMsg(context, "Review Successful. Thanks!");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ReloadHomePage(),
              ),
              (route) => false);
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  acceptOrder() {
    var result;
    var address = Uri.parse(domain + 'accptjobproc');
    var content = {
      'intro': 'accptjobproc',
      'username': username,
      'trnxid': trnxid,
      'sessionid': sessionToken,
    };

    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'accptjobproc') {
        Navigator.pop(context);

        result = result['result'];
        if (result['status'] == 'hacker') {
          print('Sorry, you could not hack us');
          logout(context);
        } else if (result['status'] == 'valid') {
          print('Accept successful');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ReloadHomePage(),
              ),
              (route) => false);
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  rejectOrder() {
    var result;
    var address = Uri.parse(domain + 'rejjobproc');
    var content = {
      'intro': 'rejjobproc',
      'username': username,
      'trnxid': trnxid,
      'sessionid': sessionToken,
    };

    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'rejjobproc') {
        Navigator.pop(context);

        result = result['result'];
        if (result['status'] == 'hacker') {
          print('Sorry, you could not hack us');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (result['status'] == 'valid') {
          print('Reject successful');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ReloadHomePage(),
              ),
              (route) => false);
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  cancelEvent() {
    var result;
    var address = Uri.parse(domain + 'cancproc');
    var content = {
      'intro': 'cancproc',
      'username': username,
      'trnxid': trnxid,
      'sessionid': sessionToken,
    };

    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'cancproc') {
        Navigator.pop(context);

        result = result['result'];
        if (result['status'] == 'hacker') {
          print('Sorry, you could not hack us');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (result['status'] == 'valid') {
          print('Cancel successful');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ReloadHomePage(),
              ),
              (route) => false);
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

/* 
  finishEvent() {
    var result;
    var address = Uri.parse(domain + 'finish');
    var content = {
      'intro': 'finish',
      'username': username,
      'trnxid': trnxid,
      'sessionid': sessionToken,
    };

    showProgressIndicator(context);

    sendMsg(content);

    socketNotifier.addListener(() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'finish') {
        Navigator.pop(context);

        result = result['result'];
        if (result['status'] == 'hacker') {
          print('Sorry, you could not hack us');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (result['status'] == 'valid') {
          print('Review successful');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ReloadHomePage(),
              ),
              (route) => false);
        }
      }
    });

    /*   sendRequest(httpC, address, content).then((value) {
      result = value;
      Navigator.pop(context);

      if (result['value'] == 'error') {
        print('network error...');
        snackMsg(context, "Network Error");
      } else if (result['value'] == 'OK') {
        result = result['result'];
        if (result['status'] == 'hacker') {
          print('Sorry, you could not hack us');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (result['status'] == 'valid') {
          print('Review successful');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ReloadHomePage(),
              ),
              (route) => false);
        }
      }
    });
 */
  }
 */
  fetchChats() {
    String receiver = (username == planner) ? client : planner;

    var result;
    var address = Uri.parse(domain + 'getchats');
    var content = {
      'intro': 'getchats',
      'username': username,
      'receiver': receiver,
      'sessionid': sessionToken,
      'nextchatid': '0'
    };
    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'getchats') {
        Navigator.pop(context);

        result = result['result'];
        if (result['status'] == 'hacker') {
          print('Sorry, you could not hack us');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (result['status'] == 'valid') {
          print('Chat fetch successful');
          print(result);
          members = [];
          members.add(receiver);
          if (!memberOnlineStatus.containsKey(receiver)) {
            memberOnlineStatus[receiver] = [];
            //set online status
            memberOnlineStatus[receiver]!.add(result['onlineStatus'][0]);
            //set last seen
            memberOnlineStatus[receiver]!.add(result['userProfile'][2]);
            //set last msg
            memberOnlineStatus[receiver]!.add('');
          }

          setState(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => Chatroom(
                  result['chats'],
                  result['userProfile'],
                  true,
                  "ChatroomSingle",
                ),
              ),
            );
          });
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  Widget build(BuildContext context) {
    print('existing order called...');
    currentRoute = "ExixtingOrderDetailPage";

    prefs.setString("currentRoute", "ExixtingOrderDetailPage");
    if (ratePlanner == false)
      return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Column(
            children: [
              Text(
                "eventGig",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                status + " Events",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          "Date Created",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          timeCreated,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        //color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          (username == planner) ? "Client" : "Planner",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          (username == planner) ? client : planner,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          "Event date",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          eventDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          "Street",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          street,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          "City",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          city,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          "State",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          state,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          "Country",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          country,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          "Event Type",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          eventType,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          "Budget",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          budget,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          "Fee",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          fee.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          "Note",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          note,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (status == "completed")
                  Container(
                    width: deviceWidth * 0.95,
                    color: Colors.black,
                    margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                    padding:
                        EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            "Rating",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        starBuilder(rating),
                      ],
                    ),
                  ),
                if (status == "completed")
                  Container(
                    width: deviceWidth * 0.95,
                    color: Colors.black,
                    margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                    padding:
                        EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            "Comment",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            comment,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[300],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (status == "pending" && username == planner)
                        ElevatedButton(
                          onPressed: () {
                            print('accept order');
                            acceptOrder();
                          },
                          child: Text("Accept"),
                        ),
                      if (status == "pending" && username == planner)
                        ElevatedButton(
                          onPressed: () {
                            print('reject order');
                            rejectOrder();
                            //(courier == username) ? confirmOrder : getOtp,
                          },
                          child: Text("Reject"),
                        ),
                      if (status == "scheduled" && username == client)
                        ElevatedButton(
                          onPressed: () {
                            print('Finish event');
                            rateUser();
                            //(courier == username) ? confirmOrder : getOtp,
                          },
                          child: Text("Finish"),
                        ),
                      if (status == "scheduled" && username == client)
                        ElevatedButton(
                          onPressed: () {
                            print('Cancel event');
                            cancelEvent();
                            //(courier == username) ? confirmOrder : getOtp,
                          },
                          child: Text("Cancel"),
                        ),
                      if (status == "pending" && username == planner)
                        ElevatedButton(
                          onPressed: () {
                            print('Chat');
                            fetchChats();
                            //(courier == username) ? confirmOrder : getOtp,
                          },
                          child: Text("Chat"),
                        )
                      else if (status == "scheduled")
                        ElevatedButton(
                          onPressed: () {
                            print('Chat');
                            fetchChats();
                            //(courier == username) ? confirmOrder : getOtp,
                          },
                          child: Text("Chat"),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    else if (ratePlanner == true)
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
                "Rate Planner",
                style: TextStyle(fontSize: 12),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Text(
                  "Rate on a scale of 5",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[300],
                  ),
                ),
                (pos == 0)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 1; i <= 5; i++)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  pos = i;
                                  print(i);
                                });
                              },
                              icon: Icon(Icons.star_outline),
                            ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 1; i <= pos; i++)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  pos = i;
                                  print(i);
                                });
                              },
                              icon: Icon(Icons.star_purple500_outlined),
                              color: Colors.orange,
                            ),
                          for (int j = pos; j < 5; j++)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  pos = j + 1;
                                  print(j);
                                });
                              },
                              icon: Icon(Icons.star_outline),
                            ),
                        ],
                      ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: ValueListenableBuilder(
                    valueListenable: textValidator,
                    builder: (BuildContext context, int value1, Widget? child) {
                      return TextFormField(
                        decoration: InputDecoration(
                          labelText: "Comment",
                          hintText: "Say something about the planner...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.multiline,
                        autovalidateMode: AutovalidateMode.always,
                        validator: (value) {
                          if (value1 == 1) {
                            return "* required";
                          } else
                            return null;
                        },
                        onChanged: (input) {
                          review = input;
                          value1 = 0;
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (review.isEmpty) textValidator.value = 1;
                    if (pos <= 0)
                      nullInputDialog(context, "Rate the user on a scale of 5",
                          "Rating missing");
                    if (pos > 0 && review.isNotEmpty) submitRating(review, pos);
                  },
                  child: Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      );
    else
      return MaterialApp(
        home: ReloadHomePage(),
      );
  }
}

class CreateOrderPage extends StatefulWidget {
  @override
  _CreateOrderPage createState() => _CreateOrderPage();
}

//Allows the user to place an order for courier
class _CreateOrderPage extends State<CreateOrderPage> {
  String eventDate = "";
  String street = "";
  String city = "";
  String state = "";
  String country = "";
  String eventType = "Select Event Type";
  String budget = "";
  String note = "";
  bool nullSignal = false;
  bool typeIt = false;
  DateTime choosenDate = DateTime.now();

  ValueNotifier<Set> textValidator = ValueNotifier<Set>({});
  ValueNotifier<int> dateNotifier = ValueNotifier<int>(0);

  Set currentField = {};

  bool homeCall = false;

  findPlanner() {
    if (eventDate.isNotEmpty ||
        eventType != "Select Event Type" ||
        street.isNotEmpty ||
        city.isNotEmpty ||
        state.isNotEmpty ||
        country.isNotEmpty ||
        budget.isNotEmpty ||
        note.isNotEmpty) {
      orderDetailList = [
        street,
        city,
        state,
        country,
        eventDate,
        eventType,
        budget,
        note
      ];
      var content = {
        'intro': 'ordproc',
        "sessionid": sessionToken,
        "username": username,
        "budget": budget,
      };

      Uri address = Uri.parse(domain + "ordproc");
      print(address);
      print(content);

      showProgressIndicator(context);

      sendMsg(content);

      liste() {
        Map<String, dynamic> result = socketResult;
        if (result['intro'] == 'ordproc') {
          Navigator.pop(context);
          requestResult(result['result']);
          socketNotifier.removeListener(liste);
        }
      }

      socketNotifier.addListener(liste);
    }
  }

  requestResult(result) {
    if (result['hit'] == 'no') {
      print('hit: no');
      nullInputDialog(
          context,
          "Sorry, no event planners at the moment...Keep retrying",
          'Unavailable');
    } else if (result['hit'] == 'yes') {
      print('hit: yes. Number of planners: ' + result['qty'].toString());
      print(result['showroom']);
      print(result['available']);

      /*  setState(() { */
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => AvailableCourierPage(
            planners: result['available'],
            showrooms: result['showroom'],
            budget: result['budget'],
          ),
        ),
      );
      //  });
    }
  }

  Widget build(BuildContext context) {
    currentRoute = "CreateOrderPage";
    prefs.setString("currentRoute", "CreateOrderPage");
    String dateLabel = "Select Event Date";

    var eventTypeItems = [
      "Select Event Type",
      "birthday",
      "wedding",
      "house warming",
      "school event",
      "peagent",
      "seminar",
      "burial",
      "others",
    ];

    if (homeCall == false)
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
                "Event data",
                style: TextStyle(fontSize: 12),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: (deviceWidth > mobileWidth)
                  ? deviceWidth * 0.6
                  : deviceWidth * 0.9,
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Divider(),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      color: Colors.grey[300],
                    ),
                    padding: EdgeInsets.only(left: 5),
                    child: DropdownButton(
                      value: eventType,
                      onChanged: (var input) {
                        setState(() {
                          eventType = input as String;
                        });
                      },
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      isDense: true,
                      alignment: AlignmentDirectional.center,
                      items: eventTypeItems.map((var item) {
                        return DropdownMenuItem(
                          child: Container(
                            decoration: (item != "Select Event Type")
                                ? BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  )
                                : BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                    color: Colors.white,
                                  ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.event,
                                  color: Colors.red,
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Text(item),
                                )
                              ],
                            ),
                          ),
                          value: item,
                        );
                      }).toList(),
                    ),
                  ),
                  Divider(),
                  ValueListenableBuilder(
                    valueListenable: textValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (input) {
                            country = input;
                            value1.remove(1);
                            currentField.add(1);
                          },
                          decoration: InputDecoration(
                            labelText: "Venue Country",
                            hintText: "Enter venue's country",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.home,
                              color: Colors.red,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value1.contains(1)) {
                              return "* required";
                            } else
                              return null;
                          },
                        ),
                      );
                    },
                  ),
                  Divider(),
                  ValueListenableBuilder(
                    valueListenable: textValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (input) {
                            state = input;
                            value1.remove(2);
                            currentField.add(2);
                          },
                          decoration: InputDecoration(
                            labelText: "Venue State",
                            hintText: "Enter venue's state",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.home,
                              color: Colors.red,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value1.contains(2)) {
                              return "* required";
                            } else
                              return null;
                          },
                        ),
                      );
                    },
                  ),
                  Divider(),
                  ElevatedButton.icon(
                    label: ValueListenableBuilder(
                        valueListenable: dateNotifier,
                        builder:
                            (BuildContext context, int value1, Widget? child) {
                          return Text(dateLabel);
                        }),
                    icon: Icon(
                      Icons.calendar_today,
                      // color: Colors.red,
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Container(
                                width: (deviceWidth > mobileWidth)
                                    ? deviceWidth * 0.6
                                    : deviceWidth * 0.8,
                                child: CalendarDatePicker(
                                  initialDate: choosenDate,
                                  firstDate: DateTime(
                                    2021,
                                  ),
                                  lastDate: DateTime(2050),
                                  onDateChanged: (value) {
                                    String year = value
                                        .toLocal()
                                        .toString()
                                        .substring(0, 4);
                                    String day = value
                                        .toLocal()
                                        .toString()
                                        .substring(8, 10);
                                    String month = value
                                        .toLocal()
                                        .toString()
                                        .substring(5, 7);
                                    List monthNum = [
                                      '01',
                                      '02',
                                      '03',
                                      '04',
                                      '05',
                                      '06',
                                      '07',
                                      '08',
                                      '09',
                                      '10',
                                      '11',
                                      '12'
                                    ];
                                    List monthAlpha = [
                                      'Jan',
                                      'Feb',
                                      'Mar',
                                      'Apr',
                                      'May',
                                      'Jun',
                                      'Jul',
                                      'Aug',
                                      'Sep',
                                      'Oct',
                                      'Nov',
                                      'Dec'
                                    ];

                                    month = monthAlpha[monthNum.indexOf(month)];

                                    print(year);
                                    print(day);
                                    print(month);

                                    eventDate = day + '-' + month + '-' + year;
                                    print(eventDate);
                                    choosenDate = value;
                                    dateLabel = eventDate;

                                    dateNotifier.value++;
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          });
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                      ),
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size.fromWidth(
                          (deviceWidth > mobileWidth)
                              ? deviceWidth * 0.4
                              : deviceWidth * 0.7,
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                  ValueListenableBuilder(
                    valueListenable: textValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (input) {
                            city = input;
                            value1.remove(3);
                            currentField.add(3);
                          },
                          decoration: InputDecoration(
                            labelText: "Venue City",
                            hintText: "Enter venue's city",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.home,
                              color: Colors.red,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value1.contains(3)) {
                              return "* required";
                            } else
                              return null;
                          },
                        ),
                      );
                    },
                  ),
                  Divider(),
                  ValueListenableBuilder(
                    valueListenable: textValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (input) {
                            street = input;
                            value1.remove(4);
                            currentField.add(4);
                          },
                          decoration: InputDecoration(
                            labelText: "Venue Street",
                            hintText: "Enter venue's street",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.home,
                              color: Colors.red,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value1.contains(4)) {
                              return "* required";
                            } else
                              return null;
                          },
                        ),
                      );
                    },
                  ),
                  Divider(),
                  ValueListenableBuilder(
                    valueListenable: textValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (input) {
                            budget = input;
                            print(budget);
                            value1.remove(5);
                            currentField.add(5);
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Budget (Naira)",
                            hintText: "Enter your budget",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.money,
                              color: Colors.red,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value1.contains(5)) {
                              //budget = "";
                              return "* required";
                            } else if (value!.contains(RegExp(r"(\D)")) &&
                                currentField.contains(5)) {
                              // budget = "";
                              return "Budget must be number";
                            } else
                              return null;
                          },
                        ),
                      );
                    },
                  ),
                  Divider(),
                  ValueListenableBuilder(
                    valueListenable: textValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (input) {
                            note = input;
                            value1.remove(6);
                            currentField.add(6);
                          },
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: "Description",
                            hintText: "Briefly describe the event...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.note,
                              color: Colors.red,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value1.contains(6)) {
                              return "* required";
                            } else
                              return null;
                          },
                        ),
                      );
                    },
                  ),
                  Divider(),
                  Divider(),
                  Container(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print(budget);
                        textValidator.value = {};
                        if (country.isEmpty) textValidator.value.add(1);
                        if (state.isEmpty) textValidator.value.add(2);
                        if (city.isEmpty) textValidator.value.add(3);
                        if (street.isEmpty) textValidator.value.add(4);
                        if (budget.isEmpty) textValidator.value.add(5);
                        if (note.isEmpty) textValidator.value.add(6);

                        if (eventType == "Select Event Type")
                          nullInputDialog(context, "Select event type",
                              "Event type missing");
                        else if (eventDate.isEmpty)
                          nullInputDialog(context, "Select event date",
                              "Event date missing");

                        if (city.isNotEmpty &&
                            street.isNotEmpty &&
                            eventType != "Select Event Type" &&
                            note.isNotEmpty &&
                            state.isNotEmpty &&
                            country.isNotEmpty &&
                            eventDate.isNotEmpty &&
                            budget.isNotEmpty) {
                          findPlanner();
                        }
                      },
                      icon: Icon(Icons.search),
                      label: Text("Find Planner"),
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(
                          Size.fromWidth(
                            (deviceWidth > mobileWidth)
                                ? deviceWidth * 0.4
                                : deviceWidth * 0.7,
                          ),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    else
      return MaterialApp(
        home: ReloadHomePage(),
      );
  }
}

class AvailableCourierPage extends StatefulWidget {
  AvailableCourierPage({
    this.planners: const [],
    this.showrooms: const [],
    this.budget: 0,
    this.showplanner: false,
    this.reviews: const [],
    this.details: const [],
    this.planner: "",
    this.dateCreated: "",
    this.clientPics: const [],
    this.currentShowroom: const [],
    this.fee: 0,
    this.directCall: false,
  });

  final List planners;
  final List showrooms;
  final double budget;
  final bool showplanner;

  final List reviews;
  final List details;
  final List clientPics;
  final List currentShowroom;
  final String planner;
  final String dateCreated;
  final double fee;
  final directCall;

  @override
  _AvailableCourierPage createState() => _AvailableCourierPage(
        planners: this.planners,
        showrooms: this.showrooms,
        budget: this.budget,
        showplanner: this.showplanner,
        reviews: this.reviews,
        details: this.details,
        planner: this.planner,
        dateCreated: this.dateCreated,
        clientPics: this.clientPics,
        currentShowroom: this.currentShowroom,
        fee: this.fee,
        directCall: this.directCall,
      );
}

//Displays the details of each available courier
class _AvailableCourierPage extends State<AvailableCourierPage> {
  _AvailableCourierPage({
    this.planners: const [],
    this.showrooms: const [],
    this.budget: 0,
    this.showplanner: false,
    this.reviews: const [],
    this.details: const [],
    this.planner: "",
    this.dateCreated: "",
    this.clientPics: const [],
    this.currentShowroom: const [],
    this.fee: 0,
    this.directCall: false,
  });

  final List planners;
  final List showrooms;
  final double budget;
  final bool showplanner;

  var callHome = false;
  //var showplanner = false;
  final List reviews;
  final List details;
  final List clientPics;
  final List currentShowroom;
  final String planner;
  final String dateCreated;
  final double fee;
  final bool directCall;

  getPlannerDetails(item, starWidget, pics) {
    var res;
    var address = Uri.parse(domain + 'plannerdetails');
    var content = {
      'intro': 'plannerdetails',
      'username': username,
      'planner': item[0],
      'sessionid': sessionToken,
    };

    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> res = socketResult;
      if (res['intro'] == 'plannerdetails') {
        Navigator.pop(context);

        res = res['result'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => AvailableCourierPage(
                reviews: res['reviews'],
                currentShowroom: pics,
                showplanner: true,
                fee: item[3].toDouble(),
                //problematic must be a number not smi
                details: res['details'],
                clientPics: res['client_pics'],
                planner: item[0],
                dateCreated: item[4]),
          ),
        );
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  requestResponse(result, item, starWidget) {
    setState(() {});
  }

  hirePlanner() {
    var result;

    print('hireplanner called... url being loaded');

    var address = Uri.parse(domain + 'hireproc');

    print('hireplanner called... url finally loaded');

    var content = {
      'intro': 'hireproc',
      'street': orderDetailList[0],
      'city': orderDetailList[1],
      'state': orderDetailList[2],
      'country': orderDetailList[3],
      'date': orderDetailList[4],
      'type': orderDetailList[5],
      'budget': orderDetailList[6].toString(),
      'note': orderDetailList[7],
      'fee': (fee * budget * 0.01).toString(),
      'username': username,
      'planner': planner,
      'sessionid': sessionToken,
    };

    print('hireplanner called... content passed');

    print(address);
    print(content);
    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'hireproc') {
        Navigator.pop(context);
        result = result['result'];
        print(result);
        if (result['status'] == 'not available') {
          print('Sorry, the planner is no longer available');
          snackMsg(context, "Sorry, the planner is no longer available");
        } else if (result['status'] == 'available') {
          print('Order placed successfully');
          snackMsg(context, "Order Placed");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ReloadHomePage(),
              ),
              (route) => false);
        } else if (result['status'] == 'hacker') {
          print('hack attempt failed');
          logout(context);
          //snackMsg(context, "hack attempt failed");
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  starBuilder(star) {
    print('starBuilder called');
    List<Widget> starList = [];

    for (var i = 1; i <= star; i++) {
      starList.add(
        Icon(
          Icons.star_outlined,
          color: Colors.orange,
          size: 14,
        ),
      );
    }
    for (var j = star; j < 5; j++) {
      starList.add(
        Icon(
          Icons.star_outline,
          color: Colors.grey,
          size: 14,
        ),
      );
    }

    return Row(
      children: starList,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget build(BuildContext context) {
    print('build called');
    currentRoute = "AvailableCourierPage";
    prefs.setString("currentRoute", "AvailableCourierPage");
    List<Widget> plannerWidgetList = [];
    // Widget courierWidget;
    int count = 0;
    int eventIndex = 2;
    List eventTypes = [
      'Event Planning History',
      'Birthdays: ',
      'Weddings: ',
      'House Warming Parties: ',
      'School Events: ',
      'Peagents: ',
      'Seminars: ',
      'Burials: ',
      'Others: '
    ];

    if (showplanner == false)
      for (List item in planners) {
        print('planner list builder called...');
        Widget starWidget = starBuilder(item[2] as int);
        print('starlist built...');
        List pics = showrooms[count];

        plannerWidgetList.add(
          GestureDetector(
            onTapUp: (value) {
              getPlannerDetails(item, starWidget, pics);
              /* setState(() {
               
              }); */
            },
            child: Container(
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: Border(
                    /* bottom: BorderSide(),
                  top: BorderSide(),
                  right: BorderSide(),
                  left: BorderSide(), */
                    ),
              ),
              margin: EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 5, top: 5),
                          height: 50,
                          width: 50,
                          child: ClipOval(
                            child: GestureDetector(
                              onTap: () => showDialog(
                                  context: context,
                                  builder: (BuildContext contxt) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            child: Image.network(
                                              //planner's profile picture
                                              (item[1].isNotEmpty)
                                                  ? domain + 'img/' + item[1]
                                                  : domain +
                                                      'img/' +
                                                      'default.png',
                                              height:
                                                  (deviceWidth > mobileWidth)
                                                      ? deviceHeight * 0.8
                                                      : deviceWidth * 0.8,
                                              width: (deviceWidth > mobileWidth)
                                                  ? deviceHeight * 0.8
                                                  : deviceWidth * 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                              child: FadeInImage.assetNetwork(
                                placeholder: "assets/images/imgloading.gif",
                                image:
                                    //planner's profile picture
                                    (item[1].isNotEmpty)
                                        ? domain + 'img/' + item[1]
                                        : domain + 'img/' + 'default.png',
                                height: (deviceWidth > mobileWidth)
                                    ? deviceHeight * 0.1
                                    : deviceWidth * 0.2,
                                width: (deviceWidth > mobileWidth)
                                    ? deviceHeight * 0.1
                                    : deviceWidth * 0.2,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.only(left: 10, bottom: 10, top: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                //username
                                children: [
                                  Text(
                                    item[0],
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                //date account was created
                                children: [
                                  Text(
                                    item[4],
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                (item[3] * budget * 0.01).toString() + " Naira",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                //average rating
                                children: [
                                  starWidget,
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: CarouselSlider(
                      items: (pics.isNotEmpty)
                          ? pics
                              .map(
                                (pic) => Container(
                                  child:
                                      Image.network(domain + 'img/' + pic[1]),
                                ),
                              )
                              .toList()
                          : [
                              Image.network(domain + 'img/' + 'default.png'),
                            ],
                      options: CarouselOptions(
                        height: deviceHeight * 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        count++;
      }

    print('scaffold called');
    //courierWidget = Row(children: courierWidgetList);
    if (callHome == true)
      return ReloadHomePage();
    else if (showplanner == true)
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
                planner + "'s Profile",
                style: TextStyle(fontSize: 12),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(
              left: 5,
              right: 5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(),
                Container(
                  //padding: EdgeInsets.only(bottom: 5, top: 5),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: ClipOval(
                              child: GestureDetector(
                                onTap: () => showDialog(
                                    context: context,
                                    builder: (BuildContext contxt) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              child: Image.network(
                                                //planner's profile picture
                                                (details[1].isNotEmpty)
                                                    ? domain +
                                                        'img/' +
                                                        details[1]
                                                    : domain +
                                                        'img/' +
                                                        'default.png',
                                                height:
                                                    (deviceWidth > mobileWidth)
                                                        ? deviceHeight * 0.8
                                                        : deviceWidth * 0.8,
                                                width:
                                                    (deviceWidth > mobileWidth)
                                                        ? deviceHeight * 0.8
                                                        : deviceWidth * 0.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                child: FadeInImage.assetNetwork(
                                  placeholder: "assets/images/imgloading.gif",
                                  image:
                                      //planner's profile picture
                                      (details[1].isNotEmpty)
                                          ? domain + 'img/' + details[1]
                                          : domain + 'img/' + 'default.png',
                                  height: (deviceWidth > mobileWidth)
                                      ? deviceHeight * 0.1
                                      : deviceWidth * 0.2,
                                  width: (deviceWidth > mobileWidth)
                                      ? deviceHeight * 0.1
                                      : deviceWidth * 0.2,
                                ),
                              ),
                              //  ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  planner,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  dateCreated,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                                starBuilder(details[0] as int),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(),
                Container(
                  child: CarouselSlider(
                    items: (currentShowroom.isNotEmpty)
                        ? currentShowroom
                            .map(
                              (pic) => Container(
                                child: Image.network(domain + 'img/' + pic[1]),
                              ),
                            )
                            .toList()
                        : [
                            Image.network(domain + 'img/' + 'default.png'),
                          ],
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                  ),
                ),
                Divider(),
                Container(
                  decoration: ShapeDecoration(
                    shape: Border(
                      bottom: BorderSide(),
                      top: BorderSide(),
                      right: BorderSide(),
                      left: BorderSide(),
                    ),
                    color: Colors.black,
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: eventTypes.map((element) {
                      if (eventTypes.indexOf(element) == 0)
                        return Text(
                          element,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        );
                      return Text(
                        element + details[eventIndex++].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Divider(),
                Flexible(
                  child: Container(
                    decoration: ShapeDecoration(
                      shape: Border(
                        bottom: BorderSide(),
                        top: BorderSide(),
                        right: BorderSide(),
                        left: BorderSide(),
                      ),
                    ),
                    margin: EdgeInsets.only(
                      // top: 5,
                      left: 2,
                      right: 2,
                      // bottom: 5,
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < reviews.length; i++)
                          Container(
                            decoration: ShapeDecoration(
                              shape: Border(
                                bottom: BorderSide(),
                                top: BorderSide(),
                                right: BorderSide(),
                                left: BorderSide(),
                              ),
                            ),
                            margin: EdgeInsets.only(
                              top: 5,
                              left: 5,
                              bottom: (i == (reviews.length - 1)) ? 5 : 0,
                              right: 5,
                            ),
                            padding: EdgeInsets.only(
                              left: 5,
                              top: 5,
                              bottom: 5,
                            ),
                            //color: Colors.red,
                            //child: ListTile(
                            child: Row(
                              //  mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /* Flexible(
                                  child: */

                                ClipOval(
                                  child: GestureDetector(
                                    onTap: () => showDialog(
                                        context: context,
                                        builder: (BuildContext contxt) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  child: /*  Image.asset(
                                                    "assets/images/passport.jpg", */
                                                      Image.network(
                                                    //reviewer's profile picture
                                                    (clientPics[i].isNotEmpty)
                                                        ? domain +
                                                            'img/' +
                                                            clientPics[i]
                                                        : domain +
                                                            'img/' +
                                                            'default.png',
                                                    height: (deviceWidth >
                                                            mobileWidth)
                                                        ? deviceHeight * 0.8
                                                        : deviceWidth * 0.8,
                                                    width: (deviceWidth >
                                                            mobileWidth)
                                                        ? deviceHeight * 0.8
                                                        : deviceWidth * 0.8,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                    child: FadeInImage.assetNetwork(
                                      placeholder:
                                          "assets/images/imgloading.gif",
                                      image:
                                          //reviewer's profile picture
                                          (clientPics[i].isNotEmpty)
                                              ? domain + 'img/' + clientPics[i]
                                              : domain + 'img/' + 'default.png',
                                      height: (deviceWidth > mobileWidth)
                                          ? deviceHeight * 0.1
                                          : deviceWidth * 0.1,
                                      width: (deviceWidth > mobileWidth)
                                          ? deviceHeight * 0.1
                                          : deviceWidth * 0.1,
                                    ),
                                  ),
                                ),
                                //  ),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        //reviewer's username
                                        children: [
                                          Flexible(
                                            child: Container(
                                              child: Text(
                                                reviews[i][0],
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              padding:
                                                  EdgeInsets.only(left: 15),
                                              child: Text(
                                                //date of completion
                                                reviews[i][1],
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        //event type
                                        children: [
                                          Flexible(
                                            child: Container(
                                              child: Text(
                                                reviews[i][2],
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      //rating
                                      Container(
                                        //padding: EdgeInsets.only(left: 10),
                                        child:
                                            starBuilder(reviews[i][3] as int),
                                        //padding: EdgeInsets.only(left: 20),
                                      ),
                                      //),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              padding: EdgeInsets.only(top: 5),
                                              color: Colors.black,
                                              constraints: BoxConstraints(
                                                  maxWidth: deviceWidth * 0.6),
                                              //comment
                                              child: Text(
                                                reviews[i][4],
                                                /* """jgjksdgjkgjkgsdjkgkjdgjkgdjkgjkgjkgjkgjkdsgjkgjkdgjkgjkdg jk
                                                gdjkg dkgjktsd kgjkgdkj kg jkgdjksgk jkjgjkgdjk jkgjkgdkj gj g
                                              kgjkgdkj kj gjkdgjk gjkdgjkgkjg kjgdjkg kgsdgkjhgsd g ihkjgsdjhg
                                                 dhg hkg sdh hdg hhdjg jkgsdjkjgjkgkjgkjgdkgsdkj""", */
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                /*  ],
                  ),
                ), */
                if (directCall == false)
                  Container(
                    child: ElevatedButton(
                      onPressed: () {
                        hirePlanner();
                      },
                      child: Text("Hire $planner"),
                    ),
                  ),
                if (directCall == false) Divider(),
              ],
            ),
          ),
        ),
      );

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
              "Available Event Planners",
              style: TextStyle(fontSize: 12),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.red[100],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: plannerWidgetList,
          ),
        ),
      ),
    );
  }
}

class ProfileSetting extends StatefulWidget {
  ProfileSetting(this.currentSettings, this.plannerStatus);

  final List currentSettings;
  final String plannerStatus;
  @override
  _ProfileSetting createState() =>
      _ProfileSetting(this.currentSettings, this.plannerStatus);
}

//Allows the user to place an order for courier
class _ProfileSetting extends State<ProfileSetting> {
  _ProfileSetting(this.currentSettings, this.plannerStatus);

  final List currentSettings;
  final String plannerStatus;
  //final cropKey = GlobalKey<CropState>();
  String profilePic = "";
  String email = "";
  String phone = "";
  String fee = "";
  String terms = "";
  String planner = "";

  List settings = [];

  bool nullSignal = false;

  bool changed = false;
  String newStatus = '';
  String newEmail = '';
  String newPhone = '';
  String newFee = '';
  String newTerms = '';
  String newPic = '';

  bool homeCall = false;

  final ValueNotifier<int> pictureChanged = ValueNotifier<int>(0);
  bool picSwitched = false;
  var picByte;
  String picName = '';

  late String croppedImageFile;
  bool openShowroom = false;
  List showroomPictures = [];

  String currentPic = '';

  saveChanges() {
    if (email.isNotEmpty && planner.isNotEmpty && fee.isNotEmpty) {
      settings = [
        profilePic,
        email,
        planner,
        terms,
        fee,
        phone,
      ];
      var content = {
        'intro': 'savesettings',
        "sessionid": sessionToken,
        "username": username,
        "profilePic": profilePic,
        "email": email,
        "planner": planner,
        "fee": fee,
        "phone": phone,
        "terms": terms,
      };

      Uri address = Uri.parse(domain + "savesettings");
      print(address);
      print(content);

      showProgressIndicator(context);

      sendMsg(content);

      liste() {
        Map<String, dynamic> res = socketResult;
        if (res['intro'] == 'savesettings') {
          Navigator.pop(context);
          res = res['result'];
          if (res['status'] == 'hacker') {
            print('hacker');
            nullInputDialog(context, "Failed hack attempt", 'Oops');
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
                (route) => false);
          } else if (res['status'] == 'available') {
            print('changes saved');
            snackMsg(context, "Changes Saved");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => ReloadHomePage(),
                ),
                (route) => false);
          }
          socketNotifier.removeListener(liste);
        }
      }

      socketNotifier.addListener(liste);
    }
  }

  showroom() {
    var content = {
      'intro': 'getshowroom',
      "sessionid": sessionToken,
      "username": username,
    };

    Uri address = Uri.parse(domain + "getshowroom");
    print(address);
    print(content);

    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> res = socketResult;
      if (res['intro'] == 'getshowroom') {
        Navigator.pop(context);
        res = res['result'];
        if (res['status'] == 'hacker') {
          print('hacker');
          nullInputDialog(context, "Failed hack attempt", 'Oops');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (res['status'] == 'valid') {
          print('Showroom retrieved');
          print(res['showroom']);
          //return res['showroom'];
          //showroomPics = res['showroom'];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Showroom(res['showroom']),
            ),
          );
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

/* 
  Future<void> cropImage(File sampleFile) async {
    final scale = cropKey.currentState!.scale;
    final area = cropKey.currentState!.area;

    if (area == null) return;

    final sample = await ImageCrop.sampleImage(
      file: sampleFile,
      preferredSize: (2000 / scale).round(),
    );

    final croppedFile = await ImageCrop.cropImage(file: sample, area: area);

    sample.delete();

    croppedImageFile = croppedFile.path;
  }
 */
  Future<void> changePicture() async {
    showProgressIndicator(context);
    Uint8List? file;
    String fileN;
    String? fileEx;
    String? filePath;
    FilePicker.platform.pickFiles(type: FileType.image).then(
      (value) async {
        if (value == null)
          print('empty file');
        else {
          file = value.files.first.bytes;
          fileN = value.files.first.name;
          fileEx = value.files.first.extension;
          filePath = value.files.first.path;

          Uri address = Uri.parse(domain + "changedp");
          print(address);

          http.MultipartRequest request =
              http.MultipartRequest('POST', address);

          print('file obtained');
          if (!kIsWeb)
          //section fot non-web implementations
          {
            //open cropper here
            print('calling image cropper');
            File newFile = File(filePath as String);
            /* final sample = */
            Navigator.pop(context);
            await imgCrop.ImageCropper.cropImage(
              sourcePath: filePath as String,
              aspectRatio: imgCrop.CropAspectRatio(ratioX: 1, ratioY: 1),
              cropStyle: imgCrop.CropStyle.circle,
              compressQuality: 20,
              aspectRatioPresets: [
                imgCrop.CropAspectRatioPreset.square,
              ],
              androidUiSettings: imgCrop.AndroidUiSettings(
                toolbarTitle: "Adjust Picture",
                toolbarColor: Colors.red,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: imgCrop.CropAspectRatioPreset.square,
                lockAspectRatio: false,
              ),
              iosUiSettings: imgCrop.IOSUiSettings(
                title: "Adjust Picture",
              ),
            ).then((croppedFile) async {
              if (croppedFile != null)
              //if user completed the cropping process
              {
                snackMsg(context, "Uploading Image...");
                await http.MultipartFile.fromPath('dp', croppedFile.path)
                    .then((value) async {
                  request.files.add(value);
                  request.fields['username'] = username;
                  request.fields['sessionid'] = sessionToken;
                  request.fields['extension'] = fileEx as String;
                  await request.send().then(
                    (value) async {
                      await http.Response.fromStream(value).then(
                        (value) {
                          //  Navigator.pop(context);

                          print(value.statusCode);
                          var result = jsonDecode(value.body);
                          if (result["status"] == "ok") {
                            print('deleting file...');
                            croppedFile.delete();
                            print('saving at heroku...');

                            var contentP = {
                              "sessionid": sessionToken,
                              "username": username,
                              "extension": fileEx as String,
                            };

                            Uri address = Uri.parse(
                                "http://eflask-app-ikp120.herokuapp.com/changedp");
                            print(address);
                            print(contentP);

                            var resp;

                            // showProgressIndicator(context);

                            sendRequest(httpC, address, contentP).then(
                              (value) {
                                resp = value;
                                //  Navigator.pop(context);

                                if (resp['value'] == 'OK') {
                                  print('saved at heroku');
                                } else {
                                  print('eror at heroku');
                                }
                              },
                            );

                            print("picture saved");
                            NetworkImage(
                              (profilePic.isEmpty || profilePic == 'None')
                                  ?
                                  //user's profile picture
                                  domain + 'img/' + 'default.png'
                                  : domain + 'img/' + profilePic,
                            ).evict().then(
                              (value) {
                                setState(() {
                                  print("setstate called");
                                });
                              },
                            );
                            // Navigator.pop(context);
                            /* PaintingBinding.instance!.imageCache!
                                              .clear(); */
                            //pictureChanged.value++;

                            snackMsg(context, "Picture saved");
                          } else
                            snackMsg(context, "Failed");
                        },
                      );
                    },
                  );
                });
              } else
              //if user canceled the cropping process
              {
                print('cropping cancelled');
              }
            });
          }
          //section for web implementations
          else {
            Navigator.pop(context);
            snackMsg(context, "Uploading Image...");
            http.MultipartFile picture =
                http.MultipartFile.fromBytes('dp', file!, filename: fileN);

            if (picture != null) {
              request.files.add(picture);
              request.fields['username'] = username;
              request.fields['sessionid'] = sessionToken;
              request.fields['extension'] = fileEx as String;
              await request.send().then(
                (value) async {
                  await http.Response.fromStream(value).then(
                    (value) {
                      // Navigator.pop(context);
                      print(value.statusCode);
                      print(value.body);
                      if (jsonDecode(value.body)['status'] == 'ok') {
                        print('saving at heroku...');
                        var contentP = {
                          "sessionid": sessionToken,
                          "username": username,
                          "extension": fileEx as String,
                        };

                        Uri address = Uri.parse(
                            "http://eflask-app-ikp120.herokuapp.com/changedp");
                        print(address);
                        print(contentP);

                        var resp;

                        showProgressIndicator(context);

                        sendRequest(httpC, address, contentP).then(
                          (value) {
                            resp = value;
                            Navigator.pop(context);

                            if (resp['value'] == 'OK') {
                              print('saved at heroku');
                            } else {
                              print('eror at heroku');
                            }
                          },
                        );
                        print('saved');
                        PaintingBinding.instance!.imageCache!.clear();
                        pictureChanged.value++;
                        snackMsg(context, "Profile picture changed!");
                        setState(() {});

                        // setState(() {});
                      } else
                        print('failed');
                    },
                  );
                },
              );
            }
          }
        }
      },
    );
  }

  deletePic(String currentPic) {
    var content = {
      'intro': 'deletepic',
      "sessionid": sessionToken,
      "username": username,
      "showroomid": currentPic[0],
    };

    Uri address = Uri.parse(domain + "deletepic");
    print(address);
    print(content);

    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> res = socketResult;
      if (res['intro'] == 'deletepic') {
        Navigator.pop(context);
        res = res['result'];
        if (res['status'] == 'hacker') {
          print('hacker');
          nullInputDialog(context, "Failed hack attempt", 'Oops');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (res['status'] == 'available') {
          print('changes saved');
          snackMsg(context, "Changes Saved");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ReloadHomePage(),
              ),
              (route) => false);
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  @override
  build(BuildContext context) {
    currentRoute = "ProfileSetting";
    prefs.setString("currentRoute", "ProfileSetting");

    var eventTypeItems = [
      "No",
      "Yes",
    ];

    profilePic = currentSettings[3];
    email = (changed == true)
        ? ((newEmail.isEmpty) ? currentSettings[1] : newEmail)
        : currentSettings[1];
    phone = (changed == true)
        ? ((newPhone.isEmpty) ? currentSettings[0] : newPhone)
        : currentSettings[0];
    fee = (changed == true)
        ? ((newFee.isEmpty) ? currentSettings[5].toString() : newFee)
        : currentSettings[5].toString();
    terms = (changed == true)
        ? ((newTerms.isEmpty) ? currentSettings[4] : newTerms)
        : currentSettings[4];

    planner = (changed == true) ? newStatus : plannerStatus;

    if (homeCall == false && openShowroom == false)
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
                "Profile Settings",
                style: TextStyle(fontSize: 12),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (BuildContext contxt) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        /* Image.asset(
                                          "assets/images/passport.jpg", */
                                        Image.network(
                                          (profilePic.isEmpty ||
                                                  profilePic == 'None')
                                              ?
                                              //user's profile picture
                                              domain + 'img/' + 'default.png'
                                              : domain + 'img/' + profilePic,
                                          height: (deviceWidth > mobileWidth)
                                              ? deviceHeight * 0.8
                                              : deviceWidth * 0.8,
                                          width: (deviceWidth > mobileWidth)
                                              ? deviceHeight * 0.8
                                              : deviceWidth * 0.8,
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: FadeInImage.assetNetwork(
                              placeholder: "assets/images/imgloading.gif",
                              image:
                                  (profilePic.isEmpty || profilePic == 'None')
                                      ?
                                      //user's profile picture
                                      domain + 'img/' + 'default.png'
                                      : domain + 'img/' + profilePic,
                              height: deviceWidth * 0.5,
                              width: deviceWidth * 0.5,
                            ),
                          ),
                          ElevatedButton.icon(
                              style: ButtonStyle(
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                changePicture();
                              },
                              label: Text("Change Picture"),
                              icon: Icon(Icons.photo_camera)),
                        ],
                      )
                    ],
                  ),
                ),
                Divider(),
                Container(
                  width: (deviceWidth > mobileWidth)
                      ? deviceWidth * 0.5
                      : deviceWidth * 0.8,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          right: 20,
                        ),
                        child: Text(
                          "Are you an Event Planner? ",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DropdownButton(
                        value: planner,
                        items: eventTypeItems.map((String item) {
                          return DropdownMenuItem<String>(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            value: item,
                          );
                        }).toList(),
                        onChanged: (var selected) {
                          setState(() {
                            changed = true;
                            newStatus = selected as String;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Divider(),
                Container(
                  width: (deviceWidth > mobileWidth)
                      ? deviceWidth * 0.5
                      : deviceWidth * 0.8,
                  //padding: EdgeInsets.all(15),
                  child: TextFormField(
                    initialValue: email,
                    onChanged: (input) {
                      email = input;
                      newEmail = input;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      prefixIcon: Icon(Icons.email, color: Colors.red),
                    ),
                    autovalidateMode: AutovalidateMode.always,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "*required";
                      } else
                        return null;
                    },
                  ),
                ),
                Divider(),
                Container(
                  width: (deviceWidth > mobileWidth)
                      ? deviceWidth * 0.5
                      : deviceWidth * 0.8,
                  // padding: EdgeInsets.all(15),
                  child: TextFormField(
                    initialValue: phone,
                    onChanged: (input) {
                      phone = input;
                      newPhone = input;
                    },
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "Phone Number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      prefixIcon: Icon(Icons.phone, color: Colors.red),
                    ),
                    autovalidateMode: AutovalidateMode.always,
                    validator: (value) {
                      if (value!.contains(RegExp(r"(\D)"))) {
                        return "Must be number";
                      } else
                        return null;
                    },
                  ),
                ),
                if (planner == 'Yes') Divider(),
                if (planner == 'Yes')
                  Container(
                    width: (deviceWidth > mobileWidth)
                        ? deviceWidth * 0.5
                        : deviceWidth * 0.8,
                    // padding: EdgeInsets.all(15),
                    child: TextFormField(
                      initialValue: fee,
                      onChanged: (input) {
                        fee = input;
                        newFee = input;
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Fee (%)",
                        hintText: "Fee in %",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: Icon(Icons.money, color: Colors.red),
                      ),
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        if (value!.isEmpty) {
                          fee = "";
                          return "*required";
                        } else if (value.contains(RegExp(r"(\D)"))) {
                          fee = "";
                          return "Fee must be number";
                        } else
                          return null;
                      },
                    ),
                  ),
                if (planner == 'Yes') Divider(),
                if (planner == 'Yes')
                  Container(
                    width: (deviceWidth > mobileWidth)
                        ? deviceWidth * 0.5
                        : deviceWidth * 0.8,
                    //  padding: EdgeInsets.all(15),
                    child: TextFormField(
                      initialValue: terms,
                      onChanged: (input) {
                        terms = input;
                        newTerms = input;
                      },
                      decoration: InputDecoration(
                        labelText: "Terms and conditions",
                        hintText: "Terms and conditions",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: Icon(Icons.warning, color: Colors.red),
                      ),
                    ),
                  ),
                Divider(),
                Container(
                    width: (deviceWidth > mobileWidth)
                        ? deviceWidth * 0.8
                        : deviceWidth * 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (planner == 'Yes')
                          Flexible(
                            child: ElevatedButton.icon(
                              style: ButtonStyle(
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                          RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ))),
                              onPressed: () {
                                showroom();
                              },
                              label: Text("Edit Showroom"),
                              icon: Icon(
                                Icons.edit,
                              ),
                            ),
                          ),
                        Flexible(
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            onPressed: () {
                              if (email.isNotEmpty && fee.isNotEmpty) {
                                saveChanges();
                              } else if (fee.isEmpty && planner == 'Yes')
                                nullInputDialog(
                                    context, "Fee is required", 'Null Input');
                              else if (email.isEmpty)
                                nullInputDialog(
                                    context, "Email is required", 'Null Input');
                            },
                            label: Text("Save"),
                            icon: Icon(Icons.save),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      );
    else
      return MaterialApp(
        home: ReloadHomePage(),
      );
  }
}

class Chatroom extends StatefulWidget {
  Chatroom(this.allChats, this.userProfile, this.single, this.currentRoute,
      {this.multipleProfiles: const [], this.idOfLastChat: 0});

  final List allChats;
  final List userProfile;
  final bool single;
  final List multipleProfiles;
  final int idOfLastChat;
  final String currentRoute;
  @override
  _Chatroom createState() =>
      _Chatroom(this.allChats, this.userProfile, this.single, this.currentRoute,
          multipleProfiles: multipleProfiles, idOfLastChat: idOfLastChat);
}

//Allows the user to place an order for courier
class _Chatroom extends State<Chatroom> {
  _Chatroom(this.allChats, this.userProfile, this.single, this.currentRoute,
      {this.multipleProfiles: const [], this.idOfLastChat: 0});

  final List allChats;
  final List userProfile;
  final bool single;
  final List multipleProfiles;
  final int idOfLastChat;
  final String currentRoute;

  bool nullSignal = false;

  bool homeCall = false;

  //List UserData = [];

  String user = '';

  List<Widget> contentList = [];

  bool refreshed = false;
  List respondentList = [];
  String newMsg = '';

  //late Timer singleChatTimer;
  //late Timer allChatTimer;

  final ValueNotifier<int> singleOnlineStatus = ValueNotifier<int>(0);
  final ValueNotifier<int> deliveryListener = ValueNotifier<int>(0);
  final ValueNotifier<bool> showIndicator = ValueNotifier<bool>(false);

  late ScrollController scrollContr;
  //late Timer newMessageTimer;
  bool ratePlanner = false;
  final ValueNotifier<int> refreshChatList = ValueNotifier<int>(0);
  Set deleted = {};
  int lastChatId = 0;
  int nextChatid = 0;
  bool fetchMore = false;

  bool adjustOffset = false;
  double lastPos = 0;
  double lastOffset = 0;
  double th = 0;
  bool notifierSet = false;
  bool uppdateSet = false;
  String prevUser = "";
  bool jumped = true;

  bool onlineStatusObtained = false;
  bool updating = false;
  TextEditingController textController = TextEditingController();
  // StreamController<int> streamControl = StreamController<int>();
  // List<Widget> chatContents = [];

  sendMesg(int msgIndex, String msgBody) {
    newMsg = '';
    print('sendMesg called');
    var content = {
      'intro': 'sendchat',
      "sessionid": sessionToken,
      "username": username,
      "message": msgBody,
      "receiver": userProfile[0],
    };

    Uri address = Uri.parse(domain + "sendchat");
    print(address);
    print(content);

    //showProgressIndicator(context);

    sendMsg(content);
    // if (sendMesgAdded == false)

    liste() {
      Map<String, dynamic> res = socketResult;
      if (res['intro'] == 'sendchat') {
        res = res['result'];
        if (res['status'] == 'hacker') {
          print('hacker');
          nullInputDialog(context, "Failed hack attempt", 'Oops');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (res['status'] == 'sent') {
          int msgid = res['chatid'];
          String msgTime =
              TimeOfDay.fromDateTime(DateTime.now().toUtc()).format(context);
          print('sent');
          print('msgid: $msgid');
          print('msgtime: $msgTime');
          print(chats);
          chats[0][6] = msgid;
          chats[0][0] = msgTime;
          print(chats);

          memberOnlineStatus[userProfile[0]]![2] = [
            username,
            userProfile[0],
            res['time'],
            res['date'],
            msgBody
          ];
          print('setting state...');
          /* int x = selected.value;
          selected.value = x + 1; */
          setState(() {});
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  getChats(user) {
    print('getChats called');
    //String receiver = (username == planner) ? client : planner;

    var result;
    var address = Uri.parse(domain + 'getchats');
    var content = {
      'intro': 'getchats',
      'username': username,
      'receiver': user,
      'sessionid': sessionToken,
      'nextchatid': nextChatid.toString(),
    };
    print(content);
    if (fetchMore == false) showProgressIndicator(context);

    sendMsg(content);
    print('updating: $updating');
    // if (getChatsAdded == false)
    //   socketNotifier.addListener(
    liste() {
      print('liste called');
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'getchats') {
        print('getchats listener called...');
        result = result['result'];
        if (result['status'] == 'hacker') {
          print('Sorry, you could not hack us');
          //  if (fetchMore == true) jumpTimer.cancel();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (result['status'] == 'valid' /* && updating == false */) {
          //updating = true;
          print('Chats obtained successful');
          print(result);
          if (fetchMore == true) {
            print('fetchmore true');
            if (result['chats'].isNotEmpty) {
              // setState(() {
              fetchMore = false;
              refreshed = true;

              nextChatid = result['chats'].last[6];
              chats.addAll(result['chats']);
              //  streamControl.add(1);
              print("getchat exited");
              adjustOffset = false;
              //setState(() {
              showIndicator.value = false;
              /* int x = selected.value;
              selected.value = x + 1; */
              setState(() {});
              //});
            } else {
              adjustOffset = true;
              fetchMore = false;
              showIndicator.value = false;
            }
            //  });
          } else {
            print("redirecting");
            //setState(() {
            List msg = [];
            print('pas1');
            msg.addAll(result['chats']);
            print('pas2');
            Navigator.pop(context);
            print('pas3');

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => Chatroom(
                  msg,
                  result['userProfile'],
                  true,
                  "ChatroomSingle",
                  idOfLastChat: (result['chats'].length > 0)
                      ? result['chats'].last[6]
                      : 0,
                ),
              ),
            );
          }
          //});
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  Set selectedChats = {};

  gotoBottom() {
    if (scrollContr.hasClients) {
      scrollContr.jumpTo(scrollContr.position.maxScrollExtent);
    } else
      Timer(Duration(milliseconds: 300), () => gotoBottom());
  }

  timeStuff(date) {
    DateTime currTime = DateTime.now();

    DateTime x = intl.DateFormat('dd-MMM-yyyy  h:mm:ss a').parseUtc(date);

    String timeDiff = (currTime.difference(x).inSeconds <= 59)
        ? "${currTime.difference(x).inSeconds}s"
        : (currTime.difference(x).inMinutes <= 59)
            ? "${currTime.difference(x).inMinutes}m"
            : (currTime.difference(x).inHours <= 23)
                ? "${currTime.difference(x).inHours}h"
                : "${currTime.difference(x).inDays}d";

    //print(timeDiff);
    return timeDiff;
  }

  timeStuffMsg(date) {
    DateTime currTime = DateTime.now();

    DateTime x = intl.DateFormat('dd-MMM-yyyy  h:mm a').parseUtc(date);

    String timeDiff = (currTime.difference(x).inSeconds <= 59)
        ? "${currTime.difference(x).inSeconds}s"
        : (currTime.difference(x).inMinutes <= 59)
            ? "${currTime.difference(x).inMinutes}m"
            : (currTime.difference(x).inHours <= 23)
                ? "${currTime.difference(x).inHours}h"
                : "${currTime.difference(x).inDays}d";

    return timeDiff;
  }

  utcToLocal(time) {
    // DateTime currTime = DateTime.now();

    DateTime localTime = intl.DateFormat('h:mm a').parseUtc(time).toLocal();

    return TimeOfDay.fromDateTime(localTime).format(context);
  }

  listener1() {
    Map<String, dynamic> res = socketResult;
    if (res['intro'] == 'newChat') {
      print('new Chat');
      List newChat = res['result'];
      print('newChat:$username $newChat');
      print('chats: $chats');
      chats.insert(0, newChat);
      print('memberOnlineStatus1: $memberOnlineStatus');
      //"""last_message=sender, receiver,time,date,message"""
      //"""result=[time,date,sender,receiver,message,seen,chatid]"""
      if (!memberOnlineStatus.containsKey(newChat[2])) {
        chatData['profiles']!.add([newChat[2], 'default.png']);
        members.add(newChat[2]);
        memberOnlineStatus[newChat[2]] = [];
        memberOnlineStatus[newChat[2]]!.add(1);
        memberOnlineStatus[newChat[2]]!.add('${newChat[0]} ${newChat[1]}');
        memberOnlineStatus[newChat[2]]!.add('');
      }
      print('added 1');
      memberOnlineStatus[newChat[2]]![2] = [
        newChat[2],
        newChat[3],
        newChat[0],
        newChat[1],
        newChat[4]
      ];
      print('added');
      refreshed = true;
      print(chats);

      print('members: $members');
      print('memberOnlineStatus2: $memberOnlineStatus');

      // if (currentRoute == "ChatroomSingle" || currentRoute == "ChatroomMulti") {
      print(currentRoute);
      print('singleChats: $singleChats');
      print('multiChats: $multiChats');
      if (currentRoute == "ChatroomSingle" || singleChats == true) {
        print('reloading single chats');
        int xv = posoNot.value + 1;
        posoNot.value = xv;
      }

      /*   int x = selected.value + 1;
      selected.value = x; */

      if (currentRoute == "ChatroomMulti") {
        int xy = allChatOnlineStatus.value + 1;
        allChatOnlineStatus.value = xy;
      }
      //}
    } else if (res['intro'] ==
            'getOnlineStatus' /* &&
        currentRoute == 'Chatroom' */
        ) {
      print('new online status update');
      print('memberOnlineStatus2: $memberOnlineStatus');
      print(res);
      res = res['result'];
      if (res['status'] == 'valid') {
        /*memberOnlineStatus= {'user': [int onlinestatus,
                              string last_seen,List last_message]} */
        //last_messages= [get, ik, 11:06 PM, 03-Feb-2022, saeea]
        int i = 0;
        for (var usr in res['users']) {
          if (!memberOnlineStatus.containsKey(usr)) {
            memberOnlineStatus[usr] = [];
            memberOnlineStatus[usr]!.add(res['onlineStatus'][i]);
            memberOnlineStatus[usr]!.add(res['last_seen'][usr]);
          } else {
            memberOnlineStatus[usr]![0] = res['onlineStatus'][i];
            memberOnlineStatus[usr]![1] = res['last_seen'][usr];
          }
          i++;
        }
        print('memberOnlineStatus3: $memberOnlineStatus');

        int x = allChatOnlineStatus.value + 1;
        allChatOnlineStatus.value = x;
      }
    }
  }

  listener2() {
    Map<String, dynamic> res = socketResult;
    if (res['intro'] == 'ping' &&
        (currentRoute == 'ChatroomMulti' || currentRoute == 'ChatroomSingle')) {
      print('getOnlineStatus calling');
      webSock.sink.add(jsonEncode({
        'intro': 'getOnlineStatus',
        'users': members,
        'username': username,
        'sessionid': sessionToken
      }));
    }
  }

  deleteChats(List chatids) {
    print("deleteChats called");
    var result;
    var address = Uri.parse(domain + 'deletechats');
    var content = {
      'intro': 'deletechats',
      'username': username,
      'chatids': jsonEncode(chatids),
      'sessionid': sessionToken,
    };

    //showProgressIndicator(context);

    sendMsg(content);

    //if (deleteChatsAdded == false)

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'deletechats') {
        result = result['result'];
        if (result['status'] == 'hacker') {
          print('Sorry, you could not hack us');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (result['status'] == 'valid') {
          print('Chats deleted');
          deleted.addAll(chatids);

          selectedChats.clear();
          int f = selected.value + 1;
          selected.value = f;
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  getUserDetails(user) {
    var res;
    var address = Uri.parse(domain + 'userdetails');
    var content = {
      'intro': 'userdetails',
      'username': username,
      'user': user,
      'sessionid': sessionToken,
    };

    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> res = socketResult;
      if (res['intro'] == 'userdetails') {
        res = res['result'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => AvailableCourierPage(
              reviews: res['reviews'],
              currentShowroom: res['showroom'],
              showplanner: true,
              // fee: item[3],
              details: res['details'],
              clientPics: res['client_pics'],
              planner: user,
              dateCreated: res['details'][10],
              directCall: true,
            ),
          ),
        );
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  removeEar(void Function() liste, ValueNotifier plug) {
    plug.removeListener(liste);
  }

  buildTable(List itemList) {
    if (itemList.isNotEmpty) {
      contentList = [];
      // int count = -1;

      //create tab body

      for (var item in itemList) {
        int pos = itemList.indexWhere((element) => element[0] == item[0]);

        // count++;
        contentList.add(
          GestureDetector(
            onTapUp: (value) {
              user = item[0];
              print('user $user');
              updating = false;
              getChats(user);
            },
            child: Container(
              padding: EdgeInsets.only(left: 5),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      //top: BorderSide(),
                      //bottom: BorderSide(),
                      // left: BorderSide(),
                      //  right: BorderSide(),
                      )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(
                        right: 10,
                        bottom: 5,
                      ),
                      child: ClipOval(
                        child: GestureDetector(
                          onTap: () => showDialog(
                              context: context,
                              builder: (BuildContext contxt) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        child: Image.network(
                                          //reviewer's profile picture
                                          (item[1].isNotEmpty)
                                              ? domain + 'img/' + item[1]
                                              : domain + 'img/' + 'default.png',
                                          /* Image.asset(
                                          "assets/images/passport.jpg", */
                                          height: (deviceWidth > mobileWidth)
                                              ? deviceHeight * 0.8
                                              : deviceWidth * 0.8,
                                          width: (deviceWidth > mobileWidth)
                                              ? deviceHeight * 0.8
                                              : deviceWidth * 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                          //padding: EdgeInsets.only(left: 5, top: 5),
                          child: FadeInImage.assetNetwork(
                            placeholder: "assets/images/imgloading.gif",
                            image: (item[1].isNotEmpty)
                                ? domain + 'img/' + item[1]
                                : domain + 'img/' + 'default.png',
                            /* Image.asset(
                            "assets/images/passport.jpg", */
                            height: (deviceWidth > mobileWidth)
                                ? deviceHeight * 0.1
                                : deviceWidth * 0.1,
                            width: (deviceWidth > mobileWidth)
                                ? deviceHeight * 0.1
                                : deviceWidth * 0.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            //alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              item[0],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: allChatOnlineStatus,
                            builder: (BuildContext context, int value1,
                                Widget? child) {
                              // final int instanceId = tileId;

                              // print(instanceId);
                              print('allChatOnlineStatus<int> changed');

                              /*memberOnlineStatus= {'user': int onlinestatus,
                              string last_seen,List last_message} */
                              //last_messages= [get, ik, 11:06 PM, 03-Feb-2022, saeea]

                              if (memberOnlineStatus[item[0]]![0] == 1)
                                return Icon(
                                  Icons.circle,
                                  color: Colors.green,
                                  size: 10,
                                );
                              return Container(
                                //   alignment: Alignment.bottomRight,

                                padding: EdgeInsets.only(left: 10, bottom: 5),
                                child: Text(
                                  timeStuff(memberOnlineStatus[item[0]]![1]),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            // alignment: Alignment.topLeft,
                            //  padding: EdgeInsets.only(left: 10),
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75),

                            child: ValueListenableBuilder(
                              valueListenable: allChatOnlineStatus,
                              builder: (BuildContext context, int value1,
                                  Widget? child) {
                                return Text(
                                  memberOnlineStatus[item[0]]![2][4],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                );
                              },
                            ),
                          ),
                          Container(
                            //  alignment: Alignment.bottomRight,
                            padding: EdgeInsets.only(left: 10),
                            child: ValueListenableBuilder(
                              valueListenable: allChatOnlineStatus,
                              builder: (BuildContext context, int value1,
                                  Widget? child) {
                                return Text(
                                  (timeStuffMsg((memberOnlineStatus[item[0]]![2]
                                          [3]) +
                                      '  ' +
                                      (memberOnlineStatus[item[0]]![2][2]))),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Column(
        children: contentList,
      );
    } else if (itemList.isEmpty)
      return Center(
        heightFactor: 10,
        child: Text(
          "No chats",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
  }

  @override
  initState() {
    super.initState();
    print('initstate called...');

    if (listener1Added == false) {
      print('adding listener1');
      socketNotifier.addListener(() => listener1());
      listener1Added = true;
    }
    if (listener2Added == false) {
      print('adding listener2');
      pingNotifier.addListener(() => listener2());
      listener2Added = true;
    }

    liste() {
      print('calling fucker...');
      refreshed = true;
      setState(() {});
      print('fucker called...');
      /*   posoNot.removeListener(liste); */
      print('fucker killed...');
    }

    if (currentRoute == "ChatroomSingle") {
      posoNot.removeListener(liste);
      posoNot.addListener(liste);
      singleChats = true;
    } else {
      singleChats = false;
    }

    nextChatid = idOfLastChat;
    if (single == true) {
    } else {}
  }

  @override
  void deactivate() {
    print('deactivated');
    /*  pingNotifier.removeListener(listener2);
    socketNotifier.removeListener(listener1); */
    super.deactivate();
  }

  @override
  dispose() {
    print('disposed');
    if (single == true) {
      //  if (singleChatTimer.isActive) singleChatTimer.cancel();
      //    if (newMessageTimer.isActive) newMessageTimer.cancel();
    } else {
      /* selected.dispose();
      allChatOnlineStatus.dispose(); */
      //    if (allChatTimer.isActive) allChatTimer.cancel();
    }
    /* pingNotifier.removeListener(listener2);
    socketNotifier.removeListener(listener1); */
    super.dispose();
  }

  @override
  build(BuildContext context) {
    //currentRoute = (single == true) ? "ChatroomSingle" : "ChatroomMulti";
    modif = false;
    print("chatroom loaded");

    if (refreshed == false) {
      print("refreshed false");
      prefs.setString("currentRoute", currentRoute);
      chats = allChats;
      refreshed = true;
      /* if(!memberOnlineStatus.containsKey(userProfile[0]) && currentRoute=="ChatroomSingle")
         memberOnlineStatus[userProfile[0]] = [];
        memberOnlineStatus[userProfile[0]]!.add(chatData['profiles']);
            memberOnlineStatus[userProfile[0]]!.add(userProfile[0]['last_seen'][usr]);
      } */
    }

    if (single == true) {
      print("chatroom single");

      print(chats);
      if (chats.isNotEmpty) lastChatId = chats.last[6];
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          brightness: Brightness.dark,
          leadingWidth: 70,
          automaticallyImplyLeading: false,
          leading: Navigator.canPop(context)
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  padding: EdgeInsets.only(left: 8),
                  color: Colors.black,
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Icon(Icons.arrow_back),
                      ),
                      Flexible(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipOval(
                              child: Container(
                                child: FadeInImage.assetNetwork(
                                  placeholder: "assets/images/imgloading.gif",
                                  image: (userProfile[1].isEmpty ||
                                          userProfile[1] == 'None')
                                      ? domain + 'img/' + 'default.png'
                                      : domain + 'img/' + userProfile[1],
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: allChatOnlineStatus,
                              builder: (BuildContext context, int value1,
                                  Widget? child) {
                                print(value1);
                                if (memberOnlineStatus.containsKey(
                                    userProfile[0])) if (memberOnlineStatus[
                                        userProfile[0]]![0] ==
                                    1)
                                  return Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Icon(
                                      Icons.circle,
                                      color: Colors.green,
                                      size: 10,
                                    ),
                                  );
                                return Container(
                                  color: Colors.transparent,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          title: GestureDetector(
            onTap: () => getUserDetails(userProfile[0]),
            child:
                /* Stack(
              children: [ */
                Text(
              userProfile[0],
              //style: TextStyle(fontSize: 12),
            ),
          ),
          actions: [
            ValueListenableBuilder(
              valueListenable: selected,
              builder: (BuildContext context, int value1, Widget? child) {
                // final int instanceId = tileId;

                // print(instanceId);
                print(value1);
                if (selectedChats.isNotEmpty)
                  return IconButton(
                    onPressed: () {
                      print('delete');
                      deleteChats(selectedChats.toList());
                    },
                    padding: EdgeInsets.only(left: 8),
                    color: Colors.black,
                    icon: Icon(Icons.delete),
                  );
                return Container();
              },
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.only(
            // top: 5,
            left: 4,
            right: 4,
            // bottom: 10,
          ),
          child: ListView.builder(
            itemCount: chats.length + 1,
            // controller: scrollContr,
            reverse: true,
            itemBuilder: (context, index) {
              print('chats.length: ${chats.length + 1}');
              //  int index = count - 1;
              print("index: $index");
              print('adjustOffset: $adjustOffset');

              if (index >= chats.length - 11 &&
                  adjustOffset == false &&
                  chats.length >= 20) {
                print("refreshing");
                adjustOffset = true;
                fetchMore = true;
                showIndicator.value = true;
                updating = false;
                getChats(userProfile[0]);
                //setState(() {});
                //updating = false;
              }
              if (index == chats.length)
                return ValueListenableBuilder(
                  valueListenable: showIndicator,
                  builder: (BuildContext context, bool value1, Widget? child) {
                    print("show indicator: $value1");

                    // if(chats.first==chat)
                    if (showIndicator.value == false)
                      return Container(
                        constraints: BoxConstraints(minHeight: 0, maxHeight: 0),
                      );
                    return Container(
                      //color: Colors.white,
                      constraints: BoxConstraints(maxHeight: 12),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        color: Colors.blue[900],
                      ),
                      //constraints: BoxConstraints(minHeight: 10, maxHeight: 10),
                    );
                  },
                );

              print("length: ${chats.length + 1}");
              return ValueListenableBuilder(
                valueListenable: selected,
                builder: (BuildContext context, int value1, Widget? child) {
                  print(value1);

                  print('chats.length: ${chats.length + 1}');
                  return GestureDetector(
                    onLongPress: () {
                      if (selectedChats.isEmpty &&
                          !deleted.contains(chats[index][6]) &&
                          chats[index][2] == username)
                      //a user can only select messages sent
                      //by him/her and which have not been deleted.

                      //Longpress should only work if user has not selected
                      //any message. If user has selected any message
                      // the user can select another message by tapping
                      //instead of longpressing it.
                      {
                        selectedChats.add(chats[index][6].hashCode);
                        selected.value++;
                        //The hashcode of chatid of any selected message
                        //must be added to the notifier set. Doing so
                        //would notify all the notifier builders
                        //listening to the notifier to rebuild their members
                      }
                      print(value1);
                    },
                    onTap: () {
                      if (selectedChats.contains(chats[index][6].hashCode))
                      //if this message has already been selected, tapping
                      //the message should unselect it by removing from
                      //the notifier set
                      {
                        selectedChats.remove(chats[index][6].hashCode);
                        int x = selected.value + 1;
                        selected.value = x;
                      } else if (selectedChats.isNotEmpty &&
                          !deleted.contains(chats[index][6]) &&
                          chats[index][2] == username)
                      //if any other message has already been selected
                      //tapping this message would select it by
                      //adding it to the notifier set
                      {
                        //initialisation begin

                        // notifierSet = true;
                        //initialisation end

                        selectedChats.add(chats[index][6].hashCode);
                        selected.value++;
                        //selects this message
                      }
                      print(value1);
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        left:
                            //align the left edge of all messages
                            (username !=
                                    chats[index][2] //ie, you are not the sender
                                )
                                ? (chats[(index == chats.length - 1)
                                            ? (index - 1 < 0)
                                                ? index
                                                : index - 1
                                            : index + 1][2] ==
                                        chats[index][2])
                                    ? 10
                                    : 0
                                : 0,
                        right:
                            //align the right edge of all messages
                            (username ==
                                    chats[index][2] //ie, you are not the sender
                                )
                                ? (chats[(index == chats.length - 1)
                                            ? (index - 1 < 0)
                                                ? index
                                                : index - 1
                                            : index + 1][2] ==
                                        chats[index][2])
                                    ? 10
                                    : 0
                                : 0,
                        top:
                            //create little gap between successive messages
                            //from the same sender.
                            //However, create much more gap between successive
                            //messages from differnt senders
                            (chats[(index == chats.length - 1)
                                        ? (index - 1 < 0)
                                            ? index
                                            : index - 1
                                        : index + 1][2] !=
                                    chats[index][2])
                                ? 10
                                : 2,
                      ),
                      child: Row(
                        children: [
                          if (!deleted.contains(chats[index][6]))
                            //Do not show messages that the user
                            //has just deleted
                            ClipPath(
                              //clippath gives each message the unique shape
                              clipper: (username != chats[index][2])
                                  //current user is not the sender
                                  ? (chats[(index == chats.length - 1)
                                              ? (index - 1 < 0)
                                                  ? index
                                                  : index - 1
                                              : index + 1][2] ==
                                          chats[index][2])
                                      ? null //from same sender
                                      : ChatShapeLeft() //from different senders
                                  //current user is the sender
                                  : (chats[(index == chats.length - 1)
                                              ? (index - 1 < 0)
                                                  ? index
                                                  : index - 1
                                              : index + 1][2] ==
                                          chats[index][2])
                                      ? null //from same sender
                                      : ChatShapeRight(), //from different senders

                              child: Container(
                                padding: EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                    left: //ie,  padding for messages on the
                                        //left
                                        //5 for message without custom clipper
                                        //15 for message with custom clipper
                                        //without this padding, clipper cuts
                                        //off some content of the message
                                        (username != chats[index][2] &&
                                                (chats[(index ==
                                                            chats.length - 1)
                                                        ? (index - 1 < 0)
                                                            ? index
                                                            : index - 1
                                                        : index + 1][2] !=
                                                    chats[index][2]))
                                            ? 15
                                            : 5,
                                    right: //ie,  padding for messages on the
                                        //right
                                        //5 for message without custom clipper
                                        //15 for message with custom clipper
                                        //without this padding, clipper cuts
                                        //off some content of the message
                                        (username == chats[index][2] &&
                                                (chats[(index ==
                                                            chats.length - 1)
                                                        ? (index - 1 < 0)
                                                            ? index
                                                            : index - 1
                                                        : index + 1][2] !=
                                                    chats[index][2]))
                                            ? 15
                                            : 5),
                                // decoration: ShapeDecoration(
                                color: (username != chats[index][2])
                                    //if message is selected, color is
                                    //grey or red[100]
                                    //else color is black or red
                                    ? (selectedChats
                                            .contains(chats[index][6].hashCode))
                                        ? Colors.grey //selected
                                        : Colors.black //not selected
                                    : (selectedChats
                                            .contains(chats[index][6].hashCode))
                                        ? Colors.red[100] //selected
                                        : Colors.red, //not selected

                                //    shape: RoundedRectangleBorder()),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  //pushes content to the end of
                                  //container
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              bottom: 2,
                                              right:
                                                  //get width of messgage and
                                                  //width of timestamp
                                                  //if timestamp occupies more
                                                  //horizontal space than the message,
                                                  //25 pad the message at the right
                                                  //to push it to the away from
                                                  //the right edge of the container
                                                  ((getTextSize(
                                                            chats[index][0],
                                                            TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 9,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                            ),
                                                            context,
                                                          ).width) >
                                                          (getTextSize(
                                                            chats[index][4],
                                                            TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            context,
                                                          ).width))
                                                      ? 25
                                                      : 0),
                                          constraints: BoxConstraints(
                                              //the width of message must
                                              //be not exceed 80% of device
                                              //width
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8),
                                          child: Text(
                                            chats[index][4],
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        /* if ((prevUser = chats[index][2]) == "")
                                          Container(), */
                                        //just a tricky way to
                                        //get username of the sender of the
                                        // current message. That condition
                                        //can never be true. LOL
                                        ValueListenableBuilder(
                                          valueListenable: deliveryListener,
                                          builder: (BuildContext context,
                                              int value2, Widget? child) {
                                            if (chats[index][0].isNotEmpty)
                                              return Container(
                                                padding:
                                                    EdgeInsets.only(top: 5),
                                                //created space between the
                                                // message and the timestamp
                                                child: Text(
                                                  utcToLocal(chats[index][0]),
                                                  // chat[0],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              );
                                            return Container(
                                              padding: EdgeInsets.only(top: 5),
                                              //created space between the
                                              // message and the timestamp
                                              child: Icon(
                                                Icons.circle,
                                                color: Colors.white,
                                                size: 3,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                        ],
                        mainAxisAlignment:
                            //if a message was sent by the current user,
                            //then that message should be on the right
                            //else, the message should be on the left
                            (username != chats[index][2])
                                //ie, current user is not the sender
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.black,
          padding: /*  (defaultTargetPlatform == TargetPlatform.linux ||
                  defaultTargetPlatform == TargetPlatform.macOS ||
                  defaultTargetPlatform == TargetPlatform.windows)
              ? EdgeInsetsDirectional.zero
              : */
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: textController,
                  onChanged: (input) {
                    newMsg = input;
                  },
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: "Message",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (newMsg.isNotEmpty) {
                    print('calling sendMesg');
                    //int indx = chats.length;

                    //int k = Random().nextInt(1000000000);
                    /*  (chats.length == 0)
                        ? chats.add([
                            "",
                            DateTime.now().day.toString(),
                            username,
                            userProfile[0],
                            newMsg,
                            0,
                            Random().nextInt(1000000000),
                          ])
                        : */
                    chats.insert(0, [
                      "",
                      DateTime.now().day.toString(),
                      username,
                      userProfile[0],
                      newMsg,
                      0,
                      Random().nextInt(1000000000),
                    ]);
                    // setState(() {

                    // newMsg = '';
                    refreshed = true;
                    //int x = selected.value;
                    // selected.value = x + 1;
                    // });
                    textController.clear();
                    setState(() {});
                    sendMesg(
                        /*  (chats.length == 0) ? */ chats
                            .length /* : chats.length - 1 */,
                        newMsg);
                  }
                },
                alignment: Alignment.topCenter,
                icon: Icon(
                  Icons.send_rounded,
                  color: Colors.green[500],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (single == false)
      return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "eventGig",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Chats",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(top: 5, left: 10, right: 10),
          child: SingleChildScrollView(
            child: Container(
              color: Colors.red[100],
              child: ValueListenableBuilder(
                valueListenable: allChatOnlineStatus,
                builder: (BuildContext context, int value1, Widget? child) {
                  return buildTable(
                    chatData['profiles']!,
                  );
                },
              ),
            ),
          ),
        ),
      );
    else
      return MaterialApp(
        home: ReloadHomePage(),
      );
  }
}

class Showroom extends StatefulWidget {
  Showroom(this.pictures);
  final List pictures;
  @override
  _Showroom createState() => _Showroom(this.pictures);
}

//Allows the user to place an order for courier
class _Showroom extends State<Showroom> {
  _Showroom(this.pictures);
  final List pictures;

  bool nullSignal = false;

  bool homeCall = false;
  List showroomPics = [];

  bool refreshed = false;

  String currentPic = '';

  var currentPosition = 0;

  reloadShowroom() {
    var content = {
      'intro': 'getshowroom',
      "sessionid": sessionToken,
      "username": username,
    };

    Uri address = Uri.parse(domain + "getshowroom");
    print(address);
    print(content);

    var res;

    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> res = socketResult;
      if (res['intro'] == 'getshowroom') {
        Navigator.pop(context);
        res = res['result'];
        if (res['status'] == 'hacker') {
          print('hacker');
          nullInputDialog(context, "Failed hack attempt", 'Oops');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (res['status'] == 'valid') {
          print('Showroom retrieved');
          print(res['showroom']);
          showroomPics = res['showroom'];
          refreshed = true;
          setState(() {});
          //return res['showroom'];
          //showroomPics = res['showroom'];
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  deletePic(var showroomid) {
    var content = {
      'intro': 'deletepic',
      "sessionid": sessionToken,
      "username": username,
      "showroomid": showroomid,
    };

    Uri address = Uri.parse(domain + "deletepic");
    print(address);
    print(content);

    var res;
    showProgressIndicator(context);

    sendMsg(content);

    liste() {
      Map<String, dynamic> res = socketResult;
      if (res['intro'] == 'deletepic') {
        Navigator.pop(context);
        res = res['result'];
        if (res['status'] == 'hacker') {
          print('hacker');
          nullInputDialog(context, "Failed hack attempt", 'Oops');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (res['status'] == 'deleted') {
          print('deleted');
          //showroomPics.removeAt(currentPosition);
          snackMsg(context, "Picture deleted");
          reloadShowroom();
        } else if (res['status'] == 'invalid') {
          print('hacker');
          nullInputDialog(context, "The picture no longer exist", 'Oops');
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  addPic() {
    Uint8List? file;
    String fileN;
    String? fileEx;
    String? filePath;
    FilePicker.platform.pickFiles().then(
      (value) async {
        if (value == null)
          print('empty file');
        else {
          showProgressIndicator(context);
          file = value.files.first.bytes;
          fileN = value.files.first.name;
          fileEx = value.files.first.extension;
          filePath = value.files.first.path;

          print('file obtained');

          Uri address = Uri.parse(domain + "uploadpic");
          print(address);

          http.MultipartRequest request =
              http.MultipartRequest('POST', address);
          if (!kIsWeb) {
            await http.MultipartFile.fromPath('dp', filePath!)
                .then((value) async {
              request.files.add(value);
              request.fields['username'] = username;
              request.fields['sessionid'] = sessionToken;
              request.fields['extension'] = fileEx as String;
              await request.send().then(
                (value) async {
                  await http.Response.fromStream(value).then(
                    (value) {
                      //Navigator.pop(context);
                      print(value.statusCode);
                      var result = jsonDecode(value.body);
                      if (result["status"] == "ok") {
                        var contentP = {
                          "sessionid": sessionToken,
                          "username": username,
                          "extension": fileEx as String,
                        };

                        Uri address = Uri.parse(
                            "http://eflask-app-ikp120.herokuapp.com/uploadpic");
                        print(address);
                        print(contentP);

                        var resp;

                        //  showProgressIndicator(context);

                        sendRequest(httpC, address, contentP).then(
                          (value) {
                            resp = value;
                            Navigator.pop(context);

                            if (resp['value'] == 'OK') {
                              print('saved at heroku');
                            } else {
                              print('eror at heroku');
                            }
                          },
                        );
                        print("picture saved");
                        snackMsg(context, "Picture saved");
                        reloadShowroom();
                      }
                    },
                  );
                },
              );
            });
          } else {
            http.MultipartFile picture =
                http.MultipartFile.fromBytes('dp', file!, filename: fileN);

            if (picture != null) {
              request.files.add(picture);
              request.fields['username'] = username;
              request.fields['sessionid'] = sessionToken;
              request.fields['extension'] = fileEx as String;
              await request.send().then(
                (value) async {
                  await http.Response.fromStream(value).then(
                    (value) {
                      Navigator.pop(context);
                      print(value.statusCode);
                      var result = jsonDecode(value.body);
                      if (result["status"] == "ok") {
                        var contentP = {
                          "sessionid": sessionToken,
                          "username": username,
                          "extension": fileEx as String,
                        };

                        Uri address = Uri.parse(
                            "http://eflask-app-ikp120.herokuapp.com/uploadpic");
                        print(address);
                        print(contentP);

                        var resp;

                        showProgressIndicator(context);

                        sendRequest(httpC, address, contentP).then(
                          (value) {
                            resp = value;
                            Navigator.pop(context);

                            if (resp['value'] == 'OK') {
                              print('saved at heroku');
                            } else {
                              print('eror at heroku');
                            }
                          },
                        );
                        print("picture saved");
                        snackMsg(context, "Picture saved");
                        reloadShowroom();
                      }
                    },
                  );
                },
              );
            }
          }
        }
      },
    );
  }

  Widget build(BuildContext context) {
    print('in');
    currentRoute = "Showroom";
    prefs.setString("currentRoute", "Showroom");

    if (refreshed == false) {
      showroomPics = pictures;
    }
    print('done');

    if (showroomPics.isNotEmpty)
      return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          leadingWidth: 15,
          automaticallyImplyLeading: false,
          leading: Navigator.canPop(context)
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  padding: EdgeInsets.only(left: 8),
                  color: Colors.black,
                  icon: Icon(Icons.arrow_back))
              : null,
          title: Column(
            children: [
              Text(
                "eventGig",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Showroom",
                style: TextStyle(fontSize: 12),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print('calling addPic');
            addPic();
          },
          child: Icon(Icons.add),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  Container(
                    child: CarouselSlider(
                      items: (showroomPics.isNotEmpty)
                          ? showroomPics
                              .map(
                                (pic) => Container(
                                  child: Image.network(
                                    domain + 'img/' + pic[1],
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    width: MediaQuery.of(context).size.width *
                                        0.95,
                                  ),
                                ),
                              )
                              .toList()
                          : [
                              Image.network(
                                domain + 'img/' + 'default.png',
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                width: MediaQuery.of(context).size.width * 0.95,
                              ),
                            ],
                      options: CarouselOptions(
                          onScrolled: (value) {
                            currentPosition = value as int;
                            print(currentPosition);
                          },
                          enableInfiniteScroll: false),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          print('calling deletePic');
                          deletePic((showroomPics[currentPosition as int][0])
                              .toString());
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    else
      return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          leadingWidth: 15,
          automaticallyImplyLeading: false,
          leading: Navigator.canPop(context)
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  padding: EdgeInsets.only(left: 8),
                  color: Colors.black,
                  icon: Icon(Icons.arrow_back))
              : null,
          title: Column(
            children: [
              Text(
                "eventGig",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Showroom",
                style: TextStyle(fontSize: 12),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print('calling addPic');
            addPic();
          },
          child: Icon(Icons.add),
        ),
        body: Container(
          child: Text(''),
        ),
      );
  }
}

class Notifications extends StatefulWidget {
  Notifications(this.notifications);
  final List notifications;
  @override
  _Notifications createState() => _Notifications(this.notifications);
}

//logs out the user
class _Notifications extends State<Notifications> {
  _Notifications(this.notifications);
  final List notifications;
  var result;
  var don = 'notSet';
  // int itemid = 0;
  ValueNotifier<int> clicked = ValueNotifier<int>(0);

  int clickedID = 0;
  int i = 0;

  notifClicked(int id) {
    var address = Uri.parse(domain + 'clickedNotification');

    var content = {
      'intro': 'clickedNotification',
      'username': username,
      'sessionid': sessionToken,
      'notifyid': id.toString()
    };

    print('notifClicked called... content passed');

    print(address);
    print(content);
    showProgressIndicator(context);

    //if (clickLocked == false)
    sendMsg(content);
    // clickLocked = true;

    liste() {
      Map<String, dynamic> result = socketResult;
      if (result['intro'] == 'clickedNotification') {
        Navigator.pop(context);
        result = result['result'];
        print(result);
        if (result['status'] == 'valid') {
          print('Notification click registered successfully');
          // clickedID = id;
          i++;
          clicked.value = i;
        } else if (result['status'] == 'hacker') {
          print('hack attempt failed');
          snackMsg(context, "hack attempt failed");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false);
        } else if (result['status'] == 'invalid') {
          print('Invalid request');
          snackMsg(context, "Invalid request");
        } else {
          print('double clicked');
        }
        socketNotifier.removeListener(liste);
      }
    }

    socketNotifier.addListener(liste);
  }

  @override
  void dispose() {
    clicked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    currentRoute = "Notifications";
    prefs.setString("currentRoute", "Notifications");
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
