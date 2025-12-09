import 'package:flutter/material.dart';
import 'Voto.dart';

class Streak {
  int votiBuoni;
  bool inStreak;

  Streak({
    this.votiBuoni = 0,
    this.inStreak = false,
  });

  Color getStreakColor() {
    if (inStreak) {
      if (votiBuoni >= 10) {
        return Colors.red[900]!;
      } else if (votiBuoni >= 5) {
        return Colors.orange[900]!;
      } else {
        return Colors.orange[300]!;
      }
    } else {
      return Colors.grey;
    }
  }

  bool isGoated(List<Voto> votiIniziali) {
    return votiIniziali.length == votiBuoni;
  }

  // --- NESSUNA MODIFICA QUI ---
  // Questo metodo calcola solo l'ultima streak.
  Streak getStreak(List<Voto> voti) {
    int streak = 0;
    bool inStreak = false;
    for (Voto voto in voti) {
      if (voto.cancellato) {
        continue;
      }
      if (voto.voto >= 6) {
        streak++;
      } else {
        streak = 0;
      }
    }

    if (streak >= 2) {
      inStreak = true;
    }
    return Streak(votiBuoni: streak, inStreak: inStreak);
  }

  static List<Streak> getAllStreaks(List<Voto> voti) {
    final List<Streak> tutteLeStreak = [];
    int streakCorrente = 0;

    // Filtra subito i voti cancellati per pulizia
    final votiValidi = voti.where((voto) => !voto.cancellato).toList();

    for (int i = 0; i < votiValidi.length; i++) {
      Voto voto = votiValidi[i];

      if (voto.voto >= 6) {
        // Il voto è sufficiente, incrementa la streak corrente
        streakCorrente++;
      }

      // Controlla se la streak si è interrotta o se siamo alla fine della lista
      bool streakInterrotta = voto.voto < 6;
      bool fineLista = i == votiValidi.length - 1;

      if ((streakInterrotta || fineLista) && streakCorrente >= 2) {
        // La streak è terminata (o la lista è finita) ed è valida (lunga almeno 2)
        // Aggiungiamo la streak trovata alla lista.
        tutteLeStreak.add(Streak(votiBuoni: streakCorrente, inStreak: true));
      }

      if (streakInterrotta) {
        // Se il voto era insufficiente, azzera il contatore per la prossima potenziale streak.
        streakCorrente = 0;
      }
    }

    return tutteLeStreak;
  }
}