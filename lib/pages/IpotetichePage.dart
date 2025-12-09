import 'package:flutter/material.dart';
import '../models/Voto.dart';

class IpotetichePage extends StatefulWidget {
  final List<Voto> voti;
  const IpotetichePage({
    super.key,
    required this.voti,
  });

  @override
  State<IpotetichePage> createState() => _IpotetichePageState();
}

class _IpotetichePageState extends State<IpotetichePage> {
  final List<double?> _nuoviVotiSelezionati = [];

  double _sommaIniziale = 0.0;
  int _conteggioIniziale = 0;
  double _mediaIniziale = 0.0;

  double _mediaIpotetica = 0.0;

  final List<double> _votiDisponibili =
  List.generate(21, (index) => index * 0.5);

  @override
  void initState() {
    super.initState();

    _addVotoField();

    for (var voto in widget.voti) {
      if (!voto.cancellato) {
        _sommaIniziale += voto.voto;
        _conteggioIniziale++;
      }
    }
    _mediaIniziale =
    _conteggioIniziale > 0 ? _sommaIniziale / _conteggioIniziale : 0.0;
    _mediaIpotetica = _mediaIniziale; // All'inizio la media ipotetica è quella iniziale
  }

  void _addVotoField() {

    if (_nuoviVotiSelezionati.length < 10) {
      setState(() {
        // Aggiungiamo 'null' per rappresentare un nuovo dropdown senza selezione
        _nuoviVotiSelezionati.add(null);
      });
      _calculateMedia(); // Ricalcola la media
    }
  }

  // Funzione per rimuovere l'ultimo menu a tendina
  void _removeVotoField() {
    // Rimuove l'ultimo campo solo se ce n'è più di uno
    if (_nuoviVotiSelezionati.length > 1) {
      setState(() {
        _nuoviVotiSelezionati.removeLast();
        _calculateMedia(); // Ricalcola la media dopo la rimozione
      });
    }
  }

  // Il cuore della logica: calcola la media ipotetica
  void _calculateMedia() {
    double sommaNuoviVoti = 0.0;
    int conteggioNuoviVoti = 0;

    // Itera sui voti selezionati, ignorando quelli null (non selezionati)
    for (final voto in _nuoviVotiSelezionati) {
      if (voto != null) {
        sommaNuoviVoti += voto;
        conteggioNuoviVoti++;
      }
    }

    // Calcola la nuova media totale
    final nuovaSommaTotale = _sommaIniziale + sommaNuoviVoti;
    final nuovoConteggioTotale = _conteggioIniziale + conteggioNuoviVoti;

    setState(() {
      _mediaIpotetica =
      nuovoConteggioTotale > 0 ? nuovaSommaTotale / nuovoConteggioTotale : _mediaIniziale;
    });
  }

  // Helper per ottenere il colore in base al voto
  Color _getColor(double media) {
    if (media >= 6.0) return Colors.green;
    if (media >= 5.0) return Colors.yellow;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medie Ipotetiche'),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.grey[900],
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'MEDIA IPOTETICA FINALE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Usiamo un AnimatedSwitcher per un effetto di transizione carino
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          // Key univoca per far scattare l'animazione al cambio del valore
                          key: ValueKey<String>(
                              _mediaIpotetica.toStringAsFixed(2)),
                          _mediaIpotetica.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: _getColor(_mediaIpotetica),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Aggiungi i voti che pensi di prendere:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              // --- LISTA DINAMICA DI MENU A TENDINA ---
              ListView.builder(
                shrinkWrap: true, // Necessario dentro a una SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // Disabilita lo scroll della lista
                itemCount: _nuoviVotiSelezionati.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    // DropdownButtonFormField è ottimo perché si integra bene nei form e ha un bordo
                    child: DropdownButtonFormField<double>(
                      value: _nuoviVotiSelezionati[index],
                      hint: Text('Seleziona voto ${index + 1}'),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.calculate_outlined),
                      ),
                      items: _votiDisponibili.map((double value) {
                        return DropdownMenuItem<double>(
                          value: value,
                          child: Text(
                            // Mostra il .0 per i voti interi per coerenza
                            value.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getColor(value),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (double? newValue) {
                        setState(() {
                          _nuoviVotiSelezionati[index] = newValue;
                        });
                        _calculateMedia(); // Ricalcola la media ogni volta che un valore cambia
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // --- PULSANTI PER AGGIUNGERE/RIMUOVERE CAMPI ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pulsante per rimuovere un campo
                  FilledButton.tonal(
                    onPressed: _nuoviVotiSelezionati.length > 1 ? _removeVotoField : null, // Disabilitato se c'è un solo campo
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.3),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.remove),
                        SizedBox(width: 8),
                        Text('Rimuovi'),
                      ],
                    ),
                  ),
                  // Pulsante per aggiungere un campo
                  FilledButton(
                    onPressed: _nuoviVotiSelezionati.length < 10 ? _addVotoField : null, // Disabilitato se si raggiunge il limite
                    child: const Row(
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 8),
                        Text('Aggiungi'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
