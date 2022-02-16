// ignore_for_file: prefer_typing_uninitialized_variables, avoid_print

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart' as socket;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Model {
  static String name = "";
  static var domain = (kIsWeb)
      ? "http://ikp120.pythonanywhere.com/"
      : "http://ikp120.pythonanywhere.com/";
  static String username = "";
  static String email = "";
  static String sessionToken = "";
  static bool emailVerified = false;
  static bool diableLogin = false;
  static var orderDetailList;
  static http.Client httpC = http.Client();
  static late SharedPreferences prefs;
  static String payload = "login";
  static bool sessionLogin = true;
  static bool blocked = false;
  static String currentRoute = "";
  static final ValueNotifier<int> selected = ValueNotifier<int>(0);
  static bool tokenSet = false;
  static int socketCount = 0;
  static List chatBuddies = [];
  static List members = [];
  static Map<String, List> memberOnlineStatus = {};
  static final ValueNotifier<int> allChatOnlineStatus = ValueNotifier<int>(0);
  static final ValueNotifier<int> posoNot = ValueNotifier<int>(0);
  static List chats = [];
  static bool modif = false;
/*memberOnlineStatus= {'user':[int onlinestatus,
String last_seen,List last_messages]} */
//last_messages= [[get, ik, 11:06 PM, 03-Feb-2022, saeea]]

  static late socket.WebSocketChannel webSock;

  static late BuildContext currentContext;

  static Stream socketStream = webSock.stream;
//int unSeen = 0;
  static final ValueNotifier<int> unSeen = ValueNotifier<int>(0);
  static final ValueNotifier<int> newRespondentLner = ValueNotifier<int>(0);

  static final ValueNotifier<int> socketNotifier = ValueNotifier<int>(0);
  static Map<String, dynamic> socketResult = {};

  static bool singleChats = false;
  static bool multiChats = false;

  static final ValueNotifier<int> pingNotifier = ValueNotifier<int>(0);

  static Map chatData = {};
  static int numOfRespondents = 0;
  static int code = 1;

  static Map respondents = {};
  static int notifID = 2;
  static double mobileWidth = 500;
  static double deviceWidth = 0;
  static double deviceHeight = 0;

  static bool listener1Added = false;
  static bool listener2Added = false;
  static bool testMode = false;
  static const String countKey = 'count';
  static const String isolateName = 'isolate';
  static int deb = 1;
  static String addr = "wss://eflask-app-ikp120.herokuapp.com/ws";
  //static String addr = "ws://127.0.0.1:3535/ws";

  static String token = '';

//{''}

//a stack implementation using queue.
//add to end, remove from end

  static Queue<BuildContext> contextQueue = Queue<BuildContext>();

  // static Map<String, BuildContext> contextMap = {};

  static setter() {
    print('init socket...');
    // webSock = IOWebSocketChannel.connect(Uri.parse(addr));

    webSock = socket.WebSocketChannel.connect(Uri.parse(addr));
    Model.webSock.stream.listen((event) {
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
    });
  }

  static resetStatics() {
    name = "";
    domain = (kIsWeb)
        ? "http://ikp120.pythonanywhere.com/"
        : "http://ikp120.pythonanywhere.com/";
    username = "";
    email = "";
    sessionToken = "";
    emailVerified = false;
    diableLogin = false;
    orderDetailList;
    httpC = http.Client();
    payload = "login";
    sessionLogin = true;
    blocked = false;
    currentRoute = "";
    tokenSet = false;
    socketCount = 0;
    chatBuddies = [];
    members = [];
    memberOnlineStatus = {};
    chats = [];
    modif = false;
    socketResult = {};

    singleChats = false;
    multiChats = false;

    chatData = {};
    numOfRespondents = 0;
    code = 1;

    respondents = {};
    notifID = 2;
    mobileWidth = 500;
    deviceWidth = 0;
    deviceHeight = 0;

    listener1Added = false;
    listener2Added = false;
    testMode = false;
    deb = 1;
    addr = "wss://eflask-app-ikp120.herokuapp.com/ws";
    //  addr = "ws://127.0.0.1:3535/ws";

    token = '';
//a stack implementation using queue.
//add to end, remove from end

    contextQueue = Queue<BuildContext>();
  }
}
