import 'package:classemorta/models/ProvaCurriculum.dart';
import 'package:classemorta/widgets/EsperienzaWid.dart';
import 'package:flutter/material.dart';
class Pctopage extends StatelessWidget {
  final PctoData? pctoDataa;
  const Pctopage({
    super.key,
    required this.pctoDataa,
  });

  @override
  Widget build(BuildContext context) {
    PctoData pctoData = pctoDataa!;
    return Scaffold(
        appBar: AppBar(
          title: const Text('PCTO'),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(), // o rimuovila per il default
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    const Text('Ore Previste: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                    Text(pctoData.orePrevisteRaw, style: const TextStyle(fontSize: 20)),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    const Text('Ore Presenze Totali: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                    Text(
                        pctoData.orePresenzeTotaliRaw, // Mostra la stringa grezza come prima
                        style: TextStyle(
                          fontSize: 20,
                          // --- CORREZIONE: Confronta direttamente i numeri interi ---
                          color: pctoData.orePresenzeTotali < pctoData.orePreviste ? Colors.red : Colors.green,
                        )
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Divider(color: Colors.grey[200], thickness: 2),
                const SizedBox(height: 20),
                const Text('Esperienze:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 20),

                SizedBox(
                  width: 300,
                  height: 600,
                  child: ListView.builder(
                    itemCount: pctoData.esperienze.length,
                      itemBuilder: (context, index) {
                        Esperienza esperienza = pctoData.esperienze[index];
                        return Esperienzawid(esp: esperienza);
                      }
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
