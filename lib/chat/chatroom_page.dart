// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors, no_logic_in_create_state, library_prefixes, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, avoid_print, deprecated_member_use, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:experi/chatshape.dart';
import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/chat/chatroom_logic.dart';
import 'package:experi/BLoC.dart' as BLoC;

class Chatroom extends StatefulWidget {
  Chatroom(this.allChats, this.userProfile, this.single, this.currentRoute,
      {this.multipleProfiles = const [], this.idOfLastChat = 0});

  final List allChats;
  final List userProfile;
  final bool single;
  final List multipleProfiles;
  final int idOfLastChat;
  final String currentRoute;
  @override
  _Chatroom createState() =>
      _Chatroom(allChats, userProfile, single, currentRoute,
          multipleProfiles: multipleProfiles, idOfLastChat: idOfLastChat);
}

//Allows the user to place an order for courier
class _Chatroom extends State<Chatroom> {
  _Chatroom(this.allChats, this.userProfile, this.single, this.currentRoute,
      {this.multipleProfiles = const [], this.idOfLastChat = 0});

  final List allChats;
  final List userProfile;
  final bool single;
  final List multipleProfiles;
  final int idOfLastChat;
  final String currentRoute;

  @override
  initState() {
    super.initState();
    print('initstate called...');

    if (Model.listener1Added == false) {
      print('adding listener1');
      Model.socketNotifier.addListener(() => listener1());
      Model.listener1Added = true;
    }
    if (Model.listener2Added == false) {
      print('adding listener2');
      Model.pingNotifier.addListener(() => listener2());
      Model.listener2Added = true;
    }

    liste() {
      print('calling fucker...');
      refreshed = true;
      setState(() {});
      print('fucker called...');
      /*   posoNot.removeListener(liste); */
      print('fucker killed...');
    }

    if (currentRoute == "ChatroomSingle") {
      Model.posoNot.removeListener(liste);
      Model.posoNot.addListener(liste);
      Model.singleChats = true;
    } else {
      Model.singleChats = false;
    }

    nextChatid = idOfLastChat;
    if (single == true) {
    } else {}
  }

  @override
  void deactivate() {
    print('deactivated');
    /*  pingNotifier.removeListener(listener2);
    Model.socketNotifier.removeListener(listener1); */
    super.deactivate();
  }

  @override
  dispose() {
    print('disposed');
    if (single == true) {
      //  if (singleChatTimer.isActive) singleChatTimer.cancel();
      //    if (newMessageTimer.isActive) newMessageTimer.cancel();
    } else {
      /* Model.selected.dispose();
      allChatOnlineStatus.dispose(); */
      //    if (allChatTimer.isActive) allChatTimer.cancel();
    }
    /* pingNotifier.removeListener(listener2);
    Model.socketNotifier.removeListener(listener1); */
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //currentRoute = (single == true) ? "ChatroomSingle" : "ChatroomMulti";
    Model.modif = false;
    print("chatroom loaded");

    if (refreshed == false) {
      print("refreshed false");
      Model.prefs.setString("currentRoute", currentRoute);
      Model.chats = allChats;
      refreshed = true;
      /* if(!Model.memberOnlineStatus.containsKey(userProfile[0]) && currentRoute=="ChatroomSingle")
         Model.memberOnlineStatus[userProfile[0]] = [];
        Model.memberOnlineStatus[userProfile[0]]!.add(chatData['profiles']);
            Model.memberOnlineStatus[userProfile[0]]!.add(userProfile[0]['last_seen'][usr]);
      } */
    }

    if (single == true) {
      print("chatroom single");

      print(Model.chats);
      if (Model.chats.isNotEmpty) lastChatId = Model.chats.last[6];
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          brightness: Brightness.dark,
          leadingWidth: 70,
          automaticallyImplyLeading: false,
          leading: Navigator.canPop(context)
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  padding: EdgeInsets.only(left: 8),
                  color: Colors.black,
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Icon(Icons.arrow_back),
                      ),
                      Flexible(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipOval(
                              child: Container(
                                child: FadeInImage.assetNetwork(
                                  placeholder: "assets/images/imgloading.gif",
                                  image: (userProfile[1].isEmpty ||
                                          userProfile[1] == 'None')
                                      ? Model.domain + 'img/' + 'default.png'
                                      : Model.domain + 'img/' + userProfile[1],
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: Model.allChatOnlineStatus,
                              builder: (BuildContext context, int value1,
                                  Widget? child) {
                                print(value1);
                                if (Model.memberOnlineStatus
                                    .containsKey(userProfile[0])) if (Model
                                            .memberOnlineStatus[
                                        userProfile[0]]![0] ==
                                    1) {
                                  return Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Icon(
                                      Icons.circle,
                                      color: Colors.green,
                                      size: 10,
                                    ),
                                  );
                                }
                                return Container(
                                  color: Colors.transparent,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          title: GestureDetector(
            onTap: () => getUserDetails(userProfile[0]),
            child:
                /* Stack(
              children: [ */
                Text(
              userProfile[0],
              //style: TextStyle(fontSize: 12),
            ),
          ),
          actions: [
            ValueListenableBuilder(
              valueListenable: Model.selected,
              builder: (BuildContext context, int value1, Widget? child) {
                // final int instanceId = tileId;

                // print(instanceId);
                print(value1);
                if (selectedChats.isNotEmpty) {
                  return IconButton(
                    onPressed: () {
                      print('delete');
                      deleteChats(selectedChats.toList());
                    },
                    padding: EdgeInsets.only(left: 8),
                    color: Colors.black,
                    icon: Icon(Icons.delete),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.only(
            // top: 5,
            left: 4,
            right: 4,
            // bottom: 10,
          ),
          child: ListView.builder(
            itemCount: Model.chats.length + 1,
            // controller: scrollContr,
            reverse: true,
            itemBuilder: (context, index) {
              print('Model.chats.length: ${Model.chats.length + 1}');
              //  int index = count - 1;
              print("index: $index");
              print('adjustOffset: $adjustOffset');

              if (index >= Model.chats.length - 11 &&
                  adjustOffset == false &&
                  Model.chats.length >= 20) {
                print("refreshing");
                adjustOffset = true;
                fetchMore = true;
                showIndicator.value = true;
                updating = false;
                getChats(userProfile[0]);
                //setState(() {});
                //updating = false;
              }
              if (index == Model.chats.length) {
                return ValueListenableBuilder(
                  valueListenable: showIndicator,
                  builder: (BuildContext context, bool value1, Widget? child) {
                    print("show indicator: $value1");

                    // if(Model.chats.first==chat)
                    if (showIndicator.value == false) {
                      return Container(
                        constraints: BoxConstraints(minHeight: 0, maxHeight: 0),
                      );
                    }
                    return Container(
                      //color: Colors.white,
                      constraints: BoxConstraints(maxHeight: 12),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        color: Colors.blue[900],
                      ),
                      //constraints: BoxConstraints(minHeight: 10, maxHeight: 10),
                    );
                  },
                );
              }

              print("length: ${Model.chats.length + 1}");
              return ValueListenableBuilder(
                valueListenable: Model.selected,
                builder: (BuildContext context, int value1, Widget? child) {
                  print(value1);

                  print('Model.chats.length: ${Model.chats.length + 1}');
                  return GestureDetector(
                    onLongPress: () {
                      if (selectedChats.isEmpty &&
                          !deleted.contains(Model.chats[index][6]) &&
                          Model.chats[index][2] == Model.username)
                      //a user can only select messages sent
                      //by him/her and which have not been deleted.

                      //Longpress should only work if user has not selected
                      //any message. If user has selected any message
                      // the user can select another message by tapping
                      //instead of longpressing it.
                      {
                        selectedChats.add(Model.chats[index][6].hashCode);
                        Model.selected.value++;
                        //The hashcode of chatid of any selected message
                        //must be added to the notifier set. Doing so
                        //would notify all the notifier builders
                        //listening to the notifier to rebuild their members
                      }
                      print(value1);
                    },
                    onTap: () {
                      if (selectedChats
                          .contains(Model.chats[index][6].hashCode))
                      //if this message has already been selected, tapping
                      //the message should unselect it by removing from
                      //the notifier set
                      {
                        selectedChats.remove(Model.chats[index][6].hashCode);
                        int x = Model.selected.value + 1;
                        Model.selected.value = x;
                      } else if (selectedChats.isNotEmpty &&
                          !deleted.contains(Model.chats[index][6]) &&
                          Model.chats[index][2] == Model.username)
                      //if any other message has already been selected
                      //tapping this message would select it by
                      //adding it to the notifier set
                      {
                        //initialisation begin

                        // notifierSet = true;
                        //initialisation end

                        selectedChats.add(Model.chats[index][6].hashCode);
                        Model.selected.value++;
                        //selects this message
                      }
                      print(value1);
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        left:
                            //align the left edge of all messages
                            (Model.username !=
                                    Model.chats[index]
                                        [2] //ie, you are not the sender
                                )
                                ? (Model.chats[(index == Model.chats.length - 1)
                                            ? (index - 1 < 0)
                                                ? index
                                                : index - 1
                                            : index + 1][2] ==
                                        Model.chats[index][2])
                                    ? 10
                                    : 0
                                : 0,
                        right:
                            //align the right edge of all messages
                            (Model.username ==
                                    Model.chats[index]
                                        [2] //ie, you are not the sender
                                )
                                ? (Model.chats[(index == Model.chats.length - 1)
                                            ? (index - 1 < 0)
                                                ? index
                                                : index - 1
                                            : index + 1][2] ==
                                        Model.chats[index][2])
                                    ? 10
                                    : 0
                                : 0,
                        top:
                            //create little gap between successive messages
                            //from the same sender.
                            //However, create much more gap between successive
                            //messages from differnt senders
                            (Model.chats[(index == Model.chats.length - 1)
                                        ? (index - 1 < 0)
                                            ? index
                                            : index - 1
                                        : index + 1][2] !=
                                    Model.chats[index][2])
                                ? 10
                                : 2,
                      ),
                      child: Row(
                        children: [
                          if (!deleted.contains(Model.chats[index][6]))
                            //Do not show messages that the user
                            //has just deleted
                            ClipPath(
                              //clippath gives each message the unique shape
                              clipper: (Model.username != Model.chats[index][2])
                                  //current user is not the sender
                                  ? (Model.chats[
                                              (index == Model.chats.length - 1)
                                                  ? (index - 1 < 0)
                                                      ? index
                                                      : index - 1
                                                  : index + 1][2] ==
                                          Model.chats[index][2])
                                      ? null //from same sender
                                      : ChatShapeLeft() //from different senders
                                  //current user is the sender
                                  : (Model.chats[
                                              (index == Model.chats.length - 1)
                                                  ? (index - 1 < 0)
                                                      ? index
                                                      : index - 1
                                                  : index + 1][2] ==
                                          Model.chats[index][2])
                                      ? null //from same sender
                                      : ChatShapeRight(), //from different senders

                              child: Container(
                                padding: EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                    left: //ie,  padding for messages on the
                                        //left
                                        //5 for message without custom clipper
                                        //15 for message with custom clipper
                                        //without this padding, clipper cuts
                                        //off some content of the message
                                        (Model.username !=
                                                    Model.chats[index][2] &&
                                                (Model.chats[(index ==
                                                            Model.chats.length -
                                                                1)
                                                        ? (index - 1 < 0)
                                                            ? index
                                                            : index - 1
                                                        : index + 1][2] !=
                                                    Model.chats[index][2]))
                                            ? 15
                                            : 5,
                                    right: //ie,  padding for messages on the
                                        //right
                                        //5 for message without custom clipper
                                        //15 for message with custom clipper
                                        //without this padding, clipper cuts
                                        //off some content of the message
                                        (Model.username ==
                                                    Model.chats[index][2] &&
                                                (Model.chats[(index ==
                                                            Model.chats.length -
                                                                1)
                                                        ? (index - 1 < 0)
                                                            ? index
                                                            : index - 1
                                                        : index + 1][2] !=
                                                    Model.chats[index][2]))
                                            ? 15
                                            : 5),
                                // decoration: ShapeDecoration(
                                color: (Model.username != Model.chats[index][2])
                                    //if message is selected, color is
                                    //grey or red[100]
                                    //else color is black or red
                                    ? (selectedChats.contains(
                                            Model.chats[index][6].hashCode))
                                        ? Colors.grey //selected
                                        : Colors.black //not selected
                                    : (selectedChats.contains(
                                            Model.chats[index][6].hashCode))
                                        ? Colors.red[100] //selected
                                        : Colors.red, //not selected

                                //    shape: RoundedRectangleBorder()),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  //pushes content to the end of
                                  //container
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              bottom: 2,
                                              right:
                                                  //get width of messgage and
                                                  //width of timestamp
                                                  //if timestamp occupies more
                                                  //horizontal space than the message,
                                                  //25 pad the message at the right
                                                  //to push it to the away from
                                                  //the right edge of the container
                                                  ((BLoC.getTextSize(
                                                            Model.chats[index]
                                                                [0],
                                                            TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 9,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                            ),
                                                            context,
                                                          ).width) >
                                                          (BLoC.getTextSize(
                                                            Model.chats[index]
                                                                [4],
                                                            TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            context,
                                                          ).width))
                                                      ? 25
                                                      : 0),
                                          constraints: BoxConstraints(
                                              //the width of message must
                                              //be not exceed 80% of device
                                              //width
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8),
                                          child: Text(
                                            Model.chats[index][4],
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        /* if ((prevUser = Model.chats[index][2]) == "")
                                          Container(), */
                                        //just a tricky way to
                                        //get Model.username of the sender of the
                                        // current message. That condition
                                        //can never be true. LOL
                                        ValueListenableBuilder(
                                          valueListenable: deliveryListener,
                                          builder: (BuildContext context,
                                              int value2, Widget? child) {
                                            if (Model
                                                .chats[index][0].isNotEmpty) {
                                              return Container(
                                                padding:
                                                    EdgeInsets.only(top: 5),
                                                //created space between the
                                                // message and the timestamp
                                                child: Text(
                                                  utcToLocal(
                                                      Model.chats[index][0]),
                                                  // chat[0],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              );
                                            }
                                            return Container(
                                              padding: EdgeInsets.only(top: 5),
                                              //created space between the
                                              // message and the timestamp
                                              child: Icon(
                                                Icons.circle,
                                                color: Colors.white,
                                                size: 3,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                        ],
                        mainAxisAlignment:
                            //if a message was sent by the current user,
                            //then that message should be on the right
                            //else, the message should be on the left
                            (Model.username != Model.chats[index][2])
                                //ie, current user is not the sender
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.black,
          padding: /*  (defaultTargetPlatform == TargetPlatform.linux ||
                  defaultTargetPlatform == TargetPlatform.macOS ||
                  defaultTargetPlatform == TargetPlatform.windows)
              ? EdgeInsetsDirectional.zero
              : */
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: textController,
                  onChanged: (input) {
                    newMsg = input;
                  },
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: "Message",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (newMsg.isNotEmpty) {
                    print('calling sendMesg');
                    //int indx = Model.chats.length;

                    //int k = Random().nextInt(1000000000);
                    /*  (Model.chats.length == 0)
                        ? Model.chats.add([
                            "",
                            DateTime.now().day.toString(),
                            Model.username,
                            userProfile[0],
                            newMsg,
                            0,
                            Random().nextInt(1000000000),
                          ])
                        : */
                    Model.chats.insert(0, [
                      "",
                      DateTime.now().day.toString(),
                      Model.username,
                      userProfile[0],
                      newMsg,
                      0,
                      Random().nextInt(1000000000),
                    ]);
                    // setState(() {

                    // newMsg = '';
                    refreshed = true;
                    //int x = Model.selected.value;
                    // Model.selected.value = x + 1;
                    // });
                    textController.clear();
                    setState(() {});
                    sendMesg(
                        /*  (Model.chats.length == 0) ? */ Model
                            .chats.length /* : Model.chats.length - 1 */,
                        newMsg,
                        userProfile[0]);
                  }
                },
                alignment: Alignment.topCenter,
                icon: Icon(
                  Icons.send_rounded,
                  color: Colors.green[500],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "eventGig",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Chats",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(top: 5, left: 10, right: 10),
          child: SingleChildScrollView(
            child: Container(
              color: Colors.red[100],
              child: ValueListenableBuilder(
                valueListenable: Model.allChatOnlineStatus,
                builder: (BuildContext context, int value1, Widget? child) {
                  return buildTable(
                    Model.chatData['profiles']!,
                  );
                },
              ),
            ),
          ),
        ),
      );
    }
  }
}
