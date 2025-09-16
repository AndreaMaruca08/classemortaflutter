
import 'package:ClasseMorta/pages/Principale.dart';
import 'package:ClasseMorta/service/AccessService.dart';
import 'package:ClasseMorta/widgets/GestioneAccesso.dart';
import 'package:flutter/material.dart';
import '../service/ApiService.dart';
import 'models/Login.dart';

void main() {
  runApp(const Login());
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClasseMorta',
      // Forza l'uso del tema scuro
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        // Fondamentale per indicare che è un tema scuro
        brightness: Brightness.dark,

        // Colore di sfondo per Scaffold (la base della maggior parte delle pagine)
        scaffoldBackgroundColor: Colors.black,

        // Stili per l'AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // Sfondo nero per AppBar
          elevation: 0, // Opzionale: rimuove l'ombra se preferisci
          titleTextStyle: TextStyle(
            color: Colors.white, // Testo bianco per il titolo
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.white, // Icone bianche nell'AppBar (es. hamburger menu)
          ),
        ),

        // Stili di testo globali
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Usato per il titolo dell'AppBar in ApodPage
          titleMedium: TextStyle(color: Colors.white), // Usato per i sottotitoli in ApodPage
          titleSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white), // Usato per la descrizione in ApodPage
          bodyMedium: TextStyle(color: Colors.white), // Stile di default per Text()
          bodySmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white), // Usato per i bottoni
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),

        // Colore per le icone globali (se non sovrascritto altrove)
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        // Colore per CircularProgressIndicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.white,
        ),

        // Colore per i Divider
        dividerColor: Colors.grey[700], // Un grigio scuro visibile su nero

        // Stili per il Drawer
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.black, // Sfondo nero per il Drawer
        ),

        // Stili per i ListTile (usati nel Drawer)
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.white,
          textColor: Colors.white,
        ),

        // SnackBar theme (opzionale ma utile)
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey[800],
          contentTextStyle: const TextStyle(color: Colors.white),
        ),

        // ColorScheme è importante per molti widget Material
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          // Puoi scegliere un colore primario, ma per solo nero/bianco non è cruciale
          // se sovrascrivi gli elementi principali.
          // Tuttavia, è bene averlo definito.
          primarySwatch: Colors.grey, // o Colors.blue, o altro
        ).copyWith(
          surface: Colors.grey[850],    // Sfondo per Card, Dialog, ecc. (leggermente più chiaro del nero puro)
          onSurface: Colors.white,        // Testo/icone su surface
          primary: Colors.grey[900],      // Colore primario (es. header Drawer)
          onPrimary: Colors.white,        // Testo/icone su primario
          secondary: Colors.grey[700],    // Colore secondario
          onSecondary: Colors.white,      // Testo/icone su secondario
        ),
      ),
      home: const AuthWrapper(precedente: false,),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController codiceController = TextEditingController(); // Rimosso 'new'
  TextEditingController passwordController = TextEditingController(); // Rimosso 'new'

  @override
  void dispose() {
    codiceController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding( // Aggiunto Padding attorno alla Column per un aspetto migliore
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centra i figli verticalmente
            crossAxisAlignment: CrossAxisAlignment.stretch, // Fa sì che le Row occupino tutta la larghezza
            children: [
              const Text(
                "Benvenuto su ClasseMorta",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 70), // Aumentato lo spazio
              Row(
                children: [
                  const Text("Codice studente:"),
                  const SizedBox(width: 10),
                  Expanded( // <-- Aggiunto Expanded
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Inserisci il tuo codice studente',
                      ),
                      controller: codiceController,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  const Text("Password:           "), // Allineato un po' per estetica (o usa SizedBox)
                  const SizedBox(width: 10),
                  Expanded( // <-- Aggiunto Expanded
                    child: TextField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Inserisci la tua password', // Modificato hintText
                      ),
                      controller: passwordController, // <-- USA IL CONTROLLER CORRETTO
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton( // Aggiunto un pulsante di login
                style: new ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.grey[800]!),
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () async {
                  final codice = codiceController.text;
                  final password = passwordController.text;

                  if(!areInputsValid(codice, password)){return;}

                  Apiservice apiService = Apiservice(codice, password, false);

                  //login
                  LoginResponse? loginResponse = await apiService.doLogin();

                  if(loginResponse == null) {
                    _mostraAlert(context, "Errore", "credenziali errate");
                    return;
                  }

                  Save save = Save();
                  await save.saveStringList([codice, password]);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage(apiService: apiService)),
                  );
                },
                child: const Text('Accedi'),
              )
            ],
          ),
        ),
      ),
    );

  }

  // Controlli input
  // Esempio codice studente: S10435383U
  bool areInputsValid(String code, String password){
    //Controlli
    if(code.isEmpty || password.isEmpty){
      _mostraAlert(context, "Errore", "Compila tutti i campi");
      return false;
    }

    if(code[0] != 'S' && code[0] != 'G'){
      _mostraAlert(context, "Errore", "Il codice deve iniziare con 'S' o 'G'");
      return false;
    }

    return true;
  }

  Future<void> _mostraAlert(BuildContext context, String titolo, String messaggio) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // L'utente DEVE premere un pulsante per chiudere (opzionale)
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titolo),
          content: SingleChildScrollView( // Usa SingleChildScrollView se il messaggio è lungo
            child: ListBody(
              children: <Widget>[
                Text(messaggio),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Chiude il dialogo
              },
            ),
            // Puoi aggiungere altri pulsanti qui, ad esempio un pulsante "Annulla"
            /*
          TextButton(
            child: const Text('Annulla'),
            onPressed: () {
              Navigator.of(context).pop(); // Chiude il dialogo
              // Esegui altra azione se necessario
            },
          ),
          */
          ],
        );
      },
    );
  }


}

