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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0, 
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Vou Assistir', icon: Icon(Icons.bookmark_outline)),
              Tab(text: 'Vou Ministrar', icon: Icon(Icons.co_present)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAbaInscricoes(user.uid),
            _buildAbaMinistrante(user.uid),
          ],
        ),
      ),
    );
  }

  // --- ABA 1: ATIVIDADES INSCRITAS (Vou Assistir) ---
  Widget _buildAbaInscricoes(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inscricoes')
          .where('usuarioId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshotInscricoes) {
        if (snapshotInscricoes.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshotInscricoes.hasData || snapshotInscricoes.data!.docs.isEmpty) {
          return _buildEmptyState(context, 'Você não possui inscrições.');
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

            if (!snapshotAtividades.hasData) return const SizedBox();
            final atividadesInscritas = snapshotAtividades.data!.docs
                .map((doc) => Atividade.fromFirestore(doc))
                .where((atividade) => atividadeIds.contains(atividade.id))
                .toList();

            if (atividadesInscritas.isEmpty) {
              return _buildEmptyState(context, 'Atividades não encontradas.');
            }

            return _buildListaAtividades(atividadesInscritas);
          },
        );
      },
    );
  }

  // --- ABA 2: ATIVIDADES COMO MINISTRANTE (Vou Ministrar) ---
  Widget _buildAbaMinistrante(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('atividades')
          .where('ministranteId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(context, 'Você não ministra atividades.');
        }

        final atividadesParaMinistrar = snapshot.data!.docs
            .map((doc) => Atividade.fromFirestore(doc))
            .toList();

        return _buildListaAtividades(atividadesParaMinistrar);
      },
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildListaAtividades(List<Atividade> lista) {
    return ListView.builder(
      itemCount: lista.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        return AtividadeCard(
          atividade: lista[index],
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalhesAtividadeScreen(atividade: lista[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String mensagem) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_note, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(mensagem, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB80D48)),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/base');
            },
            child: const Text('Explorar Programação', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}