import 'package:ClasseMorta/models/Streak.dart';
import 'package:ClasseMorta/models/Voto.dart';
import 'package:ClasseMorta/widgets/SingoloVotoWid.dart';
import 'package:ClasseMorta/widgets/torta.dart';
import 'package:flutter/material.dart';
import '../../models/Materia.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../widgets/MedieIpotetiche.dart'; // Import fl_chart

class Dettaglimateria extends StatelessWidget {
  final Materia materia;
  final int periodo;
  final bool dotted;
  const Dettaglimateria({super.key, required this.materia, required this.periodo, required this.dotted});

  @override
  Widget build(BuildContext context) {
    List<Voto> voti = materia.voti.where((voto) => voto.periodo == periodo).toList();
    if (periodo == 3) {
      voti = materia.voti;
    }

    voti.sort((a, b) => a.dataVoto.compareTo(b.dataVoto));
    List<FlSpot> spots = [];
    if (voti.isNotEmpty) {
      for (int i = 0; i < voti.length; i++) {
        spots.add(FlSpot(i.toDouble(), voti[i].voto));
      }
    }
    List<Voto> votiDisplay = voti.reversed.toList();
    List<Color> colori = getColors(voti);

    double media = getMedia(voti);
    Streak streak = Streak().getStreak(voti);

    var ratio = Materia.ratio(voti);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dettagli materia ${materia.codiceMateria}'),
      ),
      body: SingleChildScrollView(// Added SingleChildScrollView to prevent overflow if content is long
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Text(
              periodo == 3 ? "Grafico andamento anno: " : "Grafico andamento nel ${voti[0].periodo} quadrimestre: ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 20), // Add some spacing
            if (spots.isNotEmpty) // Only show the chart if there's data
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AspectRatio(
                    aspectRatio: 1.3, // Adjust aspect ratio as needed
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: getColor(media).withOpacity(0.2),
                            strokeWidth: 0.8,
                          ),
                          getDrawingVerticalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 0.8,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 2,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 35,
                              interval: spots.length > 12 ? (spots.length / 6).roundToDouble() : 1, // Meno etichette se ci sono molti punti
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < voti.length) {
                                  String dataLabel = voti[index].dataVoto;
                                  if (dataLabel.contains("-")) {
                                    var parts = dataLabel.split('-');
                                    if (parts.length > 2) { // Formato tipo YYYY-MM-DD
                                      dataLabel = "${parts[2]}/${parts[1]}";
                                    } else if (parts.length == 2) { // Formato tipo MM-DD (già processato dal tuo replaceRange)
                                      dataLabel = "${parts[1]}/${parts[0]}";
                                    }
                                  } else if (dataLabel.length > 5) { // Fallback per tagliare stringhe lunghe
                                    dataLabel = dataLabel.substring(dataLabel.length - 5); // Prende gli ultimi 5 caratteri
                                  }

                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 8.0,
                                    child: Text(dataLabel, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10)),
                                  );
                                }
                                return Text('');
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: getColor(media).withOpacity(0.8), width: 1.5),
                        ),
                        minX: 0,
                        maxX: spots.isEmpty ? 1 : spots.length.toDouble() -1,
                        minY: 0,
                        maxY: 10,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            gradient: LinearGradient(
                              colors: colori, // Usa direttamente i tuoi 'colori'
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: dotted,
                              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                radius: 4,
                                color: barData.gradient?.colors.first.withOpacity(0.9) ?? getColor(media),
                                strokeWidth: 1.5,
                                strokeColor: Colors.white,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: colori.map((color) => color.withOpacity(0.3)).toList(),
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipRoundedRadius: 8,
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                final flSpot = barSpot;
                                if (flSpot.spotIndex < 0 || flSpot.spotIndex >= voti.length) return null;

                                String dataTooltip = voti[flSpot.spotIndex].dataVoto; // Formatta se necessario
                                return LineTooltipItem(
                                  'Voto: ${flSpot.y.toStringAsFixed(1)}\n',
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  children: [
                                    TextSpan(
                                      text: dataTooltip, // Usa la data formattata qui
                                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.normal, fontSize: 12),
                                    ),
                                  ],
                                  textAlign: TextAlign.left,
                                );
                              }).where((e) => e != null).toList().cast<LineTooltipItem>();
                            },
                          ),
                        ),
                      ),
                    )
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Nessun dato disponibile per il grafico."),
              ),
            const SizedBox(height: 3),
            const Text('Nuovi             Voti             Vecchi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            Container(
              padding: const EdgeInsets.all(10.0),
              height: 100,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: voti.length,
                itemBuilder: (BuildContext context, int index) {
                  final voto = votiDisplay[index];
                  return Row(
                    children: [
                      const SizedBox(width: 10),
                      VotoSingolo(voto: voto, grandezza: 85)
                    ],
                  );
                },
              ),
            ),
            Divider( indent: 30, endIndent: 30, thickness: 2, color: getColor(media),),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 30,),
                const Text("Media: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                Text(media.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: getColor(media)),),
                const SizedBox(width: 2,),
                const Text("      Prof: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                Expanded(
                  child: Text(
                    materia.nomeProf,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 30,),
                const Text("Streak :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                Icon(
                  streak.isGoat(voti) ? Icons.star: streak.votiBuoni >= 10 ? Icons.local_fire_department: Icons.local_fire_department_outlined,
                  color: streak.isGoat(voti)? Colors.yellow : streak.getStreakColor(),
                  size: 30,
                ),
                Text(
                  " ${streak.isGoat(voti) ? "GOAT" : streak.votiBuoni}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: streak.isGoat(voti)? Colors.yellow : streak.getStreakColor()
                  ),
                ),
                const SizedBox(width: 5,),
                RatioPieChart(ratio: ratio, media: media)
              ],
            ),
            Divider( indent: 30, endIndent: 30, thickness: 2, color: getColor(media),),

            Text("Medie ipotetiche", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
            const SizedBox(height: 10,),
            SizedBox(
              height: 600,
              width: 250,
              child:  Ipotetiche(voti: voti),
            ),
            const SizedBox(height: 100,),
          ],
        ),
      ),
    );

  }
  List<Color> getColors(List<Voto> voti) {
    double media = getMedia(voti);
    if (media >= 6.0) {
      return [Colors.green, Color.fromRGBO(30, 100, 30, 1)];
    }else if(media >= 5.0){
      return [ Colors.yellow, Color.fromRGBO(100, 100, 30, 1)];
    }else{
      return [Colors.red, Color.fromRGBO(100, 30, 30, 1)];
    }
  }
  Color getColor(double media){
    if (media >= 6.0) {
      return Colors.green;
    }else if(media >= 5.0){
      return Colors.yellow;
    }else{
      return Colors.red;
    }
  }
  double getMedia(List<Voto> voti) {
    double somma = 0.0;
    for (Voto voto in voti) {
      if(voto.cancellato){
        continue;
      }
      somma += voto.voto;
    }
    return somma / voti.length;
  }
}