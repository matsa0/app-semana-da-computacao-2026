import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/atividade_model.dart'; 
import 'checkin_qrcode_screen.dart';

class CheckinManualScreen extends StatelessWidget {
  final Atividade atividade;

  const CheckinManualScreen({super.key, required this.atividade});

  Future<void> _alternarPresenca(String inscricaoId, bool valorAtual) async {
    try {
      await FirebaseFirestore.instance
          .collection('inscricoes')
          .doc(inscricaoId)
          .update({'presente': !valorAtual}); // se for false, vira true se for true, vira false
    } catch (e) {
      debugPrint('Erro ao atualizar presença: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Presença'),
        backgroundColor: const Color(0xFFB80D48),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Atividade: ${atividade.titulo}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
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
                  return const Center(child: Text('Nenhum inscrito nesta atividade ainda.'));
                }

                final inscricoes = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: inscricoes.length,
                  itemBuilder: (context, index) {
                    final inscricao = inscricoes[index];
                    final dataInscricao = inscricao.data() as Map<String, dynamic>;
                    final usuarioId = dataInscricao['usuarioId'];
                    
                    // verifica se o campo já existe. se não existir, a pessoa levou false
                    final isPresente = dataInscricao.containsKey('presente') 
                        ? dataInscricao['presente'] 
                        : false;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(usuarioId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const ListTile(
                            leading: CircularProgressIndicator(),
                            title: Text('Carregando dados do aluno...'),
                          );
                        }

                        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                        final nome = userData?['nome'] ?? '';
                        final sobrenome = userData?['sobrenome'] ?? '';
                        final email = userData?['email'] ?? '';

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          elevation: isPresente ? 2 : 0, // dá um destaque se tiver presente
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isPresente ? Colors.green : Colors.grey[300],
                              child: Icon(
                                isPresente ? Icons.check : Icons.person,
                                color: isPresente ? Colors.white : Colors.grey[700],
                              ),
                            ),
                            title: Text('$nome $sobrenome', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(email),
                            trailing: Switch(
                              value: isPresente,
                              activeColor: Colors.green, // Corrigido de activeThumbColor para activeColor para evitar outros erros de versão
                              onChanged: (bool newValue) {
                                _alternarPresenca(inscricao.id, isPresente);
                              },
                            ),
                          ),
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
      // O Botão flutuante fica aqui embaixo, fora do body!
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckinQrCodeScreen(atividade: atividade),
            ),
          );
        },
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text('Ler Ingresso', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}