import 'package:ClasseMorta/pages/detail/DettagliVoto.dart';
import 'package:ClasseMorta/widgets/Cerchio.dart'; // Assumendo che CircularProgressBar sia qui
import 'package:flutter/material.dart';
import '../models/Voto.dart';

class VotoSingolo extends StatelessWidget {
  final Voto voto;
  final Voto? prec;
  final double fontSize;
  final double grandezza;
  const VotoSingolo({
    super.key,
    required this.voto,
    required this.fontSize,
    this.prec,
    required this.grandezza,
  });


  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Dettaglivoto(voto: voto, prec: prec,)), // Sostituisci con la tua pagina
          );
        }, // Assegna la callback onTap
        splashColor: voto.voto >= 6 ? Colors.green : voto.voto >= 5 ? Colors.yellow : Colors.red, // Cambia il colore del ripple in base al voto,
        highlightColor: Colors.transparent, // Se non vuoi l'highlight prima del ripple
        borderRadius: BorderRadius.circular(grandezza / 2), // Per far sì che il ripple sia circolare come la barra
        child: CircularProgressBar(
          currentValue: voto.voto,
          maxValue: 10,
          size: grandezza,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${!voto.tipo.contains("Scritto") && !voto.tipo.contains("Orale") && !voto.tipo.contains("Pratico") ? "${voto.codiceMateria} " : ""} ${voto.displayValue}",
                textAlign: TextAlign.center, // Utile se il testo va a capo
                style: TextStyle(fontSize: fontSize,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(1.0, 2.0), // Spostamento orizzontale e verticale dell'ombra
                        blurRadius: 3.0,         // Quanto deve essere sfocata l'ombra
                        color: Colors.black, // Colore dell'ombra con opacità
                      ),
                    ]
                ), 
              ),
              const SizedBox(width: 5,),
              if(prec != null)
                Icon(
                  voto.voto > (prec?.voto ?? 0) ?
                  Icons.trending_up : voto.voto == (prec?.voto ?? 0) ?
                  Icons.trending_neutral_rounded : Icons.trending_down,
                  size: 20,
                  color: voto.voto > (prec?.voto ?? 0) ?
                  Colors.green : voto.voto == (prec?.voto ?? 0) ?
                  Colors.white : Colors.red,
                ),
            ],
          )
        ),
      ),
    );
  }
}
/*

 */
