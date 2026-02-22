import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sec_application/screens/programacao/detalhes_atividade_screen.dart';
import '../../models/atividade_model.dart';

class BuscarAtividadeScreen extends StatefulWidget {
  const BuscarAtividadeScreen({super.key});

  @override
  State<BuscarAtividadeScreen> createState() => _BuscarAtividadeScreenState();
}

class _BuscarAtividadeScreenState extends State<BuscarAtividadeScreen> {
  // quey de busca digitada pelo usuário
  String _queryDeBusca = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true, 
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Buscar por título ou ministrante...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          
          // atualiza a variável de busca toda vez que o usuário digitar algo
          onChanged: (value) {
            setState(() {
              _queryDeBusca = value.toLowerCase(); 
            });
          },
        ),
        backgroundColor: const Color(0xFFB80D48),
      ),
      

      body: _queryDeBusca.isEmpty
          ? 
          // 1º cenário: caso o usuário ainda não digitou nada
          const Center(
              child: Text(
                "Digite algo para começar a buscar...",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : 

          // 2º cenário: o usuário digitou algo, então será buscado no firebase
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('atividades').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Erro ao carregar dados"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // AQUI ACONTECE A FILTRAGEM (Lógica de "Match")
                final results = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  
                  final titulo = data['titulo'].toString().toLowerCase();
                  final ministrante = data['ministrante'].toString().toLowerCase();
                  
                  // verirfica tanto o título quanto o ministrante 
                  return titulo.contains(_queryDeBusca) || ministrante.contains(_queryDeBusca);
                }).toList();

                if (results.isEmpty) {
                  return const Center(child: Text("Nenhuma atividade encontrada."));
                }

                // forma que o resultado é exibido para o usuário
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final data = results[index];
                    final Atividade atividade = Atividade.fromFirestore(data);
                    
                    return ListTile(
                      leading: const Icon(Icons.event_note, color: Color(0xFFB80D48), size: 38),
                      title: Text(atividade.titulo),
                      titleTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB80D48)),
                      subtitle: Text("Ministrante: ${atividade.ministrante}\nData: ${atividade.data} • Horário: ${atividade.horario}"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      
                      // ao clicar no resultado exibido
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalhesAtividadeScreen(atividade: atividade),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}