import 'package:classemorta/models/ProvaCurriculum.dart';
import 'package:flutter/material.dart';

class Esperienzawid extends StatelessWidget {
  final Esperienza esp;
  const Esperienzawid({
    super.key,
    required this.esp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20,),
        SizedBox(
          width: 350,
          child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(250, 250, 250, 0.2),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(esp.nomePosto, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Ore Esperienza: ${esp.oreEsperienza}',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if(esp.orePresenzaEsperienza != 0)
                    Text('Ore Presenza: ${esp.orePresenzaEsperienza.toString().substring(0, esp.orePresenzaEsperienza.toString().length - 1)}',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              )
          ),
        )
      ],
    );
  }
}
