import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/atividade_model.dart';
import '../perfil/participantes_atividade_screen.dart';

class DetalhesAtividadeScreen extends StatefulWidget {
  final Atividade atividade;

  const DetalhesAtividadeScreen({super.key, required this.atividade});

  @override
  State<DetalhesAtividadeScreen> createState() => _DetalhesAtividadeScreenState();
}

class _DetalhesAtividadeScreenState extends State<DetalhesAtividadeScreen> {
  bool _isLoading = false;
  bool _estaInscrito = false;
  bool _isMinistrante = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final inscricaoDoc = await FirebaseFirestore.instance
        .collection('inscricoes')
        .doc('${widget.atividade.id}_${user.uid}')
        .get();

    final usuarioDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    if (mounted) {
      final userData = usuarioDoc.data();
      final isMinistranteFirebase = userData?['isMinistrante'] ?? false; // Mudou aqui

      setState(() {
        _estaInscrito = inscricaoDoc.exists;
        _isMinistrante = isMinistranteFirebase && user.uid == widget.atividade.ministranteId;
      });
    }
  }

  Future<void> _processarAcao() async {
    if (_estaInscrito) {
      await _cancelarInscricao();
    } else {
      await _realizarInscricao();
    }
  }

  Future<void> _realizarInscricao() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    final firestore = FirebaseFirestore.instance;

    try {
      final inscricoesUsuario = await firestore
          .collection('inscricoes')
          .where('usuarioId', isEqualTo: user.uid)
          .get();

      for (var doc in inscricoesUsuario.docs) {
        final atvInscritaDoc = await firestore.collection('atividades').doc(doc['atividadeId']).get();
        
        if (atvInscritaDoc.exists) {
          final dataInscrita = atvInscritaDoc['data'];
          
          // só verifica conflito se for no mesmo dia
          if (dataInscrita == widget.atividade.data) {
            final horarioInscrita = atvInscritaDoc['horario'];
            // se for uma atividade antiga no banco sem duração assume 60 min para não crashar
            final duracaoInscrita = atvInscritaDoc.data()?.toString().contains('duracao') == true 
                ? atvInscritaDoc['duracao'] 
                : 60; 
            
            // calcula o tempo da Nova Atividade (A)
            final inicioA = _horarioParaMinutos(widget.atividade.horario);
            final fimA = inicioA + widget.atividade.duracao;
            
            // calcula o tempo da Atividade Já Inscrita (B)
            final inicioB = _horarioParaMinutos(horarioInscrita);
            final fimB = inicioB + duracaoInscrita;
            
            // lógica de conflito
            if (inicioA < fimB && fimA > inicioB) {
              throw Exception('Conflito de horário! Você já está inscrito em "${atvInscritaDoc['titulo']}" neste mesmo período.');
            }
          }
        }
      }

      final atividadeRef = firestore.collection('atividades').doc(widget.atividade.id);
      final inscricaoRef = firestore.collection('inscricoes').doc('${widget.atividade.id}_${user.uid}');

      await firestore.runTransaction((transaction) async {
        final atividadeSnapshot = await transaction.get(atividadeRef);
        final int vagasAtuais = atividadeSnapshot.data()?['vagas'] ?? 0;

        if (vagasAtuais <= 0) {
          throw Exception('Não há vagas disponíveis para esta atividade.');
        }

        transaction.update(atividadeRef, {'vagas': vagasAtuais - 1});
        transaction.set(inscricaoRef, {
          'atividadeId': widget.atividade.id,
          'usuarioId': user.uid,
          'tituloAtividade': widget.atividade.titulo,
          'dataHoraInscricao': FieldValue.serverTimestamp(),
        });
      });

      _mostrarMensagem('Inscrição confirmada com sucesso!', Colors.green);
      if (mounted) setState(() => _estaInscrito = true);
      
    } catch (e) {
      _mostrarMensagem(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelarInscricao() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    final firestore = FirebaseFirestore.instance;

    try {
      final atividadeRef = firestore.collection('atividades').doc(widget.atividade.id);
      final inscricaoRef = firestore.collection('inscricoes').doc('${widget.atividade.id}_${user.uid}');

      await firestore.runTransaction((transaction) async {
        final atividadeSnapshot = await transaction.get(atividadeRef);
        final int vagasAtuais = atividadeSnapshot.data()?['vagas'] ?? 0;

        transaction.update(atividadeRef, {'vagas': vagasAtuais + 1});
        transaction.delete(inscricaoRef);
      });

      _mostrarMensagem('Inscrição cancelada com sucesso.', Colors.orange);
      if (mounted) setState(() => _estaInscrito = false);
    } catch (e) {
      _mostrarMensagem('Erro ao cancelar: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarMensagem(String texto, Color cor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: cor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Atividade')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCorPorTipo(widget.atividade.tipo),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.atividade.tipo,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.atividade.titulo,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Ministrante: ${widget.atividade.ministrante}'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, 'Data: ${widget.atividade.data}'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time, 'Horário: ${widget.atividade.horario}'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.timer, 'Duração: ${widget.atividade.duracao} minutos'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.group, 'Vagas disponíveis: ${widget.atividade.vagas}'),
            const SizedBox(height: 24),
            const Text(
              'Descrição',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.atividade.descricao.isEmpty ? 'Nenhuma descrição informada.' : widget.atividade.descricao,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            if (_isMinistrante)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB80D48),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParticipantesAtividadeScreen(atividade: widget.atividade),
                      ),
                    );
                  },
                  icon: const Icon(Icons.groups, color: Colors.white),
                  label: const Text('Ver Participantes', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _estaInscrito ? Colors.grey[700] : const Color(0xFFB80D48),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _processarAcao,
                        child: Text(
                          _estaInscrito ? 'Cancelar Inscrição' : 'Inscrever-se',
                          style: const TextStyle(fontSize: 18, color: Colors.white),
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
      case 'Palestra': return Colors.orange;
      case 'Minicurso': return Colors.green;
      case 'Oficina': return Colors.cyan;
      default: return Colors.grey;
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  int _horarioParaMinutos(String horario) {
    final partes = horario.split(':');
    if (partes.length != 2) return 0;
    
    final horas = int.tryParse(partes[0]) ?? 0;
    final minutos = int.tryParse(partes[1]) ?? 0;
    
    return (horas * 60) + minutos;
  }
}