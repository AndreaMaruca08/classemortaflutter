import 'package:flutter/material.dart';
import '../models/Voto.dart';
import 'SingoloVotoWid.dart';

class Votodisplay extends StatelessWidget {
  final Voto voto;
  final Voto? precedente;
  final double grandezza;
  const  Votodisplay({super.key, required this.voto,  this.precedente,  required this.grandezza});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          VotoSingolo(voto: voto, prec: precedente, grandezza: grandezza, fontSize: 21),
          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                voto.codiceMateria,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "${voto.dataVoto} | ${voto.nomeInteroMateria.length > 20 ? "${voto.nomeInteroMateria.substring(0, 12)}..." : voto.nomeInteroMateria}"
              )
            ],
          )

        ],
      )
    );
  }
}

