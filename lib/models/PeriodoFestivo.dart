/*
     "dayOfWeek": 6,
            "dayStatus": "SD"
        },
        {
            "dayDate": "2026-02-07",
            "dayOfWeek": 7,
            "dayStatus": "NW"
        },
        {
            "dayDate": "2026-02-08",
            "dayOfWeek": 1,
            "dayStatus": "NW"
        },
        {
            "dayDate": "2026-02-09",
            "dayOfWeek": 2,
            "dayStatus": "SD"
        },
        {
            "dayDate": "2026-02-10",
            "dayOfWeek": 3,
            "dayStatus": "SD"
        },
        {
            "dayDate": "2026-02-11",
            "dayOfWeek": 4,
            "dayStatus": "SD"
        },
        {
            "dayDate": "2026-02-12",
            "dayOfWeek": 5,
            "dayStatus": "SD"
        },
        {
            "dayDate": "2026-02-13",
            "dayOfWeek": 6,
            "dayStatus": "SD"
        },
        {
            "dayDate": "2026-02-14",
            "dayOfWeek": 7,
            "dayStatus": "NW"
        },
        {
            "dayDate": "2026-02-15",
            "dayOfWeek": 1,
            "dayStatus": "NW"
        },
        {
            "dayDate": "2026-02-16",
            "dayOfWeek": 2,
            "dayStatus": "HD"
        },
        {
            "dayDate": "2026-02-17",
            "dayOfWeek": 3,
            "dayStatus": "HD"
        },

        SD = school day
        NW = not working day
        HD = holiday day

 */
class PeriodoFestivo{
  DateTime inizio;
  DateTime fine;

  PeriodoFestivo({
    required this.inizio,
    required this.fine
  });

  static List<PeriodoFestivo>  fromJson(Map<String, dynamic> json){

    List<dynamic> daysDynamic = json["calendar"];
    List<Map<String, dynamic>> days = daysDynamic.map((e) => e as Map<String, dynamic>).toList();

    List<PeriodoFestivo> periodi = [];
    DateTime? inizioPeriodo;

    for(Map<String, dynamic> day in days){
      String dayStatus = day["dayStatus"];

      if(dayStatus == "NW" && DateTime.parse(day["dayDate"]).weekday > 5){
        continue;
      }

      DateTime dayDate = DateTime.parse(day["dayDate"]);

      if(dayStatus != "SD"){
        inizioPeriodo ??= dayDate;
      } else {
        if(inizioPeriodo != null){
          // Termina il periodo precedente
          DateTime finePeriodo = days[days.indexOf(day)-1]["dayDate"] != null ? DateTime.parse(days[days.indexOf(day)-1]["dayDate"]) : dayDate;
          periodi.add(PeriodoFestivo(inizio: inizioPeriodo, fine: finePeriodo));
          inizioPeriodo = null;
        }
      }
    }
    // Se l'ultimo periodo non è stato chiuso (es. finisce con giorni non SD)
    if(inizioPeriodo != null && days.isNotEmpty){
      periodi.add(PeriodoFestivo(inizio: inizioPeriodo, fine: DateTime.parse(days.last["dayDate"])));
    }
    return periodi;
  }
}