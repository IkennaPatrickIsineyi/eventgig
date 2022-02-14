// ignore_for_file: prefer_const_constructors, library_prefixes, avoid_print

import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart' as BLoC;
import 'package:experi/login/loginpage.dart';
import 'package:experi/chat/chatroom_page.dart';

ValueNotifier<int> textValidator = ValueNotifier<int>(0);

bool confirmed = false;
bool userRated = false;
String theReport = "";

bool ratePlanner = false;

int pos = 0;
String review = '';
String _receiver = '';

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

submitRatingEvent() {
  Map<String, dynamic> result = Model.socketResult;
  if (result['intro'] == 'finish') {
    Navigator.pop(Model.currentContext);
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
      print('Review successful');
      BLoC.snackMsg(Model.currentContext, "Review Successful. Thanks!");
      BLoC.reloadHome();
      /* Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => ReloadHomePage(),
            ),
            (route) => false); */
    }
    Model.socketNotifier.removeListener(submitRatingEvent);
  }
}

acceptOrderEvent() {
  Map<String, dynamic> result = Model.socketResult;
  if (result['intro'] == 'accptjobproc') {
    Navigator.pop(Model.currentContext);

    result = result['result'];
    if (result['status'] == 'hacker') {
      print('Sorry, you could not hack us');
      BLoC.logout(Model.currentContext);
    } else if (result['status'] == 'valid') {
      print('Accept successful');
      BLoC.reloadHome();
    }
    Model.socketNotifier.removeListener(acceptOrderEvent);
  }
}

rejectOrderEvent() {
  Map<String, dynamic> result = Model.socketResult;
  if (result['intro'] == 'rejjobproc') {
    Navigator.pop(Model.currentContext);

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
      print('Reject successful');
      BLoC.reloadHome();
    }
    Model.socketNotifier.removeListener(rejectOrderEvent);
  }
}

cancelEventEvent() {
  Map<String, dynamic> result = Model.socketResult;
  if (result['intro'] == 'cancproc') {
    Navigator.pop(Model.currentContext);

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
      print('Cancel successful');
      BLoC.reloadHome();
      /* Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => ReloadHomePage(),
            ),
            (route) => false); */
    }
    Model.socketNotifier.removeListener(cancelEventEvent);
  }
}

fetchChatsEvent() {
  Map<String, dynamic> result = Model.socketResult;
  if (result['intro'] == 'getchats') {
    Navigator.pop(Model.currentContext);

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
      print('Chat fetch successful');
      print(result);
      Model.members = [];
      Model.members.add(_receiver);
      if (!Model.memberOnlineStatus.containsKey(_receiver)) {
        Model.memberOnlineStatus[_receiver] = [];
        //set online status
        Model.memberOnlineStatus[_receiver]!.add(result['onlineStatus'][0]);
        //set last seen
        Model.memberOnlineStatus[_receiver]!.add(result['userProfile'][2]);
        //set last msg
        Model.memberOnlineStatus[_receiver]!.add('');
      }

      //setState(() {
      Navigator.push(
        Model.currentContext,
        MaterialPageRoute(
          builder: (BuildContext context) => Chatroom(
            result['chats'],
            result['userProfile'],
            true,
            "ChatroomSingle",
          ),
        ),
      );
      //  });
    }
    Model.socketNotifier.removeListener(fetchChatsEvent);
  }
}

submitRating(String review, int rating, String trnxid) {
  //var address = Uri.parse(Model.domain + 'finish');
  var content = {
    'intro': 'finish',
    'username': Model.username,
    'rating': rating.toString(),
    'comment': review,
    'trnxid': trnxid,
    'sessionid': Model.sessionToken,
  };

  BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);

  /*  liste() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'finish') {
      Navigator.pop(Model.currentContext);
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
        print('Review successful');
        BLoC.snackMsg(Model.currentContext, "Review Successful. Thanks!");
        BLoC.reloadHome();
        /* Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => ReloadHomePage(),
            ),
            (route) => false); */
      }
      Model.socketNotifier.removeListener(liste);
    }
  }
 */
  Model.socketNotifier.addListener(submitRatingEvent);
}

acceptOrder(String trnxid) {
  //var address = Uri.parse(Model.domain + 'accptjobproc');
  var content = {
    'intro': 'accptjobproc',
    'username': Model.username,
    'trnxid': trnxid,
    'sessionid': Model.sessionToken,
  };

  BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);

/*   liste() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'accptjobproc') {
      Navigator.pop(Model.currentContext);

      result = result['result'];
      if (result['status'] == 'hacker') {
        print('Sorry, you could not hack us');
        BLoC.logout(Model.currentContext);
      } else if (result['status'] == 'valid') {
        print('Accept successful');
        BLoC.reloadHome();
        /*  Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => ReloadHomePage(),
            ),
            (route) => false); */
      }
      Model.socketNotifier.removeListener(liste);
    }
  } */

  Model.socketNotifier.addListener(acceptOrderEvent);
}

rejectOrder(String trnxid) {
  //var address = Uri.parse(Model.domain + 'rejjobproc');
  var content = {
    'intro': 'rejjobproc',
    'username': Model.username,
    'trnxid': trnxid,
    'sessionid': Model.sessionToken,
  };

  BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);
/* 
  liste() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'rejjobproc') {
      Navigator.pop(Model.currentContext);

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
        print('Reject successful');
        BLoC.reloadHome();
        /*  Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => ReloadHomePage(),
            ),
            (route) => false); */
      }
      Model.socketNotifier.removeListener(liste);
    }
  } */

  Model.socketNotifier.addListener(rejectOrderEvent);
}

cancelEvent(String trnxid) {
  // var address = Uri.parse(Model.domain + 'cancproc');
  var content = {
    'intro': 'cancproc',
    'username': Model.username,
    'trnxid': trnxid,
    'sessionid': Model.sessionToken,
  };

  BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);
/* 
  liste() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'cancproc') {
      Navigator.pop(Model.currentContext);

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
        print('Cancel successful');
        BLoC.reloadHome();
        /* Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => ReloadHomePage(),
            ),
            (route) => false); */
      }
      Model.socketNotifier.removeListener(liste);
    }
  } */

  Model.socketNotifier.addListener(cancelEventEvent);
}

fetchChats(String planner, String client) {
  String receiver = (Model.username == planner) ? client : planner;

// var address = Uri.parse(Model.domain + 'getchats');
  var content = {
    'intro': 'getchats',
    'username': Model.username,
    'receiver': receiver,
    'sessionid': Model.sessionToken,
    'nextchatid': '0'
  };

  _receiver = receiver;
  BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);

  /* liste() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'getchats') {
      Navigator.pop(Model.currentContext);

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
        print('Chat fetch successful');
        print(result);
        Model.members = [];
        Model.members.add(receiver);
        if (!Model.memberOnlineStatus.containsKey(receiver)) {
          Model.memberOnlineStatus[receiver] = [];
          //set online status
          Model.memberOnlineStatus[receiver]!.add(result['onlineStatus'][0]);
          //set last seen
          Model.memberOnlineStatus[receiver]!.add(result['userProfile'][2]);
          //set last msg
          Model.memberOnlineStatus[receiver]!.add('');
        }

        //setState(() {
          Navigator.push(
            Model.currentContext,
            MaterialPageRoute(
              builder: (BuildContext context) => Chatroom(
                result['chats'],
                result['userProfile'],
                true,
                "ChatroomSingle",
              ),
            ),
          );
      //  });
      }
      Model.socketNotifier.removeListener(liste);
    }
  }
 */
  Model.socketNotifier.addListener(fetchChatsEvent);
}