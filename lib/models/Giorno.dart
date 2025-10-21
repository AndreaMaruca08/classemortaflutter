import 'package:classemorta/service/ApiService.dart';

import 'Ora.dart';
/*
  {
  "lessons":  [
    {
            "evtId": 23604280,
            "evtDate": "2025-05-30",
            "evtCode": "LSF0",
            "evtHPos": 4,
            "evtDuration": 1,
            "classDesc": "3CI INFORMATICA",
            "authorName": "CERELLO STEFANO",
            "subjectId": 241759,
            "subjectCode": null,
            "subjectDesc": "MATEMATICA E COMPLEMENTI",
            "lessonType": "Lezione",
            "lessonArg": "Consegna verifica sui logaritmi. Interrogazione Pellecchia."
  },
 ]
}
 */
class Giorno {
  List<Ora> orari;

  Giorno({
    required this.orari,
  });

  static Future<Giorno> fromJson(Map<String, dynamic> json, int giornoInt,
      DateTime lunediScorso, Apiservice service) async {
    List<Ora> l = Ora.fromJsonList(json);
    List<Ora> giorno = [];
    int oraCorrente = 1;
    l.sort((a, b) => a.ora.compareTo(b.ora));

    String nomeSostegno = "";
    for(Ora o in l){
      if(o.materia.toUpperCase() == "SOSTEGNO") {
        nomeSostegno = o.prof[0];
      }
    }

    for (int j = 0; j < l.length; j++) {
      Ora o = l[j];

      // Non si conta sostegno siccome servono gli orari
      if (o.materia.toUpperCase() == "SOSTEGNO" || o.prof[0] == nomeSostegno) {
        continue;
      }


      if (o.ora > oraCorrente) {
        int diff = o.ora - oraCorrente;

        List<Ora> oreSettimanaPrecedente = Ora.fromJsonList(
            await service.getGiornoJson(
                lunediScorso.subtract(Duration(days: 7)).add(
                    Duration(days: giornoInt))));

        for (int i = 0; i < diff; i++) {
          if ((oraCorrente - 1) < oreSettimanaPrecedente.length) {
            giorno.add(oreSettimanaPrecedente[oraCorrente - 1]);
          }
          oraCorrente++;
        }
        j--;
        continue;
      }

      if (o.ora < oraCorrente) {
        Ora? oraPrecedente;
        try {
          oraPrecedente = giorno.lastWhere((ora) => ora.ora == o.ora &&  o.prof[0] != nomeSostegno);
        } catch (e) {
          oraPrecedente = null;
        }

        // Se abbiamo trovato un'ora corrispondente...
        if (oraPrecedente != null) {
          // ...e la materia è la stessa e il professore non è già presente...
          if (oraPrecedente.materia == o.materia &&
              !oraPrecedente.prof.contains(o.prof[0])) {
            // ...allora aggiungiamo il nuovo professore alla lista dei professori dell'ora esistente.
            oraPrecedente.prof.add(o.prof[0]);
          }
        }

        // In ogni caso, saltiamo l'elaborazione ulteriore di questa ora 'doppiona'.
        continue;
      }


      // --- Aggiunta di un'ora normale ---
      giorno.add(o);
      oraCorrente++;
    }

    return Giorno(
      orari: giorno,
    );
  }
}
