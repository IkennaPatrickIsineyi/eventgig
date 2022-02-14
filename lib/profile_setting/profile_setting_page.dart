// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, no_logic_in_create_state, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart';
import 'package:experi/profile_setting/profile_setting_logic.dart';

class ProfileSetting extends StatefulWidget {
  ProfileSetting(this.currentSettings, this.plannerStatus);

  final List currentSettings;
  final String plannerStatus;
  @override
  State<ProfileSetting> createState() =>
      _ProfileSetting(currentSettings, plannerStatus);
}

//Allows the user to place an order for courier
class _ProfileSetting extends State<ProfileSetting> {
  _ProfileSetting(this.currentSettings, this.plannerStatus);

  final List currentSettings;
  final String plannerStatus;

  @override
  Widget build(BuildContext context) {
    Model.currentRoute = "ProfileSetting";
    Model.prefs.setString("currentRoute", "ProfileSetting");

    var eventTypeItems = [
      "No",
      "Yes",
    ];

    profilePic = currentSettings[3];
    email = (changed == true)
        ? ((newEmail.isEmpty) ? currentSettings[1] : newEmail)
        : currentSettings[1];
    phone = (changed == true)
        ? ((newPhone.isEmpty) ? currentSettings[0] : newPhone)
        : currentSettings[0];
    fee = (changed == true)
        ? ((newFee.isEmpty) ? currentSettings[5].toString() : newFee)
        : currentSettings[5].toString();
    terms = (changed == true)
        ? ((newTerms.isEmpty) ? currentSettings[4] : newTerms)
        : currentSettings[4];

    planner = (changed == true) ? newStatus : plannerStatus;

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
                                      (profilePic.isEmpty ||
                                              profilePic == 'None')
                                          ?
                                          //user's profile picture
                                          Model.domain + 'img/' + 'default.png'
                                          : Model.domain + 'img/' + profilePic,
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
                          image: (profilePic.isEmpty || profilePic == 'None')
                              ?
                              //user's profile picture
                              Model.domain + 'img/' + 'default.png'
                              : Model.domain + 'img/' + profilePic,
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
                            changePicture();
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
                      value: planner,
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
                          changed = true;
                          newStatus = selected as String;
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
                  initialValue: email,
                  onChanged: (input) {
                    email = input;
                    newEmail = input;
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
                  initialValue: phone,
                  onChanged: (input) {
                    phone = input;
                    newPhone = input;
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
              if (planner == 'Yes') Divider(),
              if (planner == 'Yes')
                SizedBox(
                  width: (Model.deviceWidth > Model.mobileWidth)
                      ? Model.deviceWidth * 0.5
                      : Model.deviceWidth * 0.8,
                  // padding: EdgeInsets.all(15),
                  child: TextFormField(
                    initialValue: fee,
                    onChanged: (input) {
                      fee = input;
                      newFee = input;
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
                        fee = "";
                        return "*required";
                      } else if (value.contains(RegExp(r"(\D)"))) {
                        fee = "";
                        return "Fee must be number";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
              if (planner == 'Yes') Divider(),
              if (planner == 'Yes')
                SizedBox(
                  width: (Model.deviceWidth > Model.mobileWidth)
                      ? Model.deviceWidth * 0.5
                      : Model.deviceWidth * 0.8,
                  //  padding: EdgeInsets.all(15),
                  child: TextFormField(
                    initialValue: terms,
                    onChanged: (input) {
                      terms = input;
                      newTerms = input;
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
                      if (planner == 'Yes')
                        Flexible(
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                        RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ))),
                            onPressed: () {
                              showroom();
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
                            if (email.isNotEmpty && fee.isNotEmpty) {
                              saveChanges();
                            } else if (fee.isEmpty && planner == 'Yes') {
                              nullInputDialog(
                                  context, "Fee is required", 'Null Input');
                            } else if (email.isEmpty) {
                              nullInputDialog(
                                  context, "Email is required", 'Null Input');
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
