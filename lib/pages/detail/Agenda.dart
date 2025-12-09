import 'package:classemorta/models/Info.dart';
import 'package:classemorta/models/InfoReturn.dart';
import 'package:classemorta/widgets/CompitoWidget.dart';
import 'package:flutter/material.dart';
import '../../service/ApiService.dart';

class Agenda extends StatefulWidget {
  final Apiservice apiService;
  const Agenda({super.key, required this.apiService});
  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  late Apiservice _service;
  late Future<InfoReturn> _info;
  @override
  void initState() {
    super.initState();
    _service = widget.apiService;
    _info = _service.getInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _info = (_service.getInfo());
    });
    await _info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda / Compiti / Verifiche'),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FutureBuilder<InfoReturn>(
            future: _info,
            builder: (context, snapshotOuter) {
              if (snapshotOuter.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshotOuter.hasError) {
                return Center(child: Text("Errore nel caricare i dati principali: ${snapshotOuter.error}"));
              } else if (snapshotOuter.hasData && snapshotOuter.data != null) {
                List<List<Info>?> listOfLists = snapshotOuter.data!.info;

                Future<List<Info>?> compitiFuture;
                if (listOfLists.isNotEmpty && listOfLists[0] != null) {
                  compitiFuture = Future.value(listOfLists[0]);
                } else {
                  compitiFuture = Future.value(null); // Or an empty list: Future.value([]);
                }

                Future<List<Info>?> notizieFuture;
                if (listOfLists.isNotEmpty && listOfLists[1] != null) {
                  notizieFuture = Future.value(listOfLists[1]);
                } else {
                  notizieFuture = Future.value(null); // Or an empty list: Future.value([]);
                }

                Future<List<Info>?> verificheFuture;
                if (listOfLists.isNotEmpty && listOfLists[2] != null) {
                  verificheFuture = Future.value(listOfLists[2]);
                } else {
                  verificheFuture = Future.value(null); // Or an empty list: Future.value([]);
                }

                Future<List<Info>?> altroFuture;
                if (listOfLists.isNotEmpty && listOfLists[3] != null) {
                  altroFuture = Future.value(listOfLists[3]);
                } else {
                  altroFuture = Future.value(null); // Or an empty list: Future.value([]);
                }
                Future<List<Info>?> perDomaniFuture;
                if (listOfLists.isNotEmpty && listOfLists[4] != null) {
                  perDomaniFuture = Future.value(listOfLists[4]);
                } else {
                  perDomaniFuture = Future.value(null); // Or an empty list: Future.value([]);
                }
                int timesD = 0;
                int timesDD = 0;
                int times3 = 0;
                int times4_7 = 0;
                int times8_15 = 0;
                int times15 = 0;
                if(snapshotOuter.data!.times.isNotEmpty) {
                  timesD =  snapshotOuter.data!.times[0];
                  timesDD = snapshotOuter.data!.times[1];
                  times3 = snapshotOuter.data!.times[2];
                  times4_7 = snapshotOuter.data!.times[3];
                  times8_15 = snapshotOuter.data!.times[4];
                  times15 = snapshotOuter.data!.times[5];
                }
                return Column(
                  children: [
                    SizedBox(height: 30,),
                    displayInfos("  Per domani", perDomaniFuture, "Niente per domani"),
                    SizedBox(height: 15,),
                    displayInfos("  Compiti", compitiFuture, "Nessun compito trovato"),
                    SizedBox(height: 15,),
                    displayInfos("  Cose da portare", notizieFuture, "Niente da portare"),
                    SizedBox(height: 15,),
                    displayInfos("  Verifiche", verificheFuture, "Nessuna verifica"),
                    SizedBox(height: 15,),
                    displayInfos("  Altro (non filtrati)", altroFuture, "Nessun dato avanzato"),
                    SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      height: 40,
                      width: 400,
                      child: Text(
                        "  Numero eventi",
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if( snapshotOuter.data!.times.isNotEmpty) ...[
                      displayTime(" domani", timesD),
                      displayTime(" dopo domani", timesDD),
                      displayTime(" 3 giorni", times3),
                      displayTime(" 4-7 giorni", times4_7),
                      displayTime(" 8-15 giorni", times8_15),
                      displayTime(" più di 15 giorni", times15),
                    ]else ...[
                      const Center(child: Text("Nessun evento trovato")),
                    ],
                    SizedBox(
                      height: 100,
                    ),

                  ],
                );
              } else {
                return const Center(child: Text("Nessun dato trovato"));
              }
            },
          ),
        )
      ),
    );
  }
  Widget displayTime(String title, int value){
    return Column(
      children: [
        Row(
          children: [
            Text(
                "       Eventi per",
                style: const TextStyle(fontSize: 13)
            ),
            Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const SizedBox(width: 15),
            Text(
                "$value",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,
                    color: value == 0 ? Colors.white :
                           value > 0 && value < 3 ? Colors.green :
                           value >= 3 && value < 5 ? Colors.orange : Colors.red
                )
            ),
          ],
        ),
      ],
    );
  }

  Widget displayInfos(
      String title, Future<List<Info>?> infoFuture, String notFoundText) {
    return Column(
      children: [
        const Divider(
            height: 10, thickness: 1, color: Colors.white, indent: 20, endIndent: 20),
        FutureBuilder<List<Info>?>(
          future: infoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Errore caricamento dati: ${snapshot.error}"));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<Info> loadedInfos = snapshot.data!;

              // 1. Raggruppa gli 'Info' per data
              Map<String, List<Info>> groupedByDate = {};
              for (var info in loadedInfos) {
                String dateKey = info.data.substring(0, 10);
                if (groupedByDate[dateKey] == null) {
                  groupedByDate[dateKey] = [];
                }
                groupedByDate[dateKey]!.add(info);
              }

              List<String> dateKeys = groupedByDate.keys.toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      height: 40,
                      width: 350,
                      child: Text(
                        "$title (${loadedInfos.length})",
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 280, // Aumenta l'altezza per far spazio ai titoli
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dateKeys.length,
                      itemBuilder: (BuildContext context, int index) {
                        String dateKey = dateKeys[index];
                        List<Info> infosForDate = groupedByDate[dateKey]!;

                        // 2. Crea un contenitore per ogni gruppo di date
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: getColor(infosForDate[0].dataFine),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.black, width: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 3. Aggiungi il titolo con data e distanza
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  "${getData(dateKey)} - ${getDistanza(dateKey)} (${infosForDate.length})",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // 4. Mostra gli InfoSingola per quella data
                              Row(
                                children: infosForDate
                                    .map((info) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: SizedBox(
                                    width: 290,
                                    height: 220,
                                    child: InfoSingola(info: info),
                                  ),
                                  )
                                )
                                    .toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              );
            } else {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 400,
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Center(child: Text(notFoundText))
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Color? getColor(String dataFine) {
    try {
      DateTime today = DateTime.now();
      DateTime scadenzaFine = DateTime.parse(dataFine.substring(0, 19));
      DateTime scadenzaGen = DateTime.parse(dataFine.substring(0, 10));
      Duration differenzaGen = scadenzaGen.difference(today);

      double opacita = 0.2;

      if (scadenzaFine.isBefore(today) ) {
        return today.hour < scadenzaFine.hour ? Colors.red : Colors.grey[900];
      }
      if (differenzaGen.inDays == 0) {
        return Color.fromRGBO(255, 100,100, 0.5).withOpacity(opacita);
      }
      if (differenzaGen.inDays == 1) {
        return Colors.orange[700]?.withOpacity(opacita);
      }
      if (differenzaGen.inDays == 2) {
        return Colors.orange[300]?.withOpacity(opacita);
      }
      if (differenzaGen.inDays <= 6) {
        return Colors.green[300]?.withOpacity(opacita);
      }
      return Colors.green[600]?.withOpacity(opacita);
    } catch (e) {
      return Colors.grey[300];
    }
  }

  String getData(String dataString){
    List<String> nomiGiorni = [
      'Lunedì',
      'Martedì',
      'Mercoledì',
      'Giovedì',
      'Venerdì',
      'Sabato',
      'Domenica',
    ];
    List<String> nomiMesi = [
      'Gennaio',
      'Febbraio',
      'Marzo',
      'Aprile',
      'Maggio',
      'Giugno',
      'Luglio',
      'Agosto',
      'Settembre',
      'Ottobre',
      'Novembre',
      'Dicembre',
    ];
    DateTime scadenza = DateTime.parse(dataString.substring(0, 10));
    DateTime scadenzaDateOnly = DateTime(
      scadenza.year,
      scadenza.month,
      scadenza.day,
    );

    String data = "${nomiGiorni[scadenzaDateOnly.weekday - 1].substring(0, 3)} "
        "${scadenzaDateOnly.day} ${nomiMesi[scadenzaDateOnly.month - 1].substring(0, 3)} "
        "${scadenzaDateOnly.year}";


    return data;
  }

  String getDistanza(String dataString) {

    try {
      DateTime today = DateTime.now(); // Considera di usare DateTime.now() per la data corrente reale
      DateTime scadenza = DateTime.parse(dataString.substring(0, 10));
      DateTime scadenzaDateOnly = DateTime(
        scadenza.year,
        scadenza.month,
        scadenza.day,
      );
      Duration differenza = scadenzaDateOnly.difference(today);
      if(differenza.inHours < -14){
        return "Oggi passato";
      }
      if (scadenzaDateOnly.isBefore(today)) {
        return "PER OGGI !!!";
      }
      if (differenza.inDays == 0) {
        return "DOMANI !!!";
      }
      if (differenza.inDays == 1) {
        return "Dopo domani";
      }
      return "${(differenza.inDays + 1).toString()} giorni";

    } catch (e) {
      return "Errore";
    }
  }

}
