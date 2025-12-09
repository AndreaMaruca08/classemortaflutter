import 'package:flutter/material.dart';

import '../../models/Streak.dart';
import '../../models/Voto.dart';

// Rinominato per coerenza con il contenuto, da MateriePag a DettagliStreakPag
class DettagliStreakPag extends StatelessWidget {
  final List<Voto> voti;
  const DettagliStreakPag({
    required this.voti,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calcola tutte le streak e la streak attuale una sola volta
    final List<Streak> tutteLeStreak = Streak.getAllStreaks(voti);
    final Streak streakAttuale = Streak().getStreak(voti.reversed.toList());

    // 2. Calcola le statistiche aggiuntive
    final int streakPiuLunga = tutteLeStreak.fold(0, (max, s) => max > s.votiBuoni ? max : s.votiBuoni);
    final int primaStreak = tutteLeStreak.reversed.toList().isNotEmpty ? tutteLeStreak.reversed.toList()[0].votiBuoni : 0;

    return Scaffold(
      appBar: AppBar(
        // Titolo più appropriato per la pagina
        title: const Text('Dettaglio Streak'),
      ),
      body: SingleChildScrollView(
        // ClampingScrollPhysics è una buona scelta per evitare l'overscroll glow
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Aumentato padding per più spazio
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEZIONE STATISTICHE ---
              const Text(
                'Riepilogo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildStatisticheRow(streakAttuale, streakPiuLunga, primaStreak),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // --- SEZIONE LISTA STREAK ---
              const Text(
                'Tutte le Streak',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Gestione del caso in cui non ci sono streak da mostrare
              if (tutteLeStreak.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text(
                      'Nessuna streak di voti positivi trovata.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: tutteLeStreak.length,
                  itemBuilder: (BuildContext context, int index) {
                    final streak = tutteLeStreak[index];
                    // Usiamo un indice invertito per mostrare la più recente in cima
                    final int numeroStreak = tutteLeStreak.length - index;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: streakWidget(streak, numeroStreak),
                    );
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color getColor(int  numero) {
    if (numero >= 15) {
    return Colors.red;
    }
    else if (numero >= 10) {
      return Colors.red[700]!;
    } else if (numero >= 5) {
      return Colors.orange[900]!;
    } else {
      return Colors.orange[300]!;
    }
  }

  /// Widget privato per la riga delle statistiche principali
  Widget _buildStatisticheRow(Streak streakAttuale, int streakPiuLunga, int primaStreak) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statisticaWidget('Attuale', streakAttuale.votiBuoni.toString(), getColor(streakAttuale.votiBuoni)),
          const VerticalDivider(thickness: 1),
          _statisticaWidget('Più Lunga', streakPiuLunga.toString(), getColor(streakPiuLunga)),
          const VerticalDivider(thickness: 1),
          _statisticaWidget('Prima', primaStreak.toString(), getColor(primaStreak)),
        ],
      ),
    );
  }

  /// Widget per mostrare una singola statistica (es. "Attuale", "5")
  Widget _statisticaWidget(String etichetta, String valore, Color coloreValore) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          etichetta,
          style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          valore,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: coloreValore),
        ),
      ],
    );
  }

  /// Widget completato per visualizzare una singola streak nella lista
  Widget streakWidget(Streak streak, int numeroStreak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: streak.getStreakColor().withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icona e Titolo
          Row(
            children: [
              Icon(Icons.local_fire_department, color: streak.getStreakColor(), size: 28),
              const SizedBox(width: 12),
              Text(
                'Streak #$numeroStreak', // Es. "Streak #3"
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Durata
          Text(
            '${streak.votiBuoni} voti',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
