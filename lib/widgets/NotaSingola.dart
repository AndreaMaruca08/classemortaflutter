import 'package:flutter/material.dart';

import '../models/Nota.dart';

class Notasingola extends StatelessWidget {
  final Nota nota;
  const Notasingola({
    super.key,
    required this.nota,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87;

    return Container(
      height: 450,
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
      child: SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // La Column cerca di essere il più piccola possibile, ma l'Expanded la forzerà a riempirsi
          children: [
            Text(
              nota.nomeProf.length > 35
                  ? "${nota.nomeProf.substring(0, 35)}..."
                  : nota.nomeProf,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: textColor),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_month, size: 16, color: textColor.withOpacity(0.8)),
                SizedBox(width: 6),
                Text(
                  nota.data.length > 10 ? nota.data.substring(0, 10) : nota.data,
                  style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.9)),
                ),
              ],
            ),
            SizedBox(height: 4),
            Divider(thickness: 1, color: textColor),
            SizedBox(height: 4), // Aggiunto un piccolo spazio dopo il Divider
            // DESCRIZIONE:
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Icon(Icons.description, size: 16, color: textColor.withOpacity(0.8)),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        nota.messaggio,
                        style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.9)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}
