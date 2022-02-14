// ignore_for_file: avoid_print, library_prefixes, prefer_typing_uninitialized_variables, unnecessary_null_comparison

import 'dart:convert';
import 'dart:typed_data';

import 'package:experi/login/loginpage.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart' as BLoC;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

bool nullSignal = false;

bool homeCall = false;
List showroomPics = [];

bool refreshed = false;

String currentPic = '';

var currentPosition = 0;

reloadShowroomEvent() {
  Map<String, dynamic> res = Model.socketResult;
  if (res['intro'] == 'getshowroom') {
    Navigator.pop(Model.currentContext);
    res = res['result'];
    if (res['status'] == 'hacker') {
      print('hacker');
      BLoC.nullInputDialog(Model.currentContext, "Failed hack attempt", 'Oops');
      Navigator.pushAndRemoveUntil(
          Model.currentContext,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } else if (res['status'] == 'valid') {
      print('Showroom retrieved');
      print(res['showroom']);
      showroomPics = res['showroom'];
      refreshed = true;
      // setState(() {});
      //return res['showroom'];
      //showroomPics = res['showroom'];
    }
    Model.socketNotifier.removeListener(reloadShowroomEvent);
  }
}

deletePicEvent() {
  Map<String, dynamic> res = Model.socketResult;
  if (res['intro'] == 'deletepic') {
    Navigator.pop(Model.currentContext);
    res = res['result'];
    if (res['status'] == 'hacker') {
      print('hacker');
      BLoC.nullInputDialog(Model.currentContext, "Failed hack attempt", 'Oops');
      Navigator.pushAndRemoveUntil(
          Model.currentContext,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } else if (res['status'] == 'deleted') {
      print('deleted');
      //showroomPics.removeAt(currentPosition);
      BLoC.snackMsg(Model.currentContext, "Picture deleted");
      reloadShowroom();
    } else if (res['status'] == 'invalid') {
      print('hacker');
      BLoC.nullInputDialog(
          Model.currentContext, "The picture no longer exist", 'Oops');
    }
    Model.socketNotifier.removeListener(deletePicEvent);
  }
}

reloadShowroom() {
  var content = {
    'intro': 'getshowroom',
    "sessionid": Model.sessionToken,
    "username": Model.username,
  };

  Uri address = Uri.parse(Model.domain + "getshowroom");
  print(address);
  print(content);

  BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);

  /*  liste() {
    Map<String, dynamic> res = Model.socketResult;
    if (res['intro'] == 'getshowroom') {
      Navigator.pop(Model.currentContext);
      res = res['result'];
      if (res['status'] == 'hacker') {
        print('hacker');
        BLoC.nullInputDialog(
            Model.currentContext, "Failed hack attempt", 'Oops');
        Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      } else if (res['status'] == 'valid') {
        print('Showroom retrieved');
        print(res['showroom']);
        showroomPics = res['showroom'];
        refreshed = true;
       // setState(() {});
        //return res['showroom'];
        //showroomPics = res['showroom'];
      }
      Model.socketNotifier.removeListener(liste);
    }
  } */

  Model.socketNotifier.addListener(reloadShowroomEvent);
}

deletePic(var showroomid) {
  var content = {
    'intro': 'deletepic',
    "sessionid": Model.sessionToken,
    "username": Model.username,
    "showroomid": showroomid,
  };

  Uri address = Uri.parse(Model.domain + "deletepic");
  print(address);
  print(content);

  BLoC.showProgressIndicator(Model.currentContext);

  BLoC.sendMsg(content);

  /* liste() {
    Map<String, dynamic> res = Model.socketResult;
    if (res['intro'] == 'deletepic') {
      Navigator.pop(Model.currentContext);
      res = res['result'];
      if (res['status'] == 'hacker') {
        print('hacker');
        BLoC.nullInputDialog(
            Model.currentContext, "Failed hack attempt", 'Oops');
        Navigator.pushAndRemoveUntil(
            Model.currentContext,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      } else if (res['status'] == 'deleted') {
        print('deleted');
        //showroomPics.removeAt(currentPosition);
        BLoC.snackMsg(Model.currentContext, "Picture deleted");
        reloadShowroom();
      } else if (res['status'] == 'invalid') {
        print('hacker');
        BLoC.nullInputDialog(
            Model.currentContext, "The picture no longer exist", 'Oops');
      }
      Model.socketNotifier.removeListener(liste);
    }
  } */

  Model.socketNotifier.addListener(deletePicEvent);
}

addPic() {
  Uint8List? file;
  String fileN;
  String? fileEx;
  String? filePath;
  FilePicker.platform.pickFiles().then(
    (value) async {
      if (value == null) {
        print('empty file');
      } else {
        BLoC.showProgressIndicator(Model.currentContext);
        file = value.files.first.bytes;
        fileN = value.files.first.name;
        fileEx = value.files.first.extension;
        filePath = value.files.first.path;

        print('file obtained');

        Uri address = Uri.parse(Model.domain + "uploadpic");
        print(address);

        http.MultipartRequest request = http.MultipartRequest('POST', address);
        if (!kIsWeb) {
          await http.MultipartFile.fromPath('dp', filePath!)
              .then((value) async {
            request.files.add(value);
            request.fields['username'] = Model.username;
            request.fields['sessionid'] = Model.sessionToken;
            request.fields['extension'] = fileEx as String;
            await request.send().then(
              (value) async {
                await http.Response.fromStream(value).then(
                  (value) {
                    //Navigator.pop(Model.currentContext);
                    print(value.statusCode);
                    var result = jsonDecode(value.body);
                    if (result["status"] == "ok") {
                      var contentP = {
                        "sessionid": Model.sessionToken,
                        "username": Model.username,
                        "extension": fileEx as String,
                      };

                      Uri address = Uri.parse(
                          "http://eflask-app-ikp120.herokuapp.com/uploadpic");
                      print(address);
                      print(contentP);

                      var resp;

                      //  BLoC.showProgressIndicator(Model.currentContext);

                      BLoC.sendRequest(Model.httpC, address, contentP).then(
                        (value) {
                          resp = value;
                          Navigator.pop(Model.currentContext);

                          if (resp['value'] == 'OK') {
                            print('saved at heroku');
                          } else {
                            print('eror at heroku');
                          }
                        },
                      );
                      print("picture saved");
                      BLoC.snackMsg(Model.currentContext, "Picture saved");
                      reloadShowroom();
                    }
                  },
                );
              },
            );
          });
        } else {
          http.MultipartFile picture =
              http.MultipartFile.fromBytes('dp', file!, filename: fileN);

          if (picture != null) {
            request.files.add(picture);
            request.fields['username'] = Model.username;
            request.fields['sessionid'] = Model.sessionToken;
            request.fields['extension'] = fileEx as String;
            await request.send().then(
              (value) async {
                await http.Response.fromStream(value).then(
                  (value) {
                    Navigator.pop(Model.currentContext);
                    print(value.statusCode);
                    var result = jsonDecode(value.body);
                    if (result["status"] == "ok") {
                      var contentP = {
                        "sessionid": Model.sessionToken,
                        "username": Model.username,
                        "extension": fileEx as String,
                      };

                      Uri address = Uri.parse(
                          "http://eflask-app-ikp120.herokuapp.com/uploadpic");
                      print(address);
                      print(contentP);

                      var resp;

                      BLoC.showProgressIndicator(Model.currentContext);

                      BLoC.sendRequest(Model.httpC, address, contentP).then(
                        (value) {
                          resp = value;
                          Navigator.pop(Model.currentContext);

                          if (resp['value'] == 'OK') {
                            print('saved at heroku');
                          } else {
                            print('eror at heroku');
                          }
                        },
                      );
                      print("picture saved");
                      BLoC.snackMsg(Model.currentContext, "Picture saved");
                      reloadShowroom();
                    }
                  },
                );
              },
            );
          }
        }
      }
    },
  );
}
