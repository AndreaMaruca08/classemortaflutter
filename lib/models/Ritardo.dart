import 'SchoolEvent.dart';
import 'enums/EventType.dart';
class Ritardo extends SchoolEvent {
  final String date;
  final String time;

  Ritardo({
    required super.author,
    required super.insertionDate,
    required super.motivation,
    required super.status,
    required this.date,
    required this.time,
  }) : super(type: EventType.RITARDO);

  @override
  String toString() {
    return '${super.toString()}, Date: $date, Time: $time';
  }
}