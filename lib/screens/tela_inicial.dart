import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/atividade_card.dart';
import '../../models/atividade_model.dart';
import '../screens/programacao/detalhes_atividade_screen.dart';
import '../screens/administracao/cadastrar_atividade_screen.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  String filtroSelecionado = 'Todos';
  final List<String> tipos = ['Todos', 'Palestra', 'Minicurso', 'Oficina'];
  
  bool _isOrganizador = false;

  @override
  void initState() {
    super.initState();
    _verificarPermissao();
  }

  Future<void> _verificarPermissao() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _isOrganizador = doc.data()?['isOrganizador'] ?? false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB80D48),
        elevation: 0,
        toolbarHeight: 70, // Altura ajustada
        // Substituímos qualquer texto antigo direto por essa coluna
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 2),
            Text(
              'Programação Oficial',
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          if (_isOrganizador)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CadastrarAtividadeScreen(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
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
                    label: Text(
                      tipo,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    side: BorderSide.none, 
                    backgroundColor: const Color(0xFFB80D48),
                    selectedColor: const Color(0xFFB80D48),
                    showCheckmark: isSelected,
                    checkmarkColor: Colors.white,
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
            // --- BUSCA AS INSCRIÇÕES DO USUÁRIO ---
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('inscricoes')
                  .where('usuarioId', isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, snapshotInscricoes) {
                // Criamos uma lista de IDs das atividades que o usuário já se inscreveu
                List<String> atividadeIdsInscritas = [];
                if (snapshotInscricoes.hasData) {
                  atividadeIdsInscritas = snapshotInscricoes.data!.docs
                      .map((doc) => doc['atividadeId'] as String)
                      .toList();
                }

                // --- SEGUNDO STREAM: BUSCA TODAS AS ATIVIDADES ---
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('atividades').snapshots(),
                  builder: (context, snapshotAtividades) {
                    if (snapshotAtividades.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshotAtividades.hasData || snapshotAtividades.data!.docs.isEmpty) {
                      return const Center(child: Text('Nenhuma atividade encontrada.'));
                    }

                    final atividades = snapshotAtividades.data!.docs
                        .map((doc) => Atividade.fromFirestore(doc))
                        .toList();

                    final atividadesFiltradas = filtroSelecionado == 'Todos'
                        ? atividades
                        : atividades.where((a) => a.tipo == filtroSelecionado).toList();

                    return ListView.builder(
                      itemCount: atividadesFiltradas.length,
                      itemBuilder: (context, index) {
                        final atividadeAtual = atividadesFiltradas[index];
                        
                        // VERIFICAÇÃO: Se o ID desta atividade está na lista de inscrições
                        final bool jaInscrito = atividadeIdsInscritas.contains(atividadeAtual.id);

                        return AtividadeCard(
                          atividade: atividadeAtual,
                          isOrganizador: _isOrganizador,
                          estaInscrito: jaInscrito, // <--- NOVA PROPRIEDADE PASSADA AO CARD
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalhesAtividadeScreen(atividade: atividadeAtual),
                              ),
                            );
                          },
                          onEdit: () {
                            // Navega para a tela de cadastro, mas passando a atividade atual
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CadastrarAtividadeScreen(atividade: atividadeAtual),
                              ),
                            );
                          },
                          onDelete: () {
                            _confirmarExclusao(context, atividadeAtual);
                          },
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

  // Método auxiliar para organizar o código de exclusão
  void _confirmarExclusao(BuildContext context, Atividade atividade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Atividade'),
        content: Text('Tem certeza que deseja excluir "${atividade.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); 
              await FirebaseFirestore.instance.collection('atividades').doc(atividade.id).delete();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}