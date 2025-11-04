/*
esempio di json ricevuto:
{
            "subjectId": 241774,
            "subjectCode": "TEL",
            "subjectDesc": "TELECOMUNICAZIONI",
            "evtId": 1984501,
            "evtCode": "GRV0",
            "evtDate": "2024-12-05",
            "decimalValue": 7.5,
            "displayValue": "7½",
            "displaPos": 1,
            "notesForFamily": "prima relazione: resistenze serie parallelo",
            "color": "green",
            "canceled": false,
            "underlined": false,
            "periodPos": 1,
            "periodDesc": "Quadrimestre",
            "periodLabel": "1° Quadrimestre",
            "componentPos": 3,
            "componentDesc": "Pratico",
            "weightFactor": 1,
            "skillId": 0,
            "gradeMasterId": 0,
            "skillDesc": null,
            "skillCode": null,
            "skillMasterId": 0,
            "skillValueDesc": "",
            "skillValueShortDesc": null,
            "skillValueNote": "",
            "oldskillId": 0,
            "oldskillDesc": "",
            "noAverage": false,
            "teacherName": "TACCA ERMES"
        },
 */
class Voto{
  String codiceMateria;
  String nomeInteroMateria;
  String dataVoto;
  double voto;
  String displayValue;
  String descrizione;
  int periodo;
  String tipo;
  bool cancellato;
  String nomeProf;
  Voto({
    required this.codiceMateria,
    required this.nomeInteroMateria,
    required this.dataVoto,
    required this.voto,
    required this.displayValue,
    required this.descrizione,
    required this.periodo,
    required this.tipo,
    required this.cancellato,
    required this.nomeProf,
  });
  factory Voto.fromJson(Map<String, dynamic> json){
    return Voto(
      codiceMateria: json['subjectCode'] ?? "",
      nomeInteroMateria: json['subjectDesc'] ?? "",
      dataVoto: json['evtDate'] ?? "",
      voto: json['decimalValue'] == null ? 0.0: json['decimalValue'].toDouble(),
      displayValue: json['displayValue'] ?? '',
      descrizione: json['notesForFamily'] ?? "",
      periodo: json['periodPos'] == 3 ? 2 : json['periodPos'],
      tipo: json['componentDesc'],
      cancellato: json['canceled'],
      nomeProf: json['teacherName'] ?? "",
    );
  }
  static List<Voto> fromJsonList(Map<String, dynamic> json){
    final voti = json['grades'];
    return voti.map<Voto>((json) => Voto.fromJson(json)).toList();
  }

  static List<Voto> perAchievmentVoto(List<dynamic> votiList) {
    var a =  votiList.map<Voto>((jsonMap) => Voto.fromJson(jsonMap)).toList();
    List<Voto> votiOrdinabili = List<Voto>.from(a);

    votiOrdinabili.sort((a, b) {
      bool aIsValid = a.dataVoto.length == 10; // Adattato per "AAAA-MM-GG"
      bool bIsValid = b.dataVoto.length == 10; // Adattato per "AAAA-MM-GG"
      if (aIsValid && !bIsValid)
        return -1; // 'a' valida, 'b' no -> 'a' (più recente) viene prima
      if (!aIsValid && bIsValid)
        return 1; // 'b' valida, 'a' no -> 'b' (più recente) viene prima
      if (!aIsValid && !bIsValid)
        return 0; // Entrambe non valide per lunghezza, ordine invariato
      return b.dataVoto.compareTo(a.dataVoto);
    });
    return votiOrdinabili;
  }
}