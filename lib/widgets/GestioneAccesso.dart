import 'package:ClasseMorta/models/Login.dart';
import 'package:flutter/material.dart';
import 'package:ClasseMorta/models/Credenziali.dart'; // Assicurati che il percorso sia corretto
import 'package:ClasseMorta/service/AccessService.dart'; // Assicurati che il percorso sia corretto per Save
import 'package:ClasseMorta/service/ApiService.dart';   // Assicurati che il percorso sia corretto
import 'package:ClasseMorta/pages/Principale.dart';    // Assicurati che il percorso sia corretto per MainPage
import 'package:ClasseMorta/main.dart';     // Assicurati che il percorso sia corretto per LoginPage

class AuthWrapper extends StatefulWidget {
  final bool precedente;
  const AuthWrapper({super.key, required this.precedente});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final Save _saveService = Save();
  // Non più _credenziali qui, lo stato sarà se il login è riuscito o meno
  // o l'istanza di Apiservice pronta.
  bool _isLoading = true;
  Widget? _destinationPage; // La pagina a cui navigare dopo il caricamento/login

  @override
  void initState() {
    super.initState();
    _initializeAndLogin();
  }

  Future<void> _initializeAndLogin() async {
    //prende i dati dal salvataggio e li controlla, se ci sono fa il login in automatico
    Credenziali? cred = await _saveService.getCredenziali();
    if (!mounted) return;

    if (cred != null && cred.code.isNotEmpty && cred.pass.isNotEmpty) {
      Apiservice apiService = Apiservice(cred.code, widget.precedente);
      LoginResponse? loginSuccess = await apiService.doLogin(cred.pass); // Supponiamo che doLogin restituisca bool
      if (!mounted) return;

      if (loginSuccess?.token != "") {
        setState(() {
          _destinationPage = MainPage(apiService: apiService);
          _isLoading = false;
        });
      } else {
        setState(() {
          _destinationPage = const LoginPage();
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _destinationPage = const LoginPage();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // _destinationPage dovrebbe essere sempre impostato a questo punto se _isLoading è false
    return _destinationPage ?? const LoginPage(); // Fallback se qualcosa va storto
  }
}

