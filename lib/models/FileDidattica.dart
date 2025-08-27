/*
{
            "teacherId": "A5231524",
            "teacherName": "CRUDO FRANCESCO",
            "teacherFirstName": "FRANCESCO",
            "teacherLastName": "CRUDO",
            "folders": [
                {
                    "folderId": 59768368,
                    "folderName": "I rischi della sedentarietà",
                    "lastShareDT": "2025-02-10T10:37:59+01:00",
                    "contents": [
                        {
                            "contentId": 59768369,
                            "contentName": "Effetti del movimento",
                            "objectId": 39505571,
                            "objectType": "file",
                            "shareDT": "2025-02-10T10:37:59+01:00"
                        },
                        {
                            "contentId": 59768370,
                            "contentName": "La sedentarietà come malattia",
                            "objectId": 39505572,
                            "objectType": "file",
                            "shareDT": "2025-02-10T10:37:59+01:00"
                        }
                    ]
                }
            ]
        },
 */
class Didattica {
  final String titolo;     // Nome del file
  final String docente;    // Nome del docente
  final int cartellaId;    // Id della cartella
  final int fileId;        // Id del file (contentId)
  final DateTime data;     // Data condivisione

  Didattica({
    required this.titolo,
    required this.docente,
    required this.cartellaId,
    required this.fileId,
    required this.data,
  });

  factory Didattica.fromJson(Map<String, dynamic> json, String title, String docente, int folderId) {
    return Didattica(
      titolo: title,
      docente: docente,
      cartellaId: folderId,
      fileId: json['contentId'],
      data: DateTime.parse(json['shareDT']),
    );
  }
}
