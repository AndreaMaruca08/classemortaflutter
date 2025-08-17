import 'package:ClasseMorta/models/Voto.dart';
import 'package:ClasseMorta/pages/DettagliMateria.dart';
import 'package:ClasseMorta/service/ApiService.dart';
import 'package:ClasseMorta/widgets/SingoloVotoWid.dart';
import 'package:flutter/material.dart';
import '../models/Materia.dart'; // Assicurati che il percorso sia corretto

class Materiawidget extends StatelessWidget {
  final Materia materia;
  final Apiservice service;
  const Materiawidget({
    super.key,
    required this.materia,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    // Definizione del colore del testo per leggibilità
    Color textColor = Colors.white; // o Theme.of(context).colorScheme.onSurface se usi un tema più complesso
    List<Voto>? voti = service.getMedieMateria(materia);
    return Container(
      padding: const EdgeInsets.all(12.0), // Aggiungi padding interno per non far toccare il testo ai bordi
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Allinea il testo a sinistra per la colonna
        mainAxisSize: MainAxisSize.min, // La colonna occupa solo lo spazio necessario
        children: [
          Row(
            //crossAxisAlignment: CrossAxisAlignment.start, // Se i testi possono avere altezze diverse e vuoi allinearli in alto
            children: [
              // SizedBox(width: 15), // Spazio iniziale, può essere gestito dal padding del Container o da un Expanded vuoto se necessario

              // NOME MATERIA
              Expanded( // NOME MATERIA occupa lo spazio flessibile
                flex: 2, // Dà più spazio al nome materia rispetto al prof (es. 2/3 vs 1/3)
                child: Text(
                  materia.nomeInteroMateria,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 16),

              // NOME PROF
              Expanded(
                flex: 1,
                child: Text(
                  textAlign: TextAlign.end,
                  materia.nomeProf,
                  style: TextStyle(fontSize: 14, color: textColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 30),

            ],
          ),
          Divider(
            thickness: 1,
            color: Colors.white,
          ),
          Row(
              children: [
                Text("        Totale", style: TextStyle(fontSize: 12),),
                SizedBox(width: 45,),
                Text("1° quadrimestre", style: TextStyle(fontSize: 12),),
                SizedBox(width: 15,),
                Text("2° quadrimestre", style: TextStyle(fontSize: 12),),
              ]
          ),

          if (voti != null && voti.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.start, // O come preferisci allineare
              children: [
                VotoSingolo(voto: voti[0], grandezza: 100),

                if (voti.length > 1)
                  SizedBox(width: 12),
                if (voti.length > 1)
                  VotoSingolo(voto: voti[1], grandezza: 90),

                if (voti.length > 2)
                  SizedBox(width: 10),
                if (voti.length > 2)
                  VotoSingolo(voto: voti[2], grandezza: 90),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Nessun voto registrato per questa materia',
                style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 27,),
                IconButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Dettaglimateria(materia: materia, periodo: 3,)),
                    );
                  },
                  icon: Icon(Icons.auto_graph_sharp, color: Colors.white,)),
                SizedBox(width: 70,),
                IconButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Dettaglimateria(materia: materia, periodo: 1,)),
                      );
                    },
                    icon: Icon(Icons.auto_graph_sharp, color: Colors.white,)),
                SizedBox(width: 75,),
                IconButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Dettaglimateria(materia: materia, periodo: 2,)),
                      );
                    },
                    icon: Icon(Icons.auto_graph_sharp, color: Colors.white,)),
              ],
            )


        ],
      ),
    );
  }
}
