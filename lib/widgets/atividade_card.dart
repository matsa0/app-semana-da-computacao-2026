import 'package:flutter/material.dart';
import '../models/atividade_model.dart';

class AtividadeCard extends StatelessWidget {
  final Atividade atividade;
  final VoidCallback onPressed;
  final bool isOrganizador;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AtividadeCard({
    super.key, 
    required this.atividade, 
    required this.onPressed,
    this.isOrganizador = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color tipoColor;
    switch (atividade.tipo) {
      case 'Palestra':
        tipoColor = Colors.orange;
        break;
      case 'Minicurso':
        tipoColor = Colors.green;
        break;
      case 'Oficina':
        tipoColor = Colors.cyan;
        break;
      default:
        tipoColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tipoColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    atividade.tipo,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                if (isOrganizador)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: onEdit,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              atividade.titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Ministrante: ${atividade.ministrante}'),
            Text('Data: ${atividade.data}'),
            Text('Horário: ${atividade.horario}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB80D48),
              ),
              child: const Text('Ver mais', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}