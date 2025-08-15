// In Compito.dart
class Info {
  String materia;
  String nomeInsegnante;
  String descrizione;
  String data;

  Info({
    required this.materia,
    required this.nomeInsegnante,
    required this.descrizione,
    required this.data,
  });

  factory Info.fromJson(Map<String, dynamic> json) {
    // Aggiungi controlli null più robusti qui se necessario
    return Info(
      materia: json['subjectDesc'] as String? ?? "Materia non specificata",
      nomeInsegnante: json['authorName'] as String? ?? "Insegnante sconosciuto",
      descrizione: json['notes'] as String? ?? "Nessuna descrizione",
      data: json['evtDatetimeBegin'] as String? ?? "Data non disponibile",
    );
  }

  static List<Info> fromJsonListCompiti(List<Map<String, dynamic>> jsonInput) {
    var filteredIterable = jsonInput.where((item) {
      var notesValue = item['notes'];
      if (notesValue == null) {
        return false;
      }
      String descrizione = notesValue.toString().toLowerCase();
      bool con1 = descrizione.contains("es.");
      bool con2 = descrizione.contains("compit");
      bool con3 = descrizione.contains("consegna");
      return con1 || con2 || con3;
    });

    List<Info> compitiFiltrati = filteredIterable
        .map<Info>((jsonMap) => Info.fromJson(jsonMap))
        .toList();
    return compitiFiltrati.toList();
  }

  static List<Info> fromJsonListAgenda(List<Map<String, dynamic>> jsonInput) {
    var filteredIterable = jsonInput.where((item) {
      var notesValue = item['notes'];
      if (notesValue == null) {
        return false;
      }
      String descrizione = notesValue.toString().toLowerCase();
      bool con1 = descrizione.contains("port");
      bool con2 = descrizione.contains("entrambi");
      return con1 || con2;
    });

    List<Info> compitiFiltrati = filteredIterable
        .map<Info>((jsonMap) => Info.fromJson(jsonMap))
        .toList();
    return compitiFiltrati.toList();
  }

  static List<Info> fromJsonListVerifiche(List<Map<String, dynamic>> jsonInput) {
    var filteredIterable = jsonInput.where((item) {
      var notesValue = item['notes'];
      if (notesValue == null) {
        return false;
      }
      String descrizione = notesValue.toString().toLowerCase();
      bool con1 = descrizione.contains("verific");
      bool con2 = descrizione.contains("compito in classe");
      return con1 || con2;
    });

    List<Info> compitiFiltrati = filteredIterable
        .map<Info>((jsonMap) => Info.fromJson(jsonMap))
        .toList();
    return compitiFiltrati.toList();
  }
}

