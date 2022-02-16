// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables, no_logic_in_create_state, library_prefixes, duplicate_ignore, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:experi/model.dart';
import 'package:experi/BLoC.dart' as BLoC;
import 'package:experi/login/loginLogic.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final loginObj = LoginLogic();
  @override
  void initState() {
    super.initState();
    LoginLogic.textValidator = ValueNotifier(0);
    LoginLogic.pwdResetValidator = ValueNotifier<Set>({});
    Model.currentContext = context;
  }

  @override
  void dispose() {
    LoginLogic.textValidator.dispose();
    LoginLogic.pwdResetValidator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Model.currentRoute = "login";
    Model.deviceWidth = MediaQuery.of(context).size.width;
    Model.deviceHeight = MediaQuery.of(context).size.height;

    Model.prefs.setString("currentRoute", "login");
    // LoginLogic.resetPassword = resetpwd;

    if (LoginLogic.resetPassword == true) {
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
                    valueListenable: LoginLogic.pwdResetValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          maxLength: 6,
                          onChanged: (input) {
                            loginObj.otp = input;
                            LoginLogic.pwdResetValidator.value.remove(4);
                            loginObj.currentField.add(4);
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
                              loginObj.otp = '';
                              return "*required";
                            } else if (value!.contains(RegExp(r'(\D)')) &&
                                loginObj.currentField.contains(4)) {
                              //otp = '';
                              return "Verification code is a number";
                            } else if (!value.contains(RegExp(r'(\d{6})')) &&
                                loginObj.currentField.contains(4)) {
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
                    valueListenable: LoginLogic.pwdResetValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (input) {
                            loginObj.password1 = input;
                            LoginLogic.pwdResetValidator.value.remove(5);
                            loginObj.currentField.add(5);
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
                              loginObj.password1 = '';
                              return "Password is required";
                            } else if (!value!
                                    .contains(RegExp(r'([\w\W]{8,})')) &&
                                loginObj.currentField.contains(5)) {
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
                    valueListenable: LoginLogic.pwdResetValidator,
                    builder: (BuildContext context, Set value1, Widget? child) {
                      print(value1);
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (input) {
                            loginObj.password2 = input;
                            LoginLogic.pwdResetValidator.value.remove(6);
                            loginObj.currentField.add(6);
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
                              loginObj.password2 = '';
                              return "Password is required";
                            } else if (!value!
                                    .contains(RegExp(r'([\w\W]{8,})')) &&
                                loginObj.currentField.contains(6)) {
                              //password2 = '';
                              return "Must be at least 8 character long";
                            } else if (value != loginObj.password1 &&
                                loginObj.currentField.contains(6)) {
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
                      LoginLogic.pwdResetValidator.value = {};
                      if (loginObj.otp.isEmpty) {
                        LoginLogic.pwdResetValidator.value.add(4);
                      }

                      if (loginObj.password1.isEmpty) {
                        LoginLogic.pwdResetValidator.value.add(5);
                      }
                      if (loginObj.password2.isEmpty) {
                        LoginLogic.pwdResetValidator.value.add(6);
                      }
                      if (loginObj.otp.isNotEmpty &&
                          loginObj.password1.isNotEmpty &&
                          loginObj.password2.isNotEmpty &&
                          loginObj.password1 == loginObj.password2) {
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
                    valueListenable: LoginLogic.textValidator,
                    builder: (BuildContext context, value1, Widget? child) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (input) {
                            Model.username = input;
                            LoginLogic.textValidator.value = 0;
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
                if (loginObj.usernameOnly == false) Divider(),
                if (loginObj.usernameOnly == false)
                  ValueListenableBuilder(
                      valueListenable: LoginLogic.textValidator,
                      builder: (BuildContext context, value1, Widget? child) {
                        return Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: TextFormField(
                            onChanged: (input) {
                              loginObj.password = input;
                              LoginLogic.textValidator.value = 0;
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
                                loginObj.password = "";
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
                          if (loginObj.usernameOnly == false) {
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
                              loginObj.usernameOnly = false;
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
                      onPressed: (loginObj.usernameOnly == false)
                          ? loginObj.sendOPT1
                          : (loginObj.usernameOnly == true)
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
