import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'base_screen.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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