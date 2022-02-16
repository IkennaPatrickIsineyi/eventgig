// ignore_for_file: file_names, avoid_print

import 'package:experi/login/loginLogic.dart';
import 'package:test/test.dart';
import 'package:experi/model.dart';

void main() {
  Model.testMode = true;
  Model.username = 'get';
  Model.setter();
  var loginObj = LoginLogic();

  group("Test for logic of login page", () {
    test('Testing login logic 1', () {
      print('running login logic 1 test');
      loginObj.loginSock();
      print('testing finished');
    });
    test('Testing login logic 2', () {
      print('running login logic 2 test');
      Map res = {'login': 'valid'};
      loginObj.loginResultSock(res);
      print('testing finished');
    });
  });
}
