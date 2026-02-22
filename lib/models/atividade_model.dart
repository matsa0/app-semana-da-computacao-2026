import 'package:cloud_firestore/cloud_firestore.dart';
class Atividade {
  final String id;
  final String titulo;
  final String tipo;
  final String ministrante;
  final String ministranteId;
  final String data;
  final String horario;
  final int duracao; 
  final String descricao;
  final int vagas;

  Atividade({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.ministrante,
    required this.ministranteId,
    required this.data,
    required this.horario,
    this.duracao = 60,
    this.descricao = '',
    this.vagas = 0,
  });

  factory Atividade.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Atividade(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      tipo: data['tipo'] ?? '',
      ministrante: data['ministrante'] ?? '',
      ministranteId: data['ministranteId'] ?? '',
      data: data['data'] ?? '',
      horario: data['horario'] ?? '',
      duracao: data['duracao'] ?? 60,
      descricao: data['descricao'] ?? '',
      vagas: data['vagas'] ?? 0,
    );
  }
}