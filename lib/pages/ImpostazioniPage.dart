import 'package:classemorta/models/Settings.dart';
import 'package:classemorta/service/ApiService.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../service/AccessService.dart';
// 1. Converti il widget in StatefulWidget
class Impostazionipage extends StatefulWidget {
  final Apiservice service;
  const Impostazionipage({
    super.key,
    required this.service,
  });

  @override
  State<Impostazionipage> createState() => _ImpostazionipageState();
}

// 2. Crea la classe di Stato
class _ImpostazionipageState extends State<Impostazionipage> {
  // 3. Usa un TextEditingController per gestire l'input del TextField
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // 4. Inizializza il controller con il valore attuale delle impostazioni
    _controller = TextEditingController(
      text: widget.service.impostazioni.msAnimazioneVoto.toString(),
    );
  }

  @override
  void dispose() {
    // 5. Ricorda di fare il dispose del controller per liberare risorse
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Non è più necessario prendere 'set' qui, lo facciamo nell'onPressed
    return Scaffold(
        appBar: AppBar(
          title: const Text('Impostazioni'),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      "Durata animazione voto (ms):",
                      style: TextStyle(fontSize: 11.4),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        // 6. Collega il controller al TextField
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Aggiunto un piccolo spazio
                    ElevatedButton(
                      onPressed: () {
                        // 7. Leggi il testo dal controller e salvalo
                        final nuovoValore = int.tryParse(_controller.text);

                        // Controlla se il valore è valido prima di salvare
                        if (nuovoValore != null) {
                          Settings set = widget.service.impostazioni;
                          set.msAnimazioneVoto = nuovoValore;
                          widget.service.impostazioni = set;
                          set.salvaImpostazioni();

                          // Mostra un feedback all'utente che il salvataggio è avvenuto
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Impostazione salvata!"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          // Mostra un errore se l'input non è un numero valido
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Valore non valido. Inserire un numero."),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: const Text("Salva", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                ElevatedButton(onPressed: (){
                  Save save = Save();
                  save.saveStringList([]);
                  Navigator.pushReplacement(
                    context,
                    CustomPageRoute(builder: (context) => LoginPage()),
                  );

                }, child: const Text("Log out ", style: TextStyle(color: Colors.white)),)
              ],
            ),
          ),
        ));
  }
}
