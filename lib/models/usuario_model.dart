import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id;
  final String nome;
  final String email;
  final bool isOrganizador;
  final bool isPalestrante;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.isOrganizador = false,
    this.isPalestrante = false,
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      isOrganizador: data['isOrganizador'] ?? false,
      isPalestrante: data['isPalestrante'] ?? false,
    );
  }
}