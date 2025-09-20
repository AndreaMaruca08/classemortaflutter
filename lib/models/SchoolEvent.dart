import 'enums/EventType.dart';
import 'enums/JustificationStatus.dart';

class SchoolEvent {
  final String author;
  final String insertionDate;
  final String motivation;
  final JustificationStatus status;
  final EventType type;

  SchoolEvent({
    required this.author,
    required this.insertionDate,
    required this.motivation,
    required this.status,
    required this.type,
  });

}
