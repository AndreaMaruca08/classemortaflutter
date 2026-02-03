// In Compito.dart
class Info {
  final String materia;
  final String nomeInsegnante;
  final String descrizione;
  final String data;
  final String dataFine;
  final String orario;

  Info({
    required this.materia,
    required this.nomeInsegnante,
    required this.descrizione,
    required this.data,
    required this.orario,
    required this.dataFine,
  });

  String get storageKey => "done_${materia}_${data}_${descrizione.hashCode}";

  factory Info.fromJson(Map<String, dynamic> json) {
    final begin = json['evtDatetimeBegin']?.toString() ?? "";
    final end = json['evtDatetimeEnd']?.toString() ?? "";

    String ora = "Orario non disponibile";
    if (begin.length >= 16 && end.length >= 16) {
      ora = "${begin.substring(11, 16)} - ${end.substring(11, 16)}";
    }

    return Info(
      materia: json['subjectDesc'] as String? ?? "null",
      nomeInsegnante: json['authorName'] as String? ?? "Insegnante sconosciuto",
      descrizione: json['notes'] as String? ?? "Nessuna descrizione",
      data: begin.isNotEmpty ? begin : "Data non disponibile",
      dataFine: end.isNotEmpty ? end : "Data non disponibile",
      orario: ora,
    );
  }

  static List<Info> fromJsonList(List<Map<String, dynamic>> jsonInput) {
    final list = jsonInput.map((json) => Info.fromJson(json)).toList();
    _sortInfoList(list);
    return list;
  }

  static void _sortInfoList(List<Info> list) {
    list.sort((a, b) {
      final da = DateTime.tryParse(a.data.substring(0,10)) ?? DateTime(2100);
      final db = DateTime.tryParse(b.data.substring(0,10)) ?? DateTime(2100);
      return da.compareTo(db);
    });
  }

  static List<int> getTimes(List<Map<String, dynamic>> jsonInput) {
    final infoList = fromJsonList(jsonInput);
    int contaD = 0, contaDD = 0, conta3 = 0, conta4_7 = 0, conta8_15 = 0, conta15piu = 0;

    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    for (final i in infoList) {
      final dataScadenza = DateTime.tryParse(i.dataFine.split('T')[0]) ??
          DateTime.tryParse(i.dataFine.substring(0, 10)) ??
          DateTime(2100);

      final differenza = dataScadenza.difference(todayDateOnly).inDays;

      if (differenza == 1) {
        contaD++;
      } else if (differenza == 2) {
        contaDD++;
      } else if (differenza == 3) {
        conta3++;
      } else if (differenza > 3 && differenza <= 7) {
        conta4_7++;
      } else if (differenza >= 8 && differenza <= 14) {
        conta8_15++;
      } else if (differenza > 14) {
        conta15piu++;
      }
    }
    return [contaD, contaDD, conta3, conta4_7, conta8_15, conta15piu];
  }

  // --- Filtering Logic ---

  static bool _isCompito(String desc) {
    final d = desc.toLowerCase();
    final keywords = ["es.", "eserc", "compit", "consegna", "invalsi", "studia", "n.", "scheda", "finire", "leggere", "version"];
    final excludes = ["verific", "interroga"];
    return keywords.any((k) => d.contains(k)) && !excludes.any((e) => d.contains(e));
  }

  static bool _isAgenda(String desc) {
    final d = desc.toLowerCase();
    return (d.contains("porta") || d.contains("entrambi")) && !d.contains("verific") ;
  }

  static bool _isVerifica(String desc) {
    final d = desc.toLowerCase();
    final keywords = ["verific", "interroga", "compito in classe", "recuper", "writ", "speak", "liste", "test", "presentazion", "tema"];
    final excludes = ["porta", "entrambi"];
    return keywords.any((k) => d.contains(k)) && !excludes.any((e) => d.contains(e));
  }

  static List<Info> fromJsonListCompiti(List<Map<String, dynamic>> jsonInput) {
    return fromJsonList(jsonInput.where((item) {
      final notes = item['notes']?.toString() ?? "";
      return _isCompito(notes);
    }).toList());
  }

  static List<Info> fromJsonListAgenda(List<Map<String, dynamic>> jsonInput) {
    return fromJsonList(jsonInput.where((item) {
      final notes = item['notes']?.toString() ?? "";
      return _isAgenda(notes);
    }).toList());
  }

  static List<Info> fromJsonListVerifiche(List<Map<String, dynamic>> jsonInput) {
    return fromJsonList(jsonInput.where((item) {
      final notes = item['notes']?.toString() ?? "";
      return _isVerifica(notes);
    }).toList());
  }

  static List<Info> fromJsonPerDomani(List<Map<String, dynamic>> jsonInput) {
    final today = DateTime.now();
    final filtered = jsonInput.where((item) {
      final dataStr = item['evtDatetimeEnd']?.toString();
      if (dataStr == null) return false;
      final dataScadenza = DateTime.tryParse(dataStr.substring(0, 10)) ?? DateTime(2100);
      return dataScadenza.difference(DateTime(today.year, today.month, today.day)).inDays == 1 &&
          dataScadenza.isAfter(today);
    }).toList();
    return fromJsonList(filtered);
  }

  static List<Info> fromJsonAltro(List<Map<String, dynamic>> jsonInput) {
    return fromJsonList(jsonInput.where((item) {
      final notes = item['notes']?.toString() ?? "";
      return !_isCompito(notes) && !_isAgenda(notes) && !_isVerifica(notes);
    }).toList());
  }
}
