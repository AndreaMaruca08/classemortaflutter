import 'package:flutter/material.dart';
import '../models/Giorno.dart';
import '../models/Ora.dart';

class Giornipagina extends StatelessWidget {
  final List<List<Giorno>> giorniLista;
  const Giornipagina({
    super.key,
    required this.giorniLista,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    List<Giorno> giorni = giorniLista[0];
    Giorno lun = giorni[0];
    Giorno mar = giorni[1];
    Giorno mer = giorni[2];
    Giorno gio = giorni[3];
    Giorno ven = giorni[4];

    //settimana prima ancora
    List<Giorno> giorniScorsi = giorniLista[1];
    Giorno lunS = giorniScorsi[0];
    Giorno marS = giorniScorsi[1];
    Giorno merS = giorniScorsi[2];
    Giorno gioS = giorniScorsi[3];
    Giorno venS = giorniScorsi[4];

    // Larghezza di ogni colonna giorno, calcolata in modo che circa 5 siano visibili.
    // Puoi aggiustare il moltiplicatore per decidere quanti giorni mostrare senza scorrere.
    double gr = screenSize.width * 0.18; // Leggermente aumentato per più spazio

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orari settimanali'),
      ),
      // ### CORREZIONE PRINCIPALE ###
      // 1. SingleChildScrollView con scrollDirection orizzontale.
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // <-- L'istruzione chiave!
        physics: const ClampingScrollPhysics(),
        // 2. Padding spostato dentro per non interferire con lo scroll.
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          // 3. La Row ora può espandersi orizzontalmente quanto vuole,
          //    perché il SingleChildScrollView gestirà lo scorrimento.
          child: Row(
            children: [
              displayGiorno(lun, 0, gr),
              const SizedBox(width: 5),
              displayGiorno(mar, 1, gr),
              const SizedBox(width: 5),
              displayGiorno(mer, 2, gr),
              const SizedBox(width: 5),
              displayGiorno(gio, 3, gr),
              const SizedBox(width: 5),
              displayGiorno(ven, 4, gr),

              // Separatore visivo tra le due settimane
              const SizedBox(width: 20),

              displayGiorno(lunS, 0, gr),
              const SizedBox(width: 5),
              displayGiorno(marS, 1, gr),
              const SizedBox(width: 5),
              displayGiorno(merS, 2, gr),
              const SizedBox(width: 5),
              displayGiorno(gioS, 3, gr),
              const SizedBox(width: 5),
              displayGiorno(venS, 4, gr),
            ],
          ),
        ),
      ),
    );
  }

  // ... il resto del codice (displayGiorno, getColors) rimane invariato ...
  // Ho rimosso le '?' dalla lista di colori che causavano un errore di sintassi.
  Widget displayGiorno(Giorno giorno, int giornod, double screenSize){
    List<Color?> colori = getColors(giorno, giornod); // Usare Color? per coerenza
    List<String> nomiGiorni = [
      'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì', 'Venerdì', 'Sabato', 'Domenica',
    ];
    return Container(
      height: 750, // L'altezza fissa è ok perché lo scroll è orizzontale
      width: screenSize,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(240, 240, 240, 0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(nomiGiorni[giornod], style: TextStyle(fontSize: 11)),
          Expanded(
            child: ListView.builder(
                itemCount: giorno.orari.length,
                itemBuilder: (context, index) {
                  Ora ora = giorno.orari[index];
                  return SizedBox(
                    height: 90,
                    child: Column(
                      children: [
                        const SizedBox(height: 5,),
                        Divider(
                          height: 2,
                          color: colori[index],
                        ),
                        const SizedBox(height: 5,),
                        Text(
                          "${ora.materia.substring(0, 4) == "TECN"
                              ? "TPSI"
                              : ora.materia == "LINGUA E LETTERATURA ITALIANA"
                              ? "ITAL"
                              : ora.materia.substring(0, 4)}${ora.prof.length == 2 ? " ★" : ""} | ${ora.ora}",
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: colori[index],
                              shadows: const <Shadow>[
                                Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 3.0,
                                  color: Colors.black,
                                ),
                              ]
                          ),),
                        Text("${ora.prof[0]} \n${ora.prof.length > 1 ? "--------- \n${ora.prof[1]}" : ""}", textAlign: TextAlign.center ,style: TextStyle(
                            fontSize: ora.prof.length > 1 ? 6.5:8,
                            color: colori[index],
                            shadows: const <Shadow>[
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.black,
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

  List<Color?> getColors(Giorno giorno, int index){
    List<List<Color?>> colors = [
      [
        Colors.red[300], Colors.yellow[300], Colors.cyan[300], Colors.green[300], Colors.blue[300], Colors.red[300], Colors.red[300], Colors.yellow[300],
      ],
      [
        Colors.blue[300], Colors.green[300], Colors.red[300], Colors.yellow[300], Colors.cyan[300], Colors.red[300],Colors.blue[300], Colors.green[300]
      ],
      [
        Colors.green[300], Colors.blue[300], Colors.yellow[300], Colors.cyan[300], Colors.red[300], Colors.green[300],Colors.yellow[300], Colors.blue[300]
      ],
      [
        Colors.yellow[300], Colors.cyan[300], Colors.green[300], Colors.blue[300], Colors.orange[300], Colors.red[300],Colors.yellow[300], Colors.cyan[300]
      ],
      [
        Colors.cyan[300], Colors.red[300], Colors.orange[300], Colors.yellow[300], Colors.blue[300], Colors.green[300],Colors.cyan[300], Colors.red[300]
      ]
    ];
    List<Color?> scelti = [];
    List<Color?> colori = [];
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
