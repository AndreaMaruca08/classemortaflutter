import 'package:classemorta/models/enums/AchievementRarity.dart';
import 'package:flutter/material.dart';

import 'Assenza.dart';
import 'Nota.dart';
import 'Voto.dart';
import 'enums/AchievmentType.dart';

class Achievment{
  double valueToReach;
  int count;
  bool reached;
  Icon display;
  String title;
  String description;
  String materia;
  bool positivo;
  AchievmenType type;
  AchievementRarity rarity;

  Achievment({
    required this.valueToReach,
    required this.count,
    required this.reached,
    required this.display,
    required this.title,
    required this.description,
    required this.materia,
    required this.positivo,
    required this.type,
    required this.rarity
  });



  static List<Achievment> getAchievments(List<Nota> disc, List<Nota> annotazioni,List<Voto> grades, List<Assenza> assenze, List<Assenza> ritardi, List<Assenza> uscite){
    List<Achievment> achievments = [];
    for(Achievment x in allAchievments()){
      x.reached = isReached(x, disc, annotazioni, grades, assenze, ritardi, uscite);
      achievments.add(x);
    }

    return achievments;
  }

  static bool isReached(Achievment trofeo, List<Nota> disc,  List<Nota> annotazioni, List<Voto> grades, List<Assenza> assenze, List<Assenza> ritardi, List<Assenza> uscite){
    bool reached;
    switch(trofeo.type) {
      case AchievmenType.VOTI:
        reached = checkVoti(trofeo, grades);
        break;
      case AchievmenType.VOTI_NUMERO:
        reached = checkVotinumerati(trofeo, grades);
        break;
      case AchievmenType.ASSENZA:
        reached = checkEvento(trofeo, assenze);
        break;
      case AchievmenType.RITARDO:
        reached = checkEvento(trofeo, ritardi);
        break;
      case AchievmenType.USCITE:
        reached = checkEvento(trofeo, uscite);
        break;
      case AchievmenType.NOTA_DISCIPLINARE:
        reached = checkNote(trofeo, disc);
        break;
      case AchievmenType.ANNOTAZIONE:
        reached = checkNote(trofeo, annotazioni);
        break;
      case AchievmenType.VOTI_CONSECUTIVI:
        reached = checkVotiConsecutivi(trofeo, grades);
        break;
    }
    return reached;
  }


  static bool checkVoti(Achievment trofeo, List<Voto> voti){
      for(Voto voto in voti){
        if(trofeo.materia == "null") {
          if (voto.voto >= trofeo.valueToReach && trofeo.positivo) {
            return true;
          }else if (voto.voto < trofeo.valueToReach && !trofeo.positivo){
            return true;
          }
        }else if(voto.codiceMateria == trofeo.materia){
          if (voto.voto >= trofeo.valueToReach && trofeo.positivo) {
            return true;
          }else if (voto.voto < trofeo.valueToReach && !trofeo.positivo){
            return true;
          }
        }
      }
      return false;
  }

  static bool checkVotinumerati(Achievment trofeo, List<Voto> voti){
      int count = 0;
      for(Voto voto in voti){
        if(trofeo.materia == "null") {
          if (voto.voto >= trofeo.valueToReach && trofeo.positivo) {
            count++;
          }else if (voto.voto < trofeo.valueToReach && !trofeo.positivo){
            count++;
          }
        }else if(voto.codiceMateria == trofeo.materia){
          if (voto.voto >= trofeo.valueToReach && trofeo.positivo) {
            count++;
          }else if (voto.voto < trofeo.valueToReach && !trofeo.positivo){
            count++;
          }
        }
      }
      if(count >= trofeo.count) {
        return true;
      }
      return false;
    }

  static bool checkVotiConsecutivi(Achievment trofeo, List<Voto> voti) {
    int count = 0;
    List<Voto> votiDaControllare;

    if (trofeo.materia == "null") {
      votiDaControllare = voti;
    } else {
      votiDaControllare = voti.where((voto) => voto.codiceMateria == trofeo.materia).toList();
    }
    for (Voto voto in votiDaControllare) {
      bool condizioneSoddisfatta = false;

      if (trofeo.positivo) {
        condizioneSoddisfatta = (voto.voto >= trofeo.valueToReach);
      } else { // Trofeo negativo
        condizioneSoddisfatta = (voto.voto < trofeo.valueToReach);
      }

      if (condizioneSoddisfatta) {
        count++;
      } else {
        count = 0;
      }
      if (count == trofeo.count) {
        return true; // Obiettivo raggiunto!
      }
    }

    // Se il ciclo finisce senza aver raggiunto il count, l'obiettivo non è stato raggiunto
    return false;
  }


  static bool checkEvento(Achievment trofeo, List<Assenza> assenze){
    if(trofeo.positivo) {
      return trofeo.count >= assenze.length;
    }else{
      return trofeo.count < assenze.length;
    }
  }

  static bool checkNote(Achievment trofeo, List<Nota> disc){
    if(trofeo.positivo) {
      return trofeo.count >= disc.length;
    }else{
      if(trofeo.materia == "telefono") {
        bool nota = false;
        for(Nota x in disc){
          if(x.messaggio.toLowerCase() == "telefono" || x.messaggio.toLowerCase() == "cellulare"){
            nota = true;
          }
        }
        return nota;
      }else{
        return trofeo.count < disc.length;
      }
    }
  }

  static List<Achievment> allAchievments() {
    List<Achievment> achievments = [];
    double sizeIcon = 60;

    // Primo 10
    achievments.add(Achievment(
        valueToReach: 10,
        count: 1,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.ARGENTO), size: sizeIcon),
        title: "Numero Uno",
        description: "Ottieni il tuo primo 10 dell'anno",
        materia: "null",
        positivo: true,
        type: AchievmenType.VOTI,
        rarity: AchievementRarity.ARGENTO));

    achievments.add(Achievment(
        valueToReach: 6,
        count: 5,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.ARGENTO), size: sizeIcon),
        title: "Streak promettente",
        description: "Ottieni una streak di 5 almeno una volta",
        materia: "null",
        positivo: true,
        type: AchievmenType.VOTI_CONSECUTIVI,
        rarity: AchievementRarity.ARGENTO));

    achievments.add(Achievment(
        valueToReach: 6,
        count: 10,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.PLATINO), size: sizeIcon),
        title: "Streak miracolosa",
        description: "Ottieni una streak di 10 almeno una volta",
        materia: "null",
        positivo: true,
        type: AchievmenType.VOTI_CONSECUTIVI,
        rarity: AchievementRarity.PLATINO));

    achievments.add(Achievment(
        valueToReach: 6,
        count: 15,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.LEGGENDARIO), size: sizeIcon),
        title: "GOAT",
        description: "Ottieni una streak di 15 almeno una volta",
        materia: "null",
        positivo: true,
        type: AchievmenType.VOTI_CONSECUTIVI,
        rarity: AchievementRarity.LEGGENDARIO));

    achievments.add(Achievment(
        valueToReach: 6,
        count: 3,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.ARGENTO), size: sizeIcon),
        title: "GIT GUD",
        description: "Ottieni una streak negativa di 3 almeno una volta",
        materia: "null",
        positivo: false,
        type: AchievmenType.VOTI_CONSECUTIVI,
        rarity: AchievementRarity.ARGENTO));

    achievments.add(Achievment(
        valueToReach: 6,
        count: 5,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.LEGGENDARIO), size: sizeIcon),
        title: "Disastro",
        description: "Ottieni una streak negativa di 5 almeno una volta",
        materia: "null",
        positivo: false,
        type: AchievmenType.VOTI_CONSECUTIVI,
        rarity: AchievementRarity.LEGGENDARIO));

    achievments.add(Achievment(
        valueToReach: 4,
        count: 4,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.PLATINO), size: sizeIcon),
        title: "I Fantastici 4",
        description: "Ottieni in tutto l'anno almeno 4 volte 4",
        materia: "null",
        positivo: false,
        type: AchievmenType.VOTI_NUMERO,
        rarity: AchievementRarity.PLATINO));

    achievments.add(Achievment(
        valueToReach: 7,
        count: 7,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.PLATINO), size: sizeIcon),
        title: "I Fantastici 7",
        description: "Ottieni in tutto l'anno almeno 7 volte 7",
        materia: "null",
        positivo: true,
        type: AchievmenType.VOTI_NUMERO,
        rarity: AchievementRarity.PLATINO));

    achievments.add(Achievment(
        valueToReach: 7,
        count: 3,
        reached: false,
        display: Icon(Icons.shield_outlined, color: getColorByRarity(AchievementRarity.ARGENTO), size: sizeIcon),
        title: "Sopra la media",
        description: "Ottieni 3 voti superiori o uguali a 7 consecutivamente",
        materia: "null",
        positivo: true,
        type: AchievmenType.VOTI_CONSECUTIVI,
        rarity: AchievementRarity.ARGENTO));

    achievments.add(Achievment(
        valueToReach: 10,
        count: 1,
        reached: false,
        display: Icon(Icons.grass, color: getColorByRarity(AchievementRarity.ARGENTO), size: sizeIcon),
        title: "Programmatore",
        description: "Ottieni 10 di informatica",
        materia: "INF",
        positivo: true,
        type: AchievmenType.VOTI,
        rarity: AchievementRarity.ARGENTO));

    achievments.add(Achievment(
        valueToReach: 8,
        count: 3,
        reached: false,
        display: Icon(Icons.grass, color: getColorByRarity(AchievementRarity.ORO), size: sizeIcon),
        title: "Esci di casa",
        description: "Ottieni 3 volte di fila 8 o più di informatica",
        materia: "INF",
        positivo: true,
        type: AchievmenType.VOTI_CONSECUTIVI,
        rarity: AchievementRarity.ORO));

    achievments.add(Achievment(
        valueToReach: 10,
        count: 1,
        reached: false,
        display: Icon(Icons.book, color: getColorByRarity(AchievementRarity.ARGENTO), size: sizeIcon),
        title: "Dante Alighieri",
        description: "Ottieni 10 di italiano",
        materia: "ITA",
        positivo: true,
        type: AchievmenType.VOTI,
        rarity: AchievementRarity.ARGENTO));

    achievments.add(Achievment(
        valueToReach: 10,
        count: 1,
        reached: false,
        display: Icon(Icons.emoji_events, color: getColorByRarity(AchievementRarity.BRONZO), size: sizeIcon),
        title: "Usain Bolt",
        description: "Ottieni 10 di motoria",
        materia: "MOT",
        positivo: true,
        type: AchievmenType.VOTI,
        rarity: AchievementRarity.BRONZO));

    achievments.add(Achievment(
        valueToReach: 6,
        count: 1,
        reached: false,
        display: Icon(Icons.emoji_events, color: getColorByRarity(AchievementRarity.PLATINO), size: sizeIcon),
        title: "Alzati dal divano",
        description: "Ottieni un voto sotto il 6 di motoria",
        materia: "MOT",
        positivo: false,
        type: AchievmenType.VOTI,
        rarity: AchievementRarity.PLATINO));

    achievments.add(Achievment(
        valueToReach: 10,
        count: 1,
        reached: false,
        display: Icon(Icons.calculate, color:getColorByRarity(AchievementRarity.ARGENTO), size: sizeIcon),
        title: "Pitagora chi?",
        description: "Ottieni 10 di matematica",
        materia: "MAT",
        positivo: true,
        type: AchievmenType.VOTI,
        rarity: AchievementRarity.ARGENTO));

    achievments.add(Achievment(
        valueToReach: 8,
        count: 4,
        reached: false,
        display: Icon(Icons.calculate, color: getColorByRarity(AchievementRarity.PLATINO), size: sizeIcon),
        title: "MateGoat",
        description: "Ottieni 4 volte di fila 7 o più di matematica",
        materia: "MAT",
        positivo: true,
        type: AchievmenType.VOTI_CONSECUTIVI,
        rarity: AchievementRarity.PLATINO));

    achievments.add(Achievment(
        valueToReach: 10,
        count: 1,
        reached: false,
        display: Icon(Icons.language, color: getColorByRarity(AchievementRarity.ARGENTO), size: sizeIcon),
        title: "Nativo inglese",
        description: "Ottieni 10 di inglese",
        materia: "ING",
        positivo: true,
        type: AchievmenType.VOTI,
        rarity: AchievementRarity.ARGENTO));

    achievments.add(Achievment(
        valueToReach: 8,
        count: 1,
        reached: false,
        display: Icon(Icons.language, color: getColorByRarity(AchievementRarity.BRONZO), size: sizeIcon),
        title: "Pretty good",
        description: "Ottieni 8 di inglese",
        materia: "ING",
        positivo: true,
        type: AchievmenType.VOTI,
        rarity: AchievementRarity.BRONZO));

    achievments.add(Achievment(
        valueToReach: 7.5,
        count: 3,
        reached: false,
        display: Icon(Icons.language, color: getColorByRarity(AchievementRarity.ORO), size: sizeIcon),
        title: "Pretty GOD",
        description: "Ottieni 3 volte di fila 7,5 o più di inglese",
        materia: "ING",
        positivo: true,
        type: AchievmenType.VOTI_CONSECUTIVI,
        rarity: AchievementRarity.ORO));

    achievments.add(Achievment(
        valueToReach: 8,
        count: 1,
        reached: false,
        display: Icon(Icons.shield_outlined, color: getColorByRarity(AchievementRarity.BRONZO), size: sizeIcon),
        title: "Storico",
        description: "Ottieni 8 o più di storia",
        materia: "STO",
        positivo: true,
        type: AchievmenType.VOTI,
        rarity: AchievementRarity.BRONZO));

    achievments.add(Achievment(
        valueToReach: 10,
        count: 1,
        reached: false,
        display: Icon(Icons.history, color: getColorByRarity(AchievementRarity.ORO), size: sizeIcon),
        title: "Alberto Angela",
        description: "Ottieni 10 di storia",
        materia: "STO",
        positivo: true,
        type: AchievmenType.VOTI,
        rarity: AchievementRarity.ORO));

    achievments.add(Achievment(
        valueToReach: 6,
        count: 1,
        reached: false,
        display: Icon(Icons.shield_moon, color: getColorByRarity(AchievementRarity.ARGENTO), size: sizeIcon),
        title: "La prima",
        description: "Si spera non di molte               (1 insufficienza)",
        materia: "null",
        positivo: false,
        type: AchievmenType.VOTI,
        rarity: AchievementRarity.ARGENTO));

    achievments.add(Achievment(
        valueToReach: 0,
        count: 0,
        reached: false,
        display: Icon(Icons.gpp_good, color: getColorByRarity(AchievementRarity.ARGENTO), size: sizeIcon),
        title: "Studente Modello",
        description: "Non avere note disciplinari",
        materia: "null",
        positivo: true,
        type: AchievmenType.NOTA_DISCIPLINARE,
        rarity: AchievementRarity.ARGENTO));

    achievments.add(Achievment(
        valueToReach: 0,
        count: 1,
        reached: false,
        display: Icon(Icons.gpp_bad, color: getColorByRarity(AchievementRarity.BRONZO), size: sizeIcon),
        title: "Piccolo ribelle",
        description: "Una nota sola? Tutti iniziano da qualche parte.",
        materia: "null",
        positivo: false,
        type: AchievmenType.NOTA_DISCIPLINARE,
        rarity: AchievementRarity.BRONZO));

    achievments.add(Achievment(
        valueToReach: 0,
        count: 3,
        reached: false,
        display: Icon(Icons.gpp_bad, color: getColorByRarity(AchievementRarity.ORO), size: sizeIcon),
        title: "Genio Incompreso",
        description: "Forse non ti capiscono… o forse sì, e per questo ti scrivono. (3 o più note)",
        materia: "null",
        positivo: false,
        type: AchievmenType.NOTA_DISCIPLINARE,
        rarity: AchievementRarity.ORO));

    achievments.add(Achievment(
        valueToReach: 0,
        count: 10,
        reached: false,
        display: Icon(Icons.gpp_bad, color: getColorByRarity(AchievementRarity.LEGGENDARIO), size: sizeIcon),
        title: "Pericolo Pubblico",
        description: "Il tuo comportamento è materia di avviso ufficiale. (10 o più note)",
        materia: "null",
        positivo: false,
        type: AchievmenType.NOTA_DISCIPLINARE,
        rarity: AchievementRarity.LEGGENDARIO));

    achievments.add(Achievment(
        valueToReach: 0,
        count: 0,
        reached: false,
        display: Icon(Icons.gpp_good, color: getColorByRarity(AchievementRarity.PLATINO), size: sizeIcon),
        title: "Niente richiami",
        description: "Non avere annotazioni",
        positivo: true,
        materia: "null",
        type: AchievmenType.ANNOTAZIONE,
        rarity: AchievementRarity.PLATINO));

    achievments.add(Achievment(
        valueToReach: 0,
        count: 1,
        reached: false,
        display: Icon(Icons.gpp_bad, color: getColorByRarity(AchievementRarity.BRONZO), size: sizeIcon),
        title: "Traccia Leggera",
        description: "Una piccola macchia sul registro, ma sei stato notato. (1 annotazione)",
        materia: "null",
        positivo: false,
        type: AchievmenType.ANNOTAZIONE,
        rarity: AchievementRarity.BRONZO));

    achievments.add(Achievment(
        valueToReach: 0,
        count: 10,
        reached: false,
        display: Icon(Icons.gpp_bad, color: getColorByRarity(AchievementRarity.ARGENTO), size: sizeIcon),
        title: "Ape Fastidiosa",
        description: "Ronzando tra le regole, cominci a dare fastidio. (10 annotazione)",
        materia: "null",
        positivo: false,
        type: AchievmenType.ANNOTAZIONE,
        rarity: AchievementRarity.ARGENTO));

    // Mai un'assenza
    achievments.add(Achievment(
        valueToReach: 0, // L'obiettivo è avere 0 assenze
        count: 0,
        reached: false,
        display: Icon(Icons.event_available, color: getColorByRarity(AchievementRarity.PLATINO), size: sizeIcon),
        title: "Sempre Presente",
        description: "Non avere assenze",
        materia: "null",
        positivo: true,
        type: AchievmenType.ASSENZA,
        rarity: AchievementRarity.PLATINO));

    achievments.add(Achievment(
        valueToReach: 0,
        count: 7,
        reached: false,
        display: Icon(Icons.event_busy, color: getColorByRarity(AchievementRarity.ARGENTO), size: sizeIcon),
        title: "Colazione Lunga",
        description: "Ti sei fermato al bar… e poi direttamente a casa. (7 o più assenze)",
        materia: "null",
        positivo: false,
        type: AchievmenType.ASSENZA,
        rarity: AchievementRarity.ARGENTO));

    achievments.add(Achievment(
        valueToReach: 0,
        count: 20,
        reached: false,
        display: Icon(Icons.event_busy, color: getColorByRarity(AchievementRarity.BRONZO), size: sizeIcon),
        title: "Sospeso (Onorario)",
        description: "Non serve la preside: ti punisci da solo. (20 o più assenze)",
        materia: "null",
        positivo: false,
        type: AchievmenType.ASSENZA,
        rarity: AchievementRarity.LEGGENDARIO));

    // Spaccare il minuto
    achievments.add(Achievment(
        valueToReach: 0,
        count: 0,
        reached: false,
        display: Icon(Icons.alarm_on, color: getColorByRarity(AchievementRarity.ORO), size: sizeIcon),
        title: "Spaccare il Minuto",
        description: "Nessun ritardo fino ad ora",
        materia: "null",
        positivo: true,
        type: AchievmenType.RITARDO,
        rarity: AchievementRarity.ORO));

    achievments.add(Achievment(
        valueToReach: 0,
        count: 3,
        reached: false,
        display: Icon(Icons.alarm_off, color: getColorByRarity(AchievementRarity.ORO), size: sizeIcon),
        title: "Ritardatario",
        description: "Sei arrivato in ritardo più di 3 volte",
        materia: "null",
        positivo: false,
        type: AchievmenType.RITARDO,
        rarity: AchievementRarity.ORO));

    achievments.add(Achievment(
        valueToReach: 0,
        count: 10,
        reached: false,
        display: Icon(Icons.alarm_off, color: getColorByRarity(AchievementRarity.PLATINO), size: sizeIcon),
        title: "Ritardato",
        description: "Ormai è un'abitudine (oltre i 10 ritardi)",
        materia: "null",
        positivo: false,
        type: AchievmenType.RITARDO,
        rarity: AchievementRarity.PLATINO));

    // USCITE
    achievments.add(Achievment(
        valueToReach: 0,
        count: 1,
        reached: false,
        display: Icon(Icons.hourglass_bottom, color: getColorByRarity(AchievementRarity.PLATINO),  size: sizeIcon),
        title: "Fino alla Fine",
        description: "nessuna uscita anticipata fino ad ora",
        materia: "null",
        positivo: true,
        type: AchievmenType.USCITE,
        rarity: AchievementRarity.PLATINO));

    achievments.add(Achievment(
        valueToReach: 0,
        count: 5,
        reached: false,
        display: Icon(Icons.hourglass_disabled, color: getColorByRarity(AchievementRarity.BRONZO),  size: sizeIcon),
        title: "Fuga strategica",
        description: "Esci più di 5 volte in anticipo",
        materia: "null",
        positivo: false,
        type: AchievmenType.USCITE,
        rarity: AchievementRarity.BRONZO));

    achievments.add(Achievment(
        valueToReach: 0,
        count: 15,
        reached: false,
        display: Icon(Icons.hourglass_disabled, color: getColorByRarity(AchievementRarity.LEGGENDARIO),  size: sizeIcon),
        title: "Campione della Fuga",
        description: "Hai trasformato l’uscita anticipata in uno sport. (esci 15 volte)",
        materia: "null",
        positivo: false,
        type: AchievmenType.USCITE,
        rarity: AchievementRarity.LEGGENDARIO));

    achievments.add(Achievment(
        valueToReach: 0,
        count: 0,
        reached: false,
        title: "4K",
        description: "Beccato in 4k a usare il telefono",
        materia: "telefono",
        positivo: false,
        display: Icon(Icons.workspace_premium_sharp, color: getColorByRarity(AchievementRarity.ORO), size: sizeIcon),
        type: AchievmenType.NOTA_DISCIPLINARE,
        rarity: AchievementRarity.ORO));

    return achievments;
  }
  static Color getColorByRarity(AchievementRarity rarity) {
    return switch(rarity) {
      AchievementRarity.ARGENTO => Colors.grey[500]!,
      AchievementRarity.BRONZO => Colors.orange[900]!,
      AchievementRarity.ORO => Colors.yellow,
      AchievementRarity.PLATINO => Colors.blueGrey[800]!,
      AchievementRarity.LEGGENDARIO => Colors.blue,
    };
  }


}