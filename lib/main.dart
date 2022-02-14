// ignore_for_file: library_prefixes

import 'package:experi/model.dart';
import 'package:flutter/material.dart';
import 'package:experi/login/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  Model.prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //  BLoC.provider.check();

    Model.setter();

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: LoginPage(),
    );
  }
}
