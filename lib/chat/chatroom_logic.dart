// ignore_for_file: prefer_const_constructors, avoid_print, library_prefixes, avoid_unnecessary_containers

import 'dart:async';
import 'dart:convert';

import 'package:experi/chat/chatroom_page.dart';
import 'package:intl/intl.dart' as intl;
import 'package:experi/available_planners/available_planners_page.dart';
import 'package:experi/login/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart' as BLoC;

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
List _userProfile = [];
String _msgBody = "";
List _chatids = [];

bool onlineStatusObtained = false;
bool updating = false;
TextEditingController textController = TextEditingController();
// StreamController<int> streamControl = StreamController<int>();
// List<Widget> chatContents = [];

sendMesgEvent() {
  Map<String, dynamic> res = Model.socketResult;
  if (res['intro'] == 'sendchat') {
    res = res['result'];
    if (res['status'] == 'hacker') {
      print('hacker');
      BLoC.nullInputDialog(Model.currentContext, "Failed hack attempt", 'Oops');
      Navigator.pushAndRemoveUntil(
          Model.currentContext,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } else if (res['status'] == 'sent') {
      int msgid = res['chatid'];
      String msgTime = TimeOfDay.fromDateTime(DateTime.now().toUtc())
          .format(Model.currentContext);
      print('sent');
      print('msgid: $msgid');
      print('msgtime: $msgTime');
      print(Model.chats);
      Model.chats[0][6] = msgid;
      Model.chats[0][0] = msgTime;
      print(Model.chats);

      Model.memberOnlineStatus[_userProfile[0]]![2] = [
        Model.username,
        _userProfile[0],
        res['time'],
        res['date'],
        _msgBody
      ];
      print('setting state...');
      int x = Model.selected.value;
      Model.selected.value = x + 1;
      // setState(() {});
    }
    Model.socketNotifier.removeListener(sendMesgEvent);
  }
}

getChatsEvent() {
  print('liste called');
  Map<String, dynamic> result = Model.socketResult;
  if (result['intro'] == 'getchats') {
    print('getchats listener called...');
    result = result['result'];
    if (result['status'] == 'hacker') {
      print('Sorry, you could not hack us');
      //  if (fetchMore == true) jumpTimer.cancel();
      Navigator.pushAndRemoveUntil(
          Model.currentContext,
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
          Model.chats.addAll(result['chats']);
          //  streamControl.add(1);
          print("getchat exited");
          adjustOffset = false;
          //setState(() {
          showIndicator.value = false;
          int x = Model.selected.value;
          Model.selected.value = x + 1;

          //  setState(() {});
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
        Navigator.pop(Model.currentContext);
        print('pas3');

        Navigator.push(
          Model.currentContext,
          MaterialPageRoute(
            builder: (BuildContext context) => Chatroom(
              msg,
              result['userProfile'],
              true,
              "ChatroomSingle",
              idOfLastChat:
                  (result['chats'].length > 0) ? result['chats'].last[6] : 0,
            ),
          ),
        );
      }
      //});
    }
    Model.socketNotifier.removeListener(getChatsEvent);
  }
}

deleteChatsEvent() {
  Map<String, dynamic> result = Model.socketResult;
  if (result['intro'] == 'deletechats') {
    result = result['result'];
    if (result['status'] == 'hacker') {
      print('Sorry, you could not hack us');
      Navigator.pushAndRemoveUntil(
          Model.currentContext,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } else if (result['status'] == 'valid') {
      print('Chats deleted');
      deleted.addAll(_chatids);

      selectedChats.clear();
      int f = Model.selected.value + 1;
      Model.selected.value = f;
    }
    Model.socketNotifier.removeListener(deleteChatsEvent);
  }
}

getUserDetailsEvent() {
  Map<String, dynamic> res = Model.socketResult;
  if (res['intro'] == 'userdetails') {
    res = res['result'];
    Navigator.push(
      Model.currentContext,
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
    Model.socketNotifier.removeListener(getUserDetailsEvent);
  }
}

sendMesg(int msgIndex, String msgBody, List userProfile) {
  newMsg = '';
  print('sendMesg called');
  var content = {
    'intro': 'sendchat',
    "sessionid": Model.sessionToken,
    "username": Model.username,
    "message": msgBody,
    "receiver": userProfile[0],
  };

  _userProfile = userProfile;
  _msgBody = msgBody;

  Uri address = Uri.parse(Model.domain + "sendchat");
  print(address);
  print(content);

  //BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);
  // if (sendMesgAdded == false)
/* 
  liste() {
    Map<String, dynamic> res = Model.socketResult;
    if (res['intro'] == 'sendchat') {
      res = res['result'];
      if (res['status'] == 'hacker') {
        print('hacker');
        BLoC.nullInputDialog(
            Model.currentContext, "Failed hack attempt", 'Oops');
        Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      } else if (res['status'] == 'sent') {
        int msgid = res['chatid'];
        String msgTime = TimeOfDay.fromDateTime(DateTime.now().toUtc())
            .format(Model.currentContext);
        print('sent');
        print('msgid: $msgid');
        print('msgtime: $msgTime');
        print(Model.chats);
        Model.chats[0][6] = msgid;
        Model.chats[0][0] = msgTime;
        print(Model.chats);

        Model.memberOnlineStatus[_userProfile[0]]![2] = [
          Model.username,
          _userProfile[0],
          res['time'],
          res['date'],
          msgBody
        ];
        print('setting state...');
        /* int x = Model.selected.value;
          Model.selected.value = x + 1; */
        setState(() {});
      }
      Model.socketNotifier.removeListener(liste);
    }
  }
 */
  Model.socketNotifier.addListener(sendMesgEvent);
}

getChats(user) {
  print('getChats called');
  //String receiver = (Model.username == planner) ? client : planner;

  // var address = Uri.parse(Model.domain + 'getchats');
  var content = {
    'intro': 'getchats',
    'username': Model.username,
    'receiver': user,
    'sessionid': Model.sessionToken,
    'nextchatid': nextChatid.toString(),
  };
  print(content);
  if (fetchMore == false) BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);
  print('updating: $updating');
  // if (getChatsAdded == false)
  //   Model.socketNotifier.addListener(
  /*  liste() {
    print('liste called');
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'getchats') {
      print('getchats listener called...');
      result = result['result'];
      if (result['status'] == 'hacker') {
        print('Sorry, you could not hack us');
        //  if (fetchMore == true) jumpTimer.cancel();
        Navigator.pushAndRemoveUntil(
            Model.currentContext,
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
            Model.chats.addAll(result['chats']);
            //  streamControl.add(1);
            print("getchat exited");
            adjustOffset = false;
            //setState(() {
            showIndicator.value = false;
            /* int x = Model.selected.value;
              Model.selected.value = x + 1; */
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
          Navigator.pop(Model.currentContext);
          print('pas3');

          Navigator.push(
            Model.currentContext,
            MaterialPageRoute(
              builder: (BuildContext context) => Chatroom(
                msg,
                result['userProfile'],
                true,
                "ChatroomSingle",
                idOfLastChat:
                    (result['chats'].length > 0) ? result['chats'].last[6] : 0,
              ),
            ),
          );
        }
        //});
      }
      Model.socketNotifier.removeListener(liste);
    }
  } */

  Model.socketNotifier.addListener(getChatsEvent);
}

Set selectedChats = {};

gotoBottom() {
  if (scrollContr.hasClients) {
    scrollContr.jumpTo(scrollContr.position.maxScrollExtent);
  } else {
    Timer(Duration(milliseconds: 300), () => gotoBottom());
  }
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

  return TimeOfDay.fromDateTime(localTime).format(Model.currentContext);
}

listener1() {
  Map<String, dynamic> res = Model.socketResult;
  if (res['intro'] == 'newChat') {
    print('new Chat');
    List newChat = res['result'];
    print('newChat:$Model.username $newChat');
    print('chats: ${Model.chats}');
    Model.chats.insert(0, newChat);
    print('memberOnlineStatus1: ${Model.memberOnlineStatus}');
    //"""last_message=sender, receiver,time,date,message"""
    //"""result=[time,date,sender,receiver,message,seen,chatid]"""
    if (!Model.memberOnlineStatus.containsKey(newChat[2])) {
      Model.chatData['profiles']!.add([newChat[2], 'default.png']);
      Model.members.add(newChat[2]);
      Model.memberOnlineStatus[newChat[2]] = [];
      Model.memberOnlineStatus[newChat[2]]!.add(1);
      Model.memberOnlineStatus[newChat[2]]!.add('${newChat[0]} ${newChat[1]}');
      Model.memberOnlineStatus[newChat[2]]!.add('');
    }
    print('added 1');
    Model.memberOnlineStatus[newChat[2]]![2] = [
      newChat[2],
      newChat[3],
      newChat[0],
      newChat[1],
      newChat[4]
    ];
    print('added');
    refreshed = true;
    print(Model.chats);

    print('members: ${Model.members}');
    print('memberOnlineStatus2: ${Model.memberOnlineStatus}');

    // if (Model.currentRoute == "ChatroomSingle" || Model.currentRoute == "ChatroomMulti") {
    print(Model.currentRoute);
    print('singleChats: ${Model.singleChats}');
    print('multiChats: ${Model.multiChats}');
    if (Model.currentRoute == "ChatroomSingle" || Model.singleChats == true) {
      print('reloading single chats');
      int xv = Model.posoNot.value + 1;
      Model.posoNot.value = xv;
    }

    /*   int x = Model.selected.value + 1;
      Model.selected.value = x; */

    if (Model.currentRoute == "ChatroomMulti") {
      int xy = Model.allChatOnlineStatus.value + 1;
      Model.allChatOnlineStatus.value = xy;
    }
    //}
  } else if (res['intro'] ==
          'getOnlineStatus' /* &&
        Model.currentRoute == 'Chatroom' */
      ) {
    print('new online status update');
    print('memberOnlineStatus2: ${Model.memberOnlineStatus}');
    print(res);
    res = res['result'];
    if (res['status'] == 'valid') {
      /*memberOnlineStatus= {'user': [int onlinestatus,
                              string last_seen,List last_message]} */
      //last_messages= [get, ik, 11:06 PM, 03-Feb-2022, saeea]
      int i = 0;
      for (var usr in res['users']) {
        if (!Model.memberOnlineStatus.containsKey(usr)) {
          Model.memberOnlineStatus[usr] = [];
          Model.memberOnlineStatus[usr]!.add(res['onlineStatus'][i]);
          Model.memberOnlineStatus[usr]!.add(res['last_seen'][usr]);
        } else {
          Model.memberOnlineStatus[usr]![0] = res['onlineStatus'][i];
          Model.memberOnlineStatus[usr]![1] = res['last_seen'][usr];
        }
        i++;
      }
      print('memberOnlineStatus3: ${Model.memberOnlineStatus}');

      int x = Model.allChatOnlineStatus.value + 1;
      Model.allChatOnlineStatus.value = x;
    }
  }
}

listener2() {
  Map<String, dynamic> res = Model.socketResult;
  if (res['intro'] == 'ping' &&
      (Model.currentRoute == 'ChatroomMulti' ||
          Model.currentRoute == 'ChatroomSingle')) {
    print('getOnlineStatus calling');
    Model.webSock.sink.add(jsonEncode({
      'intro': 'getOnlineStatus',
      'users': Model.members,
      'username': Model.username,
      'sessionid': Model.sessionToken
    }));
  }
}

deleteChats(List chatids) {
  print("deleteChats called");

  // var address = Uri.parse(Model.domain + 'deletechats');
  var content = {
    'intro': 'deletechats',
    'username': Model.username,
    'chatids': jsonEncode(chatids),
    'sessionid': Model.sessionToken,
  };

  //BLoC.showProgressIndicator(Model.currentContext);
  _chatids = chatids;
  BLoC.sendMsg(content);

  //if (deleteChatsAdded == false)

/*   liste() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'deletechats') {
      result = result['result'];
      if (result['status'] == 'hacker') {
        print('Sorry, you could not hack us');
        Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      } else if (result['status'] == 'valid') {
        print('Chats deleted');
        deleted.addAll(chatids);

        selectedChats.clear();
        int f = Model.selected.value + 1;
        Model.selected.value = f;
      }
      Model.socketNotifier.removeListener(liste);
    }
  } */

  Model.socketNotifier.addListener(deleteChatsEvent);
}

getUserDetails(user) {
  // var address = Uri.parse(Model.domain + 'userdetails');
  var content = {
    'intro': 'userdetails',
    'username': Model.username,
    'user': user,
    'sessionid': Model.sessionToken,
  };

  BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);

  /*  liste() {
    Map<String, dynamic> res = Model.socketResult;
    if (res['intro'] == 'userdetails') {
      res = res['result'];
      Navigator.push(
        Model.currentContext,
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
      Model.socketNotifier.removeListener(liste);
    }
  } */

  Model.socketNotifier.addListener(getUserDetailsEvent);
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
      // int pos = itemList.indexWhere((element) => element[0] == item[0]);

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
                            context: Model.currentContext,
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
                                            ? Model.domain + 'img/' + item[1]
                                            : Model.domain +
                                                'img/' +
                                                'default.png',
                                        /* Image.asset(
                                          "assets/images/passport.jpg", */
                                        height: (Model.deviceWidth >
                                                Model.mobileWidth)
                                            ? Model.deviceHeight * 0.8
                                            : Model.deviceWidth * 0.8,
                                        width: (Model.deviceWidth >
                                                Model.mobileWidth)
                                            ? Model.deviceHeight * 0.8
                                            : Model.deviceWidth * 0.8,
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
                              ? Model.domain + 'img/' + item[1]
                              : Model.domain + 'img/' + 'default.png',
                          /* Image.asset(
                            "assets/images/passport.jpg", */
                          height: (Model.deviceWidth > Model.mobileWidth)
                              ? Model.deviceHeight * 0.1
                              : Model.deviceWidth * 0.1,
                          width: (Model.deviceWidth > Model.mobileWidth)
                              ? Model.deviceHeight * 0.1
                              : Model.deviceWidth * 0.1,
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
                          valueListenable: Model.allChatOnlineStatus,
                          builder: (BuildContext context, int value1,
                              Widget? child) {
                            // final int instanceId = tileId;

                            // print(instanceId);
                            print('Model.allChatOnlineStatus<int> changed');

                            /*memberOnlineStatus= {'user': int onlinestatus,
                              string last_seen,List last_message} */
                            //last_messages= [get, ik, 11:06 PM, 03-Feb-2022, saeea]

                            if (Model.memberOnlineStatus[item[0]]![0] == 1) {
                              return Icon(
                                Icons.circle,
                                color: Colors.green,
                                size: 10,
                              );
                            }
                            return Container(
                              //   alignment: Alignment.bottomRight,

                              padding: EdgeInsets.only(left: 10, bottom: 5),
                              child: Text(
                                timeStuff(
                                    Model.memberOnlineStatus[item[0]]![1]),
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
                              maxWidth: MediaQuery.of(Model.currentContext)
                                      .size
                                      .width *
                                  0.75),

                          child: ValueListenableBuilder(
                            valueListenable: Model.allChatOnlineStatus,
                            builder: (BuildContext context, int value1,
                                Widget? child) {
                              return Text(
                                Model.memberOnlineStatus[item[0]]![2][4],
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
                            valueListenable: Model.allChatOnlineStatus,
                            builder: (BuildContext context, int value1,
                                Widget? child) {
                              return Text(
                                (timeStuffMsg(
                                    (Model.memberOnlineStatus[item[0]]![2][3]) +
                                        '  ' +
                                        (Model.memberOnlineStatus[item[0]]![2]
                                            [2]))),
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
  } else if (itemList.isEmpty) {
    return Center(
      heightFactor: 10,
      child: Text(
        "No chats",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
