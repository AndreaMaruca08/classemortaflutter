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
class Lezione{
  String prof;
  String materia;
  String data;
  String tipo;
  String argomento;
  int durataOre;
  int ora;

  Lezione({
    required this.prof,
    required this.materia,
    required this.data,
    required this.tipo,
    required this.argomento,
    required this.durataOre,
    required this.ora,

  });

  factory Lezione.fromJson(Map<String, dynamic> json) {
    return Lezione(
      prof: json['authorName'],
      materia: json['subjectDesc'],
      data: json['evtDate'],
      tipo: json['lessonType'],
      argomento: json['lessonArg'],
      durataOre: json['evtDuration'],
      ora: json['evtHPos'],
    );

  }

  static List<Lezione> fromJsonList(Map<String, dynamic> json){
    final not = json['lessons'];
    List<Lezione> lezioni = not.map<Lezione>((jsonMap) => Lezione.fromJson(jsonMap)).toList();

    List<Lezione> lezioneFiltrate = [];

    for(Lezione l in lezioni){
      if(l.materia != "SOSTEGNO"){
        lezioneFiltrate.add(l);
      }
    }

    lezioneFiltrate.sort((a, b) => a.ora.compareTo(b.ora));

    return lezioneFiltrate;
  }

}