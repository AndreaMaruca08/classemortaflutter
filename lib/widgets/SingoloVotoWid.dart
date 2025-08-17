import 'package:ClasseMorta/pages/DettagliVoto.dart';
import 'package:ClasseMorta/widgets/Cerchio.dart'; // Assumendo che CircularProgressBar sia qui
import 'package:flutter/material.dart';
import '../models/Voto.dart';

class VotoSingolo extends StatelessWidget {
  final Voto voto;
  final double grandezza;
  const VotoSingolo({
    super.key,
    required this.voto,
    required this.grandezza,
  });


  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Dettaglivoto(voto: voto)), // Sostituisci con la tua pagina
          );
        }, // Assegna la callback onTap
        splashColor: voto.voto >= 6 ? Colors.green : voto.voto >= 5 ? Colors.yellow : Colors.red, // Cambia il colore del ripple in base al voto,
        highlightColor: Colors.transparent, // Se non vuoi l'highlight prima del ripple
        borderRadius: BorderRadius.circular(grandezza / 2), // Per far sì che il ripple sia circolare come la barra
        child: CircularProgressBar(
          currentValue: voto.voto,
          maxValue: 10,
          size: grandezza,
          child: Text(
            // Considera di rendere il testo più leggibile se la grandezza è piccola
            // Potresti voler usare FittedBox o TextOverflow.ellipsis
            "${voto.codiceMateria} - ${voto.displayValue}",
            textAlign: TextAlign.center, // Utile se il testo va a capo
            style: TextStyle(fontSize: grandezza * 0.15), // Esempio di dimensione testo scalabile
          ),
        ),
      ),
    );
  }
}
