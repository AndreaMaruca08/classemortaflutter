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

  Widget displayInfos(String title, Future<List<Info>?> infoFuture, String notFoundText){
    return Column(
      children: [
        const Divider(height: 10, thickness: 1, color: Colors.white, indent: 20, endIndent: 20),
        SizedBox(
          height: 40,
          width: 400,
          child: Text(
            title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Info>?>( // Inner FutureBuilder for the "Compiti" list
          future: infoFuture, // Use the extracted list (wrapped in a Future)
          builder: (context, snapshotCompiti) {
            if (snapshotCompiti.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshotCompiti.hasError) {
              return Center(child: Text("Errore caricamento dati: ${snapshotCompiti.error}"));
            } else if (snapshotCompiti.hasData && snapshotCompiti.data!.isNotEmpty) {
              List<Info> loadedCompiti = snapshotCompiti.data!;
              return SizedBox(
                height: 210,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: loadedCompiti.length,
                  itemBuilder: (BuildContext context, int index) {
                    Info compito = loadedCompiti[index];
                    return Row(
                      children: [
                        const SizedBox(width: 10),
                        InfoSingola(info: compito)
                      ],
                    );
                  },
                ),
              );
            } else {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child:  Center(child: Text(notFoundText)),
              );
            }
          },
        ),
      ],
    );
  }

}
