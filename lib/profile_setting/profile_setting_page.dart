// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, no_logic_in_create_state, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart';
import 'package:experi/profile_setting/profile_setting_logic.dart';

class ProfileSetting extends StatefulWidget {
  @override
  State<ProfileSetting> createState() => _ProfileSetting();
}

//Allows the user to place an order for courier
class _ProfileSetting extends State<ProfileSetting> {
  final profileObj = ProfileLogic();

  @override
  Widget build(BuildContext context) {
    Model.contextQueue.addLast(context);
    Model.currentContext = context;
    Model.currentRoute = "ProfileSetting";
    Model.prefs.setString("currentRoute", "ProfileSetting");

    var eventTypeItems = [
      "No",
      "Yes",
    ];

    profileObj.profilePic = ProfileLogic.currentSettings[3];
    profileObj.email = (profileObj.changed == true)
        ? ((profileObj.newEmail.isEmpty)
            ? ProfileLogic.currentSettings[1]
            : profileObj.newEmail)
        : ProfileLogic.currentSettings[1];
    profileObj.phone = (profileObj.changed == true)
        ? ((profileObj.newPhone.isEmpty)
            ? ProfileLogic.currentSettings[0]
            : profileObj.newPhone)
        : ProfileLogic.currentSettings[0];
    profileObj.fee = (profileObj.changed == true)
        ? ((profileObj.newFee.isEmpty)
            ? ProfileLogic.currentSettings[5].toString()
            : profileObj.newFee)
        : ProfileLogic.currentSettings[5].toString();
    profileObj.terms = (profileObj.changed == true)
        ? ((profileObj.newTerms.isEmpty)
            ? ProfileLogic.currentSettings[4]
            : profileObj.newTerms)
        : ProfileLogic.currentSettings[4];

    profileObj.planner = (profileObj.changed == true)
        ? profileObj.newStatus
        : ProfileLogic.plannerStatus;

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
              "Profile Settings",
              style: TextStyle(fontSize: 12),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (BuildContext contxt) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    /* Image.asset(
                                        "assets/images/passport.jpg", */
                                    Image.network(
                                      (profileObj.profilePic.isEmpty ||
                                              profileObj.profilePic == 'None')
                                          ?
                                          //user's profile picture
                                          Model.domain + 'img/' + 'default.png'
                                          : Model.domain +
                                              'img/' +
                                              profileObj.profilePic,
                                      height: (Model.deviceWidth >
                                              Model.mobileWidth)
                                          ? Model.deviceHeight * 0.8
                                          : Model.deviceWidth * 0.8,
                                      width: (Model.deviceWidth >
                                              Model.mobileWidth)
                                          ? Model.deviceHeight * 0.8
                                          : Model.deviceWidth * 0.8,
                                    ),
                                  ],
                                );
                              });
                        },
                        child: FadeInImage.assetNetwork(
                          placeholder: "assets/images/imgloading.gif",
                          image: (profileObj.profilePic.isEmpty ||
                                  profileObj.profilePic == 'None')
                              ?
                              //user's profile picture
                              Model.domain + 'img/' + 'default.png'
                              : Model.domain + 'img/' + profileObj.profilePic,
                          height: Model.deviceWidth * 0.5,
                          width: Model.deviceWidth * 0.5,
                        ),
                      ),
                      ElevatedButton.icon(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          onPressed: () {
                            profileObj.changePicture();
                          },
                          label: Text("Change Picture"),
                          icon: Icon(Icons.photo_camera)),
                    ],
                  )
                ],
              ),
              Divider(),
              SizedBox(
                width: (Model.deviceWidth > Model.mobileWidth)
                    ? Model.deviceWidth * 0.5
                    : Model.deviceWidth * 0.8,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        right: 20,
                      ),
                      child: Text(
                        "Are you an Event Planner? ",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    DropdownButton(
                      value: profileObj.planner,
                      items: eventTypeItems.map((String item) {
                        return DropdownMenuItem<String>(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          value: item,
                        );
                      }).toList(),
                      onChanged: (var selected) {
                        setState(() {
                          profileObj.changed = true;
                          profileObj.newStatus = selected as String;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Divider(),
              SizedBox(
                width: (Model.deviceWidth > Model.mobileWidth)
                    ? Model.deviceWidth * 0.5
                    : Model.deviceWidth * 0.8,
                //padding: EdgeInsets.all(15),
                child: TextFormField(
                  initialValue: profileObj.email,
                  onChanged: (input) {
                    profileObj.email = input;
                    profileObj.newEmail = input;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: Icon(Icons.email, color: Colors.red),
                  ),
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "*required";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              Divider(),
              SizedBox(
                width: (Model.deviceWidth > Model.mobileWidth)
                    ? Model.deviceWidth * 0.5
                    : Model.deviceWidth * 0.8,
                // padding: EdgeInsets.all(15),
                child: TextFormField(
                  initialValue: profileObj.phone,
                  onChanged: (input) {
                    profileObj.phone = input;
                    profileObj.newPhone = input;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    hintText: "Phone Number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: Icon(Icons.phone, color: Colors.red),
                  ),
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) {
                    if (value!.contains(RegExp(r"(\D)"))) {
                      return "Must be number";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              if (profileObj.planner == 'Yes') Divider(),
              if (profileObj.planner == 'Yes')
                SizedBox(
                  width: (Model.deviceWidth > Model.mobileWidth)
                      ? Model.deviceWidth * 0.5
                      : Model.deviceWidth * 0.8,
                  // padding: EdgeInsets.all(15),
                  child: TextFormField(
                    initialValue: profileObj.fee,
                    onChanged: (input) {
                      profileObj.fee = input;
                      profileObj.newFee = input;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Fee (%)",
                      hintText: "Fee in %",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      prefixIcon: Icon(Icons.money, color: Colors.red),
                    ),
                    autovalidateMode: AutovalidateMode.always,
                    validator: (value) {
                      if (value!.isEmpty) {
                        profileObj.fee = "";
                        return "*required";
                      } else if (value.contains(RegExp(r"(\D)"))) {
                        profileObj.fee = "";
                        return "Fee must be number";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
              if (profileObj.planner == 'Yes') Divider(),
              if (profileObj.planner == 'Yes')
                SizedBox(
                  width: (Model.deviceWidth > Model.mobileWidth)
                      ? Model.deviceWidth * 0.5
                      : Model.deviceWidth * 0.8,
                  //  padding: EdgeInsets.all(15),
                  child: TextFormField(
                    initialValue: profileObj.terms,
                    onChanged: (input) {
                      profileObj.terms = input;
                      profileObj.newTerms = input;
                    },
                    decoration: InputDecoration(
                      labelText: "Terms and conditions",
                      hintText: "Terms and conditions",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      prefixIcon: Icon(Icons.warning, color: Colors.red),
                    ),
                  ),
                ),
              Divider(),
              SizedBox(
                  width: (Model.deviceWidth > Model.mobileWidth)
                      ? Model.deviceWidth * 0.8
                      : Model.deviceWidth * 0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (profileObj.planner == 'Yes')
                        Flexible(
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                        RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ))),
                            onPressed: () {
                              profileObj.showroom();
                            },
                            label: Text("Edit Showroom"),
                            icon: Icon(
                              Icons.edit,
                            ),
                          ),
                        ),
                      Flexible(
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (profileObj.email.isNotEmpty &&
                                profileObj.fee.isNotEmpty) {
                              profileObj.saveChanges();
                            } else if (profileObj.fee.isEmpty &&
                                profileObj.planner == 'Yes') {
                              nullInputDialog("Fee is required", 'Null Input');
                            } else if (profileObj.email.isEmpty) {
                              nullInputDialog(
                                  "Email is required", 'Null Input');
                            }
                          },
                          label: Text("Save"),
                          icon: Icon(Icons.save),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
