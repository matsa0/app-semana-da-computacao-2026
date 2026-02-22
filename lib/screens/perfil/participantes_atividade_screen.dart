import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/atividade_model.dart';

class ParticipantesAtividadeScreen extends StatelessWidget {
  final Atividade atividade;

  const ParticipantesAtividadeScreen({super.key, required this.atividade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(atividade.titulo)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Participantes inscritos',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('inscricoes')
                  .where('atividadeId', isEqualTo: atividade.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhum participante inscrito.'));
                }

                final inscricoes = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: inscricoes.length,
                  itemBuilder: (context, index) {
                    final usuarioId = inscricoes[index]['usuarioId'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(usuarioId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text('Carregando...'),
                          );
                        }

                        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                        final nome = userData?['nome'] ?? '';
                        final sobrenome = userData?['sobrenome'] ?? '';
                        final email = userData?['email'] ?? '';
                        final curso = userData?['curso'] ?? '';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFB1124C).withOpacity(0.1),
                            child: const Icon(Icons.person, color: Color(0xFFB1124C)),
                          ),
                          title: Text('$nome $sobrenome'),
                          subtitle: Text('$curso • $email'),
                        );
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