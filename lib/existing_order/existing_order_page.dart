// ignore_for_file: no_logic_in_create_state, prefer_const_constructors, library_prefixes, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, avoid_print, deprecated_member_use, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:experi/existing_order/existing_order_logic.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart' as BLoC;

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

  @override
  Widget build(BuildContext context) {
    print('existing order called...');
    Model.currentRoute = "ExixtingOrderDetailPage";

    Model.prefs.setString("currentRoute", "ExixtingOrderDetailPage");
    if (ratePlanner == false) {
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
                        timeCreated,
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
                        (Model.username == planner) ? "Client" : "Planner",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        (Model.username == planner) ? client : planner,
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
                        eventDate,
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
                        street,
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
                        city,
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
                        state,
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
                        country,
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
                        eventType,
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
                        budget,
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
                        fee.toString(),
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
                        note,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (status == "completed")
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
                        starBuilder(rating),
                      ],
                    ),
                  ),
                if (status == "completed")
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
                          comment,
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
                      if (status == "pending" && Model.username == planner)
                        ElevatedButton(
                          onPressed: () {
                            print('accept order');
                            acceptOrder(trnxid);
                          },
                          child: Text("Accept"),
                        ),
                      if (status == "pending" && Model.username == planner)
                        ElevatedButton(
                          onPressed: () {
                            print('reject order');
                            rejectOrder(trnxid);
                            //(courier == Model.username) ? confirmOrder : getOtp,
                          },
                          child: Text("Reject"),
                        ),
                      if (status == "scheduled" && Model.username == client)
                        ElevatedButton(
                          onPressed: () {
                            print('Finish event');
                            setState(() {
                              ratePlanner = true;
                            });
                            //(courier == Model.username) ? confirmOrder : getOtp,
                          },
                          child: Text("Finish"),
                        ),
                      if (status == "scheduled" && Model.username == client)
                        ElevatedButton(
                          onPressed: () {
                            print('Cancel event');
                            cancelEvent(trnxid);
                            //(courier == Model.username) ? confirmOrder : getOtp,
                          },
                          child: Text("Cancel"),
                        ),
                      if (status == "pending" && Model.username == planner)
                        ElevatedButton(
                          onPressed: () {
                            print('Chat');
                            fetchChats(planner, client);
                            //(courier == Model.username) ? confirmOrder : getOtp,
                          },
                          child: Text("Chat"),
                        )
                      else if (status == "scheduled")
                        ElevatedButton(
                          onPressed: () {
                            print('Chat');
                            fetchChats(planner, client);
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
                          } else {
                            return null;
                          }
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
                    if (pos <= 0) {
                      BLoC.nullInputDialog(context,
                          "Rate the user on a scale of 5", "Rating missing");
                    }
                    if (pos > 0 && review.isNotEmpty) {
                      submitRating(review, pos, trnxid);
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
