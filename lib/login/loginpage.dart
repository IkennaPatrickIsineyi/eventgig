// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables, no_logic_in_create_state, library_prefixes, duplicate_ignore, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart' as BLoC;
import 'package:experi/login/loginLogic.dart' as LogLogic;

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, this.resetpassword = false}) : super(key: key);
  final bool resetpassword;
  @override
  State<LoginPage> createState() => _LoginPage(resetpassword);
}

class _LoginPage extends State<LoginPage> {
  _LoginPage(this.resetpwd);
  final bool resetpwd;
  var loginObj = LogLogic.LoginLogic();
  @override
  void initState() {
    super.initState();
    LogLogic.LoginLogic.textValidator = ValueNotifier(0);
    LogLogic.LoginLogic.pwdResetValidator = ValueNotifier<Set>({});
    Model.currentContext = context;
  }

  @override
  void dispose() {
    LogLogic.LoginLogic.textValidator.dispose();
    LogLogic.LoginLogic.pwdResetValidator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Model.currentRoute = "login";
    Model.deviceWidth = MediaQuery.of(context).size.width;
    Model.deviceHeight = MediaQuery.of(context).size.height;

    Model.prefs.setString("currentRoute", "login");
    LogLogic.LoginLogic.resetPassword = resetpwd;

    if (LogLogic.LoginLogic.resetPassword == true) {
      return Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                "eventGig",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Password Reset",
                style: TextStyle(fontSize: 12),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: (Model.deviceWidth > Model.mobileWidth)
                  ? Model.deviceWidth * 0.6
                  : Model.deviceWidth * 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Divider(),
                  Text(
                    '''A 6-digit code has been sent to the email you registered with.\n\nEnter that OTP code in the field below''',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Divider(),
                  ValueListenableBuilder(
                    valueListenable: LogLogic.LoginLogic.pwdResetValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          maxLength: 6,
                          onChanged: (input) {
                            LogLogic.LoginLogic.otp = input;
                            LogLogic.LoginLogic.pwdResetValidator.value
                                .remove(4);
                            LogLogic.LoginLogic.currentField.add(4);
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "OTP Code",
                            hintText: "Enter the OTP code here",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.security,
                              color: Colors.red,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value1.contains(4)) {
                              LogLogic.LoginLogic.otp = '';
                              return "*required";
                            } else if (value!.contains(RegExp(r'(\D)')) &&
                                LogLogic.LoginLogic.currentField.contains(4)) {
                              //otp = '';
                              return "Verification code is a number";
                            } else if (!value.contains(RegExp(r'(\d{6})')) &&
                                LogLogic.LoginLogic.currentField.contains(4)) {
                              //otp = '';
                              return "Verification code is 6-digit number";
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
                    valueListenable: LogLogic.LoginLogic.pwdResetValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (input) {
                            LogLogic.LoginLogic.password1 = input;
                            LogLogic.LoginLogic.pwdResetValidator.value
                                .remove(5);
                            LogLogic.LoginLogic.currentField.add(5);
                          },
                          decoration: InputDecoration(
                            labelText: "New Password",
                            hintText: "Choose a new password",
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
                            if (value1.contains(5)) {
                              LogLogic.LoginLogic.password1 = '';
                              return "Password is required";
                            } else if (!value!
                                    .contains(RegExp(r'([\w\W]{8,})')) &&
                                LogLogic.LoginLogic.currentField.contains(5)) {
                              //password1 = '';
                              return "Must be at least 8 character long";
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
                    valueListenable: LogLogic.LoginLogic.pwdResetValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      print(value1);
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (input) {
                            LogLogic.LoginLogic.password2 = input;
                            LogLogic.LoginLogic.pwdResetValidator.value
                                .remove(6);
                            LogLogic.LoginLogic.currentField.add(6);
                          },
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            hintText: "Enter the password again",
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
                            if (value1.contains(6)) {
                              LogLogic.LoginLogic.password2 = '';
                              return "Password is required";
                            } else if (!value!
                                    .contains(RegExp(r'([\w\W]{8,})')) &&
                                LogLogic.LoginLogic.currentField.contains(6)) {
                              //password2 = '';
                              return "Must be at least 8 character long";
                            } else if (value != LogLogic.LoginLogic.password1 &&
                                LogLogic.LoginLogic.currentField.contains(6)) {
                              //password2 = '';
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
                    onPressed: () {
                      LogLogic.LoginLogic.pwdResetValidator.value = {};
                      if (LogLogic.LoginLogic.otp.isEmpty) {
                        LogLogic.LoginLogic.pwdResetValidator.value.add(4);
                      }

                      if (LogLogic.LoginLogic.password1.isEmpty) {
                        LogLogic.LoginLogic.pwdResetValidator.value.add(5);
                      }
                      if (LogLogic.LoginLogic.password2.isEmpty) {
                        LogLogic.LoginLogic.pwdResetValidator.value.add(6);
                      }
                      if (LogLogic.LoginLogic.otp.isNotEmpty &&
                          LogLogic.LoginLogic.password1.isNotEmpty &&
                          LogLogic.LoginLogic.password2.isNotEmpty &&
                          LogLogic.LoginLogic.password1 ==
                              LogLogic.LoginLogic.password2) {
                        loginObj.verifyOTP();
                      }
                    },
                    child: Text("Submit Code"),
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size.fromWidth(
                          (Model.deviceWidth > Model.mobileWidth)
                              ? Model.deviceWidth * 0.5
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
                  )
                ],
              ),
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
              "Login",
              style: TextStyle(fontSize: 12),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(),
                alignment: Alignment.center,
                child: IconButton(
                  alignment: Alignment.center,
                  onPressed: () {
                    /* Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => RegisterPage(),
                      ),
                    ); */
                  },
                  icon: Icon(Icons.account_circle_sharp),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            //alignment: Alignment.center,
            constraints: BoxConstraints(
              minWidth: 0,
              maxWidth: (Model.deviceWidth > Model.mobileWidth)
                  ? Model.deviceWidth * 0.6
                  : Model.deviceWidth * 0.9,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Divider(),
                ValueListenableBuilder(
                    valueListenable: LogLogic.LoginLogic.textValidator,
                    builder: (BuildContext context, value1, Widget? child) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (input) {
                            Model.username = input;
                            LogLogic.LoginLogic.textValidator.value = 0;
                          },
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            labelText: "Username",
                            hintText: "username",
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
                          validator: (value2) {
                            if (value1 == 1 || value1 == 3) {
                              Model.username = "";
                              return "*required";
                            } else {
                              return null;
                            }
                          },
                        ),
                      );
                    }),
                if (LogLogic.LoginLogic.usernameOnly == false) Divider(),
                if (LogLogic.LoginLogic.usernameOnly == false)
                  ValueListenableBuilder(
                      valueListenable: LogLogic.LoginLogic.textValidator,
                      builder: (BuildContext context, value1, Widget? child) {
                        return Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: TextFormField(
                            onChanged: (input) {
                              LogLogic.LoginLogic.password = input;
                              LogLogic.LoginLogic.textValidator.value = 0;
                            },
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              hintText: "Enter your password",
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
                            autovalidateMode: AutovalidateMode.always,
                            validator: (value2) {
                              if (value1 == 2 || value1 == 3) {
                                LogLogic.LoginLogic.password = "";
                                return "*required";
                              } else {
                                return null;
                              }
                            },
                          ),
                        );
                      }),
                Divider(),
                Divider(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // if (usernameOnly == false)
                    ElevatedButton(
                      onPressed: () async {
                        if (Model.diableLogin == false) {
                          if (LogLogic.LoginLogic.usernameOnly == false) {
                            Model.diableLogin = true;
                            bool nullInput = loginObj.validateInput();
                            if (nullInput == false) {
                              BLoC.showProgressIndicator(context);
                              await loginObj.loginSock();
                            } else {
                              Model.diableLogin = false;
                            }
                          } else {
                            setState(() {
                              LogLogic.LoginLogic.usernameOnly = false;
                            });
                          }
                        }
                      },
                      child: Text("Login"),
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
                    // if (usernameOnly == false)
                    Divider(), Divider(),
                    ElevatedButton(
                      onPressed: (LogLogic.LoginLogic.usernameOnly == false)
                          ? loginObj.sendOPT1
                          : (LogLogic.LoginLogic.usernameOnly == true)
                              ? loginObj.sendOTP
                              : null,
                      child: Text("Reset Password"),
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
