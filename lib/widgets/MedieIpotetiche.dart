import 'package:classemorta/widgets/SingoloVotoWid.dart';
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
    if (voti.isEmpty) {
      return const Center(
          child: Text("Nessun voto per calcolare medie ipotetiche."));
    }

    // Funzione helper per generare la lista di righe, non più in un ListView
    List<Widget> generaRigheIpotetiche() {
      List<Widget> righe = [];

      // Aggiunge l'intestazione
      righe.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Text(
                  "Se prendi ↓",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Media diventa ↓",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );

      for (int i = 0; i <= 20; i++) {
        double prossimoVotoValore = (i * 0.5);

        List<Voto> votiTemporanei = List.from(voti);

        Voto votoIpotetico = Voto(
            codiceMateria: voti[0].codiceMateria,
            nomeInteroMateria: voti[0].nomeInteroMateria,
            dataVoto: DateTime.now().toIso8601String(),
            voto: prossimoVotoValore,
            displayValue: prossimoVotoValore.toStringAsFixed(1),
            descrizione: "Voto ipotetico",
            periodo: 1,
            cancellato: false,
            nomeProf: voti[0].nomeProf,
            tipo: "Voto ipotetico");
        votiTemporanei.add(votoIpotetico);

        double mediaCalcolata = getMedia(votiTemporanei);

        Voto votoPerDisplayMedia = Voto(
            codiceMateria: "",
            nomeInteroMateria: "",
            dataVoto: "",
            voto: mediaCalcolata,
            displayValue: mediaCalcolata.toStringAsFixed(2),
            descrizione: "",
            periodo: 0,
            cancellato: false,
            nomeProf: "",
            tipo: "");

        righe.add(
          Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 4.0, horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    prossimoVotoValore.toStringAsFixed(1),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                VotoSingolo(
                    voto: votoPerDisplayMedia, grandezza: 70, fontSize: 17),
              ],
            ),
          ),
        );
      }
      return righe;
    }

    // Il widget principale ora è un Container che contiene una Column
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(240, 240, 240, 0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(2, 2),
          ),
        ],
      ),
      // Aggiungi qui la tua decoration in futuro
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: generaRigheIpotetiche(),
      ),
    );
  }

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
