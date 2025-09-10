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
class Ora{
  String materia;
  List<String> prof;
  int ora;

  Ora({
    required this.materia,
    required this.prof,
    required this.ora,
  });

  factory Ora.fromJson(Map<String, dynamic> json) {
    return Ora(
      materia: json['subjectDesc'],
      prof: [json['authorName']],
      ora: json['evtHPos'],
    );
  }

  static List<Ora> fromJsonList(Map<String, dynamic> json) {
    final lezi = json['lessons'];
    List<Ora> lezioni = lezi
        .map<Ora>((jsonMap) => Ora.fromJson(jsonMap))
        .toList();
    return lezioni;
  }


}