import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/atividade_model.dart';

class ParticipantesAtividadeScreen extends StatelessWidget {
  final Atividade atividade;

  const ParticipantesAtividadeScreen({super.key, required this.atividade});

  @override
  Widget build(BuildContext context) {
    // Envolvemos a tela no DefaultTabController para gerenciar as abas
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(atividade.titulo),
          bottom: const TabBar(
            labelColor: Color(0xFFB1124C),
            indicatorColor: Color(0xFFB1124C),
            tabs: [
              Tab(icon: Icon(Icons.group), text: 'Participantes'),
              Tab(icon: Icon(Icons.forum), text: 'Perguntas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ==========================================
            // ABA 1: CÓDIGO ORIGINAL DA LISTA DE PARTICIPANTES
            // ==========================================
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Participantes inscritos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            // ==========================================
            // ABA 2: NOVO CÓDIGO DE PERGUNTAS EM TEMPO REAL
            // ==========================================
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('atividades')
                  .doc(atividade.id)
                  .collection('perguntas')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhuma pergunta enviada ainda.'));
                }

                final perguntas = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: perguntas.length,
                  itemBuilder: (context, index) {
                    final p = perguntas[index].data() as Map<String, dynamic>;
                    final nomeUsuario = p['nomeUsuario'] ?? 'Anônimo';
                    final texto = p['texto'] ?? '';

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFB1124C),
                          child: Icon(Icons.question_mark, color: Colors.white, size: 20),
                        ),
                        title: Text(nomeUsuario, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
                          child: Text(texto, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}