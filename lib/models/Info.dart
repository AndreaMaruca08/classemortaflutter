// In Compito.dart
class Info {
  String materia;
  String nomeInsegnante;
  String descrizione;
  String data;
  String dataFine;
  String orario;

  Info({
    required this.materia,
    required this.nomeInsegnante,
    required this.descrizione,
    required this.data,
    required this.orario,
    required this.dataFine,
  });

  factory Info.fromJson(Map<String, dynamic> json) {
    String ora = "${json['evtDatetimeBegin'].toString().substring(11,  16)} - ${json['evtDatetimeEnd'].toString().substring(11,  16)}";
    return Info(
      materia: json['subjectDesc'] as String? ?? "null",
      nomeInsegnante: json['authorName'] as String? ?? "Insegnante sconosciuto",
      descrizione: json['notes'] as String? ?? "Nessuna descrizione",
      data: json['evtDatetimeBegin'] as String? ?? "Data non disponibile",
      dataFine: json['evtDatetimeEnd'] as String? ?? "Data non disponibile",
      orario: ora,
    );
  }

  static List<int> getTimes(List<Map<String, dynamic>> jsonInput){
    List<Info> info = fromJsonList(jsonInput);
    /*
      0 = per domani;
      1 = dopodomani;
      2 = 3 giorni;
      3 = 4 - 7 giorni;
      4 = 8 - 15 giorni;
      5 = oltre 15 giorni;
     */
    int contaD = 0, contaDD = 0, conta3 = 0, conta4_7 = 0, conta8_15 = 0, conta15piu = 0;
    for(Info i in info){
      DateTime dataScadenza = DateTime.tryParse(i.dataFine.substring(0,10)) ?? DateTime(2100);
      DateTime today = DateTime.now();
      int differenza = dataScadenza.difference(today).inDays;
      if(differenza == 0){
        contaD ++;
      }else if(differenza == 1){
        contaDD ++;
      }else if(differenza == 2){
        conta3 ++;
      }else if(differenza >= 3 && differenza <= 6){
        conta4_7 ++;
      }else if(differenza >= 7 && differenza <= 14){
        conta8_15 ++;
      }else{
        conta15piu ++;
      }
      print("differenza: $differenza");
    }
    return [contaD, contaDD, conta3, conta4_7, conta8_15, conta15piu];
  }

  static List<Info> fromJsonListCompiti(List<Map<String, dynamic>> jsonInput) {
    var filteredIterable = jsonInput.where((item) {
      var notesValue = item['notes'];
      if (notesValue == null) return false;

      String descrizione = notesValue.toString().toLowerCase();
      bool con1 = descrizione.contains("es.");
      bool con11 = descrizione.contains("eserc");
      bool con2 = descrizione.contains("compit");
      bool con3 = descrizione.contains("consegna");
      bool con7 = descrizione.contains("invalsi");
      bool con4 = !descrizione.contains("verific");
      bool con5 = !descrizione.contains("interroga");
      bool con6 = descrizione.contains("studia");
      bool con8 = descrizione.contains("n.");
      bool con9 = descrizione.contains("scheda");
      bool con10 = descrizione.contains("finire");
      bool con12 = descrizione.contains("leggere");
      bool con13 = descrizione.contains("version");



      return (con1 || con11 || con2 || con3 || con6 || con7 || con8 || con9 || con10 || con12 || con13) && con4 && con5;
    });

    List<Info> compitiFiltrati =
    filteredIterable.map<Info>((jsonMap) => Info.fromJson(jsonMap)).toList();

    compitiFiltrati.sort((a, b) {
      DateTime da = DateTime.tryParse(a.data) ?? DateTime(2100);
      DateTime db = DateTime.tryParse(b.data) ?? DateTime(2100);
      return da.compareTo(db);
    });

    return compitiFiltrati;
  }

  static List<Info> fromJsonListAgenda(List<Map<String, dynamic>> jsonInput) {
    var filteredIterable = jsonInput.where((item) {
      var notesValue = item['notes'];
      if (notesValue == null) return false;

      String descrizione = notesValue.toString().toLowerCase();
      bool con1 = descrizione.contains("port");
      bool con2 = descrizione.contains("entrambi");
      bool con3 = !descrizione.contains("interroga");
      bool con4 = !descrizione.contains("compito in classe");
      bool con5 = !descrizione.contains("verific");
      bool con6 = !descrizione.contains("recuper");
      bool con7 = !descrizione.contains("writ");
      bool con8 = !descrizione.contains("speak");
      bool con9 = !descrizione.contains("liste");
      bool con10 = !descrizione.contains("test");

      return (con1 || con2) && con3 && con4 && con5 && con6 && con7 && con8 && con9 && con10;
    });

    List<Info> compitiFiltrati =
    filteredIterable.map<Info>((jsonMap) => Info.fromJson(jsonMap)).toList();

    compitiFiltrati.sort((a, b) {
      DateTime da = DateTime.tryParse(a.data) ?? DateTime(2100);
      DateTime db = DateTime.tryParse(b.data) ?? DateTime(2100);
      return da.compareTo(db);
    });

    return compitiFiltrati;
  }

  static List<Info> fromJsonListVerifiche(List<Map<String, dynamic>> jsonInput) {
    var filteredIterable = jsonInput.where((item) {
      var notesValue = item['notes'];
      if (notesValue == null) return false;

      String descrizione = notesValue.toString().toLowerCase();
      bool con1 = descrizione.contains("verific");
      bool con3 = descrizione.contains("interroga");
      bool con2 = descrizione.contains("compito in classe");
      bool con4 = descrizione.contains("recuper");
      bool con5 = descrizione.contains("writ");
      bool con6 = descrizione.contains("speak");
      bool con7 = descrizione.contains("liste");
      bool con8 = descrizione.contains("test");
      bool con9 = descrizione.contains("presentazion");
      bool con10 = descrizione.contains("tema");

      return con1 || con2 || con3 || con4 || con5 || con6 || con7 || con8 || con9 || con10;
    });

    List<Info> compitiFiltrati =
    filteredIterable.map<Info>((jsonMap) => Info.fromJson(jsonMap)).toList();

    compitiFiltrati.sort((a, b) {
      DateTime da = DateTime.tryParse(a.data) ?? DateTime(2100);
      DateTime db = DateTime.tryParse(b.data) ?? DateTime(2100);
      return da.compareTo(db);
    });

    return compitiFiltrati;
  }

  static List<Info> fromJsonPerDomani(List<Map<String, dynamic>> jsonInput){
    var perDomani = jsonInput.where((item) {
      var data = item['evtDatetimeEnd'];
      if (data == null) return false;
      DateTime dataScadenza = DateTime.tryParse(data.toString().substring(0,10)) ?? DateTime(2100);
      DateTime today = DateTime.now();
      return dataScadenza.difference(today).inDays == 0;
    });
    List<Info> compitiFiltrati =
    perDomani.map<Info>((jsonMap) => Info.fromJson(jsonMap)).toList();

    compitiFiltrati.sort((a, b) {
      DateTime da = DateTime.tryParse(a.data) ?? DateTime(2100);
      DateTime db = DateTime.tryParse(b.data) ?? DateTime(2100);
      return da.compareTo(db);
    });

    return compitiFiltrati;
  }

  static List<Info> fromJsonAltro(List<Map<String, dynamic>> jsonInput) {
    var filteredIterable = jsonInput.where((item) {
      var notesValue = item['notes'];
      if (notesValue == null) return false;

      String descrizione = notesValue.toString().toLowerCase();

      bool con1 = !descrizione.contains("verific");
      bool con2 = !descrizione.contains("compito in classe");
      bool con3 = !descrizione.contains("port");
      bool con4 = !descrizione.contains("entrambi");
      bool con5 = !descrizione.contains("es");
      bool con6 = !descrizione.contains("compit");
      bool con7 = !descrizione.contains("consegna");
      bool con8 = !descrizione.contains("interroga");
      bool con9 = !descrizione.contains("recuper");
      bool con10 = !descrizione.contains("writ");
      bool con11 = !descrizione.contains("speak");
      bool con12 = !descrizione.contains("liste");
      bool con13 = !descrizione.contains("studia");
      bool con14 = !descrizione.contains("invalsi");
      bool con15 = !descrizione.contains("n.");
      bool con16 = !descrizione.contains("scheda");
      bool con17 = !descrizione.contains("finire");
      bool con18 = !descrizione.contains("presentazion");
      bool con19 = !descrizione.contains("leggere");
      bool con20 = !descrizione.contains("tema");
      bool con21 = !descrizione.contains("version");


      return con1 && con2 && con3 && con4 && con5 && con6
          && con7 && con8 && con9 && con10 && con11
          && con12 && con13 && con14 && con15 && con16
          && con17 && con18 && con19 && con20 && con21;
    });

    List<Info> compitiFiltrati =
    filteredIterable.map<Info>((jsonMap) => Info.fromJson(jsonMap)).toList();

    compitiFiltrati.sort((a, b) {
      DateTime da = DateTime.tryParse(a.data) ?? DateTime(2100);
      DateTime db = DateTime.tryParse(b.data) ?? DateTime(2100);
      return da.compareTo(db);
    });

    return compitiFiltrati;
  }

  static List<Info> fromJsonList(List<Map<String, dynamic>> jsonInput) {

    List<Info> cose =
    jsonInput.map<Info>((jsonMap) => Info.fromJson(jsonMap)).toList();

    cose.sort((a, b) {
      DateTime da = DateTime.tryParse(a.data) ?? DateTime(2100);
      DateTime db = DateTime.tryParse(b.data) ?? DateTime(2100);
      return da.compareTo(db);
    });

    return cose;
  }

}

