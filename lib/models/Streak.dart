
import 'package:flutter/material.dart';

import 'Voto.dart';

class Streak{
  int votiBuoni;
  bool inStreak;

  Streak({
    this.votiBuoni = 0,
    this.inStreak = false,
  });

  Color getStreakColor() {
    if(inStreak){
      if (votiBuoni >= 10) {
        return Colors.red[900]!;
      } else if(votiBuoni >= 5){
        return Colors.orange[900]!;
      }
      else{
        return Colors.orange[300]!;
      }
    }
    else{
      return Colors.grey;
    }
  }

  bool isGoat(List<Voto> votiIniziali){
    return votiIniziali.length == votiBuoni;
  }


  Streak getStreak(List<Voto> voti){
    int streak = 0;
    bool inStreak = false;
    for (Voto voto in voti) {
      if (voto.cancellato) {
        continue;
      }
      if (voto.voto >= 6) {
        streak++;
      } else {
        streak = 0;
      }
    }

    if(streak >= 2) {
      inStreak = true;
    }
    return Streak(
        votiBuoni: streak,
        inStreak: inStreak
    );
  }

}