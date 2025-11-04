import 'package:flutter/material.dart';
import '../models/Achievment.dart';
import '../models/enums/AchievementRarity.dart';

class Achievmentpage extends StatelessWidget {
  final List<Achievment> achievments;

  const Achievmentpage({
    super.key,
    required this.achievments,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final List<Achievment> negAchievments = achievments.where((element) => element.reached && !element.positivo).toList();
    final List<Achievment> posAchievments = achievments.where((element) => element.reached && element.positivo).toList();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Trofei'),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Allinea i titoli a sinistra
                children: [
                  const Text("Scritta rossa = non raggiunto, verde = raggiunto",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text("Sfondo verde = positivo, rosso = negativo",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("\nArancione = Bronzo - ottenuti: ${achievments.where((elemnt) => elemnt.rarity == AchievementRarity.BRONZO && elemnt.reached).length}\nGrigio chiaro = argento - ottenuti: ${achievments.where((elemnt) => elemnt.rarity == AchievementRarity.ARGENTO && elemnt.reached).length}\nGiallo = Oro - ottenuti: ${achievments.where((elemnt) => elemnt.rarity == AchievementRarity.ORO && elemnt.reached).length}\nGrigio scuro = Platino - ottenuti: ${achievments.where((elemnt) => elemnt.rarity == AchievementRarity.PLATINO && elemnt.reached).length}\nBlu = Legendario - ottenuti: ${achievments.where((elemnt) => elemnt.rarity == AchievementRarity.LEGGENDARIO && elemnt.reached).length}",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Trofei positivi guadagnati - ${posAchievments.length}",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (posAchievments.isEmpty)
                    const Center(
                      child: Text(
                        "Nessun trofeo positivo",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (posAchievments.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: posAchievments.map((achievment) => displayAchievement(context, achievment, screenSize.width)).toList(),
                    ),
                  const SizedBox(height: 10),
                  Text("Trofei negativi guadagnati - ${negAchievments.length}",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if(negAchievments.isEmpty)
                    const Center(child: Text("Nessun trofeo negativo",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),),
                  if(negAchievments.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: negAchievments.map((achievment) {
                        return displayAchievement(context, achievment, screenSize.width);
                      }).toList(),
                    ),
                  const SizedBox(height: 10,),
                  ListView.builder(itemCount: achievments.length, physics: NeverScrollableScrollPhysics(), shrinkWrap: true, itemBuilder: (context, index) {
                    return buildAchievment(achievments[index], screenSize.width);
                  })
                ],

              )
          ),
        )
    );
  }
  Widget buildAchievment(Achievment achievment, double screenSize) {
    double width = screenSize * 0.90;
    return Center(
      child: Container(
        // 3. Applica la larghezza al Container interno
        width: width,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          // Usa Color.fromRGBO per specificare i colori scuri personalizzati
          color: achievment.positivo
              ? achievment.reached ? const Color.fromRGBO(0, 60, 25, 1) : const Color.fromRGBO(0, 40, 25, 1)  // Verde molto scuro
              : achievment.reached ? const Color.fromRGBO(70, 15, 0, 1) : const Color.fromRGBO(50, 15, 0, 1), // Rosso molto scuro
          borderRadius: BorderRadius.all(Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(250, 250, 250, 0.2),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(2, 2),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(60)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(250, 250, 250, 0.2),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: achievment.display,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(achievment.title, style: TextStyle(
                      color: achievment.reached ? Colors.green : Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
                  Text(achievment.description,
                      style: TextStyle(color: Colors.white, fontSize: 15))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget displayAchievement(BuildContext context, Achievment achievment, double screenSize){
    double width = screenSize * 0.29;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AchievementDetailPage(achievement: achievment)),
        );
      },
      child: Container(
        width: width,
        height: width,
        // Rimuovo il margin per far gestire lo spazio a Wrap, come suggerito prima
        // margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: achievment.positivo
              ? const Color.fromRGBO(0, 40, 25, 1)
              : const Color.fromRGBO(50, 15, 0, 1),
          borderRadius: BorderRadius.all(Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(250, 250, 250, 0.2),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 50, color: getColorByRarity(achievment.rarity),),
            const SizedBox(height: 5),
            SizedBox(
              height: 35,
              child: Text(
                achievment.title,
                textAlign: TextAlign.center,
                // Limita il testo a 2 righe per evitare overflow
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: achievment.positivo ? Colors.green : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Color getColorByRarity(AchievementRarity rarity) {
    return switch(rarity) {
      AchievementRarity.ARGENTO => Colors.grey[500]!,
      AchievementRarity.BRONZO => Colors.orange[900]!,
      AchievementRarity.ORO => Colors.yellow,
      AchievementRarity.PLATINO => Colors.blueGrey[800]!,
      AchievementRarity.LEGGENDARIO => Colors.blue,
    };
  }
}

class AchievementDetailPage extends StatelessWidget {
  final Achievment achievement;

  const AchievementDetailPage({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(achievement.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Icon(
                Icons.emoji_events,
                size: 100,
                color: Achievmentpage(achievments: []).getColorByRarity(achievement.rarity),
              ),
              const SizedBox(height: 20),
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: achievement.reached ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
