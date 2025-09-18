import 'package:flutter/material.dart';
import '../../models/StudentCard.dart';

class StudentDetail extends StatefulWidget {
  final StudentCard card;
  const StudentDetail({super.key, required this.card});
  @override
  State<StudentDetail> createState() => _MainPageState();
}

class _MainPageState extends State<StudentDetail> {
  late StudentCard _card;
  @override
  void initState() {
    super.initState();
    _card = widget.card;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli Studente'),
      ),
      body: Padding(
        padding:const EdgeInsets.all(20.0),
        child: Container(
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

                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  const Text(
                      " Versione 1.5.0 - orari + bugfix + curriculum",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("  Informazioni studente ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Row(children: [
                      const Text("Nome e Cognome: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("${_card.nome} ${_card.cognome}"),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Row(children: [
                      const Text("Data di nascita: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_card.birthDate),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Row(children: [
                      const Text("Codice fiscale: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_card.fiscalCode),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  //SCUOLA
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("  Informazioni scuola ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Row(children: [
                      const Text("Codice scuola: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_card.schCode),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Row(children: [
                      const Text("Codice MIUR: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_card.miurSchoolCode),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Row(children: [
                      const Text("Nome scuola: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text("${_card.schName} - ${_card.schDedication}")),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Row(children: [
                      const Text("Città: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_card.schCity),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Row(children: [
                      const Text("Provincia: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_card.schProv),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  //ACCOUNT
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("  Informazioni account ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Row(children: [
                      const Text("Tipo utente: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_card.usrType == "S" ? "Studente" : _card.usrType == "P" ? "Professore" : "Genitore"),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Row(children: [
                      const Text("Codice account: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_card.ident),
                    ]),
                  ),
                ]
            )
        ),
      )
    );
  }
}

