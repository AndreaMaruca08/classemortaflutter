import 'Voto.dart';

class Materia{
  String codiceMateria;
  String nomeInteroMateria;
  String dataUltimoVoto = "";
  String nomeProf;
  List<Voto> voti;

  Materia({
    required this.codiceMateria,
    required this.nomeInteroMateria,
    required this.nomeProf,
    required this.voti,
  });

  static List<double> ratio(List<Voto> votiParam) { // Rendi votiParam opzionale

    double positivi = 0;
    double negativi = 0;
    double mid = 0;
    for (Voto voto in votiParam) {
      if (voto.cancellato) {
        continue;
      }

      if (voto.voto >= 6) {
        positivi++;
      } else if (voto.voto >= 5){
        mid++;
      } else{
        negativi++;
      }
    }
    double percPositivi = (positivi / votiParam.length) * 100;
    double percNegativi = (negativi / votiParam.length) * 100;
    double percMid = (mid / votiParam.length) * 100;

    return [positivi, negativi, mid, percPositivi, percNegativi, percMid];
  }
}
