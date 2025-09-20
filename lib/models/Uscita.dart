import 'SchoolEvent.dart';
import 'enums/EventType.dart';

class EarlyExit extends SchoolEvent {
  final String date;
  final String time;
  final String? companion;

  EarlyExit({
    required super.author,
    required super.insertionDate,
    required super.motivation,
    required super.status,
    required this.date,
    required this.time,
    this.companion,
  }) : super(type: EventType.USCITA_ANTICIPATA);

  @override
  String toString() {
    return '${super.toString()}, Date: $date, Time: $time, Companion: ${companion ?? "Nessuno"}';
  }
}
