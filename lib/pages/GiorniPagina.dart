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
    final screenSize = MediaQuery.of(context).size;
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
                displayGiorno(lun, 0,screenSize.width * 0.172),
                SizedBox(width: 5,),
                displayGiorno(mar, 1,screenSize.width * 0.172),
                SizedBox(width: 5,),
                displayGiorno(mer, 2,screenSize.width * 0.172),
                SizedBox(width: 5,),
                displayGiorno(gio, 3,screenSize.width * 0.172),
                SizedBox(width: 5,),
                displayGiorno(ven, 4,screenSize.width * 0.172),
              ],
            )
          ),
        )
    );
  }
  Widget displayGiorno(Giorno giorno, int giornod, double screenSize){
    List<Color> colori = getColors(giorno, giornod);
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
      height: 650,
      width: screenSize,
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
          Text(nomiGiorni[giornod], style: TextStyle(fontSize: 11)),
          Expanded(
            child: ListView.builder(
                itemCount: giorno.orari.length,
                itemBuilder: (context, index) {
                  Ora ora = giorno.orari[index];
                  return SizedBox(
                    height: 85,
                    child: Column(
                      children: [
                        SizedBox(height: 5,),
                        Divider(
                          height: 2,
                          color: colori[index],
                        ),
                        SizedBox(height: 5,),
                        Text("${ora.materia.substring(0, 4) == "TECN" ? "TPSI" : ora.materia == "LINGUA E LETTERATURA ITALIANA" ? "ITAL" : ora.materia.substring(0, 4)} | ${ora.ora}" , style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colori[index],
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2.0, 2.0), // Spostamento orizzontale e verticale dell'ombra
                                blurRadius: 3.0,         // Quanto deve essere sfocata l'ombra
                                color: Colors.black, // Colore dell'ombra con opacità
                              ),
                            ]
                        ),),
                        Text(ora.prof[0], textAlign: TextAlign.center ,style: TextStyle(
                            fontSize: 9,
                            color: colori[index],
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2.0, 2.0), // Spostamento orizzontale e verticale dell'ombra
                                blurRadius: 3.0,         // Quanto deve essere sfocata l'ombra
                                color: Colors.black, // Colore dell'ombra con opacità
                              ),
                            ]
                        ),)
                      ],
                    ),
                  );
                }
            ),
          )
        ],
      ),
    );
  }

  List<Color> getColors(Giorno giorno, int index){
    List<List<Color>> colors = [
    [
      ?Colors.red[300],
      ?Colors.yellow[300],
      ?Colors.cyan[300],
      ?Colors.green[300],
      ?Colors.blue[300],
      ?Colors.red[300],
    ],
    [
      ?Colors.blue[300],
      ?Colors.green[300],
      ?Colors.red[300],
      ?Colors.yellow[300],
      ?Colors.cyan[300],
      ?Colors.red[300],
    ],
    [
      ?Colors.green[300],
      ?Colors.blue[300],

      ?Colors.yellow[300],
      ?Colors.cyan[300],
      ?Colors.red[300],
      ?Colors.green[300],
    ],
     [
      ?Colors.yellow[300],
      ?Colors.cyan[300],
      ?Colors.green[300],
      ?Colors.blue[300],
      ?Colors.orange[300],
       ?Colors.red[300],
    ],
    [
      ?Colors.cyan[300],
      ?Colors.red[300],
      ?Colors.orange[300],
      ?Colors.yellow[300],
      ?Colors.blue[300],
      ?Colors.green[300],
    ]
    ];
    List<Color> scelti = [];
    List<Color> colori = [];
    scelti = colors[index];
    int colorIndex = 0;
    for (int i = 0; i < giorno.orari.length; i++) {
      colori.add(scelti[colorIndex]);
      if(i == giorno.orari.length - 1){
        break;
      }
      if(giorno.orari[i].materia != giorno.orari[i + 1].materia){
        colorIndex ++;
      }
    }
    return colori;
  }
}






