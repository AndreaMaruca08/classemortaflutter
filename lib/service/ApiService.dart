import 'dart:convert';
import 'dart:io';
import 'package:ClasseMorta/models/Assenza.dart';
import 'package:ClasseMorta/models/Giorno.dart';
import 'package:ClasseMorta/models/Info.dart';
import 'package:ClasseMorta/models/Pagella.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../models/FileDidattica.dart';
import '../models/Lezione.dart';
import '../models/Login.dart';
import '../models/Materia.dart';
import '../models/Nota.dart';
import '../models/Notizia.dart';
import '../models/StudentCard.dart';
import '../models/Voto.dart';

/// A service class for interacting with the Spaggiari API.
///
/// This class provides methods to fetch various data related to a student,
/// such as grades, absences, notes, and more.
///
///
/// ## API Endpoints
/// The following table lists the API endpoints used by this service:
///
/// | **Endpoint Path**                       | **Description**                                             |
/// | --------------------------------------- | ----------------------------------------------------------- |
/// | `/auth/login`                           | Authenticate the user and return the session token.         |
/// | `/students/{id}/grades`                 | Get the student’s grades.                                   |
/// | `/students/{id}/notes`                  | Get disciplinary notes or annotations.                      |
/// | `/students/{id}/absences`               | Get the list of recorded absences.                          |
/// | `/students/{id}/agenda/all/{from}/{to}` | Get agenda items (homework, events) between two dates.      |
/// | `/students/{id}/lessons/today`          | Get today’s lessons.                                        |
/// | `/students/{id}/lessons/{date}`         | Get lessons for a specific date.                            |
/// | `/students/{id}/calendar/all`           | Get the school calendar (holidays, events, etc.).           |
/// | `/students/{id}/didactics`              | Get didactic materials and programs.                        |
/// | `/students/{id}/books`                  | Get the list of school books.                               |
/// | `/students/{id}/card`                   | Get the student’s profile card info.                        |
/// | `/students/{id}/subjects`               | Get the list of subjects.                                   |
/// | `/students/{id}/periods`                | Get the list of school periods.                             |
/// | `/students/{id}/noticeboard`            | Get the noticeboard (general communications).               |
/// | `/students/{id}/documents`              | Get available documents (report cards, certificates, etc.). |
///
///
/// ATTENTION!!!!!!!!!!!
/// to use the functions you have to first create an instance of ApiService and
/// then use the login function to validate this instance because you need the
/// session token.
///
/// *Note: `{date}`, `{from}`, `{to}` must be in `YYYYMMDD` format.*

class Apiservice {
  final String year = (DateTime.now().year - 2002).toString();
  late String base = "https://web.spaggiari.eu/rest/v1/";

  late String login;

  late String code;
  late String card;
  late String grades;
  late String notes;
  late String absences;
  late String lessonsToday;
  late String calendarAll;
  late String didactics;
  late String books;
  late String subjects;
  late String periods;
  late String noticeboard;
  late String documents;
  late String fullCode;
  late String apriFile;

  late String token;

  late Map<String, String> otherHeaders;
  final Map<String, String> loginHeaders = {
    'Content-Type': 'application/json',
    'Z-Dev-ApiKey': 'Tg1NWEwNGIgIC0K',
    'User-Agent': 'CVVS/std/4.1.3 Android/14',
  };

  Apiservice(String codiceStudente, bool precedente) {
    if(precedente){
      base = "https://web$year.spaggiari.eu/rest/v1/";
    }
    login = "${base}auth/login";
    fullCode = codiceStudente;
    code = codiceStudente.replaceAll(RegExp(r'[a-zA-Z]'), "");

    token = '';
    card = "${base}students/$code/card";
    grades = "${base}students/$code/grades";
    notes = "${base}students/$code/notes/all";
    absences = "${base}students/$code/absences/details";
    lessonsToday = "${base}students/$code/lessons/today";
    calendarAll = "${base}students/$code/calendar/all";
    didactics = "${base}students/$code/didactics";
    books = "${base}students/$code/books";
    subjects = "${base}students/$code/subjects";
    periods = "${base}students/$code/periods";
    noticeboard = "${base}students/$code/noticeboard";
    documents = "${base}students/$code/documents";
    apriFile = "${base}students/$code/didactics/item/";
  }

  String getAgendaUrl(String fromDate, String toDate) {
    return "${base}students/$code/agenda/all/$fromDate/$toDate";
  }

  String getLessonsForDateUrl(String date) {
    return "${base}students/$code/lessons/$date";
  }

  Future<List<Voto>?> getAllVoti() async {
    if(token.isEmpty) {
      return null;
    }
    final response = await http.get(
        Uri.parse(grades),
        headers: otherHeaders
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      var voti = Voto.fromJsonList(json);
      List<Voto> finalVoti = [];
      for (Voto voto in voti) {
        if(voto.voto != 0.0){
          finalVoti.add(voto);
        }
      }
      return finalVoti;
    } else {
      throw Exception('Failed to load grades');
    }
  }

  Future<List<Voto>?> getMedieGenerali() async {
    final voti = await getAllVoti();

    if (voti == null) {
      return null;
    }

    double somma = 0.0;
    double somma1 = 0.0;
    double somma2 = 0.0;
    int count = 0;
    int count1 = 0;
    int count2 = 0;
    double mediaTot = 0.0;
    double media1 = 0.0;
    double media2 = 0.0;
    for (Voto voto in voti) {
      //si toglie religione nel conto della media
      if (voto.cancellato || voto.voto == 0.0 ||
          voto.codiceMateria.toUpperCase() == "REL" ||
          voto.nomeInteroMateria.toUpperCase() == "RELIGIONE") {
        continue;
      }
      somma += voto.voto;
      voto.periodo == 1 ? somma1 += voto.voto : somma2 += voto.voto;
      voto.periodo == 1 ? count1++ : count2++;
      count++;
    }
    mediaTot = somma / count;
    media1 = somma1 / count1;
    media2 = somma2 / count2;

    List<Voto> medie = [];

    //MEDIA TOTALE
    medie.add(Voto(
        codiceMateria: "Tot",
        nomeInteroMateria: "Media totale",
        dataVoto: "${DateTime
            .now()
            .year}",
        voto: mediaTot,
        displayValue: mediaTot.toStringAsFixed(3),
        descrizione: "Media Totale, contando tutti i voti, di tutto l'anno senza contare quelli cancellati e religione",
        periodo: 3,

        cancellato: false,
        nomeProf: "Media Totale",
        tipo: "Totale"
    ));
    //primo periodo
    medie.add(Voto(
        codiceMateria: "1°",
        nomeInteroMateria: "Media primo quadrimestre",
        dataVoto: "${DateTime
            .now()
            .year}",
        voto: media1,
        displayValue: media1.toStringAsFixed(2),
        descrizione: "Media primo quadrimestre, contando tutti i voti, di tutto il primo quadrimestre senza contare quelli cancellati e religione",
        periodo: 1,
        cancellato: false,
        nomeProf: "Media 1° periodo",
        tipo: "1° periodo"
    ));
    //secondo periodo
    medie.add(Voto(
        codiceMateria: "2°",
        nomeInteroMateria: "Media secondo quadrimestre",
        dataVoto: "${DateTime
            .now()
            .year}",
        voto: media2,
        displayValue: media2.toStringAsFixed(2),
        descrizione: "Media secondo quadrimestre, contando tutti i voti, di tutto il secondo quadrimestre senza contare quelli cancellati e religione",
        periodo: 2,
        cancellato: false,
        nomeProf: "Media 2° periodo",
        tipo: "2° periodo"
    ));

    return medie;
  }

  List<Voto>? getMedieMateria(Materia materia) {
      final voti = materia.voti;
      if (voti.isEmpty) {
        return [];
      }

      double somma = 0.0;
      double somma1 = 0.0;
      double somma2 = 0.0;
      int count = 0;
      int count1 = 0;
      int count2 = 0;
      double mediaTot = 0.0;
      double media1 = 0.0;
      double media2 = 0.0;
      for (Voto voto in voti) {
        if(voto.cancellato || voto.voto == 0){
          continue;
        }
        somma += voto.voto;
        voto.periodo == 1 ? somma1 += voto.voto : somma2 += voto.voto;
        voto.periodo == 1 ? count1++ : count2++;
        count++;
      }
      mediaTot = somma / count;
      media1 = somma1 / count1;
      media2 = somma2 / count2;

      List<Voto> medie = [];

      //MEDIA TOTALE
      medie.add(Voto(
          codiceMateria: "Tot",
          nomeInteroMateria: "Media totale di ${materia.nomeInteroMateria}",
          dataVoto: "${DateTime
              .now()
              .year}",
          voto: mediaTot,
          displayValue: mediaTot.toStringAsFixed(3),
          descrizione: "Media Totale, contando tutti i voti, di tutto l'anno senza contare quelli cancellati",
          periodo: 3,
          cancellato: false,
          nomeProf: "Media Totale",
          tipo: "Totale"
      ));

      //primo periodo
      medie.add(Voto(
          codiceMateria: "1°",
          nomeInteroMateria: "Media primo quadrimestre di ${materia.nomeInteroMateria}",
          dataVoto: "${DateTime
              .now()
              .year}",
          voto: media1,
          displayValue: media1.toStringAsFixed(2),
          descrizione: "Media primo quadrimestre, contando tutti i voti, di tutto il primo quadrimestre senza contare quelli cancellati",
          periodo: 1,
          cancellato: false,
          nomeProf: "Media 1° periodo",
          tipo: "1° periodo"
      ));
      //secondo periodo
      medie.add(Voto(
          codiceMateria: "2°",
          nomeInteroMateria: "Media secondo quadrimestre di ${materia.nomeInteroMateria}",
          dataVoto: "${DateTime
              .now()
              .year}",
          voto: media2,
          displayValue: media2.toStringAsFixed(2),
          descrizione: "Media secondo quadrimestre, contando tutti i voti, di tutto il secondo quadrimestre senza contare quelli cancellati e religione",
          periodo: 2,
          cancellato: false,
          nomeProf: "Media 2° periodo",
          tipo: "2° periodo"
      ));
      return medie;
    }

  Future<List<Voto>?> getLastVoti(int numberOfVotes) async {
    final tuttiIVoti = await getAllVoti();

    if (tuttiIVoti == null || tuttiIVoti.isEmpty) {
      return null;
    }

    List<Voto> votiOrdinabili = List<Voto>.from(tuttiIVoti);

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

    if (votiOrdinabili.length > numberOfVotes) {
      return votiOrdinabili.sublist(0, numberOfVotes);
    } else {
      return votiOrdinabili;
    }
  }

  Future<StudentCard?> getCard() async {
    final response = await http.get(
      Uri.parse(card),
      headers: otherHeaders,
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return StudentCard.fromJson(json['card']);
    }
    else {
      return null;
    }
  }

  Future<List<List<Info>>> getInfo() async {
    DateTime now = DateTime.now();

    String fromDate = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    String toDate = "${now.year}1231";

    final url = getAgendaUrl(fromDate, toDate);
    final response = await http.get(
      Uri.parse(url),
      headers: otherHeaders,
    );

    if (response.statusCode == 200) {
      final dynamic decodedJson = jsonDecode(response.body);

      // Controlla se il JSON decodificato è una Mappa e contiene la chiave "agenda"
      if (decodedJson is Map<String, dynamic> &&
          decodedJson.containsKey('agenda')) {
        final dynamic agendaData = decodedJson['agenda']; // Estrai la parte "agenda"

        if (agendaData is List) { // Ora controlla se "agendaData" è una lista
          if (decodedJson.containsKey('agenda')) {
            final dynamic agendaData = decodedJson['agenda']; // Estrai la parte "agenda"

            if (agendaData is List) {
              final List<Map<String, dynamic>> jsonMapList = List<
                  Map<String, dynamic>>.from(
                  agendaData.map((item) { // Itera su agendaData
                    if (item is Map<String, dynamic>) {
                      return item;
                    }
                    return <String, dynamic>{};
                  })
              ).where((map) => map.isNotEmpty).toList();

              var compitiFiltrati = Info.fromJsonListCompiti(jsonMapList);
              var notizieFiltrate = Info.fromJsonListAgenda(jsonMapList);
              var verificheFiltrate = Info.fromJsonListVerifiche(jsonMapList);
              var resto = Info.fromJsonAltro(jsonMapList);


              return [
                compitiFiltrati,
                notizieFiltrate,
                verificheFiltrate,
                resto
              ];
            } else {
              print("Errore: Il campo 'agenda' nel JSON non è una lista.");
              return [];
            }
          } else {
            print(
                "Errore: il JSON decodificato per i compiti non è una mappa o non contiene la chiave 'agenda'.");
            print("JSON ricevuto: $decodedJson"); // Stampa il JSON per debug
            return [];
          }
        } else {
          print("Errore: Il campo 'agenda' nel JSON non è una lista.");
          return [];
        }
      } else {
        print(
            "Errore: il JSON decodificato per i compiti non è una mappa o non contiene la chiave 'agenda'.");
        print("JSON ricevuto: $decodedJson"); // Stampa il JSON per debug
        return [];
      }
    } else {
      print("Errore HTTP durante il recupero dei compiti: ${response
          .statusCode}");
      print("Corpo della risposta (errore): ${response.body}");
      return [];
    }
  }

  List<Materia> getMaterieFromVoti(List<Voto> voti) {
    List<Materia> materie = [];

    String codeMateria = "";
    String nomeProf = "";
    String nomeMateria = "";
    Materia materiaAttuale;
    List<Voto> votiMateriaAttuale = [];
    for (Voto v in voti) {
      if(v.cancellato || v.voto == 0){
        continue;
      }
      else if(v.codiceMateria == codeMateria ){
        votiMateriaAttuale.add(v);
      }
      else {
        materiaAttuale = Materia(
            codiceMateria: codeMateria,
            nomeInteroMateria: nomeMateria,
            nomeProf: nomeProf,
            voti: votiMateriaAttuale
        );
        codeMateria = v.codiceMateria;
        nomeMateria = v.nomeInteroMateria;
        nomeProf = v.nomeProf;
        materie.add(materiaAttuale);
        votiMateriaAttuale = [];
        votiMateriaAttuale.add(v);
      }

    }
    materie.remove(materie[0]);
    return materie;

  }

  Future<List<List<Notizia>?>> getNotizie() async {
    final response = await http.get(
      Uri.parse(noticeboard),
      headers: otherHeaders,
    );
    if(response.statusCode == 200){
      final json = jsonDecode(response.body);
      final List<Notizia> result1 = Notizia.fromJsonList(json, 1);
      final List<Notizia> result2 = Notizia.fromJsonList(json, 2);
      final List<Notizia> result3 = Notizia.fromJsonList(json, 3);
      final List<Notizia> result4 = Notizia.fromJsonList(json, 4);
      final List<List<Notizia>> result = [result1, result2, result3, result4];
      return result;
    }else {
      return [];
    }
  }

  Future<void> downloadAndOpenAttachment(int pubId, int attachNum) async {
    final url =
        "$base$code/noticeboard/attach/$pubId/$attachNum";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Z-Auth-Token": token,
        'User-Agent': 'CVVS/std/4.1.3 Android/14',
        "Z-Dev-Apikey": "Tg1NWEwNGIgIC0K",
        'X-Requested-With': 'XMLHttpRequest'
      },
    );

    if (response.statusCode == 200) {
      // Salva in una cartella temporanea
      final dir = await getTemporaryDirectory();
      final filePath = "${dir.path}/allegato_$pubId.pdf";

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception("Errore durante il download: ${response.statusCode}");
    }
  }

  Future<List<List<Nota>>> getNote() async {
    final response = await http.get(
      Uri.parse(notes),
      headers: otherHeaders,
    );
    if(response.statusCode == 200){
      final json = jsonDecode(response.body);
      var note = Nota.getNote(json);

      List<String> tips = ["NTCL", "NTTE", "NTST", "NTWN"];

      int i = 0;
      for(List<Nota> lista in note){
        for(Nota nota in lista){
          if(nota.messaggio != "..."){
            continue;
          }
          final url = "${base}students/$code/notes/${tips[i]}/read/${nota.id}";
          final response = await http.post(
            Uri.parse(url),
            headers: otherHeaders,
          );
          final json = jsonDecode(response.body);
          print(json.toString());
          nota.messaggio = json['event']['evtText'];
        }
        i++;
      }


      return note;
    }else{
      return [];
    }

  }

  Future<List<Pagella>> getPagelle() async {
    final response = await http.post(
      Uri.parse(documents),
      headers: otherHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // Assicurati che "schoolReports" sia una lista nel JSON
      final pagJsonList = json["schoolReports"] as List<dynamic>?;

      if (pagJsonList != null) {
        // Utilizza il tuo metodo statico fromJsonList per convertire la lista
        return await Pagella.fromJsonList(pagJsonList);
      } else {
        // Se "schoolReports" è null o non è una lista, restituisci una lista vuota
        return [];
      }
    } else {
      // In caso di errore, restituisci una lista vuota
      return [];
    }
  }

  Future<List<List<Assenza>>> getAssenze() async{
    final response = await http.get(
      Uri.parse(absences),
      headers: otherHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<Assenza> assenze = Assenza.fromJsonList(json, "ABA0");
      final List<Assenza> uscite = Assenza.fromJsonList(json, "ABU0");
      final List<Assenza> ritardi = Assenza.fromJsonList(json, "ABR0");

      final List<List<Assenza>> ass = [assenze, uscite, ritardi];
      return ass;
    } else {
      return [];
    }
  }

  Future<List<Lezione>> getLezioni() async{
    final response = await http.get(
      Uri.parse(lessonsToday),
      headers: otherHeaders,
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return Lezione.fromJsonList(json);
    } else {
      return [];
    }
  }

  Future<List<Didattica>> fetchDidattica() async {
    final response = await http.get(
      Uri.parse(didactics),
      headers: otherHeaders, // headers già definiti
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<Didattica> files = [];

      for (var teacher in data['didacticts']) {
        final teacherName = teacher['teacherName'] ?? '';

        for (var folder in teacher['folders']) {
          final folderId = folder['folderId'];
          final title = folder['folderName'];

          for (var content in folder['contents']) {
            files.add(Didattica.fromJson(content, title,  teacherName, folderId));
          }
        }
      }

      // Ordino per data (più recente prima)
      files.sort((a, b) => b.data.compareTo(a.data));

      return files;
    } else {
      throw Exception(
        "Errore nel recupero dei file didattici: ${response.statusCode}",
      );
    }
  }

  Future<void> downloadAndOpenPdfById(String docId, String filename,) async {
    final dio = Dio();

    // Imposta gli header extra
    dio.options.headers = otherHeaders;

    // Costruisci l'URL a partire dall'id
    final url = '${base}students/$code/didactics/item/$docId';
    // Ottieni cartella temporanea
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$filename';
    final file = File(filePath);

    try {
      // Scarica il PDF
      await dio.download(url, filePath);

      if (await file.exists()) {
        print('Download completato: $filePath');
        // Apri il PDF con app esterna
        final result = await OpenFile.open(filePath);
        print(result.message);
      } else {
        print('ERRORE: il file non esiste dopo il download');
      }
    } on DioException catch (e) {
      print('ERRORE Dio: ${e.toString()}');
      if (e.response != null) {
        print('Status code: ${e.response?.statusCode}');
        print('Response headers: ${e.response?.headers}');
        print('Response data: ${e.response?.data}');
      } else {
        print('Nessuna risposta dal server');
      }
    }
  }

  Future<void> openPdf(File file) async {
    await OpenFile.open(file.path);
  }

  Future<List<Giorno>> getOrari() async {

    DateTime oggi = DateTime.now();
    int giornoSettimana = oggi.weekday;
    DateTime lunediQuesto = oggi.subtract(Duration(days: giornoSettimana - 1));
    DateTime lunediScorso = lunediQuesto.subtract(Duration(days: 7));

    String fromDate = "${lunediScorso.year}${lunediScorso.month.toString().padLeft(2, '0')}${lunediScorso.day.toString().padLeft(2, '0')}";

    List<Giorno> giorni = [];
    for(int i = 1; i < 6; i++){
      final response = await http.get(
        Uri.parse(getLessonsForDateUrl(fromDate)),
        headers: otherHeaders,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final Giorno giorno = Giorno.fromJson(json);
        giorni.add(giorno);
      } else {
        return [];
      }

    }
    return giorni;
  }



  /*
    esempio risposta:
      {
      "ident": "S10435383U",
      "firstName": "ANDREA",
      "lastName": "MARUCA",
      "showPwdChangeReminder": false,
      "tokenAP": "ca909bedc55165d497576725badfa3b0zBjpbHgfU9I0S1YyDGMC4dC38NcfwzWGK7l1iJcE4+2EXPyY93huCRX5a0gW7z9PS35xfy50PaBS8gHtTBtFiKRFl5Im+0y3HIf2Jy5xA/U3RstXKnirdOyunhkbmorvjjn0/LkWtmYJsgrtZDbVQfPAt4dm29U8Xa1h6QIVTp36SN2fhEQVuztOhwKox5wFXGHyYTh81EekBUiW1NNyupBNsBdeBFQVAISu/iFEboH/fD2ANfAxLxqxyOmzoOXTnOJS2kvS62HFrIulxPaZHL1DP6RW/iznzX/BTEhLXlhgwJzUtOyvytPN7GihP6CJq+EGw5q+MDUuD669LMPm08GkCU1+oO5f7BOMADMl6srjRG/QKJ0=",
      "token": "b7351d4fd05e7241f80a34bcc16838a40Ttgr4gl0D6TwaXdLCvn51IonQ7hi8Cq5ceiobjb0jHpMDdAJ7a0ZfuoxzboWmx6kL8GlKZRmcotonNjCHXFiMwDI4SuD+/hY2E8mBD6tkIYkisr0RVkZdNPT2CKvdWmjCjGN7hWZzyArp+iz9TXwJonZrg4wk/Vp7qU0mySrMp7hbs4gMS19lOvG1Oa3Wx52Ld5WJdG/liw8qd397lAC2qIKkm47EUYxB80+4uz2YzcxzE8H+kNrJ7Rs0pzY9Tm6hJ5gtXvAXXjVhrMiMGQxc7f1imSWtMfGEkc4ubWUI1yOYP1Rv4abb3emEPtvFDkSMh1EsJJTZB8hVhTH+OFYCCS290MkRcurUZ/0tHAJqXN4sskNDros0Yw006XU5nT6Ku79w==",
      "release": "2025-08-12T15:54:53+02:00",
      "expire": "2025-08-12T17:24:53+02:00"
      }
   */
    Future<LoginResponse?> doLogin(String password) async {
      final response = await http.post(
          Uri.parse(login),
          headers: loginHeaders,
          body: '{ "uid": "$fullCode", "pass": "$password", "ident": null}'
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        //imposta il token
        token = json['token'];
        //imposta gli headers per le altre chiamate
        otherHeaders = {
          'Content-Type': 'application/json; charset=UTF-8',
          'Z-Dev-ApiKey': 'Tg1NWEwNGIgIC0K',
          'User-Agent': 'CVVS/std/4.1.3 Android/14',
          'Z-Auth-Token': token,
          'X-Requested-With': 'XMLHttpRequest'
        };
        return new LoginResponse.fromJson(json);
      } else {
        return null;
      }
    }

}
