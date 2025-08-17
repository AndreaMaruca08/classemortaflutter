/*
{
            "evtId": 4471544,
            "evtText": "Al termine della lezione di Inglese in laboratorio linguistico, uno studente preme con tale forza i tasti della tastiera che il rumore si sente dalla cattedra. Alla domanda relativamente a chi fosse lo studente responsabile del fatto, nessuno si palesa, pertanto l'annotazione viene comminata a tutti i ragazzi presenti. Premesso che la lezione era stata svolta senza la necessità che gli studenti lavorassero sui singoli PC, si richiama l'intera classe ad un comportamento più responsabile verso le dotazioni del laboratorio, che appartengono all'intera comunità scolastica: è pertanto responsabilità di tutti utilizzarle in modo da non dare luogo a danneggiamenti, così che le attrezzature mantengano la loro funzionalità a vantaggio di tutti.",
            "evtDate": "2024-10-31",
            "authorName": "SQUARATTI MARIA CRISTINA",
            "readStatus": true
        },
 */
class Nota{
  String messaggio;
  String data;
  String nomeProf;
  bool letto;

  Nota({
    required this.messaggio,
    required this.data,
    required this.nomeProf,
    required this.letto,
  });

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      messaggio: json['evtText'],
      data: json['evtDate'],
      nomeProf: json['authorName'],
      letto: json['readStatus'],
    );
  }

  static List<List<Nota>> getNote(Map<String, dynamic> json) {
    List<Nota> annotazioni = [];
    List<Nota> avvisi = [];
    List<Nota> disciplinari = [];
    List<Nota> diClasse = [];
    final annotazioniJson = json['NTTE'];
    final disciplinariJson = json["NTCL"];
    final diClasseJson = json["NTST"];
    final avvisiJson = json["NTWN"];

    if (annotazioniJson != null) {
      annotazioni = annotazioniJson.map<Nota>((item) => Nota.fromJson(item)).toList();
    }
    if (avvisiJson != null) {
      avvisi = avvisiJson.map<Nota>((item) => Nota.fromJson(item)).toList();
    }
    if (disciplinariJson != null) {
      disciplinari = disciplinariJson.map<Nota>((item) => Nota.fromJson(item)).toList();
    }
    if(diClasseJson != null){
      diClasse = diClasseJson.map<Nota>((item) => Nota.fromJson(item)).toList();
    }

    return [disciplinari.reversed.toList(), annotazioni.reversed.toList(), diClasse.reversed.toList(), avvisi.reversed.toList()];
  }


}