import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:classemorta/models/Assenza.dart';
import 'package:classemorta/models/Giorno.dart';
import 'package:classemorta/models/Info.dart';
import 'package:classemorta/models/Pagella.dart';
import 'package:classemorta/models/PeriodoFestivo.dart';
import 'package:classemorta/models/ProvaCurriculum.dart';
import 'package:classemorta/models/RichiestaGiustifica.dart';
import 'package:classemorta/models/SchoolEvent.dart';
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
import '../models/enums/Operation.dart';
import 'HtmlParserService.dart';

/// A service class for interacting with the Spaggiari API.
///
/// This class provides methods to fetch various data related to a student,
/// such as grades, absences, notes, and more.
///
///
///Authentication
//
// POST v1/auth/login
// GET v1/auth/avatar
// GET v1/auth/status
// GET v1/auth/ticket
// User
//
// Absence
//
// GET v1/students/{studentId}/absences/details
// GET v1/students/{studentId}/absences/details/{begin}
// GET v1/students/{studentId}/absences/details/{begin}/{end}
// Agenda
//
// GET v1/students/{studentId}/agenda/all/{begin}/{end}
// GET v1/students/{studentId}/agenda/{eventCode}/{begin}/{end}
// Didactics
//
// GET v1/students/{studentId}/didactics
// GET v1/students/{studentId}/didactics/item/{contentId}
// Notice Board
//
// GET v1/students/{studentId}/noticeboard
// POST v1/students/{studentId}/noticeboard/read/{eventCode}/{pubId}/101
// GET v1/students/{studentId}/noticeboard/attach/{eventCode}/{pubId}/101
// Schoolbooks
//
// GET v1/students/{studentId}/schoolbooks
// Calendar
//
// GET v1/students/{studentId}/calendar/all 🤔🤔🤔
// Card
//
// GET v1/students/{studentId}/card
// GET v1/students/{studentId}/cards
// Grades
//
// GET v1/students/{studentId}/grades
// Lessons
//
// GET v1/students/{studentId}/lessons/today
// GET v1/students/{studentId}/lessons/{day}
// GET v1/students/{studentId}/lessons/{start}/{end}
// Notes
//
// GET v1/students/{studentId}/notes/all
// POST v1/students/{studentId}/notes/{type}/read/{note}
// Periods
//
// GET v1/students/{studentId}/periods
// Subjects
//
// GET v1/students/{studentId}/subjects
// Documents
//
// POST v1/students/{studentId}/documents
// POST v1/students/{studentId}/documents/check/{hash}
// POST v1/students/{studentId}/documents/read/{hash}
///
/// PAY ATTENTION!!!!!!!!!!!
/// to use the functions you have to first create an instance of ApiService and
/// then use the login function to validate this instance because you need the
/// session token.
///
/// *Note: `{date}`, `{from}`, `{to}` must be in `YYYYMMDD` format.*

class Apiservice {
  final String year = (DateTime.now().year - 2002).toString();
  late String base = "https://web.spaggiari.eu/rest/v1/";

  late bool precedente;

  late String login;
  late String phpSessId;
  late String pass;

  late String code;
  late String codiceStudent;
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
  late String vacanze;

  late String token;

  late Map<String, String> otherHeaders;
  final Map<String, String> loginHeaders = {
    'Content-Type': 'application/json',
    'Z-Dev-ApiKey': 'Tg1NWEwNGIgIC0K',
    'User-Agent': 'CVVS/std/4.1.3 Android/14',
  };

  Apiservice(String codiceStudente, String password, this.precedente) {
    if(precedente){
      base = "https://web$year.spaggiari.eu/rest/v1/";
    }
    pass = password;
    codiceStudent = codiceStudente;
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
    vacanze = "${base}students/$code/calendar/all";

  }

  int getYear(){
    return precedente? DateTime.now().year - 2 : DateTime.now().year;
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
      else if(v.codiceMateria == codeMateria){
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

        if(voti.where((element) => element.codiceMateria == codeMateria).length == 1 && voti.last == v){
          materiaAttuale = Materia(
              codiceMateria: codeMateria,
              nomeInteroMateria: nomeMateria,
              nomeProf: nomeProf,
              voti: votiMateriaAttuale
          );
          materie.add(materiaAttuale);
        }
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

  Future<String> readNoticeboardFile (String docId, String filename, String evtCode, int num, bool didattica, bool hasfile) async{
     final response = await http.post(
      Uri.parse("${base}students/$code/noticeboard/read/$evtCode/$docId/101"),
      headers: otherHeaders,
    );
     if(response.statusCode == 200){
       final data = jsonDecode(response.body);
       if(!hasfile){
         return data["item"]["text"];
       }
       await downloadAndOpenPdfById(docId, filename, evtCode, num, didattica);
     }
     return "";
  }

  Future<void> downloadAndOpenPdfById(String docId, String fileNameWithoutExtension, String evtCode, int num, bool didattica) async {
    final dio = Dio();

    // Imposta gli header extra
    dio.options.headers = otherHeaders;

    String url;
    if (didattica) {
      url = '${base}students/$code/didactics/item/$docId';
    } else {
      url = '${base}students/$code/noticeboard/attach/$evtCode/$docId/$num';
    }

    // Ottieni cartella temporanea
    final dir = await getTemporaryDirectory();
    String? filePath; // Inizializza come nullable

    try {
      // Esegui una richiesta HEAD per ottenere gli header prima di scaricare il corpo completo
      // o scarica direttamente e controlla la risposta.
      // Per semplicità, scaricheremo e poi controlleremo.
      // Se i file sono molto grandi, una richiesta HEAD sarebbe più efficiente.

      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes, // Scarica come stream di byte
        ),
      );

      // ... (dentro la tua funzione downloadAndOpenPdfById)

      if (response.statusCode == 200 && response.data != null) {
        String fileExtension = '.pdf'; // Estensione predefinita come da tua indicazione
        final contentTypeHeader = response.headers.value(Headers.contentTypeHeader);

        if (contentTypeHeader != null) {
          final mimeType = contentTypeHeader.split(';').first.trim(); // Estrai il tipo MIME principale

          // Utilizza la funzione dal pacchetto mime e assegna a una variabile con nome diverso
          final String determinedExtension = extensionFromMime(mimeType); // << CORREZIONE QUI

          fileExtension = '.$determinedExtension';
                  print('Content-Type: $mimeType, Estensione derivata: $fileExtension');
        } else {
          print('Content-Type header non trovato, usando estensione predefinita .pdf');
        }

        final completeFileName = '$fileNameWithoutExtension$fileExtension';
        filePath = '${dir.path}/$completeFileName';
        final file = File(filePath);

        await file.writeAsBytes(response.data);

        if (await file.exists()) {
          final result = await OpenFile.open(filePath);
          print('OpenFile result: ${result.type}, Message: ${result.message}');
          if (result.type != ResultType.done) {
            print('Errore durante l''apertura del file: ${result.message}');
          }
        } else {
          print('ERRORE: il file non esiste dopo il salvataggio');
        }
      } else {
        print('ERRORE nel download del file: Status code: ${response.statusCode}');
      }
      // ... (resto della funzione)

    } on DioException catch (e) {
      print('ERRORE Dio: ${e.toString()}');
      if (e.response != null) {
        print('Status code: ${e.response?.statusCode}');
        print('Response headers: ${e.response?.headers}');
        print('Response data: ${e.response?.data}');
      } else {
        print('Nessuna risposta dal server o errore di connessione');
      }
      // Potresti voler propagare l'errore o gestirlo mostrando un messaggio all'utente
    } catch (e) {
      print('Errore generico in downloadAndOpenPdfById: $e');
      // Gestisci altri tipi di errori
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


    List<Giorno> giorni = [];
    for(int i = 0; i < 5; i++){
      DateTime data = lunediScorso.add(Duration(days: i));
      String fromDate = "${data.year}${data.month.toString().padLeft(2, '0')}${data.day.toString().padLeft(2, '0')}";

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

  Future<String> ottieniPhpsessid() async {
    final uri = Uri.parse(
      'https://web.spaggiari.eu/auth-p7/app/default/AuthApi4.php?a=aLoginPwd',
    );

    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Origin': 'https://web.spaggiari.eu',
      'User-Agent': 'Mozilla/5.0',
    };

    final body = 'cid=&uid=$codiceStudent&pwd=$pass&pin=&target=';

    final resp = await http.post(uri, headers: headers, body: body);


    final setCookie = resp.headers['set-cookie'];
    if (setCookie == null || setCookie.isEmpty) {
      throw Exception('Nessun header Set-Cookie presente nella risposta');
    }

    // Estrae PHPSESSID dal/i Set-Cookie
    final match = RegExp(r'PHPSESSID=([^;]+)').firstMatch(setCookie);
    if (match == null) {
      throw Exception('PHPSESSID non trovato');
    }

    final phpsessid = match.group(1)!;
    return phpsessid;
  }

  Future<PctoData> getCurriculum() async {
    phpSessId =  await ottieniPhpsessid();

    final response = await http.get(
      Uri.parse("https://web.spaggiari.eu/set/app/default/curriculum.php?"),
      headers: {'UserAgent' : 'Mozilla/5.0', 'Cookie': 'PHPSESSID=$phpSessId; webrole=gen; webidentity=$codiceStudent'},
    );
    if (response.statusCode == 200) {
      final htmlContent = response.body;
      final pctoData = parsePctoHtmlIndependent(htmlContent);
      return pctoData!;
    } else {
      throw Exception('Errore durante il recupero del curriculum: ${response.statusCode}');
    }
  }

  Future<List<SchoolEvent>> getEvents() async {
    phpSessId =  await ottieniPhpsessid();

    final response = await http.get(
      Uri.parse("https://web.spaggiari.eu/fml/app/default/librettoweb.php"),
      headers: {'UserAgent' : 'Mozilla/5.0', 'Cookie': 'PHPSESSID=$phpSessId; webrole=gen; webidentity=$codiceStudent'},
    );
    if (response.statusCode == 200) {
      final htmlContent = response.body;
      final events = HtmlParserService().parseEvents(htmlContent);
      return events;
    }else{
      return [];
    }
  }

  String getOpeTipo(Ope tipo){
    return switch(tipo){
      Ope.NUOVO => "NUOVO",
      Ope.ELIMINA => "ELIMINA"
    };
  }

  Future<void> sendRequest(RichiestaGiustifica richiesta) async {

    final uri = Uri.parse(
      'https://web.spaggiari.eu/fml/app/default/librettoweb_io.php',
    );

    final Map<String, String> body = {
      'ope': getOpeTipo(richiesta.ope),
      'tipo_giustifica': richiesta.tipo_giustifica.toString(),
      'inizio_assenza': richiesta.inizio_assenza,
      'fine_assenza': richiesta.fine_assenza,
      'motivazione_assenza': richiesta.motivazione_assenza,
      'giorno_entrata_uscita': richiesta.giorno_entrata_uscita,
      'ora_entrata_uscita': richiesta.ora_entrata_uscita,
      'motivazione_entrata_uscita': richiesta.motivazione_entrata_uscita,
      'accompagnatore': richiesta.accompagnatore,
    };
    final resp = await http.post(
      uri,
      headers: {'UserAgent' : 'Mozilla/5.0', 'Cookie': 'PHPSESSID=$phpSessId; webrole=gen; webidentity=$codiceStudent', 'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );

    print('Status code: ${resp.statusCode}');
    print('Response data: ${resp.body.toString()}');
  }

  Future<List<PeriodoFestivo>> getPeriodiFestivi () async {
    final response = await http.get(
      Uri.parse(vacanze),
      headers: otherHeaders,
    );
    if(response.statusCode == 200){
      final json = jsonDecode(response.body);
      return PeriodoFestivo.fromJson(json);
    }
    else{
      print(response.body);
      print(response.statusCode);
    }
    return [];
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
    Future<LoginResponse?> doLogin() async {
      final response = await http.post(
          Uri.parse(login),
          headers: loginHeaders,
          body: '{ "uid": "$fullCode", "pass": "$pass", "ident": null}'
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
