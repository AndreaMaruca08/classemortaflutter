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
class Giorno{
  List<Ora> orari;

  Giorno({
    required this.orari,
  });

  factory Giorno.fromJson(Map<String, dynamic> json) {
    List<Ora> l = Ora.fromJsonList(json);
    List<Ora> giorno = [];
    for (Ora o in l) {
      if (o.materia.toUpperCase() != "SOSTEGNO") {
        giorno.add(o);
      }
    }
    return Giorno(
      orari: giorno,
    );
  }
}