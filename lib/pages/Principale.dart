import 'dart:async'; // Aggiunto per Future
import 'package:ClasseMorta/models/Voto.dart';
import 'package:ClasseMorta/pages/Agenda.dart';
import 'package:ClasseMorta/pages/Materie.dart';
import 'package:ClasseMorta/pages/Notizie.dart';
import 'package:ClasseMorta/widgets/SingoloVotoWid.dart';
import 'package:ClasseMorta/widgets/VotoDisplay.dart';
import 'package:flutter/material.dart';

import '../models/Notizia.dart';
import '../models/Streak.dart';
import '../models/StudentCard.dart';
import '../service/ApiService.dart';
import 'DettagliPersona.dart';

class MainPage extends StatefulWidget {
  final Apiservice apiService;
  const MainPage({super.key, required this.apiService});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Apiservice _service; // Rinominato per convenzione (_ per privato)
  late Future<List<Voto>?> _medieGeneraliFuture; // Stato per il Future
  late Future<List<Voto>?> _lastVotiFuture; // Stato per il Future
  late Future<List<Voto>?> _voti;
  late Future<List<List<Notizia>?>> _notizie;
  @override
  void initState() {
    super.initState();
    _service = widget.apiService;
    _medieGeneraliFuture = _service.getMedieGenerali() ; // Caricamento iniziale
    _lastVotiFuture = _service.getLastVoti(100);
    _voti = _service.getAllVoti();
    _notizie = _service.getNotizie();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _medieGeneraliFuture = (_service.getMedieGenerali());
      _lastVotiFuture = (_service.getLastVoti(100));
      _voti = _service.getAllVoti();
      _notizie = _service.getNotizie();
    });
    await _medieGeneraliFuture;
    await _lastVotiFuture;
    await _voti;
    await _notizie;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagina principale'),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh, // Usa la nuova funzione di refresh
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Per consentire sempre il pull-to-refresh
            child: Column(
              children: [
                //
                FutureBuilder(future: _service.getCard(), builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  else if (snapshot.hasError) {
                    return const Center(child: Text("Errore"));
                  }
                  else if (snapshot.hasData && snapshot.data != null) {
                    StudentCard card = snapshot.data!;
                    return Row(
                      children: [
                        Text(
                          "Buongiorno ${card.usrType == "S" ? "Studente" : card.usrType == "P" ? "Professore" : "Genitore di"} ${card.nome} ${card.cognome}",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => StudentDetail(card: card)), // Sostituisci con la tua pagina
                            );
                          },
                          icon: Icon(Icons.info_outline),
                          tooltip: 'Dettagli studente',
                        )


                      ],
                    );
                  }
                  else {
                    return const Center(child: Text("Nessun risultato"));
                  }
                }),
                const SizedBox(height: 20),
                FutureBuilder<List<Voto>?>( // Specificato il tipo del FutureBuilder
                  future: _medieGeneraliFuture, // Usa lo stato del Future
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Errore nel caricamento: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      // Usa snapshot.data! direttamente invece di assegnare a medieGenerali
                      // per evitare chiamate setState non necessarie all'interno del builder.
                      final List<Voto> loadedMedie = snapshot.data!;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(240, 240, 240, 0.4),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                SizedBox(width: 1),
                                Text("Media Totale", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                SizedBox(width: 33),
                                Text("Primo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                SizedBox(width: 35),
                                Text("Secondo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                // Assicurati che loadedMedie abbia abbastanza elementi
                                if (loadedMedie.isNotEmpty) VotoSingolo(voto: loadedMedie[0], grandezza: 115),
                                const SizedBox(width: 20),
                                if (loadedMedie.length > 1) VotoSingolo(voto: loadedMedie[1], grandezza: 90),
                                const SizedBox(width: 15),
                                if (loadedMedie.length > 2) VotoSingolo(voto: loadedMedie[2], grandezza: 90),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    } else {
                      return const Center(child: Text("Nessun risultato"));
                    }
                  },
                ),
                const SizedBox(height: 20),
                FutureBuilder(future: _lastVotiFuture, builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Errore nel caricamento: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final List<Voto> loadedVoti = snapshot.data!;
                    Streak streak = Streak().getStreak(loadedVoti.reversed.toList());
                    return Column(
                      children: [
                         Row(
                          children: [
                            const SizedBox(width: 1),
                            const Text("Tutti i voti", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 60),
                            const Text("Streak: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Icon(
                              streak.isGoat(loadedVoti) ? Icons.star: streak.votiBuoni >= 10 ? Icons.local_fire_department: Icons.local_fire_department_outlined,
                              color: streak.isGoat(loadedVoti)? Colors.yellow : streak.getStreakColor(),
                              size: 40,
                            ),
                            Text(
                              " ${streak.isGoat(loadedVoti) ? "GOAT" : streak.votiBuoni}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: streak.isGoat(loadedVoti)? Colors.yellow : streak.getStreakColor()
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                        height: 176,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(240, 240, 240, 0.4),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: loadedVoti.length,
                              itemBuilder: (context, index) {
                                return Votodisplay(voto: loadedVoti[index], grandezza: 88);
                              }
                          ),
                        )
                      ),
                      ],
                    );
                  }else{
                    return const Center(child: Text("Nessun risultato"));
                  }
                }),
                SizedBox(height: 10),
                Divider(thickness: 1, color: Colors.white,),
                SizedBox(height: 10),
                Row(
                  children: [
                    FutureBuilder(future: _voti, builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Errore nel caricamento: ${snapshot.error}'),
                          );
                        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          final List<Voto> loadedVoti = snapshot.data!;
                          return passaggio(context, "  Materie            ", "Materie", MateriePag(service: _service, voti: loadedVoti,), Icon(Icons.medical_information_rounded));

                        }else{
                          return const Center(child: Text("Nessuna materia con voto"));
                        }
                      }),
                    SizedBox(width: 10),
                    passaggio(context, "  Compiti           ", "Agenda", Agenda(apiService: _service), Icon(Icons.calendar_month)),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    FutureBuilder(future: _notizie, builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Errore nel caricamento: ${snapshot.error}'),
                        );
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final List<List<Notizia>?> loadedNotizie = snapshot.data!;
                        return passaggio(
                            context,
                            "  Notizie            ",
                            "Notizie/assenze prof",
                            NotiziePage(
                              circolari: loadedNotizie[0],
                              variazioni: loadedNotizie[1],
                              altro: loadedNotizie[3],
                              variazioniDiClasse: loadedNotizie[2],
                              service: _service,
                            ),
                            Icon(Icons.calendar_month)
                        );

                      }else{
                        return const Center(child: Text("Nessuna materia con voto"));
                      }
                    }),
                     SizedBox(width: 10),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );

  }

  Widget passaggio(BuildContext context, String mess, String tooltip, Widget pagina,  Icon icon){
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(240, 240, 240, 0.4),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(2, 2),
          ),
        ],
      ),
      height: 40,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => pagina), // Sostituisci con la tua pagina
              );
            },
            icon: icon,
            tooltip: tooltip,
          ),
          Text(mess)
        ],
      ),
    );

  }

}

