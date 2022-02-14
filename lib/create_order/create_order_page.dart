// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_prefixes, use_key_in_widget_constructors, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:experi/create_order/create_order_logic.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart' as BLoC;

class CreateOrderPage extends StatefulWidget {
  @override
  State<CreateOrderPage> createState() => _CreateOrderPage();
}

class _CreateOrderPage extends State<CreateOrderPage> {
  @override
  Widget build(BuildContext context) {
    Model.currentRoute = "CreateOrderPage";
    Model.prefs.setString("currentRoute", "CreateOrderPage");
    String dateLabel = "Select Event Date";

    var eventTypeItems = [
      "Select Event Type",
      "birthday",
      "wedding",
      "house warming",
      "school event",
      "peagent",
      "seminar",
      "burial",
      "others",
    ];

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
              "Event data",
              style: TextStyle(fontSize: 12),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: (Model.deviceWidth > Model.mobileWidth)
                ? Model.deviceWidth * 0.6
                : Model.deviceWidth * 0.9,
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Divider(),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                    color: Colors.grey[300],
                  ),
                  padding: EdgeInsets.only(left: 5),
                  child: DropdownButton(
                    value: eventType,
                    onChanged: (var input) {
                      setState(() {
                        eventType = input as String;
                      });
                    },
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                    isDense: true,
                    alignment: AlignmentDirectional.center,
                    items: eventTypeItems.map((var item) {
                      return DropdownMenuItem(
                        child: Container(
                          decoration: (item != "Select Event Type")
                              ? BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                )
                              : BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  color: Colors.white,
                                ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.event,
                                color: Colors.red,
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                ),
                                child: Text(item),
                              )
                            ],
                          ),
                        ),
                        value: item,
                      );
                    }).toList(),
                  ),
                ),
                Divider(),
                ValueListenableBuilder(
                  valueListenable: textValidator,
                  builder: (BuildContext context, Set value1, Widget? child) {
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextFormField(
                        onChanged: (input) {
                          country = input;
                          value1.remove(1);
                          currentField.add(1);
                        },
                        decoration: InputDecoration(
                          labelText: "Venue Country",
                          hintText: "Enter venue's country",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.home,
                            color: Colors.red,
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.always,
                        validator: (value) {
                          if (value1.contains(1)) {
                            return "* required";
                          } else {
                            return null;
                          }
                        },
                      ),
                    );
                  },
                ),
                Divider(),
                ValueListenableBuilder(
                  valueListenable: textValidator,
                  builder: (BuildContext context, Set value1, Widget? child) {
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextFormField(
                        onChanged: (input) {
                          state = input;
                          value1.remove(2);
                          currentField.add(2);
                        },
                        decoration: InputDecoration(
                          labelText: "Venue State",
                          hintText: "Enter venue's state",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.home,
                            color: Colors.red,
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.always,
                        validator: (value) {
                          if (value1.contains(2)) {
                            return "* required";
                          } else {
                            return null;
                          }
                        },
                      ),
                    );
                  },
                ),
                Divider(),
                ElevatedButton.icon(
                  label: ValueListenableBuilder(
                      valueListenable: dateNotifier,
                      builder:
                          (BuildContext context, int value1, Widget? child) {
                        return Text(dateLabel);
                      }),
                  icon: Icon(
                    Icons.calendar_today,
                    // color: Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: SizedBox(
                              width: (Model.deviceWidth > Model.mobileWidth)
                                  ? Model.deviceWidth * 0.6
                                  : Model.deviceWidth * 0.8,
                              child: CalendarDatePicker(
                                initialDate: choosenDate,
                                firstDate: DateTime(
                                  2021,
                                ),
                                lastDate: DateTime(2050),
                                onDateChanged: (value) {
                                  String year = value
                                      .toLocal()
                                      .toString()
                                      .substring(0, 4);
                                  String day = value
                                      .toLocal()
                                      .toString()
                                      .substring(8, 10);
                                  String month = value
                                      .toLocal()
                                      .toString()
                                      .substring(5, 7);
                                  List monthNum = [
                                    '01',
                                    '02',
                                    '03',
                                    '04',
                                    '05',
                                    '06',
                                    '07',
                                    '08',
                                    '09',
                                    '10',
                                    '11',
                                    '12'
                                  ];
                                  List monthAlpha = [
                                    'Jan',
                                    'Feb',
                                    'Mar',
                                    'Apr',
                                    'May',
                                    'Jun',
                                    'Jul',
                                    'Aug',
                                    'Sep',
                                    'Oct',
                                    'Nov',
                                    'Dec'
                                  ];

                                  month = monthAlpha[monthNum.indexOf(month)];

                                  print(year);
                                  print(day);
                                  print(month);

                                  eventDate = day + '-' + month + '-' + year;
                                  print(eventDate);
                                  choosenDate = value;
                                  dateLabel = eventDate;

                                  dateNotifier.value++;
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        });
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                    ),
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size.fromWidth(
                        (Model.deviceWidth > Model.mobileWidth)
                            ? Model.deviceWidth * 0.4
                            : Model.deviceWidth * 0.7,
                      ),
                    ),
                  ),
                ),
                Divider(),
                ValueListenableBuilder(
                  valueListenable: textValidator,
                  builder: (BuildContext context, Set value1, Widget? child) {
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextFormField(
                        onChanged: (input) {
                          city = input;
                          value1.remove(3);
                          currentField.add(3);
                        },
                        decoration: InputDecoration(
                          labelText: "Venue City",
                          hintText: "Enter venue's city",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.home,
                            color: Colors.red,
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.always,
                        validator: (value) {
                          if (value1.contains(3)) {
                            return "* required";
                          } else {
                            return null;
                          }
                        },
                      ),
                    );
                  },
                ),
                Divider(),
                ValueListenableBuilder(
                  valueListenable: textValidator,
                  builder: (BuildContext context, Set value1, Widget? child) {
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextFormField(
                        onChanged: (input) {
                          street = input;
                          value1.remove(4);
                          currentField.add(4);
                        },
                        decoration: InputDecoration(
                          labelText: "Venue Street",
                          hintText: "Enter venue's street",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.home,
                            color: Colors.red,
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.always,
                        validator: (value) {
                          if (value1.contains(4)) {
                            return "* required";
                          } else {
                            return null;
                          }
                        },
                      ),
                    );
                  },
                ),
                Divider(),
                ValueListenableBuilder(
                  valueListenable: textValidator,
                  builder: (BuildContext context, Set value1, Widget? child) {
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextFormField(
                        onChanged: (input) {
                          budget = input;
                          print(budget);
                          value1.remove(5);
                          currentField.add(5);
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Budget (Naira)",
                          hintText: "Enter your budget",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.money,
                            color: Colors.red,
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.always,
                        validator: (value) {
                          if (value1.contains(5)) {
                            //budget = "";
                            return "* required";
                          } else if (value!.contains(RegExp(r"(\D)")) &&
                              currentField.contains(5)) {
                            // budget = "";
                            return "Budget must be number";
                          } else {
                            return null;
                          }
                        },
                      ),
                    );
                  },
                ),
                Divider(),
                ValueListenableBuilder(
                  valueListenable: textValidator,
                  builder: (BuildContext context, Set value1, Widget? child) {
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextFormField(
                        onChanged: (input) {
                          note = input;
                          value1.remove(6);
                          currentField.add(6);
                        },
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "Briefly describe the event...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.note,
                            color: Colors.red,
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.always,
                        validator: (value) {
                          if (value1.contains(6)) {
                            return "* required";
                          } else {
                            return null;
                          }
                        },
                      ),
                    );
                  },
                ),
                Divider(),
                Divider(),
                ElevatedButton.icon(
                  onPressed: () {
                    print(budget);
                    textValidator.value = {};
                    if (country.isEmpty) textValidator.value.add(1);
                    if (state.isEmpty) textValidator.value.add(2);
                    if (city.isEmpty) textValidator.value.add(3);
                    if (street.isEmpty) textValidator.value.add(4);
                    if (budget.isEmpty) textValidator.value.add(5);
                    if (note.isEmpty) textValidator.value.add(6);

                    if (eventType == "Select Event Type") {
                      BLoC.nullInputDialog(
                          context, "Select event type", "Event type missing");
                    } else if (eventDate.isEmpty) {
                      BLoC.nullInputDialog(
                          context, "Select event date", "Event date missing");
                    }

                    if (city.isNotEmpty &&
                        street.isNotEmpty &&
                        eventType != "Select Event Type" &&
                        note.isNotEmpty &&
                        state.isNotEmpty &&
                        country.isNotEmpty &&
                        eventDate.isNotEmpty &&
                        budget.isNotEmpty) {
                      findPlanner();
                    }
                  },
                  icon: Icon(Icons.search),
                  label: Text("Find Planner"),
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size.fromWidth(
                        (Model.deviceWidth > Model.mobileWidth)
                            ? Model.deviceWidth * 0.4
                            : Model.deviceWidth * 0.7,
                      ),
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
