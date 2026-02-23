import 'package:cloud_firestore/cloud_firestore.dart';
class Atividade {
  final String id;
  final String titulo;
  final String tipo;
  final String ministrante;
  final String ministranteId;
  final DateTime dataHora;
  final int duracao; 
  final String descricao;
  final int vagas;

  Atividade({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.ministrante,
    required this.ministranteId,
    required this.dataHora,
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
      dataHora: (data['dataHora'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duracao: data['duracao'] ?? 60,
      descricao: data['descricao'] ?? '',
      vagas: data['vagas'] ?? 0,
    );
  }

  bool get atividadeProxima {
    final agora = DateTime.now();
    final diferenca = dataHora.difference(agora);
    return !diferenca.isNegative && diferenca.inMinutes <= 30; 
  }

  bool get atividadeAcontecendo {
    final agora = DateTime.now();
    final fim = dataHora.add(Duration(minutes: duracao));
    return agora.isAfter(dataHora) && agora.isBefore(fim);
  }

  bool get atividadeEncerrada => DateTime.now().isAfter(dataHora.add(Duration(minutes: duracao)));

  String get dataFormatada => "${dataHora.day.toString().padLeft(2, '0')}/${dataHora.month.toString().padLeft(2, '0')}/${dataHora.year}";
  String get horarioFormatado => "${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}";


}