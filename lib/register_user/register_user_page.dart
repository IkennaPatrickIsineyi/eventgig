// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, use_key_in_widget_constructors, deprecated_member_use

import 'package:experi/home/homeLogic.dart';
import 'package:experi/home/homepage.dart';
import 'package:experi/login/loginpage.dart';
import 'package:experi/register_user/register_user_logic.dart';
import 'package:flutter/material.dart';
import 'package:experi/model.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPage();
}

//Allows a prospective user to create an account
class _RegisterPage extends State<RegisterPage> {
  final registerObj = RegisterLogic();
  @override
  Widget build(BuildContext context) {
    Model.contextQueue.addLast(context);
    Model.currentContext = context;
    Model.currentRoute = "register";
    Model.prefs.setString("currentRoute", "register");
    var genderItems = [
      "Select gender",
      "Male",
      "Female",
    ];

    if (registerObj.loginSignal == true) {
      return LoginPage();
    } else if (registerObj.homeSignal == true) {
      HomeLogic.setter(true);

      return HomePage();
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
              "Registration",
              style: TextStyle(fontSize: 12),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                alignment: Alignment.center,
                onPressed: () {
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
                },
                icon: Icon(Icons.login),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: (Model.deviceWidth > Model.mobileWidth)
                ? Model.deviceWidth * 0.6
                : Model.deviceWidth * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                      padding: EdgeInsets.only(left: 30),
                      child: DropdownButton(
                        value: registerObj.gender,
                        onChanged: (var input) {
                          setState(() {
                            registerObj.gender = input as String;
                          });
                        },

                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        isDense: true,
                        alignment: Alignment.center,
                        //icon: Icon(Icons.face_outlined),
                        items: genderItems.map((var item) {
                          return DropdownMenuItem(
                            alignment: Alignment.center,
                            child: Container(
                              decoration: (item != "Select gender")
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
                                    Icons.person,
                                    color: Colors.red,
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                      left: 15,
                                      right: 5,
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
                      valueListenable: registerObj.textValidator,
                      builder:
                          (BuildContext context, Set value1, Widget? child) {
                        return Container(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: TextFormField(
                              onChanged: (input) {
                                Model.username = input;
                                value1.remove(1);
                                registerObj.currentField.add(1);
                              },
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                labelText: "Username",
                                hintText: "Choose a username",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.red,
                                ),
                              ),
                              autovalidateMode: AutovalidateMode.always,
                              validator: (value) {
                                if (value1.contains(1)) {
                                  Model.username = '';
                                  return "* required";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(),
                    ValueListenableBuilder(
                      valueListenable: registerObj.textValidator,
                      builder:
                          (BuildContext context, Set value1, Widget? child) {
                        return Container(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: TextFormField(
                              onChanged: (input) {
                                Model.email = input;
                                value1.remove(2);
                                registerObj.currentField.add(2);
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: "Email",
                                hintText: "email",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Colors.red,
                                ),
                              ),
                              autovalidateMode: AutovalidateMode.always,
                              validator: (value) {
                                if (value1.contains(2)) {
                                  Model.email = '';
                                  return "* required";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(),
                    ValueListenableBuilder(
                      valueListenable: registerObj.textValidator,
                      builder:
                          (BuildContext context, Set value1, Widget? child) {
                        return Container(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: TextFormField(
                              onChanged: (input) {
                                registerObj.password = input;
                                value1.remove(3);
                                registerObj.currentField.add(3);
                              },
                              decoration: InputDecoration(
                                labelText: "Password",
                                hintText: "Choose a password",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.password,
                                  color: Colors.red,
                                ),
                              ),
                              keyboardType: TextInputType.visiblePassword,
                              autovalidateMode: AutovalidateMode.always,
                              validator: (value) {
                                if (value1.contains(3)) {
                                  registerObj.password = '';
                                  return "* required";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(),
                    ValueListenableBuilder(
                      valueListenable: registerObj.textValidator,
                      builder:
                          (BuildContext context, Set value1, Widget? child) {
                        return Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: TextFormField(
                            onChanged: (input) {
                              registerObj.password2 = input;
                              value1.remove(4);
                              registerObj.currentField.add(4);
                            },
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              hintText: "Confirm password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.password,
                                color: Colors.red,
                              ),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            autovalidateMode: AutovalidateMode.always,
                            validator: (value) {
                              if (value1.contains(4)) {
                                registerObj.password2 = '';
                                return "* required";
                              } else if (value != registerObj.password &&
                                  registerObj.currentField.contains(4)) {
                                return "Passwords must match";
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
                    ElevatedButton(
                      //submit button segment
                      child: Text("Submit"),
                      onPressed: registerObj.validateInput,
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
