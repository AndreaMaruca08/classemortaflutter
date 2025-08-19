import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Assumendo che 'ratio' sia la tua lista:
// ratio[0] = numero di voti >= 6
// ratio[1] = numero di voti < 6
// ratio[2] = percentuale di voti >= 6
// ratio[3] = percentuale di voti < 6

// Esempio di dati ratio (sostituiscili con i tuoi dati reali)
// List<double> ratio = [7, 3, 70.0, 30.0]; // 7 voti buoni, 3 cattivi

class RatioPieChart extends StatelessWidget {
  final List<double> ratio;
  final double media; // Potrebbe servirti per un colore centrale o altro

  const RatioPieChart({Key? key, required this.ratio, required this.media}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ratio.length < 6 || (ratio[0] == 0 && ratio[1] == 0)) {
      return Text("Nessun dato per il rapporto voti.");
    }

    // Definisci i colori
    final Color sufficientColor = Colors.green;
    final Color insufficientColor = Colors.red;
    final Color midColor =Color.fromRGBO(200, 200, 0, 0.7);
    final Color defaultColor = Colors.grey; // In caso uno dei due sia 0

    // Prepara le sezioni del grafico a torta
    List<PieChartSectionData> sections = [];

    // Sezione Voti Sufficienti
    if (ratio[0] > 0) {
      sections.add(
        PieChartSectionData(
          color: sufficientColor,
          value: ratio[3], // Usa la percentuale per il valore della fetta
          title: '${ratio[3].toStringAsFixed(1)}%', // Etichetta sulla fetta
          radius: 40, // Raggio della fetta
          titleStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black.withOpacity(1), blurRadius: 3)],
          ),
          // badgeWidget: _Badge(Icons.thumb_up, size: 20, borderColor: Colors.black), // Opzionale
          // badgePositionPercentageOffset: .98, // Opzionale
        ),
      );
    }

    // Sezione Voti Insufficienti
    if (ratio[1] > 0) {
      sections.add(
        PieChartSectionData(
          color: insufficientColor,
          value: ratio[4], // Usa la percentuale per il valore della fetta
          title: '${ratio[4].toStringAsFixed(1)}%', // Etichetta sulla fetta
          radius: 40,
          titleStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 2)],
          ),
        ),
      );
    }

    if (ratio[2] > 0) {
      sections.add(
        PieChartSectionData(
          color: midColor,
          value: ratio[5], // Usa la percentuale per il valore della fetta
          title: '${ratio[5].toStringAsFixed(1)}%', // Etichetta sulla fetta
          radius: 40,
          titleStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 2)],
          ),
        ),
      );
    }


    // Se ci sono solo voti sufficienti o solo insufficienti, potremmo voler mostrare una singola fetta piena
    if (sections.length == 1) {
      sections[0] = sections[0].copyWith(value: 100.0, title: '100%');
    }


    // Se non ci sono voti (improbabile se hai ratio[0] o ratio[1] > 0, ma per sicurezza)
    if (sections.isEmpty) {
      // Potresti mostrare un grafico "vuoto" o un messaggio
      sections.add(PieChartSectionData(
        color: defaultColor,
        value: 100,
        title: 'N/D',
        radius: 30,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }


    return Column(
      children: [
        SizedBox(height: 10),
        SizedBox(
          height: 100, // Altezza del contenitore del grafico a torta
          width: 100,  // Larghezza del contenitore
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Puoi aggiungere interazioni qui se necessario
                },
              ),
              borderData: FlBorderData(show: false), // Nasconde il bordo del grafico
              sectionsSpace: 2, // Spazio tra le fette
              centerSpaceRadius: 20, // Raggio dello spazio centrale (per un effetto "ciambella")
              // Oppure centerSpaceRadius: 0 per un grafico a torta pieno
              sections: sections,
              // Potresti voler aggiungere un'animazione
              // startDegreeOffset: -90, // Inizia le fette da "ore 12"
            ),
            // swapAnimationDuration: Duration(milliseconds: 150), // Optional
            // swapAnimationCurve: Curves.linear, // Optional
          ),
        ),
        // Legenda opzionale
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _Indicator(color: sufficientColor, text: ' + ', isSquare: false),
            SizedBox(width: 2),
            _Indicator(color: insufficientColor, text: ' - ', isSquare: false),
            SizedBox(width: 2),
            _Indicator(color: midColor, text: ' ½ ', isSquare: false),
            SizedBox(width: 2),
            Text(
              "${ratio[0].toStringAsFixed(0)} / ${ratio[1].toStringAsFixed(0)} / ${ratio[2].toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ratio[0]>= ratio[1] ? sufficientColor : insufficientColor
              ),
            )
          ],
        ),
      ],
    );
  }
}

// Widget helper per la legenda (opzionale)
class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const _Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white))
      ],
    );
  }
}
