import 'package:classemorta/models/RichiestaGiustifica.dart';
import 'package:classemorta/models/enums/Operation.dart';
import 'package:classemorta/service/ApiService.dart';
import 'package:flutter/material.dart';
class NuovaGiustificazionePage extends StatefulWidget {
  final VoidCallback onConferma;
  final Apiservice service;

  const NuovaGiustificazionePage({Key? key, required this.service,  this.onConferma = _defaultConferma})
      : super(key: key);

  static void _defaultConferma() {
    print("Conferma di default chiamata");
  }

  @override
  State<NuovaGiustificazionePage> createState() =>
      _NuovaGiustificazionePageState();
}

class _NuovaGiustificazionePageState extends State<NuovaGiustificazionePage> {
  final _formKey = GlobalKey<FormState>();


  // Controller
  final _motivoCtrl = TextEditingController();
  final _infoCtrl = TextEditingController();
  final _accompagnatoreCtrl = TextEditingController();
  final _oraCtrl = TextEditingController(); // Controller per l'ora manuale

  // Valori selezionati
  String? _tipo; // 'Assenza', 'Permesso di entrata', 'Permesso di uscita'
  String? _causale;
  DateTime? _giornoDal;
  DateTime? _giornoAl;
  DateTime? _giornoSingolo; // Per entrata/uscita

  // Nomi costanti per i tipi per evitare errori di battitura
  static const String tipoAssenza = 'Assenza';
  static const String tipoEntrata = 'Permesso di entrata';
  static const String tipoUscita = 'Permesso di uscita';


  @override
  void dispose() {
    _motivoCtrl.dispose();
    _infoCtrl.dispose();
    _accompagnatoreCtrl.dispose();
    _oraCtrl.dispose();
    super.dispose();
  }

  void _onTipoChanged(String? nuovoTipo) {
    setState(() {
      _tipo = nuovoTipo;
      // Resetta i valori non più pertinenti
      _giornoDal = null;
      _giornoAl = null;
      _giornoSingolo = null;
      _oraCtrl.clear();
      if (_tipo != tipoUscita) {
        _accompagnatoreCtrl.clear();
      }
      // Potresti voler resettare anche _causale o altri campi se necessario
    });
  }

  // UI
  @override
  Widget build(BuildContext context) {
    bool isAssenza = _tipo == tipoAssenza;
    bool isEntrata = _tipo == tipoEntrata;
    bool isUscita = _tipo == tipoUscita;
    bool showCampiDataSingolaEOra = isEntrata || isUscita;
    bool showAccompagnatore = isUscita;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Nuova giustificazione'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _label('Dati obbligatori'),
              const SizedBox(height: 16),

              // Tipo
              _label('Seleziona tipo *'),
              _radioGroup(
                values: const [tipoAssenza, tipoEntrata, tipoUscita],
                groupValue: _tipo,
                onChanged: _onTipoChanged, // Usa il metodo per il reset
              ),
              const SizedBox(height: 16),

              // Causale (sempre visibile, ma potresti volerlo condizionare)
              _label('Causale (facoltativo)'),
              _radioGroup(
                values: const [
                  'A – Salute',
                  'AC – Certificato Medico',
                  'B – Famiglia',
                  'C – Altro',
                  'D – Trasporto',
                  'E – Sciopero'
                ],
                groupValue: _causale,
                onChanged: (v) => setState(() => _causale = v),
              ),
              const SizedBox(height: 16),

              // Campi condizionali in base al tipo
              if (_tipo != null) ...[ // Mostra il resto solo se un tipo è selezionato
                if (isAssenza) ...[
                  _label('Periodo di assenza *'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _datePickerTile('Dal', _giornoDal, (picked) => setState(() => _giornoDal = picked))),
                      const SizedBox(width: 12),
                      Expanded(child: _datePickerTile('Al', _giornoAl, (picked) => setState(() => _giornoAl = picked))),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                if (showCampiDataSingolaEOra) ...[
                  _label('Giorno e Ora *'),
                  const SizedBox(height: 8),
                  _datePickerTile('Giorno', _giornoSingolo, (picked) => setState(() => _giornoSingolo = picked)),
                  const SizedBox(height: 16),
                  _textField( // Ora come campo di testo
                    controller: _oraCtrl,
                    label: 'Ora (HH:mm) *',
                    keyboardType: TextInputType.datetime,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Campo richiesto';
                      // Semplice validazione del formato HH:mm
                      final timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
                      if (!timeRegex.hasMatch(v.trim())) {
                        return 'Formato ora non valido (HH:mm)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Motivazione (sempre visibile una volta scelto il tipo)
                _textField(
                  controller: _motivoCtrl,
                  label: 'Motivazione *',
                  maxLines: 3,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Campo richiesto' : null,
                ),
                const SizedBox(height: 16),

                if (showAccompagnatore) ...[
                  _textField(
                    controller: _accompagnatoreCtrl,
                    label: 'Accompagnatore (facoltativo)',
                  ),
                  const SizedBox(height: 16),
                ],

                _textField(
                  controller: _infoCtrl,
                  label: 'Altre informazioni (facoltativo)',
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Pulsanti
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.maybePop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[600]!),
                        ),
                        child: Text('Annulla',
                            style: TextStyle(color: Colors.grey[300])),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _conferma,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Conferma'),
                      ),
                    ),
                  ],
                ),
              ] else ... [
                // Messaggio o placeholder se nessun tipo è ancora selezionato
                Center(child: Text("Seleziona un tipo di giustificazione per continuare.", style: TextStyle(color: Colors.grey[400]))),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // Widget di utilità --------------------------------------------------------

  Widget _label(String testo) => Text(testo,
      style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.w500, fontSize: 16));

  Widget _radioGroup({
    required List<String> values,
    String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: values
            .map(
              (v) => RadioListTile<String>(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            title: Text(v, style: TextStyle(color: Colors.grey[300])),
            value: v,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: Colors.blueAccent,
          ),
        )
            .toList(),
      ),
    );
  }

  // Modificato per essere più generico e usare un callback per l'aggiornamento della data
  Widget _datePickerTile(String label, DateTime? date, ValueChanged<DateTime?> onDateChanged) {
    // Formatter per visualizzare la data in modo leggibile

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(DateTime.now().year - 5), // Ad esempio, ultimi 5 anni
          lastDate: DateTime(DateTime.now().year + 5),  // Ad esempio, prossimi 5 anni
          builder: (_, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.blueAccent,
                onPrimary: Colors.white, // Colore del testo sul primario
                surface: Colors.grey, // Sfondo del date picker
                onSurface: Colors.white, // Colore del testo nel date picker
              ),
              dialogBackgroundColor: Colors.grey[850],
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          onDateChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!)),
          filled: true,
          fillColor: Colors.grey[850],
          suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[400]),
        ),
        child: Text(
          date == null ? 'Seleziona data':  date.toString(),
          style: TextStyle(color: date == null ? Colors.grey[500] : Colors.grey[300], fontSize: 16),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.grey[300]),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent, width: 2)),
        filled: true,
        fillColor: Colors.grey[850],
      ),
    );
  }

  // Logica conferma ----------------------------------------------------------
  Future<void> _conferma() async {
    if (_tipo == null) {
      // Mostra un messaggio se il tipo non è selezionato
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Per favore, seleziona un tipo di giustificazione.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {

      RichiestaGiustifica richiestaGiustifica = RichiestaGiustifica(
          ope: Ope.NUOVO,
          tipo_giustifica: getTipo(_tipo!),
          causale: _causale!.substring(0,1),
          inizio_assenza: _giornoDal == null? "" : _giornoDal.toString().substring(0,10).replaceAll('-', '/'),
          fine_assenza: _giornoAl == null? "" : _giornoAl.toString().substring(0,10).replaceAll('-', '/'),
          motivazione_assenza: _motivoCtrl.text ?? "",
          giorno_entrata_uscita: _giornoSingolo == null? "" : _giornoSingolo.toString().substring(0,10).replaceAll('-', '/'),
          ora_entrata_uscita: _oraCtrl.text ?? "",
          motivazione_entrata_uscita: _motivoCtrl.text ?? "",
          accompagnatore: _accompagnatoreCtrl.text ?? "",
      );

      await widget.service.sendRequest(richiestaGiustifica);

      widget.onConferma();
      Navigator.maybePop(context); // Torna indietro dopo la conferma
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Per favore, correggi gli errori nel modulo.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.orangeAccent),
      );
    }
  }

  int getTipo(String tipo){
    return switch(tipo){
      'Assenza' => 0,
      'Permesso di entrata' => 1,
      'Permesso di uscita' => 2,
      _ => 0,
    };
  }

}
