import 'package:ClasseMorta/models/Info.dart';
import 'package:flutter/material.dart';

class InfoSingola extends StatelessWidget {
  final Info info;
  const InfoSingola({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87;

    return Container(
      height: 450,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: getColor(info.data)?.withOpacity(0.3),
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
          mainAxisSize: MainAxisSize.min, // La Column cerca di essere il più piccola possibile, ma l'Expanded la forzerà a riempirsi
          children: [
            Text(
              info.materia.length > 35
                  ? "${info.materia.substring(0, 35)}..."
                  : info.materia,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: textColor),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_month, size: 16, color: textColor.withOpacity(0.8)),
                SizedBox(width: 6),
                Text(
                  "${info.data.length > 10 ? info.data.substring(0, 10) : info.data} - ${getDistanza(info.data)}",
                  style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.9)),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: textColor.withOpacity(0.8)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    info.nomeInsegnante,
                    style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.9)),
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
                    child: Icon(Icons.description, size: 16, color: textColor.withOpacity(0.8)),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        info.descrizione,
                        style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.9)),
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

  // ... il tuo metodo getColor ...
  Color? getColor(String dataString) {
    try {
      DateTime today = DateTime.now(); // Considera di usare DateTime.now() per la data corrente reale
      DateTime scadenza = DateTime.parse(dataString.substring(0,10));
      DateTime scadenzaDateOnly = DateTime(scadenza.year, scadenza.month, scadenza.day);

      if (scadenzaDateOnly.isBefore(today)) {
        return Colors.grey[600];
      }
      Duration differenza = scadenzaDateOnly.difference(today);
      if(differenza.inDays <= 1){
        return Colors.red[500];
      }
      if (differenza.inDays <= 2) {
        return Colors.red[300];
      }
      if (differenza.inDays <= 7) {
        return Colors.green[300];
      }
      return Colors.green[600];
    } catch (e) {
      return Colors.grey[300];
    }
  }

  // ... il tuo metodo getDistanza ...
  String getDistanza(String dataString) {
    try {
      // DateTime now = DateTime.now(); // Non usato se today è hardcoded
      DateTime today = DateTime.now(); // Considera di usare DateTime.now() per la data corrente reale
      DateTime scadenza = DateTime.parse(dataString.substring(0,10));
      DateTime scadenzaDateOnly = DateTime(scadenza.year, scadenza.month, scadenza.day);

      if (scadenzaDateOnly.isBefore(today)) {
        return "Già passata";
      }
      if(scadenzaDateOnly.isAtSameMomentAs(today)){
        return "PER OGGI !!!";
      }
      Duration differenza = scadenzaDateOnly.difference(today);
      if(differenza.inDays == 1){
        return "DOMANI !!!";
      }
      return "${differenza.inDays.toString()} giorni";

    } catch (e) {
      return "Errore";
    }
  }
}
