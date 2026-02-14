import 'package:cloud_firestore/cloud_firestore.dart';

class Atividade {
  final String id;
  final String titulo;
  final String tipo;
  final String ministrante;
  final String data;
  final String horario;
  final String descricao;
  final int vagas;

  Atividade({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.ministrante,
    required this.data,
    required this.horario,
    this.descricao = '',
    this.vagas = 0,
  });

  // vi que existe esse método 'factory' pra converter os dados vindos do Firebase em um objeto
  factory Atividade.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Atividade(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      tipo: data['tipo'] ?? '',
      ministrante: data['ministrante'] ?? '',
      data: data['data'] ?? '',
      horario: data['horario'] ?? '',
      descricao: data['descricao'] ?? '',
      vagas: data['vagas'] ?? 0,
    );
  }
}