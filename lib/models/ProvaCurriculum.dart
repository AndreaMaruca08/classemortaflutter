import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class PctoData {
  final String orePreviste;
  final String orePresenzeTotali;
  final List<Esperienza> esperienze;

  PctoData({
    required this.orePreviste,
    required this.orePresenzeTotali,
    required this.esperienze,
  });

  @override
  String toString() {
    return 'Ore Previste: $orePreviste\nOre Presenze Totali: $orePresenzeTotali\nEsperienze: ${esperienze.join("\n  ")}';
  }
}

class Esperienza {
  final String nomePosto;
  final String oreEsperienza;
  final String orePresenzaEsperienza;
  // Add other fields you might need, like dates, tipologia, progetto etc.

  Esperienza({
    required this.nomePosto,
    required this.oreEsperienza,
    required this.orePresenzaEsperienza,
  });

  @override
  String toString() {
    return 'Nome Posto: $nomePosto, Ore Esperienza: $oreEsperienza, Ore Presenza: $orePresenzaEsperienza';
  }
}

PctoData? parsePctoHtml(String htmlContent) {
  try {
    var document = parse(htmlContent);

    // --- Estrarre Ore Previste (112) ---
    // This targets the first <p> with class "open_sans_extrabold_italic darkgraytext font_size_16 text_align_center"
    Element? orePrevisteElement = document.querySelector(
        'tr[height="60"] td p.open_sans_extrabold_italic.darkgraytext.font_size_16.text_align_center');
    String orePreviste = orePrevisteElement?.text.trim() ?? 'N/A';

    // --- Estrarre Ore Presenze Totali (116h 0m) ---
    // This targets the <p> with class "open_sans_extrabold_italic greentext font_size_14 text_align_center"
    Element? orePresenzeTotaliElement = document.querySelector(
        'tr[height="60"] td p.open_sans_extrabold_italic.greentext.font_size_14.text_align_center');
    String orePresenzeTotali =
        orePresenzeTotaliElement?.text.trim() ?? 'N/A';

    // --- Estrarre le Esperienze ---
    List<Esperienza> esperienzeList = [];
    // Each experience is in a <tr> with an id (e.g., id="2315422") inside tbody of table.ele-prog
    List<Element> righeEsperienze =
    document.querySelectorAll('table.ele-prog tbody tr[id]');

    for (var riga in righeEsperienze) {
      // Nome del posto
      // Targets the <strong> inside <p class="opensans_condensed font_size_10 darkgraytext">
      Element? nomePostoElement = riga.querySelector(
          'td div.container div p.opensans_condensed.font_size_10.darkgraytext strong');
      String nomePosto = nomePostoElement?.text.trim() ?? 'N/A';

      // Ore dell'esperienza (e.g., "100")
      // Targets <span class="open_sans_extrabold_italic font_size_20 whitetext align_center">
      Element? oreEsperienzaElement = riga.querySelector(
          'div.curriculum_col_view span.open_sans_extrabold_italic.font_size_20.whitetext.align_center');
      String oreEsperienza = oreEsperienzaElement?.text.trim() ?? 'N/A';

      // Ore presenza specifica dell'esperienza (e.g., "104h0m")
      // Targets the first <p> inside a div with specific style attribute for presence
      Element? orePresenzaEsperienzaElement = riga.querySelector(
          'td div.container div[style*="background-color: rgba(50, 205, 0, 0.5)"] p.open_sans_extrabold_italic.font_size_10.whitetext');
      String orePresenzaEsperienza =
          orePresenzaEsperienzaElement?.text.trim() ?? 'N/A';
      // If the above is not found (because it's display:none for the second entry), try a fallback or handle as "N/A"
      // For the second entry, it's explicitly set to display:none, so it might not be parseable if you only look for visible elements
      // The current selector should get it even if display:none, as it's still in the DOM.

      if (nomePosto != 'N/A') { // Basic check to ensure we have a valid experience row
        esperienzeList.add(Esperienza(
          nomePosto: nomePosto,
          oreEsperienza: oreEsperienza,
          orePresenzaEsperienza: orePresenzaEsperienza,
        ));
      }
    }

    return PctoData(
      orePreviste: orePreviste,
      orePresenzeTotali: orePresenzeTotali,
      esperienze: esperienzeList,
    );
  } catch (e) {
    print('Error parsing HTML: $e');
    return null;
  }
}