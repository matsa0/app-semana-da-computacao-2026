import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/atividade_model.dart';
import '../../widgets/atividade_card.dart';
import '../programacao/detalhes_atividade_screen.dart';

class MinhasAtividadesScreen extends StatelessWidget {
  const MinhasAtividadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Center(child: Text('Usuário não logado.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inscricoes')
          .where('usuarioId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshotInscricoes) {
        if (snapshotInscricoes.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshotInscricoes.hasData || snapshotInscricoes.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Nenhuma atividade encontrada',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB80D48),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Navegue até a aba "Início" para ver a programação.')),
                    );
                  },
                  child: const Text('Ver Programação Completa', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          );
        }

        final atividadeIds = snapshotInscricoes.data!.docs
            .map((doc) => doc['atividadeId'] as String)
            .toList();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('atividades').snapshots(),
          builder: (context, snapshotAtividades) {
            if (snapshotAtividades.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshotAtividades.hasData) {
              return const Center(child: Text('Erro ao carregar os dados das atividades.'));
            }

            final atividadesInscritas = snapshotAtividades.data!.docs
                .map((doc) => Atividade.fromFirestore(doc))
                .where((atividade) => atividadeIds.contains(atividade.id))
                .toList();

            return ListView.builder(
              itemCount: atividadesInscritas.length,
              itemBuilder: (context, index) {
                return AtividadeCard(
                  atividade: atividadesInscritas[index],
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalhesAtividadeScreen(
                          atividade: atividadesInscritas[index],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}