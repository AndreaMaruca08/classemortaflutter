import 'package:ClasseMorta/models/SchoolEvent.dart';
import 'package:ClasseMorta/models/enums/EventType.dart';
import 'package:ClasseMorta/service/ApiService.dart';
import 'package:flutter/material.dart';

import '../models/enums/JustificationStatus.dart';
import 'PaginaFormGiustifica.dart';

class Giustifichepagina extends StatelessWidget {
  final List<SchoolEvent>? events;
  final Apiservice service;

  const Giustifichepagina({
    super.key,
    required this.events,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giustifiche'),
      ),
      body: SingleChildScrollView( // Questo permette all'intero Column di essere scorrevole
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              IconButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NuovaGiustificazionePage(service: service,)), // Sostituisci con la tua pagina
                );
              }, icon: Icon(Icons.add)),

              if (events != null && events!.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events!.length,
                  itemBuilder: (BuildContext context, int index) {
                    SchoolEvent evento = events![index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: giustificaWidget(evento),
                    );
                  },
                )
              else
                const Center( // Mostra un messaggio se la lista è vuota o null
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 50.0),
                    child: Text('Nessuna giustifica da visualizzare.'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String getStringFromTipo(EventType type){
    return switch(type){
      EventType.ASSENZA => "Assenza",
      EventType.RITARDO => "Ritardo",
      EventType.USCITA_ANTICIPATA => "Uscita Anticipata",
      EventType.unknown => "Sconosciuto",
    };
  }
  Color getColorFromTipo(EventType type){
    return switch(type){
      EventType.ASSENZA => Colors.red,
      EventType.RITARDO => Colors.orange,
      EventType.USCITA_ANTICIPATA => Colors.yellow,
      EventType.unknown => Colors.grey,
    };
  }

  String getStatoFromTipo(JustificationStatus status){
    return switch(status){
      JustificationStatus.pendingApproval => "In attesa di approvazione",
      JustificationStatus.approved => "Approvata",
      JustificationStatus.rejected => "Rifiutata",
      JustificationStatus.unknown => "Sconosciuta",
    };
  }
  Color getColorFromStato(JustificationStatus status){
    return switch(status){
      JustificationStatus.pendingApproval => Colors.orange,
      JustificationStatus.approved => Colors.green,
      JustificationStatus.rejected => Colors.red,
      JustificationStatus.unknown => Colors.grey,
    };
  }

  Widget giustificaWidget(SchoolEvent event) {
    String title = "Evento Sconosciuto";
    title = getStringFromTipo(event.type);

    // Widget di base per ora
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[850], // Leggermente più chiaro per contrasto se lo sfondo è molto scuro
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Ombra più scura e meno opaca
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Allinea il testo a sinistra
        children: [
          Container(
            decoration: BoxDecoration(
              color: getColorFromTipo(event.type), // Leggermente più chiaro per contrasto se lo sfondo è molto scuro
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Ombra più scura e meno opaca
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: Text(
              "     $title      ",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

          ),
          Text(
            "Autore: ${event.author}", // Meglio aggiungere un'etichetta
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Inserito il: ${event.insertionDate}", // Aggiungi altri dettagli rilevanti
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Motivazione: ${event.motivation}", // Aggiungi altri dettagli rilevanti
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Stato: ${getStatoFromTipo(event.status)}", // Aggiungi altri dettagli rilevanti
            style: TextStyle(
              color: getColorFromStato(event.status),
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
