import 'package:shared_preferences/shared_preferences.dart';

class Settings{
  int msAnimazioneVoto;
  Settings({
    required this.msAnimazioneVoto,
  });

  Future<void> salvaImpostazioni() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('msAnimazioneVoto', msAnimazioneVoto);
  }

  Future<void> caricaImpostazioni() async {
    final prefs = await SharedPreferences.getInstance();
    msAnimazioneVoto = prefs.getInt('msAnimazioneVoto') ?? 1500;
  }
}