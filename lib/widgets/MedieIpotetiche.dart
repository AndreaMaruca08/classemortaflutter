import 'package:ClasseMorta/widgets/SingoloVotoWid.dart';
import 'package:flutter/material.dart';
import '../models/Voto.dart';

class Ipotetiche extends StatelessWidget {
  final List<Voto> voti;
  const Ipotetiche({
    super.key,
    required this.voti,
  });

  @override
  Widget build(BuildContext context) {
    // Non modificare this.voti qui.
    // Se la lista voti originale è vuota, gestisci questo caso.
    if (voti.isEmpty) {
      return const Center(child: Text("Nessun voto per calcolare medie ipotetiche."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Per far sì che le Row interne occupino la larghezza
      children: [
        Padding( // Aggiungi padding se necessario
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuisce meglio lo spazio
            children: const [
              Expanded( // Usa Expanded per dare flessibilità al testo
                child: Text(
                  "Se il prossimo voto è ↓",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // Riduci un po' la dimensione se necessario
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 10), // Spazio tra i testi
              Expanded(
                child: Text(
                  "Avrai di media ↓",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Expanded( // Permette al ListView di prendere lo spazio rimanente nel SizedBox
          child: ListView.builder(
              shrinkWrap: true, // Importante se l'altezza del ListView non è definita esplicitamente altrove
              // physics: const NeverScrollableScrollPhysics(), // Necessario se Ipotetiche non avesse un SizedBox con altezza
              itemCount: 21, // Per voti da 0.0 a 10.0 con step 0.5 (0, 0.5, ..., 10.0)
              itemBuilder: (context, index) {
                double prossimoVotoValore = (index * 0.5);

                List<Voto> votiTemporanei = List.from(this.voti); // Crea sempre una nuova lista per il calcolo

                Voto votoIpotetico = Voto(
                  codiceMateria: voti[0].codiceMateria,
                  nomeInteroMateria: voti[0].nomeInteroMateria,
                  dataVoto: DateTime.now().toIso8601String(),
                  voto: prossimoVotoValore,
                  displayValue: prossimoVotoValore.toStringAsFixed(1),
                  descrizione: "Voto ipotetico",
                  periodo: voti[0].periodo,
                  cancellato: false,
                  nomeProf: voti[0].nomeProf,
                    tipo: "Voto ipotetico"
                );
                votiTemporanei.add(votoIpotetico);

                double mediaCalcolata = getMedia(votiTemporanei);

                // Voto fittizio per visualizzare la media nel VotoSingolo
                Voto votoPerDisplayMedia = Voto(
                    codiceMateria: "",
                    nomeInteroMateria: "",
                    dataVoto: "",
                    voto: mediaCalcolata, // Qui usi la media calcolata
                    displayValue: mediaCalcolata.toStringAsFixed(2),
                    descrizione: "",
                    periodo: 0,
                    cancellato: false,
                    nomeProf: "",
                    tipo: ""
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          prossimoVotoValore.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      VotoSingolo(voto: votoPerDisplayMedia, grandezza: 70, fontSize: 17) // Riduci un po' la grandezza se serve
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }

  // Assicurati che questa funzione getMedia sia identica o compatibile
  // con quella in DettagliMateria, o meglio, centralizzala se possibile.
  double getMedia(List<Voto> votiLista) {
    if (votiLista.isEmpty) {
      return 0.0;
    }
    double somma = 0.0;
    int conteggioVotiValidi = 0;
    for (Voto voto in votiLista) {
      if (voto.cancellato) {
        continue;
      }
      somma += voto.voto;
      conteggioVotiValidi++;
    }
    return conteggioVotiValidi == 0 ? 0.0 : somma / conteggioVotiValidi;
  }
}
