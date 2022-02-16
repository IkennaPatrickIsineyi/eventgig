// ignore_for_file: prefer_const_constructors, library_prefixes, avoid_print

import 'package:experi/chat/chatroom_logic.dart';
import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart' as BLoC;

class ExistingOrder {
  static late final String client;
  static late final String planner;
  static late final String rGender;
  static late final String timeCreated;
  static late final String eventDate;
  static late final String street;
  static late final String eventType;
  static late final String budget;
  static late final String status;
  static late final String fee;
  static late final String note;
  static late final String trnxid;
  static late final int rating;
  static late final String comment;
  static late final String city;
  static late final String state;
  static late final String country;

  ValueNotifier<int> textValidator = ValueNotifier<int>(0);

  bool confirmed = false;
  bool userRated = false;
  String theReport = "";

  bool ratePlanner = false;

  int pos = 0;
  String review = '';
  String _receiver = '';

  static setter(
    String client,
    String planner,
    String rGender,
    String timeCreated,
    String eventDate,
    String street,
    String eventType,
    String budget,
    String status,
    String fee,
    String note,
    String trnxid,
    int rating,
    String comment,
    String city,
    String state,
    String country,
  ) {
    ExistingOrder.client = client;
    ExistingOrder.planner = planner;
    ExistingOrder.rGender = rGender;
    ExistingOrder.timeCreated = timeCreated;
    ExistingOrder.eventDate = eventDate;
    ExistingOrder.street = street;
    ExistingOrder.eventType = eventType;
    ExistingOrder.budget = budget;
    ExistingOrder.status = status;
    ExistingOrder.fee = fee;
    ExistingOrder.note = note;
    ExistingOrder.trnxid = trnxid;
    ExistingOrder.rating = rating;
    ExistingOrder.comment = comment;
    ExistingOrder.city = city;
    ExistingOrder.state = state;
    ExistingOrder.country = country;
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
        Navigator.pushNamedAndRemoveUntil(
            Model.currentContext, '/loginpage', (route) => false).then((value) {
          //remove/pop dialog's context from stack since the dialog has been popped
          if (Model.contextQueue.isNotEmpty) {
            Model.contextQueue.removeLast();

            //set current context variable to the next context on the stack
            Model.currentContext = Model.contextQueue.last;
          }
        });
      } else if (result['status'] == 'valid') {
        print('Review successful');
        BLoC.snackMsg(Model.currentContext, "Review Successful. Thanks!");
        BLoC.reloadHome();
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
        BLoC.logout();
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
        Navigator.pushNamedAndRemoveUntil(
            Model.currentContext, '/loginpage', (route) => false).then((value) {
          //remove/pop dialog's context from stack since the dialog has been popped
          if (Model.contextQueue.isNotEmpty) {
            Model.contextQueue.removeLast();

            //set current context variable to the next context on the stack
            Model.currentContext = Model.contextQueue.last;
          }
        });
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
        Navigator.pushNamedAndRemoveUntil(
            Model.currentContext, '/loginpage', (route) => false).then((value) {
          //remove/pop dialog's context from stack since the dialog has been popped
          if (Model.contextQueue.isNotEmpty) {
            Model.contextQueue.removeLast();

            //set current context variable to the next context on the stack
            Model.currentContext = Model.contextQueue.last;
          }
        });
      } else if (result['status'] == 'valid') {
        print('Cancel successful');
        BLoC.reloadHome();
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
        Navigator.pushNamedAndRemoveUntil(
            Model.currentContext, '/loginpage', (route) => false).then((value) {
          //remove/pop dialog's context from stack since the dialog has been popped
          if (Model.contextQueue.isNotEmpty) {
            Model.contextQueue.removeLast();

            //set current context variable to the next context on the stack
            Model.currentContext = Model.contextQueue.last;
          }
        });
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

        ChatRoom.setter(
          result['chats'],
          result['userProfile'],
          true,
          "ChatroomSingle",
        );
        Navigator.pushNamed(Model.currentContext, '/chatroom_page')
            .then((value) {
          //remove/pop dialog's context from stack since the dialog has been popped
          if (Model.contextQueue.isNotEmpty) {
            Model.contextQueue.removeLast();

            //set current context variable to the next context on the stack
            Model.currentContext = Model.contextQueue.last;
          }
        });

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

    BLoC.showProgressIndicator();

    BLoC.sendMsg(content);
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

    BLoC.showProgressIndicator();

    BLoC.sendMsg(content);

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

    BLoC.showProgressIndicator();

    BLoC.sendMsg(content);

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

    BLoC.showProgressIndicator();

    BLoC.sendMsg(content);
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
    BLoC.showProgressIndicator();

    BLoC.sendMsg(content);

    Model.socketNotifier.addListener(fetchChatsEvent);
  }
}
