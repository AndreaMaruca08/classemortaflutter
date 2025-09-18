import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; // Importa il pacchetto

class VisualizzaHtmlSemplice extends StatelessWidget {
  final String htmlData;

  const VisualizzaHtmlSemplice({Key? key, required this.htmlData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(htmlData);
    return Scaffold(
      appBar: AppBar(title: Text("Contenuto HTML")),
      body: SingleChildScrollView( // Buono per contenuti lunghi
        padding: EdgeInsets.all(16.0),
        child: Html(
          data: htmlData,
          // Puoi personalizzare stili, gestori di tap, ecc.
           style: {
             "body": Style(
               fontSize: FontSize.large,   ),
             "p": Style(color: Colors.red),
           },
        ),
      ),
    );
  }
}

// Come usarlo:
// Navigator.push(context, MaterialPageRoute(builder: (context) =>
//   VisualizzaHtmlSemplice(htmlData: "<h1>Titolo</h1><p>Questo è <b>testo</b>.</p>")
// ));
            