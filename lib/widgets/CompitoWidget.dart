import 'package:classemorta/models/Info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoSingola extends StatefulWidget {
  final Info info;
  const InfoSingola({super.key, required this.info});

  @override
  State<InfoSingola> createState() => _InfoSingolaState();
}

class _InfoSingolaState extends State<InfoSingola> {
  bool _isDone = false;
  late String _storageKey;

  @override
  void initState() {
    super.initState();
    // Crea una chiave univoca basata sui dati dell'info
    _storageKey = "done_${widget.info.materia}_${widget.info.data}_${widget.info.descrizione.hashCode}";
    _loadDoneStatus();
  }

  Future<void> _loadDoneStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isDone = prefs.getBool(_storageKey) ?? false;
      });
    }
  }

  Future<void> _toggleDone(bool? value) async {
    if (value == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, value);
    if (mounted) {
      setState(() {
        _isDone = value;
      });
    }
  }

  bool materiaIsNull() {
    return widget.info.materia == "null";
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;

    return Stack(
      children: [
        Container(
          height: 450,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: getColor(widget.info.dataFine)?.withOpacity(0.3),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: SizedBox(
            width: 300,
            child: Opacity(
              opacity: _isDone ? 0.5 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    materiaIsNull()
                        ? widget.info.nomeInsegnante
                        : widget.info.materia.length > 35
                            ? "${widget.info.materia.substring(0, 35)}..."
                            : widget.info.materia,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: textColor,
                      decoration: _isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.watch_later_outlined,
                        size: 16,
                        color: textColor.withOpacity(0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.info.orario,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (!materiaIsNull())
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 16, color: textColor.withOpacity(0.8)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.info.nomeInsegnante,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.9),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Divider(thickness: 1, color: textColor),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1.0),
                          child: Icon(
                            Icons.description,
                            size: 16,
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              widget.info.descrizione,
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withOpacity(0.9),
                                decoration: _isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Checkbox(
            value: _isDone,
            onChanged: _toggleDone,
            activeColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    );
  }

  Color? getColor(String dataFine) {
    try {
      DateTime today = DateTime.now();
      DateTime scadenzaFine = DateTime.parse(dataFine.substring(0, 19));
      DateTime scadenzaGen = DateTime.parse(dataFine.substring(0, 10));
      Duration differenzaGen = scadenzaGen.difference(today);
      if (scadenzaFine.isBefore(today)) {
        return today.hour < scadenzaFine.hour ? Colors.red : Colors.grey;
      }
      if (differenzaGen.inDays == 0) {
        return const Color.fromRGBO(255, 100, 100, 0.5);
      }
      if (differenzaGen.inDays == 1) {
        return Colors.orange[700];
      }
      if (differenzaGen.inDays == 2) {
        return Colors.orange[300];
      }
      if (differenzaGen.inDays <= 6) {
        return Colors.green[300];
      }
      return Colors.green[600];
    } catch (e) {
      return Colors.grey[300];
    }
  }
}
