import 'package:classemorta/pages/detail/DettagliVoto.dart';
import 'package:classemorta/widgets/Cerchio.dart';
import 'package:flutter/material.dart';
import '../models/Voto.dart';

class VotoSingolo extends StatefulWidget {
  final Voto voto;
  final Voto? prec;
  final double fontSize;
  final double grandezza;
  final int ms;

  const VotoSingolo({
    super.key,
    required this.voto,
    required this.fontSize,
    this.prec,
    required this.grandezza,
    required this.ms,
  });

  @override
  State<VotoSingolo> createState() => _VotoSingoloState();
}

class _VotoSingoloState extends State<VotoSingolo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _ms;


  @override
  void initState() {
    super.initState();
    _ms = widget.ms;
    _controller = AnimationController(
      duration: Duration(milliseconds: _ms),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.voto.voto).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Dettaglivoto(voto: widget.voto, prec: widget.prec, ms: _ms,)),
          );
        },
        splashColor: widget.voto.voto >= 6
            ? Colors.green
            : widget.voto.voto >= 5
            ? Colors.yellow[700]
            : Colors.red,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(widget.grandezza / 2),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CircularProgressBar(
              currentValue: _animation.value,
              maxValue: 10,
              size: widget.grandezza,
              child: child,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${widget.voto.tipo.contains("media") ? "${widget.voto.codiceMateria} " : ""} ${widget.voto.displayValue}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: !widget.voto.tipo.contains("Scritto") &&
                        !widget.voto.tipo.contains("Orale") &&
                        !widget.voto.tipo.contains("Pratico")
                        ? widget.fontSize
                        : widget.fontSize + 5,
                    shadows: const <Shadow>[
                      Shadow(
                        offset: Offset(1.0, 2.0),
                        blurRadius: 3.0,
                        color: Colors.black,
                      ),
                    ]),
              ),
              const SizedBox(
                width: 5,
              ),
              if (widget.prec != null)
                Icon(
                  widget.voto.voto > (widget.prec?.voto ?? 0)
                      ? Icons.trending_up
                      : widget.voto.voto == (widget.prec?.voto ?? 0)
                      ? Icons.trending_neutral_rounded
                      : Icons.trending_down,
                  size: 20,
                  color: widget.voto.voto > (widget.prec?.voto ?? 0)
                      ? Colors.green
                      : widget.voto.voto == (widget.prec?.voto ?? 0)
                      ? Colors.white
                      : Colors.red,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
