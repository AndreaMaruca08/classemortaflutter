import 'SchoolEvent.dart';
import 'enums/EventType.dart';

class Absence extends SchoolEvent {
  final String startDate;
  final String endDate;

  Absence({
    required super.author,
    required super.insertionDate,
    required super.motivation,
    required super.status,
    required this.startDate,
    required this.endDate,
  }) : super(type: EventType.ASSENZA);

  @override
  String toString() {
    return '${super.toString()}, StartDate: $startDate, EndDate: $endDate';
  }
}