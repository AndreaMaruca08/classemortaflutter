import 'package:classemorta/models/Streak.dart';
import 'package:classemorta/models/Voto.dart';
import 'package:classemorta/widgets/SingoloVotoWid.dart';
import 'package:classemorta/widgets/torta.dart';
import 'package:flutter/material.dart';
import '../../models/Materia.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../widgets/MedieIpotetiche.dart';

class Dettaglimateria extends StatefulWidget {
  final Materia materia;
  final int periodo;
  final bool dotted;
  const Dettaglimateria({super.key, required this.materia, required this.periodo, required this.dotted});

  @override
  State<Dettaglimateria> createState() => _DettaglimateriaState();
}

class _DettaglimateriaState extends State<Dettaglimateria> {
  // Variabili di stato della UI
  late int periodo = widget.periodo;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Materia materia = widget.materia;
  late bool dotted = widget.dotted;

  // Variabili di stato per i dati dei grafici (per l'animazione)
  List<FlSpot> chartSpots = [];
  List<BarChartGroupData> chartBarGroups = [];
  bool _isDataReady = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = _pageController.page?.round() ?? 0;
        });
      }
    });

    // Avvia la preparazione dei dati in modo asincrono per attivare l'animazione
    _prepareChartData();
  }

  void _prepareChartData() async {
    // Step 1: mostra grafico vuoto
    setState(() {
      _isDataReady = false;
      chartSpots = [];
      chartBarGroups = [];
    });

    await Future.delayed(const Duration(milliseconds: 200));

    // Step 2: calcolo dei dati
    List<Voto> voti = widget.materia.voti.where((voto) => voto.periodo == periodo).toList();
    if (periodo == 3) voti = widget.materia.voti;
    voti.sort((a, b) => a.dataVoto.compareTo(b.dataVoto));

    final localSpots = <FlSpot>[];
    for (int i = 0; i < voti.length; i++) {
      localSpots.add(FlSpot(i.toDouble(), voti[i].voto));
    }

    final localBarGroups = <BarChartGroupData>[];
    final Map<double, int> frequenzaVoti = {};
    final votiValidi = voti.where((v) => !v.cancellato).toList();
    for (var voto in votiValidi) {
      frequenzaVoti[voto.voto] = (frequenzaVoti[voto.voto] ?? 0) + 1;
    }
    for (double i = 0.0; i <= 10.0; i += 0.5) {
      localBarGroups.add(
        BarChartGroupData(
          x: (i * 10).toInt(),
          barRods: [
            BarChartRodData(
              toY: (frequenzaVoti[i] ?? 0).toDouble(),
              color: getColor(i),
              width: 8,
            ),
          ],
        ),
      );
    }

    // Step 3: imposta i dati veri e lascia fl_chart animare
    if (mounted) {
      setState(() {
        chartSpots = localSpots;
        chartBarGroups = localBarGroups;
        _isDataReady = true;
      });
    }
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Il metodo build ora è molto più pulito
  @override
  Widget build(BuildContext context) {
    // I calcoli necessari per l'intera UI rimangono qui
    List<Voto> voti = materia.voti.where((voto) => voto.periodo == periodo).toList();
    if (periodo == 3) {
      voti = materia.voti;
    }
    voti.sort((a, b) => a.dataVoto.compareTo(b.dataVoto));
    List<Voto> votiDisplay = voti.reversed.toList();
    double media = getMedia(voti);
    List<Color> colori = getColors(voti);
    Streak streak = Streak().getStreak(voti);
    var ratio = Materia.ratio(voti);
    final votiValidi = voti.where((v) => !v.cancellato).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dettagli materia ${materia.codiceMateria}'),
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Text(
              _currentPage == 0
                  ? (widget.periodo == 3 ? "Grafico andamento anno" : "Grafico andamento ${voti.isNotEmpty ? voti[0].periodo : ''}° quadrimestre")
                  : "Distribuzione dei Voti",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 10),
            // Sostituisci il tuo SizedBox(height: 330, child: PageView(...)) con questo
            SizedBox(
              height: 330,
              child: PageView(
                controller: _pageController,
                allowImplicitScrolling: false, // Per versioni più recenti
                physics: _isDataReady ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(), // Disabilita lo scroll durante il caricamento

                children: [
                  if (!_isDataReady)
                    const Center(child: CircularProgressIndicator())
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                      child: _isDataReady
                          ? TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOutCubic,
                        builder: (context, value, child) {
                          // Calcola i punti animati
                          final animatedSpots = chartSpots.map((spot) {
                            return FlSpot(spot.x, spot.y * value);
                          }).toList();

                          return LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                getDrawingHorizontalLine: (val) => FlLine(
                                  color: getColor(media).withOpacity(0.2),
                                  strokeWidth: 0.8,
                                ),
                                getDrawingVerticalLine: (val) => FlLine(
                                  color: Colors.grey.withOpacity(0.2),
                                  strokeWidth: 0.8,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) => Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 35,
                                    interval: chartSpots.length > 12
                                        ? (chartSpots.length / 6).roundToDouble()
                                        : 1,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 && index < voti.length) {
                                        String dataLabel = voti[index].dataVoto;
                                        if (dataLabel.contains("-")) {
                                          var parts = dataLabel.split('-');
                                          if (parts.length > 2) {
                                            dataLabel = "${parts[2]}/${parts[1]}";
                                          } else if (parts.length == 2) {
                                            dataLabel = "${parts[1]}/${parts[0]}";
                                          }
                                        } else if (dataLabel.length > 5) {
                                          dataLabel =
                                              dataLabel.substring(dataLabel.length - 5);
                                        }
                                        return SideTitleWidget(
                                          space: 8.0,
                                          meta: meta,
                                          child: Text(
                                            dataLabel,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: getColor(media).withOpacity(0.8),
                                  width: 1.5,
                                ),
                              ),
                              minX: 0,
                              maxX: chartSpots.isEmpty
                                  ? 1
                                  : chartSpots.length.toDouble() - 1,
                              minY: 0,
                              maxY: 10,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: animatedSpots,
                                  isCurved: true,
                                  gradient: LinearGradient(
                                    colors: colori,
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: dotted
                                        ? true
                                        : votiValidi.length > 12
                                        ? false
                                        : true,
                                    getDotPainter:
                                        (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                          radius: 4,
                                          color: barData.gradient?.colors.first
                                              .withOpacity(0.9) ??
                                              getColor(media),
                                          strokeWidth: 1.5,
                                          strokeColor: Colors.white,
                                        ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: colori
                                          .map((color) => color.withOpacity(0.3))
                                          .toList(),
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ],
                              extraLinesData: ExtraLinesData(
                                horizontalLines: [
                                  HorizontalLine(
                                    y: 6,
                                    color: Colors.white.withOpacity(0.5),
                                    strokeWidth: 2,
                                    dashArray: [5, 5],
                                    label: HorizontalLineLabel(
                                      show: true,
                                      alignment: Alignment.topRight,
                                      padding: const EdgeInsets.only(right: 5, bottom: 2),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      labelResolver: (line) => '6',
                                    ),
                                  ),
                                ],
                              ),
                              lineTouchData: LineTouchData(
                                enabled: true,
                                handleBuiltInTouches: true,
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBorder:
                                  const BorderSide(color: Colors.white, width: 1),
                                  getTooltipItems:
                                      (List<LineBarSpot> touchedBarSpots) {
                                    return touchedBarSpots.map((barSpot) {
                                      final flSpot = barSpot;
                                      if (flSpot.spotIndex < 0 ||
                                          flSpot.spotIndex >= voti.length) return null;
                                      String dataTooltip =
                                          voti[flSpot.spotIndex].dataVoto;
                                      return LineTooltipItem(
                                        'Voto: ${flSpot.y.toStringAsFixed(1)}\n',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: dataTooltip,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).whereType<LineTooltipItem>().toList();
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      )
                          : const Center(child: CircularProgressIndicator()),
                    ),


                  // --- Grafico a Barre ---
                  if (!_isDataReady)
                    const Center(child: CircularProgressIndicator())
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 25, 16, 8),
                      child: _isDataReady
                          ? TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOutCubic,
                        builder: (context, value, child) {
                          // Animiamo ogni BarChartGroupData scalando il toY dei suoi rod
                          final animatedGroups = chartBarGroups.map((group) {
                            return BarChartGroupData(
                              x: group.x,
                              barRods: group.barRods.map((rod) {
                                return BarChartRodData(
                                  // toY animato (da 0 -> rod.toY)
                                  toY: rod.toY * value,
                                  // manteniamo gli altri attributi (colore/gradiente/width/...) così com'erano
                                  color: rod.color,
                                  width: rod.width,
                                  borderRadius: rod.borderRadius,
                                  gradient: rod.gradient,
                                  borderSide: rod.borderSide,
                                  backDrawRodData: rod.backDrawRodData,
                                );
                              }).toList(),
                              // se usavi showingTooltipIndicators su group, puoi copiarlo qui (opzionale)
                              showingTooltipIndicators: group.showingTooltipIndicators,
                            );
                          }).toList();

                          return BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              // manteniamo la stessa logica di maxY che avevi
                              maxY: (votiValidi.isEmpty ? 5 : (votiValidi.length / 5) + 4),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.white.withOpacity(0.1),
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    interval: votiValidi.length > 12 ? 2 : 1,
                                    getTitlesWidget: (value, meta) {
                                      if (value == 0 || value > meta.max) return Container();
                                      return Text(value.toInt().toString(), style: TextStyle(color: Colors.white70, fontSize: 10));
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 38,
                                    interval: 10,
                                    getTitlesWidget: (value, meta) {
                                      // value è la x: noi avevamo usato x = (i * 10) per i voti (es. 65 -> 6.5)
                                      final votoReale = value / 10;
                                      // mostriamo solo le etichette in corrispondenza dell'intervallo applicato
                                      if (value.toInt() % meta.appliedInterval.toInt() != 0) {
                                        return Container();
                                      }
                                      return SideTitleWidget(
                                        space: 4,
                                        meta: meta,
                                        child: Text(
                                          // se è un intero mostro senza decimali, altrimenti 1 decimale
                                          votoReale.truncateToDouble() == votoReale
                                              ? votoReale.toInt().toString()
                                              : votoReale.toStringAsFixed(1),
                                          style: TextStyle(
                                            color: getColor(votoReale),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: animatedGroups,
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    // group.x è (voto * 10). Esempio: 65 => 6.5
                                    final votoReale = group.x / 10.0;
                                    // la frequenza reale è il valore finale (non quello animato),
                                    // quindi leggiamo la prima barRod dal group originale (chartBarGroups)
                                    int freq = 0;
                                    final originalGroup = chartBarGroups.firstWhere(
                                          (g) => g.x == group.x,
                                      orElse: () => group,
                                    );
                                    if (originalGroup.barRods.isNotEmpty) {
                                      freq = originalGroup.barRods[0].toY.toInt();
                                    }

                                    final votoLabel = votoReale.truncateToDouble() == votoReale
                                        ? votoReale.toInt().toString()
                                        : votoReale.toStringAsFixed(1);

                                    return BarTooltipItem(
                                      'Voto $votoLabel\n',
                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: "Preso $freq volte",
                                          style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeOut,
                          );
                        },
                      )
                          : const Center(child: CircularProgressIndicator()),
                    ),

                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? getColor(media) : Colors.grey,
                  ),
                );
              }),
            ),
            const SizedBox(height: 3),
            const Text('Nuovi             Voti             Vecchi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            Container(
              padding: const EdgeInsets.all(10.0),
              height: 100,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: votiDisplay.length,
                itemBuilder: (BuildContext context, int index) {
                  final voto = votiDisplay[index];
                  return Row(
                    children: [const SizedBox(width: 10), VotoSingolo(voto: voto, grandezza: 85, fontSize: 25)],
                  );
                },
              ),
            ),
            Divider(indent: 30, endIndent: 30, thickness: 2, color: getColor(media)),
            Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Media", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            Text(
                              media.toStringAsFixed(2),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: getColor(media)),
                            ),
                            const SizedBox(height: 12),
                            const Text("Streak", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            Row(
                              children: [
                                Icon(
                                  streak.isGoated(voti) ? Icons.star : (streak.votiBuoni >= 10 ? Icons.local_fire_department : Icons.local_fire_department_outlined),
                                  color: streak.isGoated(voti) ? Colors.yellow : streak.getStreakColor(),
                                  size: 30,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  streak.isGoated(voti) ? "GOAT" : "${streak.votiBuoni}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: streak.isGoated(voti) ? Colors.yellow : streak.getStreakColor(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RatioPieChart(ratio: ratio, media: media),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text("Prof: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        Expanded(
                          child: Text(
                            widget.materia.nomeProf,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Divider(indent: 30, endIndent: 30, thickness: 2, color: getColor(media)),
            const Text("Medie ipotetiche", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              child: Ipotetiche(voti: voti),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // --- Funzioni Helper ---
  List<Color> getColors(List<Voto> voti) {
    double media = getMedia(voti);
    if (media >= 6.0) {
      return [Colors.green, Color.fromRGBO(30, 100, 30, 1)];
    } else if (media >= 5.0) {
      return [Colors.yellow, Color.fromRGBO(100, 100, 30, 1)];
    } else {
      return [Colors.red, Color.fromRGBO(100, 30, 30, 1)];
    }
  }

  Color getColor(double media) {
    if (media >= 6.0) {
      return Colors.green;
    } else if (media >= 5.0) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  double getMedia(List<Voto> voti) {
    if (voti.isEmpty) {
      return 0.0;
    }
    double somma = 0.0;
    int conteggioVotiValidi = 0;
    for (Voto voto in voti) {
      if (voto.cancellato) {
        continue;
      }
      somma += voto.voto;
      conteggioVotiValidi++;
    }
    return conteggioVotiValidi == 0 ? 0.0 : somma / conteggioVotiValidi;
  }
}
