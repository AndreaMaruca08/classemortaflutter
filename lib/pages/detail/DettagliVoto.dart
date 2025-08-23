import 'package:ClasseMorta/widgets/SingoloVotoWid.dart';
import 'package:flutter/material.dart';
import '../../models/Voto.dart';

class Dettaglivoto extends StatelessWidget {
  final Voto voto;
  final Voto? prec;
  const  Dettaglivoto({super.key, required this.voto, this.prec});

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
              const Text("Tipologia voto: ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  voto.tipo,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.person, size: 30, color: Colors.white),
              Expanded(
                child: Text(
                  voto.nomeProf.isEmpty? "Docente sconosciuto" : voto.nomeProf, // Removed the length check and substring logic
                  style: const TextStyle(fontSize: 15), // Increased font size a bit for readability
                ),
              ),
            ],
          ),
            if(prec != null)
              Row(
                children: [
                  const Text(
                    "Progresso: ",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                      prec?.voto.toStringAsFixed(2) ?? "0",
                      style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold
                      ),
                  ),
                  const SizedBox(width: 10,),
                  Icon(
                    voto.voto > (prec?.voto ?? 0) ?
                      Icons.trending_up : voto.voto == (prec?.voto ?? 0) ?
                      Icons.trending_neutral_rounded : Icons.trending_down,
                    size: 40,
                    color: voto.voto > (prec?.voto ?? 0) ?
                      Colors.green : voto.voto == (prec?.voto ?? 0) ?
                      Colors.white : Colors.red,
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: Text(
                      voto.voto.toStringAsFixed(2),
                      // Removed the length check and substring logic
                      style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold
                      ),
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

