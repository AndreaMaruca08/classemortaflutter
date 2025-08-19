import 'package:ClasseMorta/widgets/Assenzawidget.dart';
import 'package:flutter/material.dart';
import '../models/Assenza.dart';

class Assenzepage extends StatelessWidget {
  final List<List<Assenza>> assenze;
  const Assenzepage({
    super.key,
    required this.assenze,
  });

  @override
  Widget build(BuildContext context) {
    List<Assenza> assenz = assenze[0].reversed.toList();
    List<Assenza> uscite = assenze[1].reversed.toList();
    List<Assenza> ritardi = assenze[2].reversed.toList();

    // Stile di testo comune per i titoli delle sezioni per miglior leggibilità
    const TextStyle sectionTitleStyle = TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Colors.white, // Colore testo chiaro per contrasto
        shadows: <Shadow>[Shadow(
          offset: Offset(1.0, 1.0), // Ombra leggermente più piccola
          blurRadius: 2.0,
          color: Colors.black54, // Ombra meno intensa
        )]);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Assenze/Uscite/Ritardi'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Allinea i titoli a sinistra
              children: [
                const Text(
                  "Assenze",
                  style: sectionTitleStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: assenz.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ass = assenz[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Padding aggiustato
                      child: Assenzawidget(assenze: ass),
                    );
                  },
                ),
                const SizedBox(height: 16), // Aumentato spazio
                const Text(
                  "Uscite",
                  style: sectionTitleStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                ListView.builder(
                  // scrollDirection: Axis.horizontal, // Rimosso
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: uscite.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ass = uscite[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Assenzawidget(assenze: ass),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  "Ritardi",
                  style: sectionTitleStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                ListView.builder(
                  // scrollDirection: Axis.horizontal, // Non necessario per una lista verticale
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: ritardi.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ass = ritardi[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Assenzawidget(assenze: ass),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        )
    );
  }
}
