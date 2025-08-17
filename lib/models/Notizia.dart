import 'package:ClasseMorta/models/Attach.dart';

/*
{
            "pubId": 23209883,
            "pubDT": "2025-04-07T10:01:02+02:00",
            "readStatus": false,
            "evtCode": "CF",
            "cntId": 8806670,
            "cntValidFrom": "2025-04-07",
            "cntValidTo": "2025-08-31",
            "cntValidInRange": true,
            "cntStatus": "active",
            "cntTitle": "1829 - Variazione d'orario – Assenza Prof. Crudo – martedì 08/04/2025 ",
            "cntCategory": "Scuola/famiglia",
            "cntHasChanged": false,
            "cntHasAttach": true,
            "needJoin": false,
            "needReply": false,
            "needFile": false,
            "needSign": false,
            "evento_id": "8806670",
            "dinsert_allegato": "2025-04-07 10:01:02",
            "attachments": [
                {
                    "fileName": "2025 04 08 Assenza Crudo.pdf",
                    "attachNum": 1
                }
            ]
        },
 */
class Notizia{
  int codiceDocumento;
  bool hasFile;
  String title;
  bool letta = false;
  List<Attach> files;

  Notizia({
    required this.codiceDocumento,
    required this.hasFile,
    required this.title,
    required this.letta,
    required this.files,
  });

  factory Notizia.fromJson(Map<String, dynamic> json) {
    return Notizia(
      codiceDocumento: json['pubId'],
      hasFile: json['cntHasAttach'],
      title: json['cntTitle'],
      letta: json['readStatus'],
      files: Attach.fromJsonList(json),
    );

  }

  static List<Notizia> fromJsonList(Map<String, dynamic> json, int type){
    final not = json['items'];
    dynamic filteredIterable;

    if(type == 1) {
       filteredIterable = not.where((item) {
        var notesValue = item['cntTitle'];
        if (notesValue == null) {
          return false;
        }
        String descrizione = notesValue.toString().toLowerCase();
        bool con1 = descrizione.contains("circ");
        return con1;
      });
    }else if(type == 2){
      filteredIterable = not.where((item) {
        var notesValue = item['cntTitle'];
        if (notesValue == null) {
          return false;
        }
        String descrizione = notesValue.toString().toLowerCase();
        bool con1 = descrizione.contains("variazione d'orario");
        bool con2 = descrizione.contains("variazioni orario");
        bool con3 = descrizione.contains("assenza");
        return con1 || con2 || con3;
      });
    }else if(type == 3){
      filteredIterable = not.where((item) {
        var notesValue = item['cntTitle'];
        if (notesValue == null) {
          return false;
        }
        String descrizione = notesValue.toString().toLowerCase();
        bool con1 = descrizione.contains("variazioni di aula");
        return con1;
      });
    }
    else if(type == 4){
      filteredIterable = not.where((item) {
        var notesValue = item['cntTitle'];
        if (notesValue == null) {
          return false;
        }
        String descrizione = notesValue.toString().toLowerCase();
        bool con2 = !descrizione.contains("circ");
        bool con1 = !descrizione.contains("variazione d'orario");
        bool con3 = !descrizione.contains("variazioni di aula");
        bool con4 = !descrizione.contains("variazioni orario");
        bool con5 = !descrizione.contains("assenza");
        return con1 && con2 && con3 && con4 && con5;
      });
    }
    List<Notizia> notizieFiltrate = filteredIterable
        .map<Notizia>((jsonMap) => Notizia.fromJson(jsonMap))
        .toList();
    return notizieFiltrate.toList();

  }




}