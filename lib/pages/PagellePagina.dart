import 'package:classemorta/models/Pagella.dart';
import 'package:flutter/material.dart';
import '../widgets/PagellaWid.dart';

class Pagellepagina extends StatelessWidget {
  final List<Pagella>? pagelle;
  const Pagellepagina({
    super.key,
    required this.pagelle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pagelle'),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(), // o rimuovila per il default
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: pagelle?.length,
            itemBuilder: (BuildContext context, int index) {
              final pagella = pagelle?[index];

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Pagellawid(pagella: pagella!),
              );
            },
          ),
        )
    );
  }
}
