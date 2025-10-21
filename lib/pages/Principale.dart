import 'dart:async';
import 'package:classemorta/main.dart';
import 'package:classemorta/models/Achievment.dart';
import 'package:classemorta/models/Materia.dart';
import 'package:classemorta/models/PeriodoFestivo.dart';
import 'package:classemorta/models/ProvaCurriculum.dart';
import 'package:classemorta/models/Voto.dart';
import 'package:classemorta/pages/AchievmentPage.dart';
import 'package:classemorta/pages/GiorniPagina.dart';
import 'package:classemorta/pages/GiustifichePagina.dart';
import 'package:classemorta/pages/ImpostazioniPage.dart';
import 'package:classemorta/pages/PctoPage.dart';
import 'package:classemorta/pages/VacanzePage.dart';
import 'package:classemorta/pages/detail/Agenda.dart';
import 'package:classemorta/pages/AssenzePage.dart';
import 'package:classemorta/pages/detail/DettagliMateria.dart';
import 'package:classemorta/pages/Materie.dart';
import 'package:classemorta/pages/NotePagina.dart';
import 'package:classemorta/pages/Notizie.dart';
import 'package:classemorta/pages/PagellePagina.dart';
import 'package:classemorta/service/NotificheService.dart';
import 'package:classemorta/service/SharedPreferencesService.dart';
import 'package:classemorta/widgets/GestioneAccesso.dart';
import 'package:classemorta/widgets/SingoloVotoWid.dart';
import 'package:classemorta/widgets/VotoDisplay.dart';
import 'package:flutter/material.dart';

import '../models/Assenza.dart';
import '../models/FileDidattica.dart';
import '../models/Giorno.dart';
import '../models/Lezione.dart';
import '../models/Nota.dart';
import '../models/Notizia.dart';
import '../models/Pagella.dart';
import '../models/SchoolEvent.dart';
import '../models/Streak.dart';
import '../models/StudentCard.dart';
import '../service/ApiService.dart';
import '../widgets/Lezionewidget.dart';
import 'DidatticaPagina.dart';
import 'detail/DettagliPersona.dart';

class MainPage extends StatefulWidget {
  final Apiservice apiService;
  final String? code;
  const MainPage({super.key, required this.apiService, this.code});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Apiservice _service;
  late Future<List<Voto>?> _medieGeneraliFuture;
  late Future<List<Voto>?> _lastVotiFutureMedie;
  late Future<List<Voto>?> _lastVotiFuture;
  late Future<List<Voto>?> _voti;
  late Future<List<List<Notizia>?>> _notizie;
  late Future<List<List<Nota>>> _note;
  late Future<List<Pagella>?> _pagelle;
  late Future<List<List<Assenza>>> _assenze;
  late Future<List<Lezione>> _lessonsToday;
  late Future<List<Didattica>> _didattica;
  late Future<List<Giorno>> _giorni;
  late Future<PctoData> _datiCurriculum;
  late Future<List<SchoolEvent>> _events;
  late Future<List<PeriodoFestivo>> _vacanze;
  late Future<List<Achievment>> _achievments;
  late Future<StudentCard?> _card;


  @override
  void initState() {
    super.initState();
    _service = widget.apiService;
    _medieGeneraliFuture = _service.getMedieGenerali() ; // Caricamento iniziale
    _lastVotiFutureMedie = _service.getLastVoti(200);
    _voti = _service.getAllVoti();
    _lastVotiFuture = _service.getLastVoti(200);
    _notizie = _service.getNotizie();
    _pagelle = _service.getPagelle() as Future<List<Pagella>?>;
    _assenze = _service.getAssenze();
    _note = _service.getNote();
    _lessonsToday = _service.getLezioni();
    _didattica = _service.fetchDidattica();
    _giorni = _service.getOrari();
    _datiCurriculum = _service.getCurriculum();
    _events = _service.getEvents();
    _vacanze = _service.getPeriodiFestivi();
    _achievments = _service.processAchievments();
    _card = _service.getCard();

  }

  Future<void> _handleRefresh() async {
    setState(() {
      _medieGeneraliFuture = (_service.getMedieGenerali());
      _lastVotiFutureMedie = (_service.getLastVoti(200));
      _voti = _service.getAllVoti();
      _lastVotiFuture = _service.getLastVoti(200);
      _notizie = _service.getNotizie();
      _note = _service.getNote();
      _assenze = _service.getAssenze();
      _lessonsToday = _service.getLezioni();
      _pagelle = _service.getPagelle() as Future<List<Pagella>?>;
      _didattica = _service.fetchDidattica();
      _giorni = _service.getOrari();
      _datiCurriculum = _service.getCurriculum();
      _events = _service.getEvents();
      _vacanze = _service.getPeriodiFestivi();
      _achievments = _service.processAchievments();
      _card = _service.getCard();
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
    await _didattica;
    await _giorni;
    await _datiCurriculum;
    await _events;
    await _vacanze;
    await _achievments;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Pagina principale'),
            SizedBox(width: screenSize.width * 0.15,),
            IconButton(onPressed: (){
              Navigator.push(
                context,
                CustomPageRoute(builder: (context) => Impostazionipage(service: _service,)));
            }, icon: Icon(Icons.settings))
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh, // Usa la nuova funzione di refresh
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Per consentire sempre il pull-to-refresh
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //CARTA STUDENTE
                if(_service.precedente)
                  Text("ANNO PRECEDENTE : ${_service.getYear()}", style: TextStyle(color: Colors.red[800]),),
                FutureBuilder(future: _card, builder: (context, snapshot) {
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
                            fontSize: 14,
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
                              CustomPageRoute(builder: (context) => StudentDetail(card: card)),
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
                const SizedBox(height: 10),
                FutureBuilder(future: _achievments, builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  else if (snapshot.hasError) {
                    return Center(child: Text("Errore ${snapshot.error}"));
                  }
                  else if (snapshot.hasData && snapshot.data != null) {
                    List<Achievment> achievments = snapshot.data!;
                    int negativi = 0;
                    int positivi = 0;
                    int positiviNum = 0;
                    int negativiNum = 0;
                    for(Achievment x in achievments){
                      if(x.positivo){
                        positiviNum ++;
                      }else{
                        negativiNum ++;
                      }
                      if(x.reached){
                        if(x.positivo) {
                          positivi ++;
                        }else{
                          negativi ++;
                        }
                      }
                    }
                    return ElevatedButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey[900])),
                        onPressed: () {
                          Navigator.push(
                            context,
                            CustomPageRoute(builder: (context) => Achievmentpage(achievments: achievments)), // Sostituisci con la tua pagina
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.white, size: 23),
                            const SizedBox(width: 20,),
                            Text("Trofei", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10,),
                            Text("Pos: $positivi/$positiviNum - ", style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Neg $negativi/$negativiNum", style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold))
                          ],
                        )
                    );

                  }
                  else {
                    return const Center(child: Text("Nessun risultato"));
                  }
                }),
                const SizedBox(height: 10),
                const Text("Media totale",
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                //MEDIE
                FutureBuilder<List<Voto>?>(
                  future: _medieGeneraliFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Anno non iniziato'),
                      );
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final List<Voto> loadedMedie = snapshot.data!;
                      return SizedBox(
                        width: screenSize.width * 0.90,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(250, 250, 250, 0.2),
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
                                  // Assicurati che loadedMedie abbia abbastanza elementi
                                  if (!loadedMedie[0].voto.isNaN) VotoSingolo(voto: loadedMedie[0], grandezza: 115, fontSize: 17, ms: _service.impostazioni.msAnimazioneVoto,),
                                  SizedBox(width: 8),
                                  if (!loadedMedie[1].voto.isNaN) VotoSingolo(voto: loadedMedie[1], grandezza: 100, fontSize: 17, ms: _service.impostazioni.msAnimazioneVoto),
                                  SizedBox(width: 8),
                                  if (!loadedMedie[2].voto.isNaN) VotoSingolo(voto: loadedMedie[2], grandezza: 100, fontSize: 17, ms: _service.impostazioni.msAnimazioneVoto),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Sostituisci il vecchio FutureBuilder con questo
                              FutureBuilder<List<Voto>?>(
                                future: _lastVotiFutureMedie,
                                builder: (context, snapshotVoti) {
                                  // STATO DI CARICAMENTO
                                  if (snapshotVoti.connectionState == ConnectionState.waiting) {
                                    return const SizedBox(
                                      height: 48, // Mantieni l'altezza della riga dei bottoni
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }

                                  // STATO DI ERRORE
                                  if (snapshotVoti.hasError) {
                                    return const SizedBox(
                                      height: 48,
                                      child: Center(child: Text("Errore nel caricare i voti")),
                                    );
                                  }

                                  // STATO CON DATI VALIDI
                                  if (snapshotVoti.hasData && snapshotVoti.data!.isNotEmpty) {
                                    final voti = snapshotVoti.data!;

                                    // La logica per le notifiche rimane separata e sicura
                                    WidgetsBinding.instance.addPostFrameCallback((_) {

                                      if(!_service.precedente) {
                                        notificheVoti(voti);
                                      }
                                    });



                                    // Ripristino la tua Row originale con la spaziatura corretta
                                    return Row(
                                      children: [
                                        const SizedBox(width: 36,), // Tua spaziatura originale
                                        IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  CustomPageRoute(
                                                      builder: (context) =>
                                                          Dettaglimateria(materia: Materia(
                                                              codiceMateria: "Anno intero",
                                                              nomeInteroMateria: "Anno",
                                                              nomeProf: "Sistema",
                                                              voti: voti
                                                          ),
                                                            periodo: 3,
                                                            dotted: false,
                                                            msAnimazione: _service.impostazioni.msAnimazioneVoto,
                                                          )
                                                  ));
                                            },
                                            icon: const Icon(Icons.auto_graph_sharp,
                                              color: Colors.white,)),
                                        const SizedBox(width: 68,), // Tua spaziatura originale
                                        IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  CustomPageRoute(
                                                      builder: (context) =>
                                                          Dettaglimateria(materia: Materia(
                                                              codiceMateria: "1° quadrimestre",
                                                              nomeInteroMateria: "1° quadrimestre",
                                                              nomeProf: "Sistema",
                                                              voti: voti
                                                          ),
                                                            periodo: 1,
                                                            dotted: false,
                                                            msAnimazione: _service.impostazioni.msAnimazioneVoto,
                                                          )
                                                  ));
                                            },
                                            icon: const Icon(Icons.auto_graph_sharp,
                                              color: Colors.white,)),
                                        const SizedBox(width: 60,), // Tua spaziatura originale
                                        if (!loadedMedie[2].voto.isNaN)
                                          IconButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    CustomPageRoute(
                                                        builder: (context) =>
                                                            Dettaglimateria(materia: Materia(
                                                                codiceMateria: "2° quadrimestre",
                                                                nomeInteroMateria: "2° quadrimestre",
                                                                nomeProf: "Sistema",
                                                                voti: voti
                                                            ),
                                                              periodo: 2,
                                                              dotted: false,
                                                              msAnimazione: _service.impostazioni.msAnimazioneVoto,
                                                            )
                                                    ));
                                              },
                                              icon: const Icon(Icons.auto_graph_sharp,
                                                color: Colors.white,)),
                                      ],
                                    );
                                  }
                                  // STATO SENZA DATI
                                  else {
                                    return const SizedBox(
                                      height: 48,
                                      child: Center(child: Text("Nessun voto da mostrare")),
                                    );
                                  }
                                },
                              ),


                            ],

                          ),
                        ),
                      );
                    } else {
                      return const Center(child: Text("Nessun risultato, controlla la connessione"));
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
                      child: Text('Anno non iniziato'),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final List<Voto> loadedVoti = snapshot.data!;
                    Streak streak = Streak().getStreak(loadedVoti.reversed.toList());
                    return Column(
                      children: [
                         Row(
                          children: [
                            const SizedBox(width: 1),
                            const Text("Tutti i voti", style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 15),
                            const Text("-   Streak: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Icon(
                              streak.isGoated(loadedVoti) ? Icons.star: streak.votiBuoni >= 10 ? Icons.local_fire_department: Icons.local_fire_department_outlined,
                              color: streak.isGoated(loadedVoti)? Colors.yellow : streak.getStreakColor(),
                              size: 40,
                            ),
                            Text(
                              " ${streak.isGoated(loadedVoti) ? "GOAT" : streak.votiBuoni}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: streak.isGoated(loadedVoti)? Colors.yellow : streak.getStreakColor(),

                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                        height: 176,
                        child: Container(
                          width: screenSize.width * 0.90,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(240, 240, 240, 0.2),
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
                                Voto votoCorrente = loadedVoti[index];
                                Voto? precedenteCronologico;

                                // Cerca negli elementi SUCCESSIVI della lista (che sono cronologicamente PRECEDENTI)
                                for (int j = index + 1; j < loadedVoti.length; j++) {
                                  if (loadedVoti[j].codiceMateria == votoCorrente.codiceMateria) {
                                    precedenteCronologico = loadedVoti[j]; // Trovato il primo voto cronologicamente precedente della stessa materia
                                    break;
                                  }
                                }

                                return Votodisplay(
                                  voto: votoCorrente, // Il voto più recente (es. MAT 7.5)
                                  precedente: precedenteCronologico, // Il voto di MAT che è venuto prima del 7.5
                                  grandezza: 88,
                                  ms: _service.impostazioni.msAnimazioneVoto,
                                );
                              }
                          ),
                        )
                      ),
                      ],
                    );
                  }else{
                    return Center(child: SizedBox(width: screenSize.width * 0.43, child: Text("        Nessun voto"),));
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
                            child: SizedBox(width: 175, child: Text("        Errore    "),),
                          );
                        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          final List<Voto> loadedVoti = snapshot.data!;
                          return passaggio(context, "  Materie            ", "Materie", MateriePag(service: _service, voti: loadedVoti,), Icon(Icons.medical_information_rounded, size: 25,));

                        }else{
                          return Center(child: SizedBox(width: screenSize.width * 0.43, child: Text("        Nessun voto"),));
                        }
                    }),
                    SizedBox(width: 10),
                    passaggio(context, "  Compiti          ", "Agenda", Agenda(apiService: _service), Icon(Icons.edit_calendar_outlined, size: 25,)),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    FutureBuilder(future: _notizie, builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Anno non iniziato'),
                        );
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final List<List<Notizia>?> loadedNotizie = snapshot.data!;
                        WidgetsBinding.instance.addPostFrameCallback((_) {

                          if(!_service.precedente && loadedNotizie[1] != null) {
                            notificheAssenzeProf(loadedNotizie[1]!);
                          }
                        });
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
                            Icon(Icons.calendar_month, size: 25,)
                        );

                      }else{
                        return Center(child: SizedBox(width: screenSize.width * 0.43, child: Text("        Nessuna notizia"),));
                      }
                    }),
                    SizedBox(width: 10),
                    FutureBuilder(future: _note, builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Anno non iniziato'),
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
                            Icon(Icons.edit_note_outlined, size: 25,)
                        );

                      }else{
                        return Center(child: SizedBox(width: screenSize.width * 0.43, child: Text("        Nessuna nota"),));
                      }
                    }),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [

                    FutureBuilder(future: _pagelle, builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Anno non iniziato'),
                        );
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final List<Pagella> pag = snapshot.data!;
                        return passaggio(
                            context,
                            "  Pagelle            ",
                            "Pagelle",
                            Pagellepagina(pagelle: pag),
                            Icon(Icons.mark_email_read, size: 25,)
                        );

                      }else{
                        return Center(child: SizedBox(width: screenSize.width * 0.43, child: const Text("      Nessuna pagella"),));
                      }
                    }),
                    SizedBox(width: 10,),
                    FutureBuilder(future: _didattica, builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('    Anno non iniziato'),
                        );
                        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final List<Didattica> didattica = snapshot.data!;
                        return passaggio(
                            context,
                            "  Didattica        ",
                            "Didattica",
                            Didatticapagina(didattica: didattica, service: _service),
                            Icon(Icons.sticky_note_2_outlined, size: 25,)
                        );

                      }else{
                        return Center(child: SizedBox(width: screenSize.width * 0.43, child: Text("Nessun file"),));
                      }

                    }
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    FutureBuilder(future: _giorni, builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Orari mancanti'),
                        );
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final List<Giorno> loadedGiorni = snapshot.data!;
                        return passaggio(
                            context,
                            "  Orari                 ",
                            "orari settimanali",
                            Giornipagina(
                              giorni: loadedGiorni,
                            ),
                            Icon(Icons.watch_later, size: 25,)
                        );

                      }else{
                        return Center(child: SizedBox(width: screenSize.width * 0.43, child: Text("        Nessun orario"),));
                      }
                    }),
                    const SizedBox(width: 10),
                    FutureBuilder(future: _datiCurriculum, builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('         Errore'),
                        );
                      } else if (snapshot.hasData) {
                        final PctoData pcto = snapshot.data!;
                        return passaggio(
                            context,
                            "  Curriculum    ",
                            "Curriculum / ore PCTO",
                            Pctopage(
                              pctoDataa: pcto,
                            ),
                            Icon(Icons.book, size: 25,)
                        );

                      }else{
                        return Center(child: SizedBox(width: screenSize.width * 0.43, child: Text("        Nessun curriculum"),));
                      }
                    }),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    if(widget.code?[0] == 'G')...[
                    FutureBuilder(future: _events, builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('         Errore'),
                        );
                      } else if (snapshot.hasData) {
                        final List<SchoolEvent> events = snapshot.data!;
                        return passaggio(
                            context,
                            "  Giustifiche       ",
                            "Giustifica un evento",
                            Giustifichepagina(events: events, service: _service,),
                            Icon(Icons.add, size: 25,)
                        );

                      }else{
                        return Center(child: SizedBox(width: screenSize.width * 0.43, child: Text("        Nessun evento"),));
                      }
                    }),
                      const SizedBox(width: 10),
                    ],
                    FutureBuilder(future: _vacanze, builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(' Errore'),
                        );
                      } else if (snapshot.hasData) {
                        final List<PeriodoFestivo> vacanze = snapshot.data!;
                        return passaggio(
                            context,
                            "  Vacanze        ",
                            "Periodi di vacanza",
                            Vacanzepage(periodi: vacanze),
                            Icon(Icons.games_outlined, size: 25,)
                        );
                      }else{
                        return Center(child: SizedBox(width: screenSize.width * 0.43, child: Text("        Nessuna vacanza"),));
                      }
                    }),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),

                const Divider(thickness: 1, color: Colors.white,),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Lezioni  Oggi | ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}",
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
                                child: Text('Anno non iniziato'),
                              );
                            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              final List<Lezione> lezioni = snapshot.data!;
                              return ListView.builder(
                                itemCount: lezioni.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Lezione lezione = lezioni[index];
                                  return Column(
                                    children: [
                                      SizedBox(
                                        width: 330,
                                        child: Lezionewidget(lezione: lezione),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  );
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

                const Divider(thickness: 1, color: Colors.white,),
                FutureBuilder(future: _assenze, builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Anno non iniziato'),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final List<List<Assenza>> ass = snapshot.data!;
                    return SizedBox(
                      width: screenSize.width * 0.9,
                      child:  Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(240, 240, 240, 0.2),
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
                                  width: screenSize.width * 0.43,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(255, 0, 0, 0.6),
                                    borderRadius: BorderRadius.all(Radius.circular(25)),
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
                                    " Assenze ${ass[0].length}   ",
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
                                  width: screenSize.width * 0.43,
                                  padding: EdgeInsets.all(10),
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(255, 255, 0, 0.6),
                                    borderRadius: BorderRadius.all(Radius.circular(25)),
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
                                    width:  screenSize.width * 0.43,
                                    height: 10,
                                    child: Text(
                                      "   Uscite ${ass[1].length}   ",
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
                                  width:  screenSize.width * 0.43,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 255, 0.6),
                                    borderRadius: BorderRadius.all(Radius.circular(25)),
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
                                    "    Ritardi ${ass[2].length}   ",
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
                                    width:  screenSize.width * 0.43,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(0, 0, 0, 0.6),
                                      borderRadius: BorderRadius.all(Radius.circular(25)),
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
                                            fontSize: 19,
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
                                              CustomPageRoute(builder: (context) => Assenzepage(assenze:ass)), // Sostituisci con la tua pagina
                                            );
                                          },
                                          icon: Icon(Icons.info_outline, size: 25,),
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
                      )
                    );

                  }else{
                    return const Center(child: Text("Nessuna assenza/ritardo/usccita"));
                  }
                }),
                SizedBox(height: 30,),
                anno(true),
                SizedBox(height: 10,),
                anno(false),
                SizedBox(height: 200,),

              ],
            ),
          ),
        ),
      ),
    );

  }

  Widget anno(bool precedente){
    return Container(
        padding: EdgeInsets.all(10),
        height: 60,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.grey[900],
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
            IconButton(
              onPressed: (){
                Navigator.pushReplacement(
                  context,
                  CustomPageRoute(builder: (context) => AuthWrapper(precedente: precedente)), // Sostituisci con la tua pagina
                );
              },
              icon: Icon(precedente? Icons.arrow_back_ios: Icons.arrow_forward_ios, color: Colors.white),
            ),
            Text(
              precedente? "Anno precedente": "Anno attuale",
              style: TextStyle(
                fontSize: 14,
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
            )
          ],
        )
    );
  }

  Widget passaggio(BuildContext context, String mess, String tooltip, Widget pagina,  Icon icon){
    final screenSize = MediaQuery.of(context).size;
    return SizedBox(
      height: 43,
      width: screenSize.width * 0.43,
      child: Tooltip(
        message: tooltip,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          onPressed: () {
            Navigator.push(
              context,
              CustomPageRoute(builder: (context) => pagina),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mess,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> notificheAssenzeProf(List<Notizia> notizie) async {
    // Controlla se il widget è ancora "attivo" prima di procedere
    if (!mounted) return;

    // 1. Carica in modo sicuro il conteggio precedente dei voti dalle SharedPreferences
    final String? conteggioSalvato = await SharedPreferencesService.load("NumeroAssenze");

    // 2. Converti in modo sicuro il valore caricato in un numero. Se non esiste, usa 0.
    final int vecchiVoti = int.tryParse(conteggioSalvato ?? '0') ?? 0;
    final int votiAttuali = notizie.length;

    // 3. Confronta e determina se ci sono effettivamente nuovi voti
    if (votiAttuali > vecchiVoti) {
      final int numeroNuoviVoti = votiAttuali - vecchiVoti;

      // 4. Prendi solo la lista dei nuovi voti
      // Il metodo skip() salta i primi `vecchiVoti` elementi, che già conoscevamo
      final nuoviVoti = notizie.skip(vecchiVoti).toList();

      // 5. Invia una notifica PER OGNI nuovo voto
      for (int i = 0; i < nuoviVoti.length; i++) {
        final Notizia not = nuoviVoti[i];


      await NotificheService().showNotification(not.title, i + 100, "Variazione di orario");
      }

      // 6. Salva il nuovo conteggio totale SOLO DOPO che la logica è completata
      final sh = SharedPreferencesService(
        name: "NumeroAssenze",
        value: votiAttuali.toString(),
      );
      await sh.save();
    }
  }

  // Aggiungi questa funzione DENTRO la classe _MainPageState, ma FUORI dal metodo build.
  Future<void> notificheVoti(List<Voto> votiRecenti) async {
    // Controlla se il widget è ancora "attivo" prima di procedere
    if (!mounted) return;

    // 1. Carica in modo sicuro il conteggio precedente dei voti dalle SharedPreferences
    final String? conteggioSalvato = await SharedPreferencesService.load("NumeroVoti");

    // 2. Converti in modo sicuro il valore caricato in un numero. Se non esiste, usa 0.
    final int vecchiVoti = int.tryParse(conteggioSalvato ?? '0') ?? 0;
    final int votiAttuali = votiRecenti.length;

    // 3. Confronta e determina se ci sono effettivamente nuovi voti
    if (votiAttuali > vecchiVoti) {
      final int numeroNuoviVoti = votiAttuali - vecchiVoti;
      print("INFO: Trovati $numeroNuoviVoti nuovi voti.");

      // 4. Prendi solo la lista dei nuovi voti
      // Il metodo skip() salta i primi `vecchiVoti` elementi, che già conoscevamo
      final nuoviVoti = votiRecenti.skip(vecchiVoti).toList();

      // 5. Invia una notifica PER OGNI nuovo voto
      for (int i = 0; i < nuoviVoti.length; i++) {
        final Voto nuovoVoto = nuoviVoti[i];


        await NotificheService().showNotification("   ${nuovoVoto.codiceMateria}   ${nuovoVoto.displayValue}     | desc: ${nuovoVoto.descrizione} | prof: ${nuovoVoto.nomeProf}", i + 1, "Nuovo voto");
      }

      // 6. Salva il nuovo conteggio totale SOLO DOPO che la logica è completata
      final sh = SharedPreferencesService(
        name: "NumeroVoti",
        value: votiAttuali.toString(),
      );
      await sh.save();
    } else {
      print("INFO: Nessun nuovo voto trovato.");
    }
  }


}

