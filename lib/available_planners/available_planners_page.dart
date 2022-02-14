// ignore_for_file: no_logic_in_create_state, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, curly_braces_in_flow_control_structures, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_typing_uninitialized_variables, avoid_unnecessary_containers, deprecated_member_use

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/available_planners/available_planners_logic.dart';

class AvailableCourierPage extends StatefulWidget {
  AvailableCourierPage({
    this.planners = const [],
    this.showrooms = const [],
    this.budget = 0,
    this.showplanner = false,
    this.reviews = const [],
    this.details = const [],
    this.planner = "",
    this.dateCreated = "",
    this.clientPics = const [],
    this.currentShowroom = const [],
    this.fee = 0,
    this.directCall = false,
  });

  final List planners;
  final List showrooms;
  final double budget;
  final bool showplanner;

  final List reviews;
  final List details;
  final List clientPics;
  final List currentShowroom;
  final String planner;
  final String dateCreated;
  final double fee;
  final directCall;

  @override
  _AvailableCourierPage createState() => _AvailableCourierPage(
        planners: planners,
        showrooms: showrooms,
        budget: budget,
        showplanner: showplanner,
        reviews: reviews,
        details: details,
        planner: planner,
        dateCreated: dateCreated,
        clientPics: clientPics,
        currentShowroom: currentShowroom,
        fee: fee,
        directCall: directCall,
      );
}

class _AvailableCourierPage extends State<AvailableCourierPage> {
  _AvailableCourierPage({
    this.planners = const [],
    this.showrooms = const [],
    this.budget = 0,
    this.showplanner = false,
    this.reviews = const [],
    this.details = const [],
    this.planner = "",
    this.dateCreated = "",
    this.clientPics = const [],
    this.currentShowroom = const [],
    this.fee = 0,
    this.directCall = false,
  });

  final List planners;
  final List showrooms;
  final double budget;
  final bool showplanner;

  var callHome = false;
  //var showplanner = false;
  final List reviews;
  final List details;
  final List clientPics;
  final List currentShowroom;
  final String planner;
  final String dateCreated;
  final double fee;
  final bool directCall;

  @override
  Widget build(BuildContext context) {
    print('build called');
    Model.currentRoute = "AvailableCourierPage";
    Model.prefs.setString("currentRoute", "AvailableCourierPage");
    List<Widget> plannerWidgetList = [];
    // Widget courierWidget;
    int count = 0;
    int eventIndex = 2;
    List eventTypes = [
      'Event Planning History',
      'Birthdays: ',
      'Weddings: ',
      'House Warming Parties: ',
      'School Events: ',
      'Peagents: ',
      'Seminars: ',
      'Burials: ',
      'Others: '
    ];

    if (showplanner == false)
      for (List item in planners) {
        print('planner list builder called...');
        Widget starWidget = starBuilder(item[2] as int);
        print('starlist built...');
        List pics = showrooms[count];

        plannerWidgetList.add(
          GestureDetector(
            onTapUp: (value) {
              getPlannerDetails(item, starWidget, pics);
              /* setState(() {
               
              }); */
            },
            child: Container(
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: Border(
                    /* bottom: BorderSide(),
                  top: BorderSide(),
                  right: BorderSide(),
                  left: BorderSide(), */
                    ),
              ),
              margin: EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5, top: 5),
                        height: 50,
                        width: 50,
                        child: ClipOval(
                          child: GestureDetector(
                            onTap: () => showDialog(
                                context: context,
                                builder: (BuildContext contxt) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          child: Image.network(
                                            //planner's profile picture
                                            (item[1].isNotEmpty)
                                                ? Model.domain +
                                                    'img/' +
                                                    item[1]
                                                : Model.domain +
                                                    'img/' +
                                                    'default.png',
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
                            child: FadeInImage.assetNetwork(
                              placeholder: "assets/images/imgloading.gif",
                              image:
                                  //planner's profile picture
                                  (item[1].isNotEmpty)
                                      ? Model.domain + 'img/' + item[1]
                                      : Model.domain + 'img/' + 'default.png',
                              height: (Model.deviceWidth > Model.mobileWidth)
                                  ? Model.deviceHeight * 0.1
                                  : Model.deviceWidth * 0.2,
                              width: (Model.deviceWidth > Model.mobileWidth)
                                  ? Model.deviceHeight * 0.1
                                  : Model.deviceWidth * 0.2,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10, bottom: 10, top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              //username
                              children: [
                                Text(
                                  item[0],
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              //date account was created
                              children: [
                                Text(
                                  item[4],
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              (item[3] * budget * 0.01).toString() + " Naira",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              //average rating
                              children: [
                                starWidget,
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  CarouselSlider(
                    items: (pics.isNotEmpty)
                        ? pics
                            .map(
                              (pic) =>
                                  Image.network(Model.domain + 'img/' + pic[1]),
                            )
                            .toList()
                        : [
                            Image.network(
                                Model.domain + 'img/' + 'default.png'),
                          ],
                    options: CarouselOptions(
                      height: Model.deviceHeight * 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        count++;
      }

    print('scaffold called');
    //courierWidget = Row(children: courierWidgetList);
    if (showplanner == true) {
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
                planner + "'s Profile",
                style: TextStyle(fontSize: 12),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(
              left: 5,
              right: 5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(),
                Container(
                  //padding: EdgeInsets.only(bottom: 5, top: 5),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: ClipOval(
                              child: GestureDetector(
                                onTap: () => showDialog(
                                    context: context,
                                    builder: (BuildContext contxt) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              child: Image.network(
                                                //planner's profile picture
                                                (details[1].isNotEmpty)
                                                    ? Model.domain +
                                                        'img/' +
                                                        details[1]
                                                    : Model.domain +
                                                        'img/' +
                                                        'default.png',
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
                                child: FadeInImage.assetNetwork(
                                  placeholder: "assets/images/imgloading.gif",
                                  image:
                                      //planner's profile picture
                                      (details[1].isNotEmpty)
                                          ? Model.domain + 'img/' + details[1]
                                          : Model.domain +
                                              'img/' +
                                              'default.png',
                                  height:
                                      (Model.deviceWidth > Model.mobileWidth)
                                          ? Model.deviceHeight * 0.1
                                          : Model.deviceWidth * 0.2,
                                  width: (Model.deviceWidth > Model.mobileWidth)
                                      ? Model.deviceHeight * 0.1
                                      : Model.deviceWidth * 0.2,
                                ),
                              ),
                              //  ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  planner,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  dateCreated,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                                starBuilder(details[0] as int),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(),
                Container(
                  child: CarouselSlider(
                    items: (currentShowroom.isNotEmpty)
                        ? currentShowroom
                            .map(
                              (pic) => Container(
                                child: Image.network(
                                    Model.domain + 'img/' + pic[1]),
                              ),
                            )
                            .toList()
                        : [
                            Image.network(
                                Model.domain + 'img/' + 'default.png'),
                          ],
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                  ),
                ),
                Divider(),
                Container(
                  decoration: ShapeDecoration(
                    shape: Border(
                      bottom: BorderSide(),
                      top: BorderSide(),
                      right: BorderSide(),
                      left: BorderSide(),
                    ),
                    color: Colors.black,
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: eventTypes.map((element) {
                      if (eventTypes.indexOf(element) == 0) {
                        return Text(
                          element,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        );
                      }
                      return Text(
                        element + details[eventIndex++].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Divider(),
                Flexible(
                  child: Container(
                    decoration: ShapeDecoration(
                      shape: Border(
                        bottom: BorderSide(),
                        top: BorderSide(),
                        right: BorderSide(),
                        left: BorderSide(),
                      ),
                    ),
                    margin: EdgeInsets.only(
                      // top: 5,
                      left: 2,
                      right: 2,
                      // bottom: 5,
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < reviews.length; i++)
                          Container(
                            decoration: ShapeDecoration(
                              shape: Border(
                                bottom: BorderSide(),
                                top: BorderSide(),
                                right: BorderSide(),
                                left: BorderSide(),
                              ),
                            ),
                            margin: EdgeInsets.only(
                              top: 5,
                              left: 5,
                              bottom: (i == (reviews.length - 1)) ? 5 : 0,
                              right: 5,
                            ),
                            padding: EdgeInsets.only(
                              left: 5,
                              top: 5,
                              bottom: 5,
                            ),
                            //color: Colors.red,
                            //child: ListTile(
                            child: Row(
                              //  mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /* Flexible(
                                  child: */

                                ClipOval(
                                  child: GestureDetector(
                                    onTap: () => showDialog(
                                        context: context,
                                        builder: (BuildContext contxt) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  child: /*  Image.asset(
                                                    "assets/images/passport.jpg", */
                                                      Image.network(
                                                    //reviewer's profile picture
                                                    (clientPics[i].isNotEmpty)
                                                        ? Model.domain +
                                                            'img/' +
                                                            clientPics[i]
                                                        : Model.domain +
                                                            'img/' +
                                                            'default.png',
                                                    height: (Model.deviceWidth >
                                                            Model.mobileWidth)
                                                        ? Model.deviceHeight *
                                                            0.8
                                                        : Model.deviceWidth *
                                                            0.8,
                                                    width: (Model.deviceWidth >
                                                            Model.mobileWidth)
                                                        ? Model.deviceHeight *
                                                            0.8
                                                        : Model.deviceWidth *
                                                            0.8,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                    child: FadeInImage.assetNetwork(
                                      placeholder:
                                          "assets/images/imgloading.gif",
                                      image:
                                          //reviewer's profile picture
                                          (clientPics[i].isNotEmpty)
                                              ? Model.domain +
                                                  'img/' +
                                                  clientPics[i]
                                              : Model.domain +
                                                  'img/' +
                                                  'default.png',
                                      height: (Model.deviceWidth >
                                              Model.mobileWidth)
                                          ? Model.deviceHeight * 0.1
                                          : Model.deviceWidth * 0.1,
                                      width: (Model.deviceWidth >
                                              Model.mobileWidth)
                                          ? Model.deviceHeight * 0.1
                                          : Model.deviceWidth * 0.1,
                                    ),
                                  ),
                                ),
                                //  ),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        //reviewer's username
                                        children: [
                                          Flexible(
                                            child: Container(
                                              child: Text(
                                                reviews[i][0],
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              padding:
                                                  EdgeInsets.only(left: 15),
                                              child: Text(
                                                //date of completion
                                                reviews[i][1],
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        //event type
                                        children: [
                                          Flexible(
                                            child: Container(
                                              child: Text(
                                                reviews[i][2],
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      //rating
                                      Container(
                                        //padding: EdgeInsets.only(left: 10),
                                        child:
                                            starBuilder(reviews[i][3] as int),
                                        //padding: EdgeInsets.only(left: 20),
                                      ),
                                      //),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              padding: EdgeInsets.only(top: 5),
                                              color: Colors.black,
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      Model.deviceWidth * 0.6),
                                              //comment
                                              child: Text(
                                                reviews[i][4],
                                                /* """jgjksdgjkgjkgsdjkgkjdgjkgdjkgjkgjkgjkgjkdsgjkgjkdgjkgjkdg jk
                                                gdjkg dkgjktsd kgjkgdkj kg jkgdjksgk jkjgjkgdjk jkgjkgdkj gj g
                                              kgjkgdkj kj gjkdgjk gjkdgjkgkjg kjgdjkg kgsdgkjhgsd g ihkjgsdjhg
                                                 dhg hkg sdh hdg hhdjg jkgsdjkjgjkgkjgkjgdkgsdkj""", */
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                /*  ],
                  ),
                ), */
                if (directCall == false)
                  Container(
                    child: ElevatedButton(
                      onPressed: () {
                        hirePlanner(fee, budget, planner);
                      },
                      child: Text("Hire $planner"),
                    ),
                  ),
                if (directCall == false) Divider(),
              ],
            ),
          ),
        ),
      );
    }
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
              "Available Event Planners",
              style: TextStyle(fontSize: 12),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.red[100],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: plannerWidgetList,
          ),
        ),
      ),
    );
  }
}
