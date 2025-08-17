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
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 10),
              SizedBox(
                width: 300,
                child:Expanded(
                  child: Text(
                      notizia.title,
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)
                  ),
                ),
              )


            ],
          ),
          // Dentro il Widget build di Notiziawidget

// ... altro codice del Notiziawidget ...
          SizedBox(height: 10),
          if (notizia.files.isNotEmpty) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notizia.files.length, // **DEVI SEMPRE FORNIRE itemCount!**
              itemBuilder: (context, index) {
                final file = notizia.files[index];
                return Padding( // Opzionale: aggiungi padding per ogni riga di file
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
                      SizedBox(
                        width: 300,
                        child: Expanded(
                          child: Text(
                            file.fileName,
                            overflow: TextOverflow.ellipsis, // Gestisce nomi di file lunghi
                          ),
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
    );
  }
}
