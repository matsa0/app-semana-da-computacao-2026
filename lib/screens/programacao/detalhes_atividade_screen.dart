import 'package:flutter/material.dart';
import '../../models/atividade_model.dart';

class DetalhesAtividadeScreen extends StatelessWidget {
  final Atividade atividade;

  const DetalhesAtividadeScreen({super.key, required this.atividade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Atividade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCorPorTipo(atividade.tipo),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                atividade.tipo,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              atividade.titulo,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Ministrante: ${atividade.ministrante}'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, 'Data: ${atividade.data}'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time, 'Horário: ${atividade.horario}'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.group, 'Vagas disponíveis: ${atividade.vagas}'),
            const SizedBox(height: 24),
            const Text(
              'Descrição',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              atividade.descricao.isEmpty ? 'Nenhuma descrição informada.' : atividade.descricao,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB80D48),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // Ação temporária, a lógica com Firebase virá depois
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lógica de inscrição em desenvolvimento.')),
                  );
                },
                child: const Text(
                  'Inscrever-se',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCorPorTipo(String tipo) {
    switch (tipo) {
      case 'Palestra':
        return Colors.orange;
      case 'Minicurso':
        return Colors.green;
      case 'Oficina':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}