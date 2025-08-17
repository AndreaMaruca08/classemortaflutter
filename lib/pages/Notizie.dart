import 'package:ClasseMorta/service/ApiService.dart';
import 'package:ClasseMorta/widgets/NotiziaWidget.dart';
import 'package:flutter/material.dart';
import '../models/Notizia.dart'; // Assicurati che il percorso del modello Notizia sia corretto

class NotiziePage extends StatelessWidget {
  final List<Notizia>? circolari;
  final List<Notizia>? variazioni;
  final List<Notizia>? altro;
  final List<Notizia>? variazioniDiClasse;
  final Apiservice service; // Nota: 'Apiservice' inizia con la maiuscola per convenzione delle classi

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
              if (variazioni != null && variazioni!.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Variazioni di orario',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: altezzaBloccoNotizie, // Altezza fissa per questo blocco
                  child: ListView.builder(
                    itemCount: variazioni!.length,
                    itemBuilder: (context, index) {
                      final notizia = variazioni![index];
                      return Column(
                        children: [
                          Notiziawidget(notizia: notizia, service: service,),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20), // Spazio tra i blocchi di notizie
              ],

              if (variazioniDiClasse != null && variazioniDiClasse!.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Variazioni di aula',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: altezzaBloccoNotizie,
                  child: ListView.builder(
                    itemCount: variazioniDiClasse!.length,
                    itemBuilder: (context, index) {
                      final notizia = variazioniDiClasse![index];
                      return Column(
                        children: [
                          Notiziawidget(notizia: notizia, service: service,),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20), // Spazio tra i blocchi di notizie
              ],

              // Sezione Circolari
              if (circolari != null && circolari!.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Circolari',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: altezzaBloccoNotizie, // Altezza fissa per questo blocco
                  child: ListView.builder(
                    itemCount: circolari!.length,
                    itemBuilder: (context, index) {
                      final notizia = circolari![index];
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

              // Sezione Altro
              if (altro != null && altro!.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Altro',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: altezzaBloccoNotizie, // Altezza fissa per questo blocco
                  child: ListView.builder(
                    itemCount: altro!.length,
                    itemBuilder: (context, index) {
                      final notizia = altro![index];
                      return Column(
                        children: [
                          Notiziawidget(notizia: notizia, service: service,),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20), // Spazio alla fine dell'ultima sezione, se necessario
              ],

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
}
