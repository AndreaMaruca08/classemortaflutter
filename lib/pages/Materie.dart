import 'package:ClasseMorta/service/ApiService.dart';
import 'package:ClasseMorta/widgets/MateriaWidget.dart';
import 'package:flutter/material.dart';
import '../models/Materia.dart';
import '../models/Voto.dart';

class MateriePag extends StatelessWidget {
  final List<Voto>? voti;
  final Apiservice service;
  const MateriePag({
    super.key,
    required this.voti,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    List<Materia> materie = service.getMaterieFromVoti(voti!);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Materie'),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(), // o rimuovila per il default
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: materie.length,
                  itemBuilder: (BuildContext context, int index) {
                    final materia = materie[index];

                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Materiawidget(materia: materia, service: service),
                    );
                  },
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        )
    );
  }
}
