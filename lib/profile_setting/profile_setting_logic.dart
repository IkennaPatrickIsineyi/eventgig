// ignore_for_file: prefer_const_constructors, avoid_print, library_prefixes, prefer_typing_uninitialized_variables, unnecessary_null_comparison

import 'dart:convert';
import 'dart:typed_data';

import 'package:experi/showroom/showroom_logic.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart' as BLoC;

import 'package:http/http.dart' as http;

import 'package:image_cropper/image_cropper.dart' as imgCrop;

class ProfileLogic {
  static late final List currentSettings;
  static late final String plannerStatus;

  String profilePic = "";
  String email = "";
  String phone = "";
  String fee = "";
  String terms = "";
  String planner = "";

  List settings = [];

  bool nullSignal = false;

  bool changed = false;
  String newStatus = '';
  String newEmail = '';
  String newPhone = '';
  String newFee = '';
  String newTerms = '';
  String newPic = '';

  bool homeCall = false;

  final ValueNotifier<int> pictureChanged = ValueNotifier<int>(0);
  bool picSwitched = false;
  var picByte;
  String picName = '';

  late String croppedImageFile;
  bool openShowroom = false;
  List showroomPictures = [];

  String currentPic = '';

  static setter(List currentSettings, String plannerStatus) {
    ProfileLogic.currentSettings = currentSettings;
    ProfileLogic.plannerStatus = plannerStatus;
  }

  saveChanges() {
    if (email.isNotEmpty && planner.isNotEmpty && fee.isNotEmpty) {
      settings = [
        profilePic,
        email,
        planner,
        terms,
        fee,
        phone,
      ];
      var content = {
        'intro': 'savesettings',
        "sessionid": Model.sessionToken,
        "username": Model.username,
        "profilePic": profilePic,
        "email": email,
        "planner": planner,
        "fee": fee,
        "phone": phone,
        "terms": terms,
      };

      Uri address = Uri.parse(Model.domain + "savesettings");
      print(address);
      print(content);

      BLoC.showProgressIndicator();

      BLoC.sendMsg(content);

      liste() {
        Map<String, dynamic> res = Model.socketResult;
        if (res['intro'] == 'savesettings') {
          Navigator.pop(Model.currentContext);
          res = res['result'];
          if (res['status'] == 'hacker') {
            print('hacker');
            BLoC.nullInputDialog("Failed hack attempt", 'Oops');

            Navigator.pushNamedAndRemoveUntil(
                    Model.currentContext, '/loginpage', (route) => false)
                .then((value) {
              //remove/pop dialog's context from stack since the dialog has been popped
              if (Model.contextQueue.isNotEmpty) {
                Model.contextQueue.removeLast();

                //set current context variable to the next context on the stack
                Model.currentContext = Model.contextQueue.last;
              }
            });
          } else if (res['status'] == 'available') {
            print('changes saved');
            BLoC.snackMsg(Model.currentContext, "Changes Saved");
            BLoC.reloadHome();
          }
          Model.socketNotifier.removeListener(liste);
        }
      }

      Model.socketNotifier.addListener(liste);
    }
  }

  showroom() {
    var content = {
      'intro': 'getshowroom',
      "sessionid": Model.sessionToken,
      "username": Model.username,
    };

    Uri address = Uri.parse(Model.domain + "getshowroom");
    print(address);
    print(content);

    BLoC.showProgressIndicator();

    BLoC.sendMsg(content);

    liste() {
      Map<String, dynamic> res = Model.socketResult;
      if (res['intro'] == 'getshowroom') {
        Navigator.pop(Model.currentContext);
        res = res['result'];
        if (res['status'] == 'hacker') {
          print('hacker');
          BLoC.nullInputDialog("Failed hack attempt", 'Oops');

          Navigator.pushNamedAndRemoveUntil(
                  Model.currentContext, '/loginpage', (route) => false)
              .then((value) {
            //remove/pop dialog's context from stack since the dialog has been popped
            if (Model.contextQueue.isNotEmpty) {
              Model.contextQueue.removeLast();

              //set current context variable to the next context on the stack
              Model.currentContext = Model.contextQueue.last;
            }
          });
        } else if (res['status'] == 'valid') {
          print('Showroom retrieved');
          print(res['showroom']);
          ShowroomLogic.setter(res['showroom']);
          Navigator.pushNamed(Model.currentContext, '/showroom').then((value) {
            //remove/pop dialog's context from stack since the dialog has been popped
            if (Model.contextQueue.isNotEmpty) {
              Model.contextQueue.removeLast();

              //set current context variable to the next context on the stack
              Model.currentContext = Model.contextQueue.last;
            }
          });
        }
        Model.socketNotifier.removeListener(liste);
      }
    }

    Model.socketNotifier.addListener(liste);
  }

  Future<void> changePicture() async {
    BLoC.showProgressIndicator();
    Uint8List? file;
    String fileN;
    String? fileEx;
    String? filePath;
    FilePicker.platform.pickFiles(type: FileType.image).then(
      (value) async {
        if (value == null) {
          print('empty file');
        } else {
          file = value.files.first.bytes;
          fileN = value.files.first.name;
          fileEx = value.files.first.extension;
          filePath = value.files.first.path;

          Uri address = Uri.parse(Model.domain + "changedp");
          print(address);

          http.MultipartRequest request =
              http.MultipartRequest('POST', address);

          print('file obtained');
          if (!kIsWeb)
          //section fot non-web implementations
          {
            //open cropper here
            print('calling image cropper');
            // File newFile = File(filePath as String);
            /* final sample = */
            Navigator.pop(Model.currentContext);
            await imgCrop.ImageCropper.cropImage(
              sourcePath: filePath as String,
              aspectRatio: imgCrop.CropAspectRatio(ratioX: 1, ratioY: 1),
              cropStyle: imgCrop.CropStyle.circle,
              compressQuality: 20,
              aspectRatioPresets: [
                imgCrop.CropAspectRatioPreset.square,
              ],
              androidUiSettings: imgCrop.AndroidUiSettings(
                toolbarTitle: "Adjust Picture",
                toolbarColor: Colors.red,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: imgCrop.CropAspectRatioPreset.square,
                lockAspectRatio: false,
              ),
              iosUiSettings: imgCrop.IOSUiSettings(
                title: "Adjust Picture",
              ),
            ).then((croppedFile) async {
              if (croppedFile != null)
              //if user completed the cropping process
              {
                BLoC.snackMsg(Model.currentContext, "Uploading Image...");
                await http.MultipartFile.fromPath('dp', croppedFile.path)
                    .then((value) async {
                  request.files.add(value);
                  request.fields['username'] = Model.username;
                  request.fields['sessionid'] = Model.sessionToken;
                  request.fields['extension'] = fileEx as String;
                  await request.send().then(
                    (value) async {
                      await http.Response.fromStream(value).then(
                        (value) {
                          print(value.statusCode);
                          var result = jsonDecode(value.body);
                          if (result["status"] == "ok") {
                            print('deleting file...');
                            croppedFile.delete();
                            print('saving at heroku...');

                            var contentP = {
                              "sessionid": Model.sessionToken,
                              "username": Model.username,
                              "extension": fileEx as String,
                            };

                            Uri address = Uri.parse(
                                "http://eflask-app-ikp120.herokuapp.com/changedp");
                            print(address);
                            print(contentP);

                            var resp;

                            // BLoC.showProgressIndicator(Model.currentContext);

                            BLoC.sendRequest(Model.httpC, address, contentP)
                                .then(
                              (value) {
                                resp = value;

                                if (resp['value'] == 'OK') {
                                  print('saved at heroku');
                                } else {
                                  print('eror at heroku');
                                }
                              },
                            );

                            print("picture saved");
                            NetworkImage(
                              (profilePic.isEmpty || profilePic == 'None')
                                  ?
                                  //user's profile picture
                                  Model.domain + 'img/' + 'default.png'
                                  : Model.domain + 'img/' + profilePic,
                            ).evict();

                            BLoC.snackMsg(
                                Model.currentContext, "Picture saved");
                          } else {
                            BLoC.snackMsg(Model.currentContext, "Failed");
                          }
                        },
                      );
                    },
                  );
                });
              } else
              //if user canceled the cropping process
              {
                print('cropping cancelled');
              }
            });
          }
          //section for web implementations
          else {
            Navigator.pop(Model.currentContext);
            BLoC.snackMsg(Model.currentContext, "Uploading Image...");
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
                      print(value.statusCode);
                      print(value.body);
                      if (jsonDecode(value.body)['status'] == 'ok') {
                        print('saving at heroku...');
                        var contentP = {
                          "sessionid": Model.sessionToken,
                          "username": Model.username,
                          "extension": fileEx as String,
                        };

                        Uri address = Uri.parse(
                            "http://eflask-app-ikp120.herokuapp.com/changedp");
                        print(address);
                        print(contentP);

                        var resp;

                        BLoC.showProgressIndicator();

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
                        print('saved');
                        PaintingBinding.instance!.imageCache!.clear();
                        pictureChanged.value++;
                        BLoC.snackMsg(
                            Model.currentContext, "Profile picture changed!");
                        //setState(() {});

                        // setState(() {});
                      } else {
                        print('failed');
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

  deletePic(String currentPic) {
    var content = {
      'intro': 'deletepic',
      "sessionid": Model.sessionToken,
      "username": Model.username,
      "showroomid": currentPic[0],
    };

    Uri address = Uri.parse(Model.domain + "deletepic");
    print(address);
    print(content);

    BLoC.showProgressIndicator();

    BLoC.sendMsg(content);

    liste() {
      Map<String, dynamic> res = Model.socketResult;
      if (res['intro'] == 'deletepic') {
        Navigator.pop(Model.currentContext);
        res = res['result'];
        if (res['status'] == 'hacker') {
          print('hacker');
          BLoC.nullInputDialog("Failed hack attempt", 'Oops');

          Navigator.pushNamedAndRemoveUntil(
              Model.currentContext, '/loginpage', (route) => false);
        } else if (res['status'] == 'available') {
          print('changes saved');
          BLoC.snackMsg(Model.currentContext, "Changes Saved");
          BLoC.reloadHome();
        }
        Model.socketNotifier.removeListener(liste);
      }
    }

    Model.socketNotifier.addListener(liste);
  }
}
