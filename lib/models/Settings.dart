import 'package:shared_preferences/shared_preferences.dart';

class Settings{
  int msAnimazioneVoto;
  int msAnimazioneGraficoAndamento;
  int msAnimazioneGraficoNumeri;
  Settings({
    required this.msAnimazioneVoto,
    required this.msAnimazioneGraficoAndamento,
    required this.msAnimazioneGraficoNumeri,
  });

  Future<void> salvaImpostazioni() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('msAnimazioneVoto', msAnimazioneVoto);
    await prefs.setInt('AnimazioneGraficoAndamento', msAnimazioneGraficoAndamento);
    await prefs.setInt('AnimazioneGraficoNumeri', msAnimazioneGraficoNumeri);
  }

  Future<void> caricaImpostazioni() async {
    final prefs = await SharedPreferences.getInstance();
    msAnimazioneVoto = prefs.getInt('msAnimazioneVoto') ?? 1500;
    msAnimazioneGraficoAndamento = prefs.getInt('AnimazioneGraficoAndamento') ?? 1500;
    msAnimazioneGraficoNumeri = prefs.getInt('AnimazioneGraficoNumeri') ?? 1200;
  }
}