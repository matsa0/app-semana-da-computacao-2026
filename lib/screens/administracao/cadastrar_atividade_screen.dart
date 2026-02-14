import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastrarAtividadeScreen extends StatefulWidget {
  const CadastrarAtividadeScreen({super.key});

  @override
  State<CadastrarAtividadeScreen> createState() => _CadastrarAtividadeScreenState();
}

class _CadastrarAtividadeScreenState extends State<CadastrarAtividadeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _tituloController = TextEditingController();
  final _ministranteController = TextEditingController();
  final _dataController = TextEditingController();
  final _horarioController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _vagasController = TextEditingController();

  String _tipoSelecionado = 'Palestra';
  final List<String> _tipos = ['Palestra', 'Minicurso', 'Oficina'];
  
  bool _isLoading = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _ministranteController.dispose();
    _dataController.dispose();
    _horarioController.dispose();
    _descricaoController.dispose();
    _vagasController.dispose();
    super.dispose();
  }

  Future<void> _salvarAtividade() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('atividades').add({
        'titulo': _tituloController.text.trim(),
        'tipo': _tipoSelecionado,
        'ministrante': _ministranteController.text.trim(),
        'data': _dataController.text.trim(),
        'horario': _horarioController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'vagas': int.tryParse(_vagasController.text.trim()) ?? 0,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atividade cadastrada com sucesso!')),
      );
      Navigator.pop(context);
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Atividade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título da Atividade', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _tipoSelecionado,
                decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
                items: _tipos.map((tipo) {
                  return DropdownMenuItem(value: tipo, child: Text(tipo));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _tipoSelecionado = val);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ministranteController,
                decoration: const InputDecoration(labelText: 'Nome do Ministrante', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dataController,
                      decoration: const InputDecoration(labelText: 'Data (ex: 15/10/2026)', border: OutlineInputBorder()),
                      validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _horarioController,
                      decoration: const InputDecoration(labelText: 'Horário (ex: 14:00)', border: OutlineInputBorder()),
                      validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _vagasController,
                decoration: const InputDecoration(labelText: 'Quantidade de Vagas', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB80D48),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _salvarAtividade,
                      child: const Text('Salvar Atividade', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}