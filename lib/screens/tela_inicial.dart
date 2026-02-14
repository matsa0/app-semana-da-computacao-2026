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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atividades'),
        actions: [
          if (_isOrganizador) // botão só aparece se isso for verdadiero
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CadastrarAtividadeScreen(),
                  ),
                );
              },
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
                    final atividadeAtual = atividadesFiltradas[index];
                    
                    return AtividadeCard(
                      atividade: atividadeAtual,
                      isOrganizador: _isOrganizador, // Passa a permissão para o card
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
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Excluir Atividade'),
                            content: Text('Tem certeza que deseja excluir "${atividadeAtual.titulo}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context); 
                                  await FirebaseFirestore.instance.collection('atividades').doc(atividadeAtual.id).delete();
                                },
                                child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                              ),
                            ],
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
    );
  }
}