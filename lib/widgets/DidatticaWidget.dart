import 'package:ClasseMorta/models/FileDidattica.dart';
import 'package:ClasseMorta/service/ApiService.dart';
import 'package:flutter/material.dart';

class Didatticawidget extends StatelessWidget {
  final Didattica fileSingolo;
  final Apiservice apiservice;
  const Didatticawidget({
    super.key,
    required this.fileSingolo,
    required this.apiservice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileSingolo.docente,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(
                      2.0,
                      2.0,
                    ), // Spostamento orizzontale e verticale dell'ombra
                    blurRadius: 3.0, // Quanto deve essere sfocata l'ombra
                    color: Colors.black.withOpacity(
                      0.5,
                    ), // Colore dell'ombra con opacità
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              fileSingolo.titolo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(
                      2.0,
                      2.0,
                    ), // Spostamento orizzontale e verticale dell'ombra
                    blurRadius: 3.0, // Quanto deve essere sfocata l'ombra
                    color: Colors.black.withOpacity(
                      0.5,
                    ), // Colore dell'ombra con opacità
                  ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(Icons.date_range_sharp),
                const SizedBox(width: 5),
                Text(
                  fileSingolo.data.toString().substring(0, 19),
                  style: TextStyle(
                    fontSize: 16,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(
                          2.0,
                          2.0,
                        ), // Spostamento orizzontale e verticale dell'ombra
                        blurRadius: 3.0, // Quanto deve essere sfocata l'ombra
                        color: Colors.black.withOpacity(
                          0.5,
                        ), // Colore dell'ombra con opacità
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20,),
                IconButton(
                  onPressed: () async {
                    await apiservice.downloadAndOpenPdfById(
                      '${fileSingolo.fileId}',
                      '${fileSingolo.titolo}',
                        "",
                        0,
                        true
                    );
                  },
                  icon: Icon(Icons.file_download),
                ),
              ],
            ),

            SizedBox(height: 6),

          ],
        ),
      )
    );
  }
}
