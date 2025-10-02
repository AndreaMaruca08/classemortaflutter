import 'package:classemorta/pages/html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/Pagella.dart';

class Pagellawid extends StatelessWidget {
  final Pagella pagella;
  const Pagellawid({
    super.key,
    required this.pagella,
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
          Text(
            pagella.titolo,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VisualizzaHtmlSemplice(htmlData: pagella.html,)), // Sostituisci con la tua pagina
                );
              },
              icon: Icon(Icons.document_scanner_outlined)
          )
        ],
      )
    );
  }
}
