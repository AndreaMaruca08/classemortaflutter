import 'package:classemorta/models/PeriodoFestivo.dart';
import 'package:flutter/material.dart';

class Vacanzepage extends StatelessWidget {
  final List<PeriodoFestivo> periodi;
  const Vacanzepage({
    super.key,
    required this.periodi,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    DateTime natale = DateTime(DateTime.now().year, 12, 25);
    DateTime fineScuola = periodi[periodi.length - 1].inizio;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Vacanze'),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(), // o rimuovila per il default
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("    Eventi speciali", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                eventoSpeciale(natale, "Natale", screenSize.width * 0.95),
                eventoSpeciale(fineScuola, "Fine della scuola", screenSize.width * 0.95),
                const Text("    Periodi di vacanza (no weekend)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                const SizedBox(height: 10,),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: periodi.length,
                  itemBuilder: (BuildContext context, int index) {
                    final periodo = periodi[index];

                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: singoloPeriodo(periodo),
                    );
                  },
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        )
    );
  }
  String getData(String dataString){
    List<String> nomiGiorni = [
      'Lunedì',
      'Martedì',
      'Mercoledì',
      'Giovedì',
      'Venerdì',
      'Sabato',
      'Domenica',
    ];
    List<String> nomiMesi = [
      'Gennaio',
      'Febbraio',
      'Marzo',
      'Aprile',
      'Maggio',
      'Giugno',
      'Luglio',
      'Agosto',
      'Settembre',
      'Ottobre',
      'Novembre',
      'Dicembre',
    ];
    DateTime scadenza = DateTime.parse(dataString.substring(0, 10));
    DateTime scadenzaDateOnly = DateTime(
      scadenza.year,
      scadenza.month,
      scadenza.day,
    );

    String data = "${nomiGiorni[scadenzaDateOnly.weekday - 1].substring(0, 3)} "
        "${scadenzaDateOnly.day} ${nomiMesi[scadenzaDateOnly.month - 1].substring(0, 3)} "
        "${scadenzaDateOnly.year}";


    return data;
  }

  bool eEstivo(PeriodoFestivo periodo){
    return periodo.inizio.month >= 6 && periodo.fine.month <= 9  && periodo.inizio.year == periodo.fine.year && periodo.fine.month != periodo.inizio.month;
  }

  String getDistance(DateTime time){
    DateTime now = DateTime.now();
    Duration diff = time.difference(now);
    if(diff.inDays < 0){
      return "Già passata :(";
    }else{
      return "Mancano ${diff.inDays} giorni";
    }
  }

  Widget singoloPeriodo(PeriodoFestivo periodo){
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
      child: Column(
        children: [
          Text("${eEstivo(periodo) ? "Vacanza estiva" : "Vacanza normale"} - ${periodo.fine.difference(periodo.inizio).inDays + 1} giorni  ", style: TextStyle(color: eEstivo(periodo)? Colors.blue  : Colors.green),),
          Text("${getData(periodo.inizio.toString())}  | ${getData(periodo.fine.toString())}"),
          Text(getDistance(periodo.inizio))
        ],
      ),
    );
  }

  Widget eventoSpeciale(DateTime time, String title, double size){
    DateTime now = DateTime.now();
    return SizedBox(
      width: size,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(240, 240, 240, 0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            Text("Giorni: ${time.difference(now).inDays}", style: TextStyle(fontSize: 16)),
            Text("Ore ${time.difference(now).inHours}", style: TextStyle(fontSize: 16)),
            Text("Min ${time.difference(now).inMinutes}", style: TextStyle(fontSize: 16)),
            Text("Sec ${time.difference(now).inSeconds}", style: TextStyle(fontSize: 16)),
          ],
        ),
      )
    );
  }

}
