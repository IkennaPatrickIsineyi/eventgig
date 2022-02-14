// ignore_for_file: prefer_typing_uninitialized_variables, avoid_print

import 'dart:async';
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

  static setter() {
    print('init socket...');
    // webSock = IOWebSocketChannel.connect(Uri.parse(addr));

    webSock = socket.WebSocketChannel.connect(Uri.parse(addr));
  }
}
