import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sec_application/models/atividade_model.dart';
import 'tela_inicial.dart';
import './minhas_atividades/minhas_atividades_screen.dart';
import './perfil/perfil_screen.dart';
import './buscar_atividade/buscar_atividade_screen.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;
  bool _temBadgeAtivo = false;
  StreamSubscription? _inscricoesSubscription;

  @override
  void initState() {
    super.initState();
    _iniciarMonitoramenteDeBadge();
  }

  @override
  void dispose() {
    _inscricoesSubscription?.cancel();
    super.dispose();
  }

  void _iniciarMonitoramenteDeBadge() {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // escuta a coleção de inscrições do usuário que está logado
    _inscricoesSubscription = FirebaseFirestore.instance
        .collection('inscricoes')
        .where('usuarioId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) async {

        bool encontrouProxima = false;

        for (var doc in snapshot.docs) {
          // busca os detalhes da atividade para checar o horário
          final atvDoc = await FirebaseFirestore.instance
              .collection('atividades')
              .doc(doc['atividadeId'])
              .get();

          if (atvDoc.exists) {
            final atividade = Atividade.fromFirestore(atvDoc);

            if (atividade.atividadeProxima || atividade.atividadeAcontecendo) {
              encontrouProxima = true;
              break; 
            }
          }
        }

        if (mounted) {
          setState(() => _temBadgeAtivo = encontrouProxima);
        }
      });
  }

  final List<Widget> _screens = const [
    TelaInicial(),
    BuscarAtividadeScreen(),
    MinhasAtividadesScreen(),
    PerfilScreen(),
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
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),

          BottomNavigationBarItem(
            icon: Badge(
              smallSize: 10,
              backgroundColor: const Color(0xFFB80D48),
              isLabelVisible: _temBadgeAtivo,
              child: Icon(
                _selectedIndex == 2 ? Icons.bookmark_added : Icons.bookmark_added_outlined
                ), 
            ),
            label: 'Minhas Atividades',
          ),

          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
