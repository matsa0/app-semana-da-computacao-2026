import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/usuario_model.dart'; // Ajuste o caminho da sua model

class GerenciarPermissoesScreen extends StatefulWidget {
  const GerenciarPermissoesScreen({super.key});

  @override
  State<GerenciarPermissoesScreen> createState() => _GerenciarPermissoesScreenState();
}

class _GerenciarPermissoesScreenState extends State<GerenciarPermissoesScreen> {
  String _filtroNome = "";

  // MUDANÇA: Função para atualizar apenas os campos de permissão no Firestore
  Future<void> _atualizarPermissao(String uid, String novoTipo) async {
    bool isOrganizador = novoTipo == 'Organizador';
    bool isMinistrante = novoTipo == 'Ministrante';

    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'isOrganizador': isOrganizador,
        'isMinistrante': isMinistrante,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissões atualizadas!'), backgroundColor: Colors.green,),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Permissões')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Pesquisar usuário por nome...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _filtroNome = value.toLowerCase()),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var usuarios = snapshot.data!.docs
                    .map((doc) => Usuario.fromFirestore(doc))
                    .where((u) => u.nome.toLowerCase().contains(_filtroNome))
                    .toList();

                return ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];
                    
                    String tipoAtualNoBanco;
                    if (usuario.isOrganizador) {
                      tipoAtualNoBanco = 'Organizador';
                    } else if (usuario.isMinistrante) {
                      tipoAtualNoBanco = 'Ministrante';
                    } else {
                      tipoAtualNoBanco = 'Participante';
                    }

                    return ListTile(
                      title: Text(usuario.nome),
                      subtitle: Text(usuario.email),
                      trailing: DropdownButton<String>(
                        value: tipoAtualNoBanco,
                        onChanged: (String? novoTipo) {
                          if (novoTipo != null) _atualizarPermissao(usuario.id, novoTipo);
                        },
                        items: ['Participante', 'Ministrante', 'Organizador']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                      ),
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