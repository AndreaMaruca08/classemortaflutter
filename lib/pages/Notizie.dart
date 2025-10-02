import 'package:classemorta/service/ApiService.dart';
import 'package:classemorta/widgets/NotiziaWidget.dart';
import 'package:flutter/material.dart';
import '../models/Notizia.dart'; // Assicurati che il percorso del modello Notizia sia corretto

class NotiziePage extends StatelessWidget {
  final List<Notizia>? circolari;
  final List<Notizia>? variazioni;
  final List<Notizia>? altro;
  final List<Notizia>? variazioniDiClasse;
  final Apiservice service;

  const NotiziePage({
    super.key,
    required this.circolari,
    required this.variazioni,
    required this.altro,
    required this.variazioniDiClasse,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    // Definisci un'altezza comune per i blocchi di notizie
    // Puoi regolare questo valore in base al design e a quanti item vuoi mostrare prima dello scroll
    const double altezzaBloccoNotizie = 300.0; // Esempio: 200 pixels di altezza

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notizie'),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Padding generale per il contenuto
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Allinea i titoli delle sezioni a sinistra
            children: [
              // Sezione Variazioni di orario
              buildBloccoNotizie("Variazioni di orario", variazioni),
              // Variazioni di aula
              buildBloccoNotizie("Variazioni di aula", variazioniDiClasse),
              // Sezione Circolari
              buildBloccoNotizie('Circolari', circolari),
              // Sezione Altro
              buildBloccoNotizie('Altro', altro),

              // Messaggio se non ci sono notizie di nessun tipo
              if ((variazioni == null || variazioni!.isEmpty) &&
                  (circolari == null || circolari!.isEmpty) &&
                  (altro == null || altro!.isEmpty) &&
                  (variazioniDiClasse == null || variazioniDiClasse!.isEmpty)) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30.0),
                    child: Text(
                      'Nessuna notizia disponibile al momento.',
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBloccoNotizie(String titolo, List<Notizia>? notizie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (notizie != null && notizie!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              titolo,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: notizie.length == 1 ? 230 : 400, // Altezza fissa per questo blocco
            child: ListView.builder(
              itemCount: notizie.length,
              itemBuilder: (context, index) {
                final notizia = notizie[index];
                return Column(
                  children: [
                    Notiziawidget(notizia: notizia, service: service),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20), // Spazio tra i blocchi di notizie
        ],
      ]
    );
  }
}
