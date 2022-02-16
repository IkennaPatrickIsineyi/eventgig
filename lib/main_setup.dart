import 'package:shared_preferences/shared_preferences.dart';
import 'package:experi/model.dart';

class SetupMain {
  setup() async {
    Model.prefs = await SharedPreferences.getInstance();
  }
}
