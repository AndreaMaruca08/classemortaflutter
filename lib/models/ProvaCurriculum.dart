import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

// --- DATA MODELS (PctoData, Esperienza) - Assume these are the same as before ---
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
  // You might want to add:
  // final String tipologia;
  // final String progetto;
  // final String dataInizio;
  // final String dataFine;
  // final String annoScolastico;

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
// --- END OF DATA MODELS ---


PctoData? parsePctoHtmlIndependent(String htmlContent) {
  try {
    var document = parse(htmlContent);

    String orePrevisteStr = 'N/A';
    String orePresenzeTotaliStr = 'N/A';

    // --- Estrarre Ore Previste e Ore Presenze Totali ---
    // Try to find the row containing these based on some distinct features.
    // This row seems to have "Ore totali previste" and "presenze" texts.
    List<Element> potentialHeaderRows = document.querySelectorAll('table.ele-prog tbody tr');
    Element? summaryRow;

    for (var row in potentialHeaderRows) {
      final pElements = row.querySelectorAll('td p');
      bool foundOrePrevisteText = false;
      bool foundPresenzeText = false;
      for (var p in pElements) {
        String text = p.text.toLowerCase().trim();
        if (text.contains('ore totali previste')) {
          foundOrePrevisteText = true;
        }
        if (text == 'presenze') { // Exact match for "presenze"
          foundPresenzeText = true;
        }
      }
      if (foundOrePrevisteText && foundPresenzeText) {
        summaryRow = row;
        break;
      }
    }


    if (summaryRow != null) {
      // Once we have the summaryRow, find the specific <p> tags
      // This relies on the structure within that identified row.
      var pTagsInSummaryRow = summaryRow.querySelectorAll('p');
      if (pTagsInSummaryRow.length >= 2) { // Basic check
        // Ore Previste: First <p> inside a <td> that also contains "Ore totali previste"
        Element? orePrevisteCell = summaryRow.children.firstWhere(
                (cell) => cell.text.contains('Ore totali previste'),
            orElse: () => Element.tag('td')); // return dummy if not found
        orePrevisteStr = orePrevisteCell.querySelector('p:first-child')?.text.trim() ?? 'N/A';


        // Ore Presenze Totali: First <p> inside a <td> that also contains "presenze"
        Element? orePresenzeCell = summaryRow.children.firstWhere(
                (cell) => cell.text.contains('presenze') && cell.text.contains('h'), // ensure it's the hour value
            orElse: () => Element.tag('td'));
        orePresenzeTotaliStr = orePresenzeCell.querySelector('p:first-child')?.text.trim() ?? 'N/A';
      }
    }


    // --- Estrarre le Esperienze ---
    List<Esperienza> esperienzeList = [];
    // Each experience is in a <tr> with an id (e.g., id="2315422") inside tbody of table.ele-prog
    List<Element> righeEsperienze = document.querySelectorAll('table.ele-prog tbody tr[id]');

    for (var riga in righeEsperienze) {
      if (riga.id == 'placeholder_row') continue; // Skip placeholder

      // Nome del posto: Look for a <strong> tag that is likely the company name.
      // It's often within a <p> with class "opensans_condensed"
      Element? nomePostoElement = riga.querySelector('p[class*="opensans_condensed"] strong');
      if (nomePostoElement == null) {
        // Fallback: Sometimes it's just a <strong> under a general container for the description
        var descriptionContainer = riga.children.firstWhere(
                (td) => td.querySelectorAll('p[class*="font_size_12"][class*="darkgraytext"]').any((p) => p.text.toLowerCase().contains("tipologia:")),
            orElse: () => Element.tag('td')); // Dummy element
        nomePostoElement = descriptionContainer.querySelector('a p strong'); // if it's wrapped in an <a>
        if (nomePostoElement == null) {
          nomePostoElement = descriptionContainer.querySelector('p strong'); // more general
        }
      }
      String nomePosto = nomePostoElement?.text.trim() ?? 'N/A';


      // Ore dell'esperienza (e.g., "100 ore")
      // Looks for a span with large font, whitetext, and often a sibling <p> with "ore"
      Element? oreEsperienzaElement = riga.querySelector('div[class*="curriculum_col_view"] span[class*="font_size_20"]');
      String oreEsperienza = oreEsperienzaElement?.text.trim() ?? 'N/A';

      // Ore presenza specifica dell'esperienza (e.g., "104h0m")
      // This is tricky because its visibility changes. We target the structure.
      // Look for a <td> containing two divs, one for presence, one for absence,
      // typically with background colors.
      String orePresenzaEsperienza = 'N/A';
      List<Element> cellsInRow = riga.children;
      // Find the cell that likely contains presence/absence hours
      for (var cell in cellsInRow) {
        var presenceDiv = cell.querySelector('div[style*="rgba(50, 205, 0"] p[class*="font_size_10"]'); // Greenish background for presence
        if (presenceDiv != null) {
          orePresenzaEsperienza = presenceDiv.text.trim();
          if (orePresenzaEsperienza.isEmpty){ // If text is empty, it might be the hidden case
            // For hidden cases, the actual value might not be present or easily distinguishable if the <p> is empty.
            // We'll stick with what's visibly or structurally parsable.
            // If it's consistently empty in hidden sections, 'N/A' or an empty string is the best we can do without more info.
            orePresenzaEsperienza = '0h0m'; // Default to 0 if empty but div found
          }
          break;
        }
      }
      if (orePresenzaEsperienza.isEmpty && nomePosto != 'N/A' && nomePosto != 'CORSO SICUREZZA. FORMAZIONE BASE E SPECIFICA') {
        orePresenzaEsperienza = 'N/A'; // if truly not found for actual experiences
      } else if (orePresenzaEsperienza.isEmpty && (nomePosto == 'N/A' || nomePosto == 'CORSO SICUREZZA. FORMAZIONE BASE E SPECIFICA')){
        orePresenzaEsperienza = '0h0m'; // Default for courses where it's often hidden and means 0 effectively
      }


      if (nomePosto != 'N/A' || oreEsperienza != 'N/A') { // Add if we found at least some data
        esperienzeList.add(Esperienza(
          nomePosto: nomePosto,
          oreEsperienzaRaw: oreEsperienza,
          orePresenzaEsperienzaRaw: orePresenzaEsperienza.isNotEmpty ? orePresenzaEsperienza : '0h0m',
        ));
      }
    }

    return PctoData(
      orePrevisteRaw: orePrevisteStr,
      orePresenzeTotaliRaw: orePresenzeTotaliStr,
      esperienze: esperienzeList,
    );
  } catch (e, stacktrace) {
    print('Error parsing HTML: $e');
    print('Stacktrace: $stacktrace');
    return null;
  }
}
