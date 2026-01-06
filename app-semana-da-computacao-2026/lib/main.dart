import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Pacote que instalamos

void main() async {
  // Garante que o motor do Flutter esteja pronto
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa a conexão com o Firebase
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
        primarySwatch: Colors.blue, // Cor padrão do app
        useMaterial3: true,
      ),
      // Por enquanto, mostraremos apenas uma tela simples de teste
      home: const TelaTeste(),
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