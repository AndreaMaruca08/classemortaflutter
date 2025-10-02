import 'package:classemorta/widgets/NotaSingola.dart';
import 'package:flutter/material.dart';
import '../models/Nota.dart';

class Notepagina extends StatelessWidget {
  final List<List<Nota>> note;
  const Notepagina({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    List<Nota> disciplinari = note[0];
    List<Nota> annotazioni = note[1];
    List<Nota> diClasse = note[2];
    List<Nota> avvisi = note[3];
    return Scaffold(
        appBar: AppBar(
          title: const Text('Note'),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(), // o rimuovila per il default
          child: Padding( // Aggiungi padding generale se necessario
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text("DISCIPLINARI", style: TextStyle(fontSize: 25)),
                NotaS(avvisi: disciplinari),
                const SizedBox(height: 10),
                const Text("ANNOTAZIONI", style: TextStyle(fontSize: 25)),
                NotaS(avvisi: annotazioni),
                const SizedBox(height: 10),
                const Text("Note di classe", style: TextStyle(fontSize: 25),),
                NotaS(avvisi: diClasse),
                const SizedBox(height: 10),
                const Text("Avvisi per la famiglia", style: TextStyle(fontSize: 25),),
                NotaS(avvisi: avvisi)
              ],
            ),
          ),
        )
    );
  }

  SizedBox NotaS({required List<Nota> avvisi}){
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: avvisi.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Notasingola(nota: avvisi[index]),
          );
        },
      ),
    );
  }
}






