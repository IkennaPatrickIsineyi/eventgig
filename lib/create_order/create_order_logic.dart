// ignore_for_file: library_prefixes, avoid_print

import 'package:experi/available_planners/available_planners_logic.dart';
import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart' as BLoC;

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
    Model.orderDetailList = [
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
      "sessionid": Model.sessionToken,
      "username": Model.username,
      "budget": budget,
    };

    Uri address = Uri.parse(Model.domain + "ordproc");
    print(address);
    print(content);

    BLoC.showProgressIndicator();

    BLoC.sendMsg(content);

    liste() {
      Map<String, dynamic> result = Model.socketResult;
      if (result['intro'] == 'ordproc') {
        Navigator.pop(Model.currentContext);
        requestResult(result['result']);
        Model.socketNotifier.removeListener(liste);
      }
    }

    Model.socketNotifier.addListener(liste);
  }
}

requestResult(result) {
  if (result['hit'] == 'no') {
    print('hit: no');
    BLoC.nullInputDialog(
        "Sorry, no event planners at the moment...Keep retrying",
        'Unavailable');
  } else if (result['hit'] == 'yes') {
    print('hit: yes. Number of planners: ' + result['qty'].toString());
    print(result['showroom']);
    print(result['available']);

    /*  setState(() { */
    AvailablePlannersLogic.setter(
      planners: result['available'],
      showrooms: result['showroom'],
      budget: result['budget'],
    );
    Navigator.pushNamed(Model.currentContext, '/available_planners')
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
}
