import 'package:classemorta/models/FileDidattica.dart';
import 'package:classemorta/service/ApiService.dart';
import 'package:classemorta/widgets/DidatticaWidget.dart';
import 'package:flutter/material.dart';

class Didatticapagina extends StatelessWidget {
  final List<Didattica> didattica;
  final Apiservice service;
  const Didatticapagina({
    super.key,
    required this.didattica,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Files'),
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
                  itemCount: didattica.length,
                  itemBuilder: (BuildContext context, int index) {
                    final did = didattica[index];
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Didatticawidget(fileSingolo: did, apiservice: service),
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
