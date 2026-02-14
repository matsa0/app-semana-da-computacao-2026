import 'package:flutter/material.dart';
import 'tela_inicial.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    TelaInicial(),
    Center(child: Text("Buscar por atividade")),
    Center(child: Text("Minhas atividades")),
    Center(child: Text("Perfil")),
  ];

  final List<Widget> _titles = const [
    Text('Página Inicial', textAlign: TextAlign.left),
    Text('Buscar Atividades', textAlign: TextAlign.left),
    Text('Minhas Atividades', textAlign: TextAlign.left),
    Text('Perfil', textAlign: TextAlign.left),
  ];

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _titles[_selectedIndex]),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFB80D48),
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_added_outlined), label: 'Minhas Atividades'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
