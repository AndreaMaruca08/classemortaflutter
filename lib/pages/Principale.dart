import 'dart:async'; // Aggiunto per Future
import 'package:ClasseMorta/models/Materia.dart';
import 'package:ClasseMorta/models/Voto.dart';
import 'package:ClasseMorta/pages/detail/Agenda.dart';
import 'package:ClasseMorta/pages/AssenzePage.dart';
import 'package:ClasseMorta/pages/detail/DettagliMateria.dart';
import 'package:ClasseMorta/pages/Materie.dart';
import 'package:ClasseMorta/pages/NotePagina.dart';
import 'package:ClasseMorta/pages/Notizie.dart';
import 'package:ClasseMorta/pages/PagellePagina.dart';
import 'package:ClasseMorta/widgets/SingoloVotoWid.dart';
import 'package:ClasseMorta/widgets/VotoDisplay.dart';
import 'package:flutter/material.dart';

import '../models/Assenza.dart';
import '../models/Lezione.dart';
import '../models/Nota.dart';
import '../models/Notizia.dart';
import '../models/Pagella.dart';
import '../models/Streak.dart';
import '../models/StudentCard.dart';
import '../service/ApiService.dart';
import '../widgets/Lezionewidget.dart';
import 'detail/DettagliPersona.dart';

class MainPage extends StatefulWidget {
  final Apiservice apiService;
  const MainPage({super.key, required this.apiService});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Apiservice _service; // Rinominato per convenzione (_ per privato)
  late Future<List<Voto>?> _medieGeneraliFuture; // Stato per il Future
  late Future<List<Voto>?> _lastVotiFutureMedie; // Stato per il Future
  late Future<List<Voto>?> _lastVotiFuture; // Stato per il Future
  late Future<List<Voto>?> _voti;
  late Future<List<List<Notizia>?>> _notizie;
  late Future<List<List<Nota>>> _note;
  late Future<List<Pagella>?> _pagelle;
  late Future<List<List<Assenza>>> _assenze;
  late Future<List<Lezione>> _lessonsToday;

  @override

  void initState() {
    super.initState();
    _service = widget.apiService;
    _medieGeneraliFuture = _service.getMedieGenerali() ; // Caricamento iniziale
    _lastVotiFutureMedie = _service.getLastVoti(100);
    _voti = _service.getAllVoti();
    _lastVotiFuture = _service.getLastVoti(100);
    _notizie = _service.getNotizie();
    _pagelle = _service.getPagelle() as Future<List<Pagella>?>;
    _assenze = _service.getAssenze();
    _note = _service.getNote();
    _lessonsToday = _service.getLezioni();

  }

  Future<void> _handleRefresh() async {
    setState(() {
      _medieGeneraliFuture = (_service.getMedieGenerali());
      _lastVotiFutureMedie = (_service.getLastVoti(100));
      _voti = _service.getAllVoti();
      _lastVotiFuture = _service.getLastVoti(100);
      _notizie = _service.getNotizie();
      _note = _service.getNote();
      _assenze = _service.getAssenze();
      _lessonsToday = _service.getLezioni();
      _pagelle = _service.getPagelle() as Future<List<Pagella>?>;
    });
    await _medieGeneraliFuture;
    await _lastVotiFutureMedie;
    await _voti;
    await _lastVotiFuture;
    await _notizie;
    await _note;
    await _pagelle;
    await _lessonsToday;
    await _assenze;
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
                //CARTA STUDENTE
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
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(2.0, 2.0), // Spostamento orizzontale e verticale dell'ombra
                                  blurRadius: 3.0,         // Quanto deve essere sfocata l'ombra
                                  color: Colors.black.withOpacity(0.5), // Colore dell'ombra con opacità
                                ),
                              ]
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

                //MEDIE
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
                             Row(
                              children: [
                                SizedBox(width: 1),
                                Text(
                                    "Media Totale",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                        shadows: <Shadow>[
                                          Shadow(
                                            offset: Offset(2.0, 2.0), // Spostamento orizzontale e verticale dell'ombra
                                            blurRadius: 3.0,         // Quanto deve essere sfocata l'ombra
                                            color: Colors.black, // Colore dell'ombra con opacità
                                          ),
                                        ]
                                    )
                                ),
                                SizedBox(width: 33),
                                Text(
                                    "Primo",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        shadows: <Shadow>[
                                          Shadow(
                                            offset: Offset(2.0, 2.0), // Spostamento orizzontale e verticale dell'ombra
                                            blurRadius: 3.0,         // Quanto deve essere sfocata l'ombra
                                            color: Colors.black, // Colore dell'ombra con opacità
                                          ),
                                        ]
                                    )
                                ),
                                SizedBox(width: 35),
                                Text(
                                    "Secondo",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        shadows: <Shadow>[
                                          Shadow(
                                            offset: Offset(2.0, 2.0), // Spostamento orizzontale e verticale dell'ombra
                                            blurRadius: 3.0,         // Quanto deve essere sfocata l'ombra
                                            color: Colors.black, // Colore dell'ombra con opacità
                                          ),
                                        ]
                                    )
                                ),
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
                            FutureBuilder<List<Voto>?>(
                              future: _lastVotiFutureMedie, // Usa il Future esistente per i voti
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                else if (snapshot.hasError) {
                                  return const Center(child: Text("Errore"));
                                }
                                else if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                                  List<Voto> voti = snapshot.data!;
                                  return Row(
                                    children: [
                                      SizedBox(width: 27,),
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Dettaglimateria(materia: Materia(
                                                            codiceMateria: "Anno intero",
                                                            nomeInteroMateria: "Anno",
                                                            nomeProf: "Sistema",
                                                            voti: voti
                                                        ),
                                                          periodo: 3,
                                                          dotted: false,
                                                        )
                                                ));
                                          },
                                          icon: Icon(Icons.auto_graph_sharp,
                                            color: Colors.white,)),
                                      SizedBox(width: 82,),
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Dettaglimateria(materia: Materia(
                                                            codiceMateria: "1° quadrimestre",
                                                            nomeInteroMateria: "1° quadrimestre",
                                                            nomeProf: "Sistema",
                                                            voti: voti
                                                        ),
                                                          periodo: 1,
                                                          dotted: false,
                                                        )
                                                ));
                                          },
                                          icon: Icon(Icons.auto_graph_sharp,
                                            color: Colors.white,)),
                                      SizedBox(width: 60,),
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Dettaglimateria(materia: Materia(
                                                            codiceMateria: "2° quadrimestre",
                                                            nomeInteroMateria: "2° quadrimestre",
                                                            nomeProf: "Sistema",
                                                            voti: voti
                                                        ),
                                                          periodo: 2,
                                                          dotted: false,
                                                        )
                                                ));
                                          },
                                          icon: Icon(Icons.auto_graph_sharp,
                                            color: Colors.white,)),
                                    ],
                                  );
                                }else{
                                  return const Center(child: Text("Nessun risultato"));
                                }
                              },
                            ),
                          ],

                        ),
                      );
                    } else {
                      return const Center(child: Text("Nessun risultato"));
                    }
                  },

                ),

                const SizedBox(height: 20),

                //VOTI
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
                                  color: streak.isGoat(loadedVoti)? Colors.yellow : streak.getStreakColor(),

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
                            "  Notizie             ",
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
                    SizedBox(width: 12),
                    FutureBuilder(future: _note, builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Errore nel caricamento: ${snapshot.error}'),
                        );
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final List<List<Nota>> loadedNote = snapshot.data!;
                        return passaggio(
                            context,
                            "  Note               ",
                            "Note/Annotazioni/",
                            Notepagina(
                              note: loadedNote,
                            ),
                            Icon(Icons.edit_note_outlined)
                        );

                      }else{
                        return const Center(child: Text("Nessuna materia con voto"));
                      }
                    }),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    FutureBuilder(future: _pagelle, builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Errore nel caricamento: ${snapshot.error}'),
                        );
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final List<Pagella> pag = snapshot.data!;
                        return passaggio(
                            context,
                            "  Pagelle            ",
                            "Pagelle",
                            Pagellepagina(pagelle: pag),
                            Icon(Icons.edit_note_outlined)
                        );

                      }else{
                        return const Center(child: Text("Nessuna materia con voto"));
                      }
                    }),
                    SizedBox(width: 10,),

                  ],
                ),
                SizedBox(
                  height: 10,
                ),

                const Divider(thickness: 1, color: Colors.white,),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Lezioni   ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 400,
                        child: FutureBuilder<List<Lezione>>(
                          future: _lessonsToday,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Errore nel caricamento: ${snapshot.error}'),
                              );
                            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              final List<Lezione> lezioni = snapshot.data!;
                              return ListView.builder(
                                itemCount: lezioni.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Lezione lezione = lezioni[index];
                                  return Lezionewidget(lezione: lezione);
                                },
                              );
                            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                              return const Center(child: Text("Nessuna lezione per oggi"));
                            } else {
                              return const Center(child: Text("Le lezioni devono ancora iniziare"));
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                  ],
                ),
// ...

                const Divider(thickness: 1, color: Colors.white,),
                FutureBuilder(future: _assenze, builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Errore nel caricamento: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final List<List<Assenza>> ass = snapshot.data!;
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
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              SizedBox(width: 5,),
                              Container(
                                padding: EdgeInsets.all(10),
                                height: 70,
                                width: 160,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 0, 0, 0.6),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(10, 10, 10, 0.4),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "   Assenze ${ass[0].length}   ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      BoxShadow(
                                        color: Color.fromRGBO(10, 10, 10, 0.4),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Container(
                                width: 155,
                                padding: EdgeInsets.all(10),
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 0, 0.6),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(10, 10, 10, 0.4),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: SizedBox(
                                  width: 150,
                                  height: 10,
                                  child: Text(
                                    "    Uscite ${ass[1].length}   ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          BoxShadow(
                                          color: Color.fromRGBO(10, 10, 10, 0.4),
                                          spreadRadius: 1,
                                          blurRadius: 1,
                                          offset: Offset(2, 2),
                                          ),
                                        ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              SizedBox(width: 5,),
                              Container(
                                padding: EdgeInsets.all(10),
                                height: 75,
                                width: 160,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(0, 0, 255, 0.6),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(10, 10, 10, 0.4),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "      Ritardi ${ass[2].length}   ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      BoxShadow(
                                        color: Color.fromRGBO(10, 10, 10, 0.4),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Container(
                                padding: EdgeInsets.all(10),
                                height: 75,
                                width: 155,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(0, 0, 0, 0.6),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(10, 10, 10, 0.4),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Dettagli",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          BoxShadow(
                                            color: Color.fromRGBO(10, 10, 10, 0.4),
                                            spreadRadius: 1,
                                            blurRadius: 1,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => Assenzepage(assenze:ass)), // Sostituisci con la tua pagina
                                          );
                                        },
                                        icon: Icon(Icons.info_outline),
                                        tooltip: "Dettagli assenze",
                                    )
                                  ],
                                )
                              ),

                            ],
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    );

                  }else{
                    return const Center(child: Text("Nessuna assenza/ritardo/usccita"));
                  }
                }),
                SizedBox(height: 200,)

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
          Text(mess , style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(2.0, 2.0), // Spostamento orizzontale e verticale dell'ombra
                blurRadius: 3.0,         // Quanto deve essere sfocata l'ombra
                color: Colors.black.withOpacity(0.5), // Colore dell'ombra con opacità
              ),
            ]
          ),)
        ],
      ),
    );

  }

}

