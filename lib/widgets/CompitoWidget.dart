import 'package:classemorta/models/Info.dart';
import 'package:flutter/material.dart';

class InfoSingola extends StatelessWidget {
  final Info info;
  const InfoSingola({super.key, required this.info});

  bool materiaIsNull(){
    return info.materia == "null";
  }
  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;

    return Container(
      height: 450,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: getColor(info.dataFine)?.withOpacity(0.3),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize
              .min, // La Column cerca di essere il più piccola possibile, ma l'Expanded la forzerà a riempirsi
          children: [
            Text(
              materiaIsNull() ? info.nomeInsegnante :
              info.materia.length > 35
                  ? "${info.materia.substring(0, 35)}..."
                  : info.materia,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: textColor,
              ),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: textColor.withOpacity(0.8),
                ),
                SizedBox(width: 6),
                Text(
                  getData(info.data),
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor.withOpacity(0.9),
                  ),
                ),
                Text(
                  " - ${getDistanza(info.data)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.watch_later_outlined,
                  size: 16,
                  color: textColor.withOpacity(0.8),
                ),
                SizedBox(width: 6),
                Text(
                  info.orario,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if(!materiaIsNull())
            Row(
              children: [
                Icon(Icons.person, size: 16, color: textColor.withOpacity(0.8)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    info.nomeInsegnante,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Divider(thickness: 1, color: textColor),
            SizedBox(height: 4), // Aggiunto un piccolo spazio dopo il Divider
            // DESCRIZIONE:
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Icon(
                      Icons.description,
                      size: 16,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        info.descrizione,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Color? getColor(String dataFine) {
    try {
      DateTime today = DateTime.now(); // Considera di usare DateTime.now() per la data corrente reale
      DateTime scadenzaFine = DateTime.parse(dataFine.substring(0, 19));
      DateTime scadenzaGen = DateTime.parse(dataFine.substring(0, 10));
      Duration differenzaGen = scadenzaGen.difference(today);
      if (scadenzaFine.isBefore(today) ) {
        return today.hour < scadenzaFine.hour ? Colors.red : Colors.grey;
      }
      if (differenzaGen.inDays == 0) {
        return Color.fromRGBO(255, 100,100, 0.5);
      }
      if (differenzaGen.inDays == 1) {
        return Colors.orange[700];
      }
      if (differenzaGen.inDays == 2) {
        return Colors.orange[300];
      }
      if (differenzaGen.inDays <= 6) {
        return Colors.green[300];
      }
      return Colors.green[600];
    } catch (e) {
      return Colors.grey[300];
    }
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

  String getDistanza(String dataString) {

    try {
      DateTime today = DateTime.now(); // Considera di usare DateTime.now() per la data corrente reale
      DateTime scadenza = DateTime.parse(dataString.substring(0, 10));
      DateTime scadenzaDateOnly = DateTime(
        scadenza.year,
        scadenza.month,
        scadenza.day,
      );
      Duration differenza = scadenzaDateOnly.difference(today);
      if(differenza.inHours < -14){
        return "Oggi passato";
      }
      if (scadenzaDateOnly.isBefore(today)) {
        return "PER OGGI !!!";
      }
      if (differenza.inDays == 0) {
        return "DOMANI !!!";
      }
      if (differenza.inDays == 1) {
        return "Dopo domani";
      }
      return "${(differenza.inDays + 1).toString()} giorni";

    } catch (e) {
      return "Errore";
    }
  }
}
