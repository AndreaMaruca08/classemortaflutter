import 'package:ClasseMorta/models/Ritardo.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

import '../models/Absence.dart';
import '../models/SchoolEvent.dart';
import '../models/Uscita.dart';
import '../models/enums/EventType.dart';
import '../models/enums/JustificationStatus.dart';


class HtmlParserService {
  List<SchoolEvent> parseEvents(String htmlContent) {
    final document = parse(htmlContent);
    final List<SchoolEvent> events = [];

    final eventRows = document.querySelectorAll('table#data_table tr[height="100"]');

    for (final row in eventRows) {
      try {
        final author = _extractText(row.querySelector('p.open_sans_semibold.font_size_10.darkgraytext'));
        final insertionDate = _extractText(row.querySelectorAll('p.open_sans_semibold.font_size_10.graytext').last);

        final descriptionDiv = row.querySelector('div.open_sans.font_size_11.graytext');
        final descriptionText = _extractText(descriptionDiv).toLowerCase();
        final motivation = _extractText(descriptionDiv?.querySelector('span[id\$="_motivazione"]'));

        final status = _determineStatus(row);
        final eventType = eventTypeFromString(descriptionText);

        SchoolEvent? currentEvent;

        if (eventType == EventType.ASSENZA) {
          currentEvent = _extractAbsenceDetails(
            descriptionText: descriptionText,
            author: author,
            insertionDate: insertionDate,
            motivation: motivation,
            status: status,
          );
        } else if (eventType == EventType.RITARDO) {
          currentEvent = _extractDelayDetails(
            descriptionText: descriptionText,
            author: author,
            insertionDate: insertionDate,
            motivation: motivation,
            status: status,
          );
        } else if (eventType == EventType.USCITA_ANTICIPATA) {
          currentEvent = _extractEarlyExitDetails(
            descriptionText: descriptionText,
            author: author,
            insertionDate: insertionDate,
            motivation: motivation,
            status: status,
          );
        }

        if (currentEvent != null) {
          events.add(currentEvent);
        } else if (eventType != EventType.unknown) {
          // Logga se un tipo di evento conosciuto non ha potuto essere parsato
          print('Impossibile parsare i dettagli per un evento di tipo $eventType: $descriptionText');
        }

      } catch (e, s) {
        print('Errore durante il parsing di una riga evento: $e');
        print(s);
      }
    }
    return events;
  }

  String _extractText(dom.Element? element) {
    return element?.text.trim() ?? 'N/D';
  }

  JustificationStatus _determineStatus(dom.Element row) {
    if (row.querySelector('div.modifica_giustifica') != null) {
      return JustificationStatus.pendingApproval;
    } else if (row.querySelector('div.open_sans.font_size_10.greentext') != null) {
      return JustificationStatus.approved;
    }
    return JustificationStatus.unknown;
  }

  Absence? _extractAbsenceDetails({
    required String descriptionText,
    required String author,
    required String insertionDate,
    required String motivation,
    required JustificationStatus status,
  }) {
    final RegExp regex = RegExp(r"dal\s*(.*?)\s*al\s*(.*?)\s*per");
    final match = regex.firstMatch(descriptionText);
    if (match != null && match.groupCount >= 2) {
      final startDate = match.group(1)!.trim();
      final endDate = match.group(2)!.trim();
      return Absence(
        author: author,
        insertionDate: insertionDate,
        motivation: motivation,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
    }
    return null;
  }

  Ritardo? _extractDelayDetails({
    required String descriptionText,
    required String author,
    required String insertionDate,
    required String motivation,
    required JustificationStatus status,
  }) {
    final RegExp regex = RegExp(r"alle ore\s*(\d{2}:\d{2})\s*di\s*(.*?)\s*(?:per|&nbsp;accompagnatore)");
    final match = regex.firstMatch(descriptionText);
    if (match != null && match.groupCount >= 2) {
      final time = match.group(1)!.trim();
      final date = match.group(2)!.trim().replaceAll('</br>', '').trim();
      return Ritardo(
        author: author,
        insertionDate: insertionDate,
        motivation: motivation,
        status: status,
        date: date,
        time: time,
      );
    }
    return null;
  }

  EarlyExit? _extractEarlyExitDetails({
    required String descriptionText,
    required String author,
    required String insertionDate,
    required String motivation,
    required JustificationStatus status,
  }) {
    final RegExp regexDateTime = RegExp(r"alle ore\s*(\d{2}:\d{2})\s*di\s*(.*?)\s*(?:per|&nbsp;accompagnatore)");
    final matchDateTime = regexDateTime.firstMatch(descriptionText);

    if (matchDateTime != null && matchDateTime.groupCount >= 2) {
      final time = matchDateTime.group(1)!.trim();
      final date = matchDateTime.group(2)!.trim().replaceAll('</br>', '').trim();
      final companion = _extractCompanion(descriptionText);

      return EarlyExit(
        author: author,
        insertionDate: insertionDate,
        motivation: motivation,
        status: status,
        date: date,
        time: time,
        companion: companion,
      );
    }
    return null;
  }

  String? _extractCompanion(String text) {
    final RegExp regex = RegExp(r"accompagnatore:\s*<b>\s*(.*?)\s*</b>");
    final match = regex.firstMatch(text.toLowerCase()); // .toLowerCase() per matchare "nessuno" in modo case-insensitive
    if (match != null && match.groupCount >= 1) {
      final companionText = match.group(1)!.trim();
      return companionText == 'nessuno' ? null : companionText;
    }
    return null;
  }

  

}
