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
    int ora = l[0].ora;

    if(ora > 1){
      for(int i = 1; i < ora; i++){
        giorno.add(Ora(materia: "ASSENZA PROF", ora: i, prof: ["ASSENZA"]));
      }
    }

    for (Ora o in l) {
      //non si conta sostegno siccome servono gli orari
      if (o.materia.toUpperCase() == "SOSTEGNO") {
        continue;
      }
      if(ora > o.ora){
        continue;
      }

      giorno.add(o);
      ora++;
    }
    return Giorno(
      orari: giorno,
    );
  }
}