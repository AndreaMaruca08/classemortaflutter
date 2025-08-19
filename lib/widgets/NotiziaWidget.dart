import 'package:ClasseMorta/service/ApiService.dart';
import 'package:flutter/material.dart';
import '../models/Notizia.dart';

class Notiziawidget extends StatelessWidget {
  final Notizia notizia;
  final Apiservice service;
  const Notiziawidget({
    super.key,
    required this.notizia,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(240, 240, 240, 0.4),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding( // Aggiunto Padding per non far toccare il contenuto ai bordi del Container
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Allinea i figli a sinistra
          mainAxisSize: MainAxisSize.min, // Fa sì che la Column occupi solo lo spazio verticale necessario
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Allinea gli elementi della Row in alto
              children: [
                SizedBox(width: 10), // Spazio iniziale
                Expanded( // <--- CORRETTO: Ora il Text si espande nella Row
                  child: Text(
                    notizia.title,
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    // softWrap: true, // Già di default, ma per chiarezza
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (notizia.files.isNotEmpty) ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notizia.files.length,
                itemBuilder: (context, index) {
                  final file = notizia.files[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            service.downloadAndOpenAttachment(notizia.codiceDocumento, file.attachNum);
                          },
                          icon: Icon(Icons.file_copy_outlined),
                          tooltip: "Apri file",
                        ),
                        SizedBox(width: 8), // Spazio tra icona e testo
                        Expanded( // <--- CORRETTO: Ora il Text si espande nella Row
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
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
