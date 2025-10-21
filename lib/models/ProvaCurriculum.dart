import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

// --- I TUOI MODELLI (PctoData, Esperienza) RIMANGONO INVARIATI ---
class PctoData {
  final String orePrevisteRaw;
  final String orePresenzeTotaliRaw;
  final List<Esperienza> esperienze;

  int get orePreviste => _parseHours(orePrevisteRaw);
  int get orePresenzeTotali => _parseHours(orePresenzeTotaliRaw);

  PctoData({
    required this.orePrevisteRaw,
    required this.orePresenzeTotaliRaw,
    required this.esperienze,
  });

  static int _parseHours(String? hourString) {
    if (hourString == null || hourString.trim().isEmpty || hourString == 'N/A') {
      return 0;
    }
    final numericPart = hourString.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericPart.isEmpty) {
      return 0;
    }
    return int.tryParse(numericPart) ?? 0;
  }

  @override
  String toString() {
    return 'Ore Previste: $orePrevisteRaw (${orePreviste}h)\nOre Presenze Totali: $orePresenzeTotaliRaw (${orePresenzeTotali}h)\nEsperienze: ${esperienze.join("\n  ")}';
  }
}

class Esperienza {
  final String nomePosto;
  final String oreEsperienzaRaw;
  final String orePresenzaEsperienzaRaw;

  int get oreEsperienza => PctoData._parseHours(oreEsperienzaRaw);
  int get orePresenzaEsperienza => PctoData._parseHours(orePresenzaEsperienzaRaw);


  Esperienza({
    required this.nomePosto,
    required this.oreEsperienzaRaw,
    required this.orePresenzaEsperienzaRaw,
  });

  @override
  String toString() {
    return 'Nome Posto: $nomePosto, Ore Esperienza: $oreEsperienzaRaw (${oreEsperienza}h), Ore Presenza: $orePresenzaEsperienzaRaw (${orePresenzaEsperienza}h)';
  }
}
// --- FINE MODELLI ---


// NUOVA VERSIONE DELLA FUNZIONE DI PARSING
// NUOVA VERSIONE DELLA FUNZIONE DI PARSING - UNIVERSALE
// VERSIONE FINALE E CORRETTA - SENZA SELETTORI NON SUPPORTATI
PctoData? parsePctoHtmlIndependent(String htmlContent) {
  try {
    var document = parse(htmlContent);

    String orePrevisteStr = 'N/A';
    String orePresenzeTotaliStr = 'N/A';

    // --- CORREZIONE: Estrarre Ore Previste e Ore Presenze Totali ---
    // Il selettore ':has' non è supportato. Dobbiamo farlo manualmente.
    Element? summaryRow;
    // 1. Troviamo tutte le righe della tabella.
    final allRows = document.querySelectorAll('table.ele-prog tr');
    // 2. Iteriamo per trovare quella che contiene il testo desiderato.
    for (var row in allRows) {
      if (row.text.contains('Ore totali previste')) {
        summaryRow = row;
        break; // Trovata, usciamo dal ciclo.
      }
    }

    if (summaryRow != null) {
      // La logica interna per trovare i dati una volta trovata la riga è corretta.
      orePrevisteStr = summaryRow.querySelector('p.font_size_16')?.text.trim() ?? 'N/A';
      orePresenzeTotaliStr = summaryRow.querySelector('p.font_size_14.greentext')?.text.trim() ?? 'N/A';
    }

    // --- Estrarre le Esperienze (Questa parte era già corretta) ---
    List<Esperienza> esperienzeList = [];
    List<Element> righeEsperienze = document.querySelectorAll('table.ele-prog tbody tr[id]');

    for (var riga in righeEsperienze) {
      if (riga.id == 'placeholder_row') continue;

      String nomePosto = riga.querySelector('a p strong')?.text.trim() ?? 'N/A';
      if (nomePosto == 'N/A') {
        nomePosto = riga.querySelector('p.opensans_condensed strong')?.text.trim() ?? 'N/A';
      }

      String oreEsperienza = riga.querySelector('div[class*="curriculum_col_view"] span[class*="font_size_20"]')?.text.trim() ?? 'N/A';

      String orePresenzaEsperienza = 'N/A';

      // 1° TENTATIVO: Cerca il div di presenza VISIBILE.
      var presenceDivVisible = riga.querySelector('div[style*="display: ;"] div[style*="rgba(50, 205, 0"] p');
      if (presenceDivVisible != null && presenceDivVisible.text.trim().isNotEmpty) {
        orePresenzaEsperienza = presenceDivVisible.text.trim();
      }

      // 2° TENTATIVO: Se fallisce, cerca il div ANCHE SE NASCOSTO.
      if (orePresenzaEsperienza == 'N/A') {
        var presenceDivHidden = riga.querySelector('div[style*="display: none"] div[style*="rgba(50, 205, 0"] p');
        if (presenceDivHidden != null && presenceDivHidden.text.trim().isNotEmpty) {
          orePresenzaEsperienza = presenceDivHidden.text.trim();
        }
      }

      // 3° TENTATIVO (Fallback Logico): Se i div sono vuoti o assenti.
      if (orePresenzaEsperienza == 'N/A' && PctoData._parseHours(oreEsperienza) > 0) {
        var annoScolasticoHeader = riga.previousElementSibling;
        if (annoScolasticoHeader != null && annoScolasticoHeader.text.contains('20')) {
          String oreAnnoTesto = annoScolasticoHeader.querySelector('span.greentext')?.text.trim() ?? '';
          if (oreAnnoTesto.isNotEmpty && PctoData._parseHours(oreEsperienza) == PctoData._parseHours(oreAnnoTesto)) {
            orePresenzaEsperienza = oreAnnoTesto;
          }
        }
      }

      // 4° TENTATIVO (Pulizia Finale): Se ancora non trovato, assegna 0.
      if (orePresenzaEsperienza == 'N/A') {
        orePresenzaEsperienza = '0h0m';
      }

      if (nomePosto != 'N/A') {
        esperienzeList.add(Esperienza(
          nomePosto: nomePosto,
          oreEsperienzaRaw: oreEsperienza,
          orePresenzaEsperienzaRaw: orePresenzaEsperienza,
        ));
      }
    }

    return PctoData(
      orePrevisteRaw: orePrevisteStr,
      orePresenzeTotaliRaw: orePresenzeTotaliStr,
      esperienze: esperienzeList,
    );
  } catch (e, stacktrace) {
    print('Errore durante il parsing dell\'HTML: $e');
    print('Stacktrace: $stacktrace');
    return null;
  }
}

