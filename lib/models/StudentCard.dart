/*
esempio di json restituito
"card": {
        "ident": "S10435383U",
        "usrType": "S",
        "usrId": 10435383,
        "miurSchoolCode": "NOTF02000R",
        "miurDivisionCode": "NOTF02000R",
        "firstName": "ANDREA",
        "lastName": "MARUCA",
        "birthDate": "2008-11-16",
        "fiscalCode": "MRCNDR08S16B019I",
        "schCode": "NOIT0009",
        "schName": "ISTITUTO TECNICO INDUSTRIALE STATALE",
        "schDedication": "\" DA VINCI \"",
        "schCity": "BORGOMANERO",
        "schProv": "NO"
    }
 */
class StudentCard{
  String ident;
  String usrType;
  String miurSchoolCode;
  String nome;
  String cognome;
  String birthDate;
  String fiscalCode;
  String schCode;
  String schName;
  String schDedication;
  String schCity;
  String schProv;
  StudentCard({
    required this.ident,
    required this.usrType,
    required this.miurSchoolCode,
    required this.nome,
    required this.cognome,
    required this.birthDate,
    required this.fiscalCode,
    required this.schCode,
    required this.schName,
    required this.schDedication,
    required this.schCity,
    required this.schProv,
  });

  factory StudentCard.fromJson(Map<String, dynamic> json) {
    try {
      return StudentCard(
        ident: json['ident'],
        usrType: json['usrType'],
        miurSchoolCode: json['miurSchoolCode'],
        nome: json['firstName'],
        cognome: json['lastName'],
        birthDate: json['birthDate'],
        fiscalCode: json['fiscalCode'],
        schCode: json['schCode'],
        schName: json['schName'],
        schDedication: json['schDedication'],
        schCity: json['schCity'],
        schProv: json['schProv'],
      );
    }catch (Exception) {
      print("ERRORE NEL FROMJSON CARD : $Exception");
      return StudentCard(
        ident: "ERRORE",
        usrType: "ERRORE",
        miurSchoolCode: "ERRORE",
        nome: "ERRORE",
        cognome: "ERRORE",
        birthDate: "ERRORE",
        fiscalCode: "ERRORE",
        schCode: "ERRORE",
        schName: "ERRORE",
        schDedication: "ERRORE",
        schCity: "ERRORE",
        schProv: "ERRORE",
      );
    }
  }

}