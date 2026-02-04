import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'base_screen.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semana da Computação',
      theme: ThemeData(
        primaryColor: const Color(0xFFB80D48),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB80D48),
          foregroundColor: Colors.white,
          centerTitle: false,
        )
      ),  

      home: BaseScreen(),
    );
  }
}

class TelaTeste extends StatelessWidget {
  const TelaTeste({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teste do Projeto")),
      body: const Center(
        child: Text(
          "Firebase Conectado com Sucesso!",
          style: TextStyle(fontSize: 20, color: Colors.green),
        ),
      ),
    );
  }
}
