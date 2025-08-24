class Didattica {
  final String titolo;      // Nome della cartella (folderName)
  final String docente;     // Nome docente (teacherName)
  final int fileId;       // Id della cartella
  final DateTime data;      // Data ultimo share

  Didattica({
    required this.titolo,
    required this.docente,
    required this.fileId,
    required this.data,
  });

  factory Didattica.fromJson(Map<String, dynamic> json, String docente) {
    return Didattica(
      titolo: json['folderName'] ?? '',
      docente: docente,
      fileId: json['folderId'] + 1,
      data: DateTime.parse(json['lastShareDT']),
    );
  }
}
