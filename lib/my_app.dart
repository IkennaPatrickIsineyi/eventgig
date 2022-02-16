import 'package:experi/available_planners/available_planners_page.dart';
import 'package:experi/chat/chatroom_page.dart';
import 'package:experi/create_order/create_order_page.dart';
import 'package:experi/existing_order/existing_order_page.dart';
import 'package:experi/home/homepage.dart';
import 'package:experi/login/loginpage.dart';
import 'package:experi/model.dart';
import 'package:experi/profile_setting/profile_setting_page.dart';
import 'package:experi/register_user/register_user_page.dart';
import 'package:flutter/material.dart';

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
      routes: <String, WidgetBuilder>{
        '/loginpage': (BuildContext context) => LoginPage(),
        '/available_planners': (BuildContext context) => AvailablePlannerPage(),
        '/chatroom_page': (BuildContext context) => Chatroom(),
        '/create_order': (BuildContext context) => CreateOrderPage(),
        '/existing_order': (BuildContext context) => ExixtingOrderDetailPage(),
        '/home_page': (BuildContext context) => HomePage(),
        '/profile_setting': (BuildContext context) => ProfileSetting(),
        '/register': (BuildContext context) => RegisterPage(),
      },
    );
  }
}
