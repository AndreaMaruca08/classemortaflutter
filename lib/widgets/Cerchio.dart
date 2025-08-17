import 'dart:math' as math; // Per pi
import 'package:flutter/material.dart';

class CircleProgressPainter extends CustomPainter {
  final double progress; // Valore da 0.0 a 1.0
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  CircleProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calcola il centro e il raggio del cerchio
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width / 2, size.height / 2) - strokeWidth / 2;

    // Paint per lo sfondo del cerchio (il bordo "vuoto")
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke // Disegna solo il bordo
      ..strokeCap = StrokeCap.round; // Estremità del tratto arrotondate

    // Disegna il cerchio di sfondo completo
    canvas.drawCircle(center, radius, backgroundPaint);

    // Paint per la parte di progresso del cerchio
    final Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke // Disegna solo il bordo
      ..strokeCap = StrokeCap.round; // Estremità del tratto arrotondate

    // Calcola l'angolo di sweep per il progresso
    // 2 * pi è un cerchio completo (360 gradi)
    final double sweepAngle = 2 * math.pi * progress;

    // Disegna l'arco di progresso
    // -pi / 2 è l'angolo di partenza per iniziare dalla parte superiore del cerchio
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Angolo di partenza (in alto)
      sweepAngle,    // Angolo di sweep (quanto del cerchio disegnare)
      false,         // useCenter: false (non disegnare linee dal centro all'arco)
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}

class CircularProgressBar extends StatelessWidget {
  final double currentValue;
  final double maxValue;
  final double size; // Dimensione del widget (larghezza e altezza)
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final Widget? child; // Widget opzionale da mostrare al centro

  const CircularProgressBar({
    super.key,
    required this.currentValue,
    required this.maxValue,
    this.size = 100.0,
    this.strokeWidth = 10.0,
    this.backgroundColor = Colors.grey,
    this.child,  this.progressColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    // Calcola il progresso normalizzato da 0.0 a 1.0
    final double progress = (currentValue / maxValue).clamp(0.0, 1.0);

    final Color coloreEffettivo = currentValue >= 6 ?  Colors.green : currentValue < 5 ? Colors.red : Colors.yellow;
    final Color coloreSfondo = currentValue >= 6 ?  Colors.green[100]! : currentValue < 5 ? Colors.red[100]! : Colors.yellow[100]!;
    return SizedBox(
      width: size,
      height: size,
      child: Stack( // Usa Stack per sovrapporre il CustomPaint e il child (opzionale)
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size), // Assicura che CustomPaint abbia la dimensione corretta
            painter: CircleProgressPainter(
              progress: progress,
              strokeWidth: strokeWidth,
              backgroundColor: coloreSfondo,
              progressColor: coloreEffettivo,
            ),
          ),
          if (child != null) child!, // Mostra il child se fornito
        ],
      ),
    );
  }
}

