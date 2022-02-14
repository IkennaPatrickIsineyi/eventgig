// ignore_for_file: prefer_const_constructors, library_prefixes, prefer_typing_uninitialized_variables, file_names, avoid_print, prefer_const_literals_to_create_immutables

import 'package:experi/model.dart';
import 'package:flutter/material.dart';
import 'package:experi/BLoC.dart' as BLoC;
import 'package:experi/notification/notification_page.dart';
import 'package:experi/login/loginpage.dart';
import 'package:experi/existing_order/existing_order_page.dart';

import 'package:experi/profile_setting/profile_setting_page.dart';
import 'package:experi/chat/chatroom_page.dart';

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
ValueNotifier<int> reloadPage = ValueNotifier<int>(0);

//late Timer homeTimer;

getNotificationsEvent() {
  Map<String, dynamic> result = Model.socketResult;
  if (result['intro'] == 'getunclicked') {
    Navigator.pop(Model.currentContext);
    result = result['result'];
    print(result);
    if (result['status'] == 'valid') {
      print('Notifications retrieved successfully');

      Navigator.push(
        Model.currentContext,
        MaterialPageRoute(
          builder: (BuildContext context) => Notifications(result['unclicked']),
        ),
      );
    } else if (result['status'] == 'hacker') {
      print('hack attempt failed');
      BLoC.snackMsg(Model.currentContext, "hack attempt failed");
      Navigator.pushAndRemoveUntil(
          Model.currentContext,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } else if (result['status'] == 'invalid') {
      print('Invalid request');
      BLoC.snackMsg(Model.currentContext, "Invalid request");
    }
    Model.socketNotifier.removeListener(getNotificationsEvent);
  }
}

getDetailsEvent() {
  Map<String, dynamic> result = Model.socketResult;
  if (result['intro'] == 'detailproc') {
    Navigator.pop(Model.currentContext);
    result = result['result'];
    print(result);
    if (result['status'] == 'valid') {
      print('Orders retrieved successfully');

      Navigator.push(
        Model.currentContext,
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
      BLoC.snackMsg(Model.currentContext, "hack attempt failed");
      Navigator.pushAndRemoveUntil(
          Model.currentContext,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } else if (result['status'] == 'invalid') {
      print('Invalid request');
      BLoC.snackMsg(Model.currentContext, "Invalid request");
    }
    Model.socketNotifier.removeListener(getDetailsEvent);
  }
}

getSettingsEvent() {
  Map<String, dynamic> result = Model.socketResult;
  if (result['intro'] == 'getsettings') {
    Navigator.pop(Model.currentContext);
    result = result['result'];
    print(result);
    if (result['status'] == 'valid') {
      print('Settings retrieved successfully');

      Navigator.push(
        Model.currentContext,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              ProfileSetting(result['settings'], result['planner']),
        ),
      );
    } else if (result['status'] == 'hacker') {
      print('hack attempt failed');
      BLoC.snackMsg(Model.currentContext, "hack attempt failed");
      Navigator.pushAndRemoveUntil(
          Model.currentContext,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } else if (result['status'] == 'invalid') {
      print('Invalid request');
      BLoC.snackMsg(Model.currentContext, "Invalid request");
    }
    Model.socketNotifier.removeListener(getSettingsEvent);
  }
}

chatHistoryEvent() {
  Map<String, dynamic> result = Model.socketResult;
  if (result['intro'] == 'chathistory') {
    Navigator.pop(Model.currentContext);
    result = result['result'];
    print(result);
    if (result['status'] == 'valid') {
      print('Chat History retrieved');

      Model.chatData = result;
      Model.chatBuddies = result['profiles'];
      int i = 0;
      Model.members = [];
      Model.memberOnlineStatus = {};
      for (var user in result['profiles']) {
        Model.memberOnlineStatus[user[0]] = [
          result['onlineStatus'][i],
          result['last_seen'][i],
          result['last_messages'][i]
        ];
        Model.members.add(user[0]);
        /*Model.memberOnlineStatus= {'user':[result['online'][i],
            result['last_seen'][i],result['last_message'][i]]} */
        //last_messages= [[get, ik, 11:06 PM, 03-Feb-2022, saeea]]
        i++;
      }
      Model.numOfRespondents = (Model.chatData['profiles']).length;
      Navigator.push(
        Model.currentContext,
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
      BLoC.snackMsg(Model.currentContext, "hack attempt failed");
      Navigator.pushAndRemoveUntil(
          Model.currentContext,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } else if (result['status'] == 'invalid') {
      print('Invalid request');
      BLoC.snackMsg(Model.currentContext, "Invalid request");
    }
    Model.socketNotifier.removeListener(chatHistoryEvent);
  }
}

sendOTPEvent() {
  Map<String, dynamic> result = Model.socketResult;
  if (result['intro'] == 'genOtp') {
    Navigator.pop(Model.currentContext);

    print(result);
    result = result['result'];
    if (result['status'] == 'sent') {
      print('Email Sent');
      BLoC.snackMsg(Model.currentContext, "Email Sent");
      // setState(() {
      verifyEmail = true;
      //});
      int x = reloadPage.value + 1;
      reloadPage.value = x;
    } else if (result['status'] == 'hacker') {
      print('hack attempt failed');
      BLoC.snackMsg(Model.currentContext, "hack attempt failed");
      Navigator.pushAndRemoveUntil(
          Model.currentContext,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    }
    Model.socketNotifier.removeListener(sendOTPEvent);
  }
}

verifyOTPEvent() {
  Map<String, dynamic> result = Model.socketResult;
  if (result['intro'] == 'verifyOtp') {
    Navigator.pop(Model.currentContext);
    print(result);
    result = result['result'];
    if (result['status'] == 'verified') {
      print('Email Sent');
      BLoC.snackMsg(Model.currentContext, "Verification successfull");
      Model.emailVerified = true;
      BLoC.reloadHome();
    } else if (result['status'] == 'hacker') {
      print('hack attempt failed');
      BLoC.snackMsg(Model.currentContext, "hack attempt failed");
      Navigator.pushAndRemoveUntil(
          Model.currentContext,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } else if (result['status'] == 'invalid') {
      print('invalid otp');
      BLoC.snackMsg(Model.currentContext, "Invalid OTP");
    }
    Model.socketNotifier.removeListener(verifyOTPEvent);
  }
}

updateLastSeenEvent() {
  print('updated last seen');
  Map<String, dynamic> result = Model.socketResult;
  if (result['intro'] == 'updateLastSeen') {
    result = result['result'];
    if (result['status'] == 'hacker') {
      print('Sorry, you could not hack us');
    } else if (result['status'] == 'valid') {
      print('Last Seen updated');
    } //Model.socketNotifier.removeListener(liste);
  }
}

getNotifications() {
  var address = Uri.parse(Model.domain + 'getunclicked');

  var content = {
    "intro": "getunclicked",
    'username': Model.username,
    'sessionid': Model.sessionToken,
  };

  print('getunclicked called... content passed');

  print(address);
  print(content);
  BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);

  /* liste() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'getunclicked') {
      Navigator.pop(Model.currentContext);
      result = result['result'];
      print(result);
      if (result['status'] == 'valid') {
        print('Notifications retrieved successfully');

        Navigator.push(
          Model.currentContext,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                Notifications(result['unclicked']),
          ),
        );
      } else if (result['status'] == 'hacker') {
        print('hack attempt failed');
        BLoC.snackMsg(Model.currentContext, "hack attempt failed");
        Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      } else if (result['status'] == 'invalid') {
        print('Invalid request');
        BLoC.snackMsg(Model.currentContext, "Invalid request");
      }
      Model.socketNotifier.removeListener(liste);
    }
  } */

  Model.socketNotifier.addListener(getNotificationsEvent);
}

reload() {
  return Future.delayed(
      Duration(
        seconds: 1,
      ), () {
    BLoC.reloadHome();
  });
}

getDetails(var trnxid) {
  var address = Uri.parse(Model.domain + 'detailproc');

  var content = {
    "intro": "detailproc",
    'trnxid': trnxid.toString(),
    'username': Model.username,
    'sessionid': Model.sessionToken,
  };

  print('detailproc called... content passed');

  print(address);
  print(content);
  BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);

  /* liste() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'detailproc') {
      Navigator.pop(Model.currentContext);
      result = result['result'];
      print(result);
      if (result['status'] == 'valid') {
        print('Orders retrieved successfully');

        Navigator.push(
          Model.currentContext,
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
        BLoC.snackMsg(Model.currentContext, "hack attempt failed");
        Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      } else if (result['status'] == 'invalid') {
        print('Invalid request');
        BLoC.snackMsg(Model.currentContext, "Invalid request");
      }
      Model.socketNotifier.removeListener(liste);
    }
  } */

  Model.socketNotifier.addListener(getDetailsEvent);
}

getSettings() {
  var address = Uri.parse(Model.domain + 'getsettings');

  var content = {
    'intro': 'getsettings',
    'username': Model.username,
    'sessionid': Model.sessionToken,
  };

  print('getsettings called... content passed');

  print(address);
  print(content);
  BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);

  /* liste() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'getsettings') {
      Navigator.pop(Model.currentContext);
      result = result['result'];
      print(result);
      if (result['status'] == 'valid') {
        print('Settings retrieved successfully');

        Navigator.push(
          Model.currentContext,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                ProfileSetting(result['settings'], result['planner']),
          ),
        );
      } else if (result['status'] == 'hacker') {
        print('hack attempt failed');
        BLoC.snackMsg(Model.currentContext, "hack attempt failed");
        Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      } else if (result['status'] == 'invalid') {
        print('Invalid request');
        BLoC.snackMsg(Model.currentContext, "Invalid request");
      }
      Model.socketNotifier.removeListener(liste);
    }
  }
 */
  Model.socketNotifier.addListener(getSettingsEvent);
}

chatHistory() {
  var address = Uri.parse(Model.domain + 'chathistory');

  var content = {
    'intro': 'chathistory',
    'username': Model.username,
    'sessionid': Model.sessionToken,
  };

  print('chathistory called... content passed');

  print(address);
  print(content);
  BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);

  /*  liste() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'chathistory') {
      Navigator.pop(Model.currentContext);
      result = result['result'];
      print(result);
      if (result['status'] == 'valid') {
        print('Chat History retrieved');

        Model.chatData = result;
        Model.chatBuddies = result['profiles'];
        int i = 0;
        Model.members = [];
        Model.memberOnlineStatus = {};
        for (var user in result['profiles']) {
          Model.memberOnlineStatus[user[0]] = [
            result['onlineStatus'][i],
            result['last_seen'][i],
            result['last_messages'][i]
          ];
          Model.members.add(user[0]);
          /*Model.memberOnlineStatus= {'user':[result['online'][i],
            result['last_seen'][i],result['last_message'][i]]} */
          //last_messages= [[get, ik, 11:06 PM, 03-Feb-2022, saeea]]
          i++;
        }
        Model.numOfRespondents = (Model.chatData['profiles']).length;
        Navigator.push(
          Model.currentContext,
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
        BLoC.snackMsg(Model.currentContext, "hack attempt failed");
        Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      } else if (result['status'] == 'invalid') {
        print('Invalid request');
        BLoC.snackMsg(Model.currentContext, "Invalid request");
      }
      Model.socketNotifier.removeListener(liste);
    }
  } */

  Model.socketNotifier.addListener(chatHistoryEvent);
}

reRoute(String direction) {
  print('reroute called');
  if (direction == 'setting') {
    getSettings();
  } else if (direction == 'chat') {
    chatHistory();
  } else if (direction == 'logout') {
    BLoC.logout(Model.currentContext);
  }
}

sendOTP() {
  var address = Uri.parse(Model.domain + 'genOtp');

  var content = {
    'intro': 'genOtp',
    'subject': 'Email Verification Code',
    'username': Model.username,
    'sessionid': Model.sessionToken,
  };

  print('sendOTP called... content passed');

  print(address);
  print(content);
  BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);

  /* liste() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'genOtp') {
      Navigator.pop(Model.currentContext);

      print(result);
      result = result['result'];
      if (result['status'] == 'sent') {
        print('Email Sent');
        BLoC.snackMsg(Model.currentContext, "Email Sent");
        setState(() {
          verifyEmail = true;
        });
      } else if (result['status'] == 'hacker') {
        print('hack attempt failed');
        BLoC.snackMsg(Model.currentContext, "hack attempt failed");
        Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      }
      Model.socketNotifier.removeListener(liste);
    }
  } */

  Model.socketNotifier.addListener(sendOTPEvent);
}

verifyOTP() {
  var address = Uri.parse(Model.domain + 'verifyOtp');

  var content = {
    'intro': 'verifyOtp',
    'otp': otp,
    'username': Model.username,
    'sessionid': Model.sessionToken,
  };

  print('verifyOTP called... content passed');

  print(address);
  print(content);
  BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);

  /* liste() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'verifyOtp') {
      Navigator.pop(Model.currentContext);
      print(result);
      result = result['result'];
      if (result['status'] == 'verified') {
        print('Email Sent');
        BLoC.snackMsg(Model.currentContext, "Verification successfull");
        Model.emailVerified = true;
        BLoC.reloadHome();
      } else if (result['status'] == 'hacker') {
        print('hack attempt failed');
        BLoC.snackMsg(Model.currentContext, "hack attempt failed");
        Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      } else if (result['status'] == 'invalid') {
        print('invalid otp');
        BLoC.snackMsg(Model.currentContext, "Invalid OTP");
      }
      Model.socketNotifier.removeListener(liste);
    }
  } */

  Model.socketNotifier.addListener(verifyOTPEvent);
}

updateLastSeen() {
  //var address = Uri.parse(Model.domain + 'updateLastSeen');
  var content = {
    'intro': 'updateLastSeen',
    'username': Model.username,
    'sessionid': Model.sessionToken,
  };

  BLoC.sendMsg(content);
/* 
  liste() {
    print('updated last seen');
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'updateLastSeen') {
      result = result['result'];
      if (result['status'] == 'hacker') {
        print('Sorry, you could not hack us');
      } else if (result['status'] == 'valid') {
        print('Last Seen updated');
      } //Model.socketNotifier.removeListener(liste);
    }
  } */

  Model.socketNotifier.addListener(updateLastSeenEvent);
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
                          context: Model.currentContext,
                          builder: (BuildContext contxt) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Image.network(
                                    //reviewer's profile picture

                                    (picsList[indx].isNotEmpty)
                                        ? Model.domain +
                                            'img/' +
                                            picsList[indx][0][0]
                                        : Model.domain + 'img/' + 'default.png',
                                    height:
                                        (Model.deviceWidth > Model.mobileWidth)
                                            ? Model.deviceHeight * 0.8
                                            : Model.deviceWidth * 0.8,
                                    width:
                                        (Model.deviceWidth > Model.mobileWidth)
                                            ? Model.deviceHeight * 0.7
                                            : Model.deviceWidth * 0.8,
                                  ),
                                ),
                              ],
                            );
                          }),
                      //padding: EdgeInsets.only(left: 5, top: 5),
                      child: FadeInImage.assetNetwork(
                        placeholder: "assets/images/imgloading.gif",
                        image: (picsList[count].isNotEmpty)
                            ? Model.domain + 'img/' + picsList[count][0][0]
                            : Model.domain + 'img/' + 'default.png',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        //event_type
                        Container(
                          constraints:
                              BoxConstraints(minWidth: Model.deviceWidth * 0.4),
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
                          BoxConstraints(maxWidth: Model.deviceWidth * 0.6),
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
  } else if (itemList.isEmpty) {
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
}
