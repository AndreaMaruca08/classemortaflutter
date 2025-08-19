/*
{
            "evtId": 2516222,
            "evtCode": "ABA0",
            "evtDate": "2024-11-06",
            "evtHPos": null,
            "evtValue": null,
            "isJustified": true,
            "justifReasonCode": "D",
            "justifReasonDesc": "Problemi di trasporto / traffico",
            "hoursAbsence": [],
            "webJustifStatus": 1
        },

        //ABAO = assenza
        //ABUO = uscita
        //ABRO = ritardo
 */
import 'dart:ffi';

class Assenza{
  String data;
  bool giustificata;
  String giustificazione;
  String type;

  Assenza({
    required this.data,
    required this.giustificata,
    required this.giustificazione,
    required this.type,
  });

  factory Assenza.fromJson(Map<String, dynamic> json){
    return Assenza(
      data: json['evtDate'],
      giustificata: json['isJustified'],
      giustificazione: json['justifReasonDesc'] ?? "",
      type: json['evtCode'],
    );
  }

  static List<Assenza> fromJsonList(Map<String, dynamic> json, String type){
    final j = json["events"];
    List<Assenza> assenze = j.map<Assenza>((jsonMap) => Assenza.fromJson(jsonMap)).toList();


    List<Assenza> ass = [];
    for(Assenza a in assenze){
      print(a.type);
      print(type);
      print("_----");
      if(a.type == type ){

        ass.add(a);
      }
    }

    return ass;
  }
}