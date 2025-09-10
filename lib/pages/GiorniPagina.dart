import 'package:flutter/material.dart';
import '../models/Giorno.dart';
import '../models/Ora.dart';

class Giornipagina extends StatelessWidget {
  final List<Giorno> giorni;
  const Giornipagina({
    super.key,
    required this.giorni,
  });

  @override
  Widget build(BuildContext context) {

    Giorno lun = giorni[0];
    Giorno mar = giorni[1];
    Giorno mer = giorni[2];
    Giorno gio = giorni[3];
    Giorno ven = giorni[4];

    return Scaffold(
        appBar: AppBar(
          title: const Text('Orari settimanali'),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(), // o rimuovila per il default
          child: Padding( // Aggiungi padding generale se necessario
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                displayGiorno(lun, 0),
                SizedBox(width: 5,),
                displayGiorno(mar, 1),
                SizedBox(width: 5,),
                displayGiorno(mer, 2),
                SizedBox(width: 5,),
                displayGiorno(gio, 3),
                SizedBox(width: 5,),
                displayGiorno(ven, 4),
              ],
            )
          ),
        )
    );
  }
  Widget displayGiorno(Giorno giorno, int giornod){
    List<String> nomiGiorni = [
      'Lunedì',
      'Martedì',
      'Mercoledì',
      'Giovedì',
      'Venerdì',
      'Sabato',
      'Domenica',
    ];
    return Container(
      height: 500,
      width: 75,
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
      // Dentro il metodo displayGiorno
      child: Column(
        children: [
          Text(nomiGiorni[giornod]),
          Expanded(
            child: ListView.builder(
                itemCount: giorno.orari.length,
                itemBuilder: (context, index) {
                  Ora ora = giorno.orari[index];
                  return Column(
                    children: [
                      SizedBox(height: 5,),
                      Divider(
                        height: 2,
                        color: Colors.white,
                      ),
                      SizedBox(height: 5,),
                      Text(ora.materia.substring(0, 4) , style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(2.0, 2.0), // Spostamento orizzontale e verticale dell'ombra
                              blurRadius: 3.0,         // Quanto deve essere sfocata l'ombra
                              color: Colors.black.withOpacity(0.5), // Colore dell'ombra con opacità
                            ),
                          ]
                      ),),
                      Text(ora.prof[0], textAlign: TextAlign.center ,style: TextStyle(
                          fontSize: 10,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(2.0, 2.0), // Spostamento orizzontale e verticale dell'ombra
                              blurRadius: 3.0,         // Quanto deve essere sfocata l'ombra
                              color: Colors.black.withOpacity(0.5), // Colore dell'ombra con opacità
                            ),
                          ]
                      ),)
                    ],
                  );
                }
            ),
          )
        ],
      ),
    );
  }
}






