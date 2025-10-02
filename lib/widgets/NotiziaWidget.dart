import 'package:classemorta/service/ApiService.dart';
import 'package:flutter/material.dart';
import '../models/Notizia.dart';

// 1. Converti in StatefulWidget
class Notiziawidget extends StatefulWidget {
  final Notizia notizia;
  final Apiservice service;
  const Notiziawidget({
    super.key,
    required this.notizia,
    required this.service,
  });

  @override
  State<Notiziawidget> createState() => _NotiziawidgetState();
}

class _NotiziawidgetState extends State<Notiziawidget> {
  // 2. Definisci una variabile di stato per il testo della risposta
  String? _responseBody; // Inizialmente null

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.notizia.title, // Accedi a notizia tramite widget.notizia
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            Text("   Inserito il ${widget.notizia.dataDiInserimento}"),
            Text(
              "  ${widget.notizia.letta ? "Letta" : "Non Letta"}",
              style: TextStyle(
                  color: widget.notizia.letta ? Colors.green : Colors.red,
                  fontSize: 20),
            ),
            SizedBox(height: 10),
            if (widget.notizia.files.isNotEmpty) ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.notizia.files.length,
                itemBuilder: (context, index) {
                  final file = widget.notizia.files[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            widget.service.readNoticeboardFile( // Accedi a service tramite widget.service
                                widget.notizia.codiceDocumento.toString(),
                                file.fileName,
                                widget.notizia.evtCode,
                                file.attachNum,
                                false,
                                true);
                          },
                          icon: Icon(Icons.file_copy_outlined),
                          tooltip: "Apri file",
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            file.fileName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            if (!widget.notizia.hasFile) ...[
              IconButton(
                onPressed: () async {
                  String resp = await widget.service.readNoticeboardFile(
                      widget.notizia.codiceDocumento.toString(),
                      "",
                      widget.notizia.evtCode,
                      101,
                      false,
                      false);
                  setState(() {
                    _responseBody = resp;
                  });
                },
                icon: Icon(Icons.read_more),
                tooltip: "Leggi contenuto", // Aggiunto tooltip per chiarezza
              ),
              // 4. Visualizza il testo se _responseBody non è null
              if (_responseBody != null) ...[
                SizedBox(height: 8), // Aggiungi uno spazio
                Padding( // Aggiungi padding per il testo
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(_responseBody!),
                ),
              ]
            ],
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
