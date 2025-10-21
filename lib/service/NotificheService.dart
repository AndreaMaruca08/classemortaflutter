import 'dart:io'; // <-- 1. IMPORTA 'dart:io' PER CONTROLLARE LA PIATTAFORMA
import 'package:flutter/foundation.dart'; // <-- Importa per usare 'kIsWeb'
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificheService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Codice da eseguire solo su mobile
      final status = await Permission.notification.request();
      if (status.isDenied) {
        print("Permesso per le notifiche negato dall'utente.");
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('iconanot');

      // Aggiungi anche le impostazioni per iOS/macOS per completezza
      const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

      final InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin, // Usa le stesse di iOS
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          // ...
        },
      );
    } else {
      // Su altre piattaforme (macOS, Windows, Linux, Web), non fare nulla.
      print("INFO: Inizializzazione notifiche saltata (piattaforma non supportata).");
    }
  }

  Future<void> showNotification(String content, int id, String intestazione) async {
    // --- 3. AGGIUNGI LO STESSO CONTROLLO ANCHE QUI ---
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      if (!(await Permission.notification.isGranted)) {
        print("Impossibile mostrare la notifica: permesso non concesso.");
        return;
      }

      // ... (tutto il tuo codice per creare i dettagli della notifica)
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'timer_channel_id',
        'Voto',
        channelDescription: 'Nuovo voto',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        id,
        intestazione,
        content,
        platformChannelSpecifics,
      );
    } else {
      print("INFO: Mostra notifica saltata (piattaforma non supportata).");
    }
  }
}
