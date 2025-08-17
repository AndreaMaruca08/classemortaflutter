import 'package:ClasseMorta/models/Info.dart';
import 'package:ClasseMorta/widgets/CompitoWidget.dart';
import 'package:flutter/material.dart';
import '../service/ApiService.dart';

class Agenda extends StatefulWidget {
  final Apiservice apiService;
  const Agenda({super.key, required this.apiService});
  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  late Apiservice _service;
  late Future<List<List<Info>?>> _info;
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
          child: FutureBuilder<List<List<Info>?>>( // Outer FutureBuilder for the main list of lists
            future: _info,
            builder: (context, snapshotOuter) {
              if (snapshotOuter.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshotOuter.hasError) {
                print(snapshotOuter.error);
                return Center(child: Text("Errore nel caricare i dati principali: ${snapshotOuter.error}"));
              } else if (snapshotOuter.hasData && snapshotOuter.data != null) {
                List<List<Info>?> listOfLists = snapshotOuter.data!;

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

                return Column(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 100,
                      child: const Text(
                        "Compiti",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    FutureBuilder<List<Info>?>( // Inner FutureBuilder for the "Compiti" list
                      future: compitiFuture, // Use the extracted list (wrapped in a Future)
                      builder: (context, snapshotCompiti) {
                        if (snapshotCompiti.connectionState == ConnectionState.waiting && listOfLists.isEmpty) {
                          // Show loading only if the outer future hasn't resolved yet with data
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshotCompiti.hasError) {
                          print(snapshotCompiti.error);
                          return Center(child: Text("Errore caricamento compiti: ${snapshotCompiti.error}"));
                        } else if (snapshotCompiti.hasData && snapshotCompiti.data!.isNotEmpty) {
                          List<Info> loadedCompiti = snapshotCompiti.data!;
                          return SizedBox(
                            height: 230,
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
                            child: const Center(child: Text("Nessun compito trovato")),
                          );
                        }
                      },
                    ),
                    //LIBRI DA PORTARE
                    SizedBox(
                      height: 40,
                      width: 200,
                      child: const Text(
                        "    Cose da portare",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    FutureBuilder<List<Info>?>( // Inner FutureBuilder for the "Compiti" list
                      future: notizieFuture, // Use the extracted list (wrapped in a Future)
                      builder: (context, snapshotCompiti) {
                        if (snapshotCompiti.connectionState == ConnectionState.waiting && listOfLists.isEmpty) {
                          // Show loading only if the outer future hasn't resolved yet with data
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshotCompiti.hasError) {
                          print(snapshotCompiti.error);
                          return Center(child: Text("Errore caricamento libri da portare: ${snapshotCompiti.error}"));
                        } else if (snapshotCompiti.hasData && snapshotCompiti.data!.isNotEmpty) {
                          List<Info> loadedCompiti = snapshotCompiti.data!;
                          return SizedBox(
                            height: 175,
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
                            child: const Center(child: Text("Nessuna cosa trovata")),
                          );
                        }
                      },
                    ),
                    SizedBox(
                      height: 40,
                      width: 100,
                      child: const Text(
                        "Verifiche",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    FutureBuilder<List<Info>?>( // Inner FutureBuilder for the "Compiti" list
                      future: verificheFuture, // Use the extracted list (wrapped in a Future)
                      builder: (context, snapshotCompiti) {
                        if (snapshotCompiti.connectionState == ConnectionState.waiting && listOfLists.isEmpty) {
                          // Show loading only if the outer future hasn't resolved yet with data
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshotCompiti.hasError) {
                          print(snapshotCompiti.error);
                          return Center(child: Text("Errore caricamento verifiche: ${snapshotCompiti.error}"));
                        } else if (snapshotCompiti.hasData && snapshotCompiti.data!.isNotEmpty) {
                          List<Info> loadedCompiti = snapshotCompiti.data!;
                          return SizedBox(
                            height: 200,
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
                            child: const Center(child: Text("Nessuna verifica trovata")),
                          );
                        }
                      },
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

}
