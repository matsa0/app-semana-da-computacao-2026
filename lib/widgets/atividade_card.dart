import 'package:flutter/material.dart';
import '../models/atividade_model.dart';

class AtividadeCard extends StatelessWidget {
  final Atividade atividade;
  final VoidCallback onPressed;
  final bool isOrganizador;
  final bool estaInscrito; // Campo adicionado
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AtividadeCard({
    super.key, 
    required this.atividade, 
    required this.onPressed,
    this.isOrganizador = false,
    this.estaInscrito = false, 
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
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: atividade.atividadeEncerrada
            ? const BorderSide(color: Colors.grey, width: 1)
            : (atividade.atividadeProxima || atividade.atividadeAcontecendo
                ? BorderSide(
                    color: atividade.atividadeAcontecendo ? Colors.green : const Color(0xFFB80D48), 
                    width: 2,
                  )
                : BorderSide.none),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (atividade.atividadeAcontecendo || atividade.atividadeProxima || atividade.atividadeEncerrada)
            Container(
              width: double.infinity,
              color: atividade.atividadeEncerrada
                  ? Colors.grey
                  : (atividade.atividadeAcontecendo ? Colors.green : const Color(0xFFB80D48)),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                atividade.atividadeEncerrada ? 'ENCERRADA' : (atividade.atividadeAcontecendo ? 'ACONTECENDO AGORA!' : 'COMEÇA EM BREVE'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),    
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                        
                        if (estaInscrito)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green, width: 1),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check, size: 12, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text(
                                    'INSCRITO',
                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    // Botões de ADM (Edit/Delete)
                    if (isOrganizador)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                            onPressed: onEdit,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
                Text(
                  'Data: ${atividade.dataFormatada}',
                  style: TextStyle(
                    color: atividade.atividadeProxima ? const Color(0xFFB80D48) : Colors.black87,
                    fontWeight: atividade.atividadeProxima ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  'Horário: ${atividade.horarioFormatado}',
                  style: TextStyle(
                    color: atividade.atividadeProxima ? const Color(0xFFB80D48) : Colors.black87,
                    fontWeight: atividade.atividadeProxima ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (atividade.local.isNotEmpty)
                  Text('Local: ${atividade.local}'),
                Text('Vagas: ${atividade.vagas}'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: estaInscrito ? Colors.green : const Color(0xFFB80D48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text(
                      estaInscrito ? 'Inscrito - Ver detalhes' : 'Ver mais', 
                      style: const TextStyle(color: Colors.white)
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}