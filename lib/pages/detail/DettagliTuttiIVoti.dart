import 'package:classemorta/service/ApiService.dart';
import 'package:flutter/material.dart';
import '../../models/Voto.dart';
import '../../widgets/VotoDisplay.dart';

// Ho corretto anche il titolo dell'AppBar per riflettere il contenuto
class Dettaglituttiivoti extends StatelessWidget {
  final List<Voto> voti;
  final Apiservice service;
  const Dettaglituttiivoti({
    required this.voti,
    required this.service,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Titolo più appropriato per la pagina
        title: const Text('Tutti i Voti'),
      ),
      // RIMOSSO SingleChildScrollView
      body: ListView.builder(
        // NON serve più shrinkWrap: true
        // IMPOSTA la fisica di scorrimento desiderata (o lascia il default)
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: voti.length,
        itemBuilder: (context, index) {
          Voto votoCorrente = voti[index];
          Voto? precedenteCronologico;

          // Cerca negli elementi SUCCESSIVI della lista (che sono cronologicamente PRECEDENTI)
          for (int j = index + 1; j < voti.length; j++) {
            if (voti[j].codiceMateria == votoCorrente.codiceMateria) {
              precedenteCronologico = voti[j]; // Trovato il primo voto cronologicamente precedente della stessa materia
              break;
            }
          }

          return Votodisplay(
            voto: votoCorrente,
            precedente: precedenteCronologico,
            grandezza: 88,
            ms: service.impostazioni.msAnimazioneVoto,
          );
        },
      ),
    );
  }
}
