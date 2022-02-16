// ignore_for_file: no_logic_in_create_state, prefer_const_constructors, library_prefixes, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, avoid_print, deprecated_member_use, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:experi/existing_order/existing_order_logic.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart' as BLoC;

class ExixtingOrderDetailPage extends StatefulWidget {
  @override
  State<ExixtingOrderDetailPage> createState() => _ExixtingOrderDetailPage();
}

//Displays the details of an exixting order
class _ExixtingOrderDetailPage extends State<ExixtingOrderDetailPage> {
  final existingOrderLogic = ExistingOrder();
  @override
  Widget build(BuildContext context) {
    print('existing order called...');
    Model.currentRoute = "ExixtingOrderDetailPage";

    Model.prefs.setString("currentRoute", "ExixtingOrderDetailPage");
    if (existingOrderLogic.ratePlanner == false) {
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
                ExistingOrder.status + " Events",
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
                  width: Model.deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date Created",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ExistingOrder.timeCreated,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Model.deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (Model.username == ExistingOrder.planner)
                            ? "Client"
                            : "Planner",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        (Model.username == ExistingOrder.planner)
                            ? ExistingOrder.client
                            : ExistingOrder.planner,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Model.deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Event date",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ExistingOrder.eventDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Model.deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Street",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ExistingOrder.street,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Model.deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "City",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ExistingOrder.city,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Model.deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "State",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ExistingOrder.state,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Model.deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Country",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ExistingOrder.country,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Model.deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Event Type",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ExistingOrder.eventType,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Model.deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Budget",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ExistingOrder.budget,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Model.deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Fee",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ExistingOrder.fee.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Model.deviceWidth * 0.95,
                  color: Colors.black,
                  margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Note",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ExistingOrder.note,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (ExistingOrder.status == "completed")
                  Container(
                    width: Model.deviceWidth * 0.95,
                    color: Colors.black,
                    margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                    padding:
                        EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rating",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        existingOrderLogic.starBuilder(ExistingOrder.rating),
                      ],
                    ),
                  ),
                if (ExistingOrder.status == "completed")
                  Container(
                    width: Model.deviceWidth * 0.95,
                    color: Colors.black,
                    margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                    padding:
                        EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Comment",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          ExistingOrder.comment,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w400,
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
                      if (ExistingOrder.status == "pending" &&
                          Model.username == ExistingOrder.planner)
                        ElevatedButton(
                          onPressed: () {
                            print('accept order');
                            existingOrderLogic
                                .acceptOrder(ExistingOrder.trnxid);
                          },
                          child: Text("Accept"),
                        ),
                      if (ExistingOrder.status == "pending" &&
                          Model.username == ExistingOrder.planner)
                        ElevatedButton(
                          onPressed: () {
                            print('reject order');
                            existingOrderLogic
                                .rejectOrder(ExistingOrder.trnxid);
                            //(courier == Model.username) ? confirmOrder : getOtp,
                          },
                          child: Text("Reject"),
                        ),
                      if (ExistingOrder.status == "scheduled" &&
                          Model.username == ExistingOrder.client)
                        ElevatedButton(
                          onPressed: () {
                            print('Finish event');
                            setState(() {
                              existingOrderLogic.ratePlanner = true;
                            });
                            //(courier == Model.username) ? confirmOrder : getOtp,
                          },
                          child: Text("Finish"),
                        ),
                      if (ExistingOrder.status == "scheduled" &&
                          Model.username == ExistingOrder.client)
                        ElevatedButton(
                          onPressed: () {
                            print('Cancel event');
                            existingOrderLogic
                                .cancelEvent(ExistingOrder.trnxid);
                            //(courier == Model.username) ? confirmOrder : getOtp,
                          },
                          child: Text("Cancel"),
                        ),
                      if (ExistingOrder.status == "pending" &&
                          Model.username == ExistingOrder.planner)
                        ElevatedButton(
                          onPressed: () {
                            print('Chat');
                            existingOrderLogic.fetchChats(
                                ExistingOrder.planner, ExistingOrder.client);
                            //(courier == Model.username) ? confirmOrder : getOtp,
                          },
                          child: Text("Chat"),
                        )
                      else if (ExistingOrder.status == "scheduled")
                        ElevatedButton(
                          onPressed: () {
                            print('Chat');
                            existingOrderLogic.fetchChats(
                                ExistingOrder.planner, ExistingOrder.client);
                            //(courier == Model.username) ? confirmOrder : getOtp,
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
    } else {
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
                (existingOrderLogic.pos == 0)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 1; i <= 5; i++)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  existingOrderLogic.pos = i;
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
                          for (int i = 1; i <= existingOrderLogic.pos; i++)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  existingOrderLogic.pos = i;
                                  print(i);
                                });
                              },
                              icon: Icon(Icons.star_purple500_outlined),
                              color: Colors.orange,
                            ),
                          for (int j = existingOrderLogic.pos; j < 5; j++)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  existingOrderLogic.pos = j + 1;
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
                    valueListenable: existingOrderLogic.textValidator,
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
                          } else {
                            return null;
                          }
                        },
                        onChanged: (input) {
                          existingOrderLogic.review = input;
                          value1 = 0;
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (existingOrderLogic.review.isEmpty)
                      existingOrderLogic.textValidator.value = 1;
                    if (existingOrderLogic.pos <= 0) {
                      BLoC.nullInputDialog(context,
                          "Rate the user on a scale of 5", "Rating missing");
                    }
                    if (existingOrderLogic.pos > 0 &&
                        existingOrderLogic.review.isNotEmpty) {
                      existingOrderLogic.submitRating(existingOrderLogic.review,
                          existingOrderLogic.pos, ExistingOrder.trnxid);
                    }
                  },
                  child: Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
