// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, avoid_print, library_prefixes, prefer_const_declarations

import 'package:experi/model.dart';
import 'package:flutter/material.dart';
import 'package:experi/BLoC.dart' as BLoC;

class AvailablePlannersLogic {
  // call setter method to initialise the static variables
  static late List planners;
  static late final List showrooms;
  static late final double budget;
  static late final bool showplanner;

  static late final List reviews;
  static late final List details;
  static late final List clientPics;
  static late final List currentShowroom;
  static late final String planner;
  static late final String dateCreated;
  static late final double fee;
  static late final bool directCall;

  //var callHome = false;
  var _pics;

  static setter(
      {String planner = "",
      List showrooms = const [],
      double budget = 0,
      bool showplanner = false,
      List reviews = const [],
      List details = const [],
      List clientPics = const [],
      List currentShowroom = const [],
      List planners = const [],
      String dateCreated = "",
      double fee = 0,
      bool directCall = false}) {
    AvailablePlannersLogic.planners = planners;
    AvailablePlannersLogic.showrooms = showrooms;
    AvailablePlannersLogic.budget = budget;
    AvailablePlannersLogic.showplanner = showplanner;
    AvailablePlannersLogic.reviews = reviews;
    AvailablePlannersLogic.details = details;
    AvailablePlannersLogic.clientPics = clientPics;
    AvailablePlannersLogic.currentShowroom = currentShowroom;
    AvailablePlannersLogic.planner = planner;
    AvailablePlannersLogic.dateCreated = dateCreated;
    AvailablePlannersLogic.fee = fee;
    AvailablePlannersLogic.directCall = directCall;
  }

  getPlannerDetailsEvent() {
    Map<String, dynamic> res = Model.socketResult;
    if (res['intro'] == 'plannerdetails') {
      Navigator.pop(Model.currentContext);

      res = res['result'];
      reviews = res['reviews'];
      currentShowroom = _pics;
      showplanner = true;
      // fee= _fee.toDouble(),
      //problematic must be a number not smi
      details = res['details'];
      clientPics = res['client_pics'];
      //  planner= _planner,
      // dateCreated= _dateCreated

      Navigator.pushNamed(Model.currentContext, '/available_planners')
          .then((value) {
        //remove/pop dialog's context from stack since the dialog has been popped
        if (Model.contextQueue.isNotEmpty) {
          Model.contextQueue.removeLast();

          //set current context variable to the next context on the stack
          Model.currentContext = Model.contextQueue.last;
        }
      });

      Model.socketNotifier.removeListener(getPlannerDetailsEvent);
    }
  }

  hirePlannerEvent() {
    Map<String, dynamic> result = Model.socketResult;
    if (result['intro'] == 'hireproc') {
      Navigator.pop(Model.currentContext);
      result = result['result'];
      print(result);
      if (result['status'] == 'not available') {
        print('Sorry, the planner is no longer available');
        BLoC.snackMsg(
            Model.currentContext, "Sorry, the planner is no longer available");
      } else if (result['status'] == 'available') {
        print('Order placed successfully');
        BLoC.snackMsg(Model.currentContext, "Order Placed");
        BLoC.reloadHome();
      } else if (result['status'] == 'hacker') {
        print('hack attempt failed');
        BLoC.logout();
        //snackMsg(context, "hack attempt failed");
      }
      Model.socketNotifier.removeListener(hirePlannerEvent);
    }
  }

  getPlannerDetails(item, starWidget, pics) {
    // var address = Uri.parse(Model.domain + 'plannerdetails');
    var content = {
      'intro': 'plannerdetails',
      'username': Model.username,
      'planner': item[0],
      'sessionid': Model.sessionToken,
    };
    //  _dateCreated = item[4];
    //  _fee = item[3];
    _pics = pics;
    // _planner = item[0];

    BLoC.showProgressIndicator();

    BLoC.sendMsg(content);

    Model.socketNotifier.addListener(getPlannerDetailsEvent);
  }

  hirePlanner(fee, budget, planner) {
    print('hireplanner called... url being loaded');

    var address = Uri.parse(Model.domain + 'hireproc');

    print('hireplanner called... url finally loaded');

    var content = {
      'intro': 'hireproc',
      'street': Model.orderDetailList[0],
      'city': Model.orderDetailList[1],
      'state': Model.orderDetailList[2],
      'country': Model.orderDetailList[3],
      'date': Model.orderDetailList[4],
      'type': Model.orderDetailList[5],
      'budget': Model.orderDetailList[6].toString(),
      'note': Model.orderDetailList[7],
      'fee': (fee * budget * 0.01).toString(),
      'username': Model.username,
      'planner': planner,
      'sessionid': Model.sessionToken,
    };

    print('hireplanner called... content passed');

    print(address);
    print(content);
    BLoC.showProgressIndicator();

    BLoC.sendMsg(content);

    Model.socketNotifier.addListener(hirePlannerEvent);
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
}
