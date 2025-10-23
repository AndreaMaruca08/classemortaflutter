import 'package:classemorta/models/Voto.dart';
import 'package:classemorta/pages/detail/DettagliMateria.dart';
import 'package:classemorta/service/ApiService.dart';
import 'package:classemorta/widgets/SingoloVotoWid.dart';
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
    List<Voto> votiMat = materia.voti;
    Voto? ultimo;
    Voto? penultimo;
    if(votiMat.length > 1){
       ultimo = votiMat.last;
       penultimo = votiMat[votiMat.length - 2];
    }
    return Container(
      padding: const EdgeInsets.all(12.0), // Aggiungi padding interno per non far toccare il testo ai bordi
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(240, 240, 240, 0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(2, 2),
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
              Expanded(
                flex: 2,
                child: Text(
                  materia.nomeInteroMateria,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    shadows: <Shadow>[Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Colors.black,
                    ),]),
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
                  style: TextStyle(fontSize: 14, color: textColor, shadows: [Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Colors.black,
                  ),]),
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
                Text("        Totale", style: TextStyle(
                  fontSize: 12,
                    shadows: <Shadow>[
                    Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Colors.black,
                    ),
                    ]),
                ),
                SizedBox(width: 45,),
                Text("1° quadrimestre", style: TextStyle(
                    fontSize: 12,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Colors.black,
                      ),
                    ]),
                ),
                SizedBox(width: 15,),
                Text("2° quadrimestre", style: TextStyle(
                    fontSize: 12,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Colors.black,
                      ),
                    ]),
                ),
              ]
          ),

          if (voti != null && voti.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.start, // O come preferisci allineare
              children: [
                VotoSingolo(voto: voti[0], grandezza: 100, fontSize: 15, ms: service.impostazioni.msAnimazioneVoto),

                if (voti.length > 1)
                  SizedBox(width: 12),
                if (voti.length > 1)
                  VotoSingolo(voto: voti[1], grandezza: 90, fontSize: 16, ms: service.impostazioni.msAnimazioneVoto),

                if (voti.length > 2 && !voti[2].voto.isNaN)
                  SizedBox(width: 10),
                if (voti.length > 2 && !voti[2].voto.isNaN)
                  VotoSingolo(voto: voti[2], grandezza: 90, fontSize: 16, ms: service.impostazioni.msAnimazioneVoto),
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
                      MaterialPageRoute(builder: (context) => Dettaglimateria(materia: materia, periodo: 3, dotted: true, msAnimazione: service.impostazioni.msAnimazioneVoto, service: service)),
                    );
                  },
                  icon: Icon(Icons.auto_graph_sharp, color: Colors.white,)),
                SizedBox(width: 60,),
                IconButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Dettaglimateria(materia: materia, periodo: 1, dotted: true, msAnimazione: service.impostazioni.msAnimazioneVoto, service: service)),
                      );
                    },
                    icon: Icon(Icons.auto_graph_sharp, color: Colors.white,)),
                SizedBox(width: 55,),
                if (voti!.length > 2 && !voti[2].voto.isNaN)
                IconButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Dettaglimateria(materia: materia, periodo: 2, dotted: true, msAnimazione: service.impostazioni.msAnimazioneVoto, service: service)),
                      );
                    },
                    icon: Icon(Icons.auto_graph_sharp, color: Colors.white,)),
              ],
            ),

          if(votiMat.length > 1 && ultimo != null && penultimo != null)...[
            Divider(
              thickness: 1,
              color: Colors.white,
            ),
            Row(
              children: [
                ultimo.voto> penultimo.voto?
                Icon(
                  Icons.arrow_upward,
                  color: Colors.green,
                  size: 25,

                ):
                Icon(
                  Icons.arrow_downward,
                  color: Colors.red,
                  size: 25,
                ),
                SizedBox(width: 150, child: Text("${ultimo.voto > penultimo.voto ? "Aumento di" : "Calo di"}: ${ultimo.voto - penultimo.voto} "),),


                SizedBox(width: 130, child: Text("Ultimo voto: ${ultimo.voto}", style: TextStyle(color: ultimo.voto >= 6 ? Colors.green : ultimo.voto < 5 ? Colors.red : Colors.yellow, fontSize: 15),),),

              ],
            )

          ]
        ],
      ),
    );
  }
}
