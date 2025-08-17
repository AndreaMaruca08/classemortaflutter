import 'package:ClasseMorta/models/Streak.dart';
import 'package:ClasseMorta/models/Voto.dart';
import 'package:ClasseMorta/widgets/SingoloVotoWid.dart';
import 'package:flutter/material.dart';
import '../models/Materia.dart';
import 'package:fl_chart/fl_chart.dart';

import '../widgets/MedieIpotetiche.dart'; // Import fl_chart

class Dettaglimateria extends StatelessWidget {
  final Materia materia;
  final int periodo;
  const Dettaglimateria({super.key, required this.materia, required this.periodo});

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
                  aspectRatio: 1.5, // Adjust aspect ratio as needed
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30, // Adjust space for X-axis labels
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < voti.length) {
                               return Text(voti[value.toInt()].dataVoto.replaceRange(0, 5, ""), style: TextStyle(fontSize: 10),);
                              }
                              return Text('');
                            },
                            interval: 1, // Show a label for each data point
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: const Color(0xff37434d), width: 1),
                      ),
                      minX: 0,
                      maxX: spots.length.toDouble() -1, // Adjust based on your data
                      minY: 0, // Assuming grades are not negative
                      maxY: 10, // Assuming grades are up to 10
                      lineBarsData: [
                        LineChartBarData(
                          show: true,
                          spots: spots,
                          gradient: LinearGradient(
                              colors: colori,
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter
                          ),
                          isCurved: true,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),

                      ],
                    ),
                  ),
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
                Text(
                  "Rapporto |${ratio[0].toStringAsFixed(0)}/${ratio[1].toStringAsFixed(0)}|-|${ratio[2].toStringAsFixed(1)}%/${ratio[3] != 0.0 ? ratio[3].toStringAsFixed(1) : ""}%|",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: ratio[0] > ratio[1] ? Colors.green : Colors.red,
                  ),
                )
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
