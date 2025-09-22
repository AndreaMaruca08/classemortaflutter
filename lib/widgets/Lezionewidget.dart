import 'package:flutter/material.dart';
import '../models/Lezione.dart';

class Lezionewidget extends StatelessWidget {
  final Lezione lezione;
  const Lezionewidget({
    super.key,
    required this.lezione,
  });

  double getHeight(String arg){
    switch(arg.length){
      case > 100:
        return 300;
      case > 50:
        return 250;
      case > 20:
        return 230;
      default:
        return 212;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: getHeight(lezione.argomento),
      padding: EdgeInsets.all(10),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${lezione.materia} - ${lezione.ora} ora",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.white,
                size: 19,
              ),
              Expanded(
                child: Text(
                    "${lezione.prof}",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: Text(
              lezione.argomento,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],

      )
    );
  }
}
