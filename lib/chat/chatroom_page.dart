// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors, no_logic_in_create_state, library_prefixes, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, avoid_print, deprecated_member_use, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:experi/chatshape.dart';
import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/chat/chatroom_logic.dart';
import 'package:experi/BLoC.dart' as BLoC;

class Chatroom extends StatefulWidget {
  @override
  State<Chatroom> createState() => _Chatroom();
}

//Allows the user to place an order for courier
class _Chatroom extends State<Chatroom> {
  final chatObj = ChatRoom();
  @override
  initState() {
    super.initState();
    print('initstate called...');

    if (Model.listener1Added == false) {
      print('adding listener1');
      Model.socketNotifier.addListener(() => chatObj.listener1());
      Model.listener1Added = true;
    }
    if (Model.listener2Added == false) {
      print('adding listener2');
      Model.pingNotifier.addListener(() => chatObj.listener2());
      Model.listener2Added = true;
    }

    liste() {
      print('calling fucker...');
      chatObj.refreshed = true;
      setState(() {});
      print('fucker called...');
      /*   posoNot.removeListener(liste); */
      print('fucker killed...');
    }

    if (ChatRoom.currentRoute == "ChatroomSingle") {
      Model.posoNot.removeListener(liste);
      Model.posoNot.addListener(liste);
      Model.singleChats = true;
    } else {
      Model.singleChats = false;
    }

    chatObj.nextChatid = ChatRoom.idOfLastChat;
    if (ChatRoom.single == true) {
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
    if (ChatRoom.single == true) {
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
    //currentRoute = (ChatRoom.single == true) ? "ChatroomSingle" : "ChatroomMulti";
    Model.modif = false;
    print("chatroom loaded");

    if (chatObj.refreshed == false) {
      print("refreshed false");
      Model.prefs.setString("currentRoute", ChatRoom.currentRoute);
      Model.chats = ChatRoom.allChats;
      chatObj.refreshed = true;
      /* if(!Model.memberOnlineStatus.containsKey(ChatRoom.userProfile[0]) && currentRoute=="ChatroomSingle")
         Model.memberOnlineStatus[ChatRoom.userProfile[0]] = [];
        Model.memberOnlineStatus[ChatRoom.userProfile[0]]!.add(chatData['profiles']);
            Model.memberOnlineStatus[ChatRoom.userProfile[0]]!.add(ChatRoom.userProfile[0]['last_seen'][usr]);
      } */
    }

    if (ChatRoom.single == true) {
      print("chatroom single");

      print(Model.chats);
      if (Model.chats.isNotEmpty) chatObj.lastChatId = Model.chats.last[6];
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
                                  image: (ChatRoom.userProfile[1].isEmpty ||
                                          ChatRoom.userProfile[1] == 'None')
                                      ? Model.domain + 'img/' + 'default.png'
                                      : Model.domain +
                                          'img/' +
                                          ChatRoom.userProfile[1],
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: Model.allChatOnlineStatus,
                              builder: (BuildContext context, int value1,
                                  Widget? child) {
                                print(value1);
                                if (Model.memberOnlineStatus.containsKey(
                                    ChatRoom.userProfile[0])) if (Model
                                            .memberOnlineStatus[
                                        ChatRoom.userProfile[0]]![0] ==
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
            onTap: () => chatObj.getUserDetails(ChatRoom.userProfile[0]),
            child:
                /* Stack(
              children: [ */
                Text(
              ChatRoom.userProfile[0],
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
                if (chatObj.selectedChats.isNotEmpty) {
                  return IconButton(
                    onPressed: () {
                      print('delete');
                      chatObj.deleteChats(chatObj.selectedChats.toList());
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
              print('adjustOffset: ${chatObj.adjustOffset}');

              if (index >= Model.chats.length - 11 &&
                  chatObj.adjustOffset == false &&
                  Model.chats.length >= 20) {
                print("refreshing");
                chatObj.adjustOffset = true;
                chatObj.fetchMore = true;
                chatObj.showIndicator.value = true;
                chatObj.updating = false;
                chatObj.getChats(ChatRoom.userProfile[0]);
                //setState(() {});
                //chatObj.updating = false;
              }
              if (index == Model.chats.length) {
                return ValueListenableBuilder(
                  valueListenable: chatObj.showIndicator,
                  builder: (BuildContext context, bool value1, Widget? child) {
                    print("show indicator: $value1");

                    // if(Model.chats.first==chat)
                    if (chatObj.showIndicator.value == false) {
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
                      if (chatObj.selectedChats.isEmpty &&
                          !chatObj.deleted.contains(Model.chats[index][6]) &&
                          Model.chats[index][2] == Model.username)
                      //a user can only select messages sent
                      //by him/her and which have not been deleted.

                      //Longpress should only work if user has not selected
                      //any message. If user has selected any message
                      // the user can select another message by tapping
                      //instead of longpressing it.
                      {
                        chatObj.selectedChats
                            .add(Model.chats[index][6].hashCode);
                        Model.selected.value++;
                        //The hashcode of chatid of any selected message
                        //must be added to the notifier set. Doing so
                        //would notify all the notifier builders
                        //listening to the notifier to rebuild their members
                      }
                      print(value1);
                    },
                    onTap: () {
                      if (chatObj.selectedChats
                          .contains(Model.chats[index][6].hashCode))
                      //if this message has already been selected, tapping
                      //the message should unselect it by removing from
                      //the notifier set
                      {
                        chatObj.selectedChats
                            .remove(Model.chats[index][6].hashCode);
                        int x = Model.selected.value + 1;
                        Model.selected.value = x;
                      } else if (chatObj.selectedChats.isNotEmpty &&
                          !chatObj.deleted.contains(Model.chats[index][6]) &&
                          Model.chats[index][2] == Model.username)
                      //if any other message has already been selected
                      //tapping this message would select it by
                      //adding it to the notifier set
                      {
                        //initialisation begin

                        // notifierSet = true;
                        //initialisation end

                        chatObj.selectedChats
                            .add(Model.chats[index][6].hashCode);
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
                          if (!chatObj.deleted.contains(Model.chats[index][6]))
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
                                    ? (chatObj.selectedChats.contains(
                                            Model.chats[index][6].hashCode))
                                        ? Colors.grey //selected
                                        : Colors.black //not selected
                                    : (chatObj.selectedChats.contains(
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
                                          valueListenable:
                                              chatObj.deliveryListener,
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
                                                  chatObj.utcToLocal(
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
                  controller: chatObj.textController,
                  onChanged: (input) {
                    chatObj.newMsg = input;
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
                  if (chatObj.newMsg.isNotEmpty) {
                    print('calling sendMesg');
                    //int indx = Model.chats.length;

                    //int k = Random().nextInt(1000000000);
                    /*  (Model.chats.length == 0)
                        ? Model.chats.add([
                            "",
                            DateTime.now().day.toString(),
                            Model.username,
                            ChatRoom.userProfile[0],
                            chatObj.newMsg,
                            0,
                            Random().nextInt(1000000000),
                          ])
                        : */
                    Model.chats.insert(0, [
                      "",
                      DateTime.now().day.toString(),
                      Model.username,
                      ChatRoom.userProfile[0],
                      chatObj.newMsg,
                      0,
                      Random().nextInt(1000000000),
                    ]);
                    // setState(() {

                    // chatObj.newMsg = '';
                    chatObj.refreshed = true;
                    //int x = Model.selected.value;
                    // Model.selected.value = x + 1;
                    // });
                    chatObj.textController.clear();
                    setState(() {});
                    chatObj.sendMesg(
                        /*  (Model.chats.length == 0) ? */ Model
                            .chats.length /* : Model.chats.length - 1 */,
                        chatObj.newMsg,
                        ChatRoom.userProfile[0]);
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
                  return chatObj.buildTable(
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
