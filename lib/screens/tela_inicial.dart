import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/atividade_card.dart';
import '../../models/atividade_model.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  String filtroSelecionado = 'Todos';
  final List<String> tipos = ['Todos', 'Palestra', 'Minicurso', 'Oficina'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atividades')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Confira as atividades',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: tipos.map((tipo) {
                bool isSelected = filtroSelecionado == tipo;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tipo),
                    selected: isSelected,
                    selectedColor: const Color(0xFFB80D48),
                    onSelected: (_) {
                      setState(() {
                        filtroSelecionado = tipo;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('atividades').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhuma atividade encontrada.'));
                }

                final atividades = snapshot.data!.docs.map((doc) => Atividade.fromFirestore(doc)).toList();

                final atividadesFiltradas = filtroSelecionado == 'Todos'
                    ? atividades
                    : atividades.where((a) => a.tipo == filtroSelecionado).toList();

                return ListView.builder(
                  itemCount: atividadesFiltradas.length,
                  itemBuilder: (context, index) {
                    return AtividadeCard(
                      atividade: atividadesFiltradas[index],
                      onPressed: () {
                        // ação ao clicar no card
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}