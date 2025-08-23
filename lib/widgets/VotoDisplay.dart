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
          VotoSingolo(voto: voto, prec: precedente, grandezza: grandezza),
          const SizedBox(width: 10),
          Icon(
            Icons.calendar_month,
            size: 20,
          ),
          Text(
            "${voto.dataVoto} | ${voto.nomeInteroMateria.length > 20 ? "${voto.nomeInteroMateria.substring(0, 20)}..." : voto.nomeInteroMateria}",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      )
    );
  }
}

