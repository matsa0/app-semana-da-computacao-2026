import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _nomeController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  String? _cursoSelecionado;
  final List<String> _cursos = [
    'Sistemas de Informação',
    'Engenharia de Computação',
    'Engenharia Elétrica',
    'Engenharia de Produção',
    'Outro'
  ];
  bool _loading = false;

  final Color primaryColor = const Color(0xFFB1124C);

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _nomeController.text = data['nome'] ?? '';
      _sobrenomeController.text = data['sobrenome'] ?? '';
final cursoBanco = data['curso'] ?? '';
      if (_cursos.contains(cursoBanco)) {
        setState(() => _cursoSelecionado = cursoBanco);
      } else if (cursoBanco.isNotEmpty) {
        setState(() => _cursoSelecionado = 'Outro');
      }    }
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    final sobrenome = _sobrenomeController.text.trim();
    final curso = _cursoSelecionado ?? '';

    if (nome.isEmpty || sobrenome.isEmpty || curso.isEmpty) {
      _showMessage('Preencha todos os campos');
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({'nome': nome, 'sobrenome': sobrenome, 'curso': curso});

      if (!mounted) return;
      _showMessage('Perfil atualizado com sucessso!');
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Erro: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Icon(Icons.person, size: 50, color: primaryColor),
                ),
              ),
              const SizedBox(height: 32),
              _input('Nome', Icons.person, _nomeController),
              const SizedBox(height: 16),
              _input('Sobrenome', Icons.person_outline, _sobrenomeController),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _cursoSelecionado,
                decoration: InputDecoration(
                  labelText: 'Curso',
                  prefixIcon: const Icon(Icons.school),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: _cursos.map((String curso) {
                  return DropdownMenuItem<String>(
                    value: curso,
                    child: Text(curso),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _cursoSelecionado = newValue;
                  });
                },
              ),
              const SizedBox(height: 32),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _salvar,
                      child: const Text(
                        'Salvar Alterações',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}