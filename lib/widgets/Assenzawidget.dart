import 'package:flutter/material.dart';
import '../models/Assenza.dart'; // Assicurati che il path sia corretto

class Assenzawidget extends StatelessWidget {
  final Assenza assenze;
  const Assenzawidget({
    super.key,
    required this.assenze,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Rimosso alignment: Alignment.topLeft da qui, perché lo gestiamo nella Column
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(100, 0, 0, 0.6),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // <-- AGGIUNGI QUESTO
        mainAxisSize: MainAxisSize.min, // Utile per far sì che la colonna non occupi più spazio del necessario in altezza
        children: [
          Text(
            "${assenze.data} - ${assenze.giustificata ? "Giustificata" : "Non Giustificata"}",
            // textAlign: TextAlign.left, // Non più strettamente necessario se la Column allinea a start
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: assenze.giustificata ? Colors.green : Colors.white,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 2.0,
                  color: Colors.black54,
                )
              ],
            ),
          ),
          SizedBox(height: 4), // Aggiungi un piccolo spazio se necessario
          Text(
            assenze.giustificazione,
            textAlign: TextAlign.left, // Questo ora funzionerà come previsto perché la Column è allineata a start
            style: TextStyle(
              fontSize: 19, // Considera una dimensione leggermente minore per la giustificazione o uno stile diverso
              fontWeight: FontWeight.normal, // Forse non bold per la giustificazione?
              color: assenze.giustificata ? Colors.green.shade100 : Colors.white70, // Un colore leggermente più tenue
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 2.0,
                  color: Colors.black54,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
