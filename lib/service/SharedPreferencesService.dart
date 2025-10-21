import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  late final dynamic value;
  final String name;

  SharedPreferencesService({
    required this.value,
    required this.name,
  });

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    // Salva sempre il valore come una stringa per coerenza
    await prefs.setString(name, value.toString());
  }
  static Future<String?> load(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(name);
  }
}
