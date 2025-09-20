import 'enums/Operation.dart';

class RichiestaGiustifica{
  Ope ope;
  int tipo_giustifica;
  String causale;
  String inizio_assenza;
  String fine_assenza;
  String motivazione_assenza;
  String giorno_entrata_uscita;
  String ora_entrata_uscita;
  String motivazione_entrata_uscita;
  String accompagnatore;

  RichiestaGiustifica({
    required this.ope,
    required this.tipo_giustifica,
    required this.causale,
    required this.inizio_assenza,
    required this.fine_assenza,
    required this.motivazione_assenza,
    required this.giorno_entrata_uscita,
    required this.ora_entrata_uscita,
    required this.motivazione_entrata_uscita,
    required this.accompagnatore,
  });



}