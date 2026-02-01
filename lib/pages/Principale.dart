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
import 'package:classemorta/pages/detail/DettagliStreak.dart';
import 'package:classemorta/pages/detail/DettagliTuttiIVoti.dart';
import 'package:classemorta/service/NotificheService.dart';
import 'package:classemorta/service/SharedPreferencesService.dart';
import 'package:classemorta/widgets/GestioneAccesso.dart';
import 'package:classemorta/widgets/SingoloVotoWid.dart';
import 'package:classemorta/widgets/VotoDisplay.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late Future<List<List<Giorno>>> _giorni;
  late Future<PctoData> _datiCurriculum;
  late Future<List<SchoolEvent>> _events;
  late Future<List<PeriodoFestivo>> _vacanze;
  late Future<List<Achievment>> _achievments;
  late Future<StudentCard?> _card;

  @override
  void initState() {
    super.initState();
    _service = widget.apiService;
    _initFutures();
  }

  void _initFutures() {
    _medieGeneraliFuture = _service.getMedieGenerali();
    _lastVotiFutureMedie = _service.getLastVoti(200);
    _voti = _service.getAllVoti(false);
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
      _initFutures();
    });
    await Future.wait([
      _medieGeneraliFuture,
      _lastVotiFutureMedie,
      _voti,
      _lastVotiFuture,
      _notizie,
      _note,
      _pagelle,
      _lessonsToday,
      _assenze,
      _didattica,
      _giorni,
      _datiCurriculum,
      _events,
      _vacanze,
      _achievments,
    ]);
  }

  Future<void> _launchExternalSite() async {    showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // Recupera il PHPSESSID fresco
    String sid = await _service.ottieniPhpsessid();
    if (mounted) Navigator.pop(context);

    final String identity = _service.codiceStudent;
    final Uri url = Uri.parse('https://web.spaggiari.eu/home/app/default/menu.php');

    // Tentativo con configurazione avanzata
    bool launched = await launchUrl(
      url,
      mode: LaunchMode.inAppBrowserView, // Più moderno di inAppWebView
      webViewConfiguration: WebViewConfiguration(
        enableJavaScript: true,
        enableDomStorage: true,
        headers: {
          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
          'Cookie': 'PHPSESSID=$sid; webrole=gen; webidentity=$identity',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Upgrade-Insecure-Requests': '1',
        },
      ),
    );

    if (!launched && mounted) {
      throw 'Impossibile lanciare l\'URL';
    }
  } catch (e) {
    if (mounted) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore apertura: $e')),
      );
    }
  }
  }

  Widget _buildRegistroWebButton(Size screenSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        width: screenSize.width * 0.9,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[800],
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
          ),
          onPressed: _launchExternalSite,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.public, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Apri Registro Web",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Pagina principale'),
            SizedBox(width: screenSize.width * 0.15),
            IconButton(
              onPressed: () => Navigator.push(
                context,
                CustomPageRoute(builder: (context) => Impostazionipage(service: _service)),
              ),
              icon: const Icon(Icons.settings),
            )
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_service.precedente)
                  Text("ANNO PRECEDENTE : ${_service.getYear()}", style: TextStyle(color: Colors.red[800])),
                _buildStudentCard(),
                const SizedBox(height: 10),
                _buildAchievements(),
                const SizedBox(height: 10),
                const Text("Media totale", style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildMedieSection(screenSize),
                const SizedBox(height: 20),
                _buildVotiSection(screenSize),
                const SizedBox(height: 10),
                const Divider(thickness: 1, color: Colors.white),
                const SizedBox(height: 10),
                _buildGridActions(context),
                const SizedBox(height: 8),
                _buildRegistroWebButton(screenSize),
                const SizedBox(height: 8),
                _buildLezioniSection(),
                const Divider(thickness: 1, color: Colors.white),
                _buildAssenzeSection(screenSize),
                const SizedBox(height: 30),
                anno(true),
                const SizedBox(height: 10),
                anno(false),
                const SizedBox(height: 200),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard() {
    return FutureBuilder(
      future: _card,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return const Center(child: Text("Errore"));
        if (snapshot.hasData && snapshot.data != null) {
          StudentCard card = snapshot.data!;
          return Row(
            children: [
              Text(
                "Buongiorno ${card.usrType == "S" ? "Studente" : card.usrType == "P" ? "Professore" : "Genitore di"} ${card.nome} ${card.cognome}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(offset: const Offset(2.0, 2.0), blurRadius: 3.0, color: Colors.black.withOpacity(0.5))],
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                onPressed: () => Navigator.push(context, CustomPageRoute(builder: (context) => StudentDetail(card: card))),
                icon: const Icon(Icons.info_outline),
                tooltip: 'Dettagli studente',
              )
            ],
          );
        }
        return const Center(child: Text("Nessun risultato"));
      },
    );
  }

  Widget _buildAchievements() {
    return FutureBuilder(
      future: _achievments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Errore ${snapshot.error}"));
        if (snapshot.hasData && snapshot.data != null) {
          List<Achievment> achievments = snapshot.data!;
          int positivi = achievments.where((x) => x.positivo && x.reached).length;
          int negativi = achievments.where((x) => !x.positivo && x.reached).length;
          int positiviNum = achievments.where((x) => x.positivo).length;
          int negativiNum = achievments.where((x) => !x.positivo).length;

          return ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900]),
            onPressed: () => Navigator.push(context, CustomPageRoute(builder: (context) => Achievmentpage(achievments: achievments))),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.white, size: 23),
                const SizedBox(width: 20),
                const Text("Trofei", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Text("Pos: $positivi/$positiviNum - ", style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Neg $negativi/$negativiNum", style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold))
              ],
            ),
          );
        }
        return const Center(child: Text("Nessun risultato"));
      },
    );
  }

  Widget _buildMedieSection(Size screenSize) {
    return FutureBuilder<List<Voto>?>(
      future: _medieGeneraliFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return const Center(child: Text('Anno non iniziato'));
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final List<Voto> loadedMedie = snapshot.data!;
          return Container(
            width: screenSize.width * 0.90,
            decoration: _boxDecoration(),
            child: Column(
              children: [
                const SizedBox(height: 5),
                Row(
                  children: [
                    if (!loadedMedie[0].voto.isNaN) VotoSingolo(voto: loadedMedie[0], grandezza: 115, fontSize: 17, ms: _service.impostazioni.msAnimazioneVoto),
                    const SizedBox(width: 8),
                    if (!loadedMedie[1].voto.isNaN) VotoSingolo(voto: loadedMedie[1], grandezza: 100, fontSize: 17, ms: _service.impostazioni.msAnimazioneVoto),
                    const SizedBox(width: 8),
                    if (!loadedMedie[2].voto.isNaN) VotoSingolo(voto: loadedMedie[2], grandezza: 100, fontSize: 17, ms: _service.impostazioni.msAnimazioneVoto),
                  ],
                ),
                const SizedBox(height: 10),
                _buildMedieGraphs(loadedMedie),
              ],
            ),
          );
        }
        return const Center(child: Text("Nessun risultato"));
      },
    );
  }

  Widget _buildMedieGraphs(List<Voto> loadedMedie) {
    return FutureBuilder<List<Voto>?>(
      future: _lastVotiFutureMedie,
      builder: (context, snapshotVoti) {
        if (snapshotVoti.connectionState == ConnectionState.waiting) return const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()));
        if (snapshotVoti.hasError) return const SizedBox(height: 48, child: Center(child: Text("Errore")));
        if (snapshotVoti.hasData && snapshotVoti.data!.isNotEmpty) {
          final voti = snapshotVoti.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_service.precedente) notificheVoti(voti);
          });
          return Row(
            children: [
              const SizedBox(width: 2),
              if (!loadedMedie[0].voto.isNaN) _graphButton("Anno", 3, voti),
              const SizedBox(width: 5),
              if (!loadedMedie[1].voto.isNaN) _graphButton("1° quad", 1, voti),
              const SizedBox(width: 2),
              if (!loadedMedie[2].voto.isNaN) _graphButton("2° quad", 2, voti),
            ],
          );
        }
        return const SizedBox(height: 48, child: Center(child: Text("Nessun voto")));
      },
    );
  }

  Widget _graphButton(String title, int periodo, List<Voto> voti) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900]),
      onPressed: () => Navigator.push(
        context,
        CustomPageRoute(
          builder: (context) => Dettaglimateria(
            materia: Materia(codiceMateria: title, nomeInteroMateria: title, nomeProf: "Sistema", voti: voti),
            periodo: periodo,
            service: _service,
            dotted: false,
            msAnimazione: _service.impostazioni.msAnimazioneVoto,
          ),
        ),
      ),
      child: const SizedBox(width: 60, child: Icon(Icons.auto_graph_sharp, color: Colors.white, size: 30)),
    );
  }

  Widget _buildVotiSection(Size screenSize) {
    return FutureBuilder(
      future: _lastVotiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return const Center(child: Text('Anno non iniziato'));
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final List<Voto> loadedVoti = snapshot.data!;
          Streak streak = Streak().getStreak(loadedVoti.reversed.toList());
          return Column(
            children: [
              Row(
                children: [
                  _actionButton("Tutti i voti", screenSize.width * 0.43, () => Navigator.push(context, CustomPageRoute(builder: (context) => Dettaglituttiivoti(voti: loadedVoti, service: _service)))),
                  _streakButton(streak, loadedVoti, screenSize.width * 0.45),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 176,
                width: screenSize.width * 0.90,
                decoration: _boxDecoration(),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: loadedVoti.length,
                  itemBuilder: (context, index) {
                    Voto votoCorrente = loadedVoti[index];
                    Voto? precedenteCronologico = loadedVoti.skip(index + 1).firstWhere((v) => v.codiceMateria == votoCorrente.codiceMateria, orElse: () => Voto(voto: double.nan, displayValue: "", descrizione: "", codiceMateria: "", nomeProf: "", nomeInteroMateria: '', dataVoto: '', periodo: 3, tipo: '', cancellato: false));
                    return Votodisplay(
                      voto: votoCorrente,
                      precedente: precedenteCronologico.voto.isNaN ? null : precedenteCronologico,
                      grandezza: 88,
                      ms: _service.impostazioni.msAnimazioneVoto,
                    );
                  },
                ),
              ),
            ],
          );
        }
        return Center(child: SizedBox(width: screenSize.width * 0.43, child: const Text("Nessun voto")));
      },
    );
  }

  Widget _buildGridActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            FutureBuilder(
              future: _voti,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return passaggio(context, "  Materie", "Materie", MateriePag(service: _service, voti: snapshot.data!), const Icon(Icons.medical_information_rounded));
                }
                return passaggio(context, "  Materie", "Materie", Container(), const Icon(Icons.medical_information_rounded));
              },
            ),
            const SizedBox(width: 10),
            passaggio(context, "  Compiti", "Agenda", Agenda(apiService: _service), const Icon(Icons.edit_calendar_outlined)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FutureBuilder(
              future: _notizie,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final loadedNotizie = snapshot.data!;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_service.precedente && loadedNotizie[1] != null) notificheAssenzeProf(loadedNotizie[1]!);
                  });
                  return passaggio(context, "  Notizie", "Notizie", NotiziePage(circolari: loadedNotizie[0], variazioni: loadedNotizie[1], altro: loadedNotizie[3], variazioniDiClasse: loadedNotizie[2], service: _service), const Icon(Icons.calendar_month));
                }
                return passaggio(context, "  Notizie", "Notizie", Container(), const Icon(Icons.calendar_month));
              },
            ),
            const SizedBox(width: 10),
            FutureBuilder(
              future: _note,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return passaggio(context, "  Note", "Note", Notepagina(note: snapshot.data!), const Icon(Icons.edit_note_outlined));
                }
                return passaggio(context, "  Note", "Note", Container(), const Icon(Icons.edit_note_outlined));
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FutureBuilder(
              future: _pagelle,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return passaggio(context, "  Pagelle", "Pagelle", Pagellepagina(pagelle: snapshot.data!), const Icon(Icons.mark_email_read));
                }
                return passaggio(context, "  Pagelle", "Pagelle", Container(), const Icon(Icons.mark_email_read));
              },
            ),
            const SizedBox(width: 10),
            FutureBuilder(
              future: _didattica,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return passaggio(context, "  Didattica", "Didattica", Didatticapagina(didattica: snapshot.data!, service: _service), const Icon(Icons.sticky_note_2_outlined));
                }
                return passaggio(context, "  Didattica", "Didattica", Container(), const Icon(Icons.sticky_note_2_outlined));
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FutureBuilder(
              future: _giorni,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return passaggio(context, "  Orari", "Orari", Giornipagina(giorniLista: snapshot.data!), const Icon(Icons.watch_later));
                }
                return passaggio(context, "  Orari", "Orari", Container(), const Icon(Icons.watch_later));
              },
            ),
            const SizedBox(width: 10),
            FutureBuilder(
              future: _datiCurriculum,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return passaggio(context, "  Curriculum", "Curriculum", Pctopage(pctoDataa: snapshot.data!), const Icon(Icons.book));
                }
                return passaggio(context, "  Curriculum", "Curriculum", Container(), const Icon(Icons.book));
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (widget.code?[0] == 'G') ...[
              FutureBuilder(
                future: _events,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return passaggio(context, "  Giustifiche", "Giustifiche", Giustifichepagina(events: snapshot.data!, service: _service), const Icon(Icons.add));
                  }
                  return passaggio(context, "  Giustifiche", "Giustifiche", Container(), const Icon(Icons.add));
                },
              ),
              const SizedBox(width: 10),
            ],
            FutureBuilder(
              future: _vacanze,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return passaggio(context, "  Vacanze", "Vacanze", Vacanzepage(periodi: snapshot.data!), const Icon(Icons.games_outlined));
                }
                return passaggio(context, "  Vacanze", "Vacanze", Container(), const Icon(Icons.games_outlined));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLezioniSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Lezioni Oggi | ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}", style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 400,
          child: FutureBuilder<List<Lezione>>(
            future: _lessonsToday,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return const Center(child: Text('Anno non iniziato'));
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Lezionewidget(lezione: snapshot.data![index])),
                );
              }
              return const Center(child: Text("Nessuna lezione per oggi"));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAssenzeSection(Size screenSize) {
    return FutureBuilder(
      future: _assenze,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return const Center(child: Text('Anno non iniziato'));
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final ass = snapshot.data!;
          return Container(
            width: screenSize.width * 0.9,
            decoration: _boxDecoration(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _assenzaBox("Assenze", ass[0].length, const Color.fromRGBO(255, 0, 0, 0.6), screenSize.width * 0.43),
                    _assenzaBox("Uscite", ass[1].length, const Color.fromRGBO(255, 255, 0, 0.6), screenSize.width * 0.43),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _assenzaBox("Ritardi", ass[2].length, const Color.fromRGBO(0, 0, 255, 0.6), screenSize.width * 0.43),
                    Container(
                      width: screenSize.width * 0.43,
                      height: 75,
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(25)),
                      child: InkWell(
                        onTap: () => Navigator.push(context, CustomPageRoute(builder: (context) => Assenzepage(assenze: ass))),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Dettagli", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), Icon(Icons.info_outline)]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const Center(child: Text("Nessuna assenza"));
      },
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(25),
      boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.1), spreadRadius: 1, blurRadius: 1, offset: const Offset(2, 2))],
    );
  }

  Widget _actionButton(String text, double width, VoidCallback onPressed) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900]),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _streakButton(Streak streak, List<Voto> loadedVoti, double width) {
    bool goated = streak.isGoated(loadedVoti);
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900]),
        onPressed: () => Navigator.push(context, CustomPageRoute(builder: (context) => DettagliStreakPag(voti: loadedVoti))),
        child: Row(
          children: [
            const Text("Streak: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Icon(goated ? Icons.star : Icons.local_fire_department, color: goated ? Colors.yellow : streak.getStreakColor(), size: 30),
            Text(" ${goated ? "GOAT" : streak.votiBuoni}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: goated ? 13 : 20, color: goated ? Colors.yellow : streak.getStreakColor())),
          ],
        ),
      ),
    );
  }

  Widget _assenzaBox(String label, int count, Color color, double width) {
    return Container(
      width: width,
      height: 70,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(25)),
      alignment: Alignment.center,
      child: Text("$label $count", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget anno(bool precedente) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 60,
      width: 200,
      decoration: _boxDecoration().copyWith(borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pushReplacement(context, CustomPageRoute(builder: (context) => AuthWrapper(precedente: precedente))),
            icon: Icon(precedente ? Icons.arrow_back_ios : Icons.arrow_forward_ios, color: Colors.white),
          ),
          Text(precedente ? "Anno precedente" : "Anno attuale", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget passaggio(BuildContext context, String mess, String tooltip, Widget pagina, Icon icon) {
    final screenSize = MediaQuery.of(context).size;
    return SizedBox(
      height: 43,
      width: screenSize.width * 0.43,
      child: Tooltip(
        message: tooltip,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)), padding: const EdgeInsets.symmetric(horizontal: 8)),
          onPressed: () => Navigator.push(context, CustomPageRoute(builder: (context) => pagina)),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Expanded(child: Text(mess, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> notificheAssenzeProf(List<Notizia> notizie) async {
    if (!mounted) return;
    final String? conteggioSalvato = await SharedPreferencesService.load("NumeroAssenze");
    final int vecchiVoti = int.tryParse(conteggioSalvato ?? '0') ?? 0;
    final int votiAttuali = notizie.length;

    if (votiAttuali > vecchiVoti) {
      final nuoviVoti = notizie.skip(vecchiVoti).toList();
      for (int i = 0; i < nuoviVoti.length; i++) {
        await NotificheService().showNotification(nuoviVoti[i].title, i + 100, "Variazione di orario");
      }
      await SharedPreferencesService(name: "NumeroAssenze", value: votiAttuali.toString()).save();
    }
  }

  Future<void> notificheVoti(List<Voto> votiRecenti) async {
    if (!mounted) return;
    final String? conteggioSalvato = await SharedPreferencesService.load("NumeroVoti");
    final int vecchiVoti = int.tryParse(conteggioSalvato ?? '0') ?? 0;
    final int votiAttuali = votiRecenti.length;

    if (votiAttuali > vecchiVoti) {
      final nuoviVoti = votiRecenti.reversed.toList().skip(vecchiVoti).toList();
      int i = 0;
      for (Voto nuovoVoto in nuoviVoti) {
        await NotificheService().showNotification("${nuovoVoto.codiceMateria} ${nuovoVoto.displayValue} | desc: ${nuovoVoto.descrizione}", i + 1, "Nuovo voto");
        i++;
      }
      await SharedPreferencesService(name: "NumeroVoti", value: votiAttuali.toString()).save();
    }
  }
}
