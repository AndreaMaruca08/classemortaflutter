import 'package:shared_preferences/shared_preferences.dart';

import '../models/Credenziali.dart';

class Save{
  Future<void> saveStringList(List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("accesso", value);
  }
  Future<Credenziali?>? getCredenziali() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? value = prefs.getStringList("accesso");
    if(value == null) {
      return null;
    }
    return Credenziali.fromList(value);
  }
}