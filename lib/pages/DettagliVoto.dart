import 'package:ClasseMorta/widgets/SingoloVotoWid.dart';
import 'package:flutter/material.dart';
import '../models/Voto.dart';

class Dettaglivoto extends StatelessWidget {
  final Voto voto;
  const  Dettaglivoto({super.key, required this.voto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettagli voto del | ${voto.dataVoto} |'),
      ),
      body: Column(
        children: [
          VotoSingolo(voto: voto, grandezza: 120),
          Divider(thickness: 2, color: getcoloreVoto(voto.voto)),
          Row(
            children: [
              Icon(voto.cancellato? Icons.delete_outline: Icons.check, size: 30),
              Expanded( // Added Expanded here
                child: Text(
                  voto.cancellato ? "Voto cancellato" : "Voto valido",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: voto.cancellato ? Colors.red : Colors.green),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.date_range_outlined, size: 30),
              Expanded(
                child: Text(
                  voto.dataVoto,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text("Periodo: ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  voto.periodo == 1? "1° quadrimestre" : "2° quadrimestre",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text("Materia: ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  voto.nomeInteroMateria,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text("Desc: ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  voto.descrizione.isEmpty? "Nessuna descrizione" : voto.descrizione,
                  style: const TextStyle(fontSize: 15)),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.person, size: 30, color: Colors.white),
              Expanded(
                child: Text(
                  voto.nomeProf.isEmpty? "Docente sconosciuto" : voto.nomeProf, // Removed the length check and substring logic
                  style: const TextStyle(fontSize: 15), // Increased font size a bit for readability
                ),
              ),
            ],
          ),


        ],
      ),

    );
  }
  Color getcoloreVoto(double voto) {
    if (voto >= 6) {
      return Colors.green;
    } else if (voto >= 5) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }

  }
}

