import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/atividade_model.dart';
import '../interacao/participantes_atividade_screen.dart';
import '../administracao/checkin_manual_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  final TextEditingController _perguntaController = TextEditingController();
  bool _isOrganizador = false;
  
  @override
  void dispose() {
    _perguntaController.dispose();
    super.dispose();
  }

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
      final isMinistranteFirebase = userData?['isMinistrante'] ?? false; 
      final isOrganizadorFirebase = userData?['isOrganizador'] ?? false;

      setState(() {
        _estaInscrito = inscricaoDoc.exists;
        _isMinistrante = isMinistranteFirebase && user.uid == widget.atividade.ministranteId;
        _isOrganizador = isOrganizadorFirebase;
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

      final inicioAtividade = widget.atividade.dataHora;
      final fimAtividade = inicioAtividade.add(Duration(minutes: widget.atividade.duracao));

    for (var doc in inscricoesUsuario.docs) {
      final atvInscritaDoc = await firestore.collection('atividades').doc(doc['atividadeId']).get();
      
      if (atvInscritaDoc.exists) {
        final dadosBD = atvInscritaDoc.data() as Map<String, dynamic>;
        
        // extrai o Timestamp do Firebase e converte para DateTime
        final DateTime inicioB = (dadosBD['dataHora'] as Timestamp).toDate();
        final int duracaoB = dadosBD['duracao'] ?? 60;
        final DateTime fimB = inicioB.add(Duration(minutes: duracaoB));

        // duas atividades conflitam se: (Início A < Fim B) e (Fim A > Início B)
        bool temConflito = inicioAtividade.isBefore(fimB) && fimAtividade.isAfter(inicioB);

        if (temConflito) {
          throw Exception(
            'Conflito de horário! Você já está inscrito em "${dadosBD['titulo']}" que ocorre das '
            '${inicioB.hour.toString().padLeft(2, '0')}:${inicioB.minute.toString().padLeft(2, '0')} até '
            '${fimB.hour.toString().padLeft(2, '0')}:${fimB.minute.toString().padLeft(2, '0')}.'
          );
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

  void _mostrarQRCode() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final inscricaoId = '${widget.atividade.id}_${user.uid}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meu Ingresso', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Apresente este QR Code na entrada do evento para o Organizador.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                data: inscricaoId, // texto que o leitor vai ler
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white, // fundo branco
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Color(0xFFB80D48))),
          ),
        ],
      ),
    );
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

  Future<void> _enviarPergunta() async {
    final texto = _perguntaController.text.trim();
    if (texto.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    try {
      final userDoc = await firestore.collection('usuarios').doc(user!.uid).get();
      final nome = userDoc.data()?['nome'] ?? 'Anônimo';

      await firestore
          .collection('atividades')
          .doc(widget.atividade.id)
          .collection('perguntas')
          .add({
        'usuarioId': user.uid,
        'nomeUsuario': nome,
        'texto': texto,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _perguntaController.clear(); 
      _mostrarMensagem('Pergunta enviada!', Colors.green);
      
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      _mostrarMensagem('Erro ao enviar. Tente novamente.', Colors.red);
    }
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
            _buildInfoRow(
              Icons.calendar_today, 
              'Data: ${widget.atividade.dataHora.day.toString().padLeft(2, '0')}/${widget.atividade.dataHora.month.toString().padLeft(2, '0')}/${widget.atividade.dataHora.year}'
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time, 
              'Horário: ${widget.atividade.dataHora.hour.toString().padLeft(2, '0')}:${widget.atividade.dataHora.minute.toString().padLeft(2, '0')}'
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.timer, 'Duração: ${widget.atividade.duracao} minutos'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.group, 'Vagas disponíveis: ${widget.atividade.vagas}'),
            const SizedBox(height: 8),
            if (widget.atividade.local.isNotEmpty)
              _buildInfoRow(Icons.location_on, 'Local: ${widget.atividade.local}'),
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
              Column(
                children: [
                  if (_estaInscrito) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, 
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _mostrarQRCode,
                        icon: const Icon(Icons.qr_code_2, color: Colors.white),
                        label: const Text(
                          'Meu Ingresso (QR Code)', 
                          style: TextStyle(fontSize: 18, color: Colors.white)
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
               
                  SizedBox(
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _estaInscrito ? Colors.grey[700] : const Color(0xFFB80D48),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: (!_estaInscrito && (widget.atividade.atividadeAcontecendo || widget.atividade.atividadeEncerrada))
                                ? null 
                                : _processarAcao,
                            child: Text(
                              (!_estaInscrito && (widget.atividade.atividadeAcontecendo || widget.atividade.atividadeEncerrada))
                                  ? 'Inscrições encerradas' 
                                  : (_estaInscrito ? 'Cancelar Inscrição' : 'Inscrever-se'),
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                  ),
                ],
              ),

            // ==========================================
            // 1. ÁREA DE PERGUNTAS (Exclusivo Palestras)
            // ==========================================
            if (_estaInscrito && !_isMinistrante && widget.atividade.tipo == 'Palestra') ...[              
              const Divider(height: 32),
              const Text('Dúvidas para o palestrante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _perguntaController,
                      decoration: const InputDecoration(
                        hintText: 'Digite sua pergunta...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFFB80D48)),
                    onPressed: _enviarPergunta,
                  ),
                ],
              ),
            ], 

            // ==========================================
            // 2. ÁREA DO ORGANIZADOR (Check-in)
            // ==========================================
            if (_isOrganizador) ...[
              const SizedBox(height: 32), 
              const Divider(color: Colors.indigo, thickness: 1), 
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Área do Organizador', 
                  style: TextStyle(fontSize: 14, color: Colors.indigo, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo, 
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  
                  onPressed: widget.atividade.atividadeEncerrada
                      ? null // desabilita o botão se já encerrou
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckinManualScreen(atividade: widget.atividade),
                            ),
                          );
                        },
                  icon: const Icon(Icons.checklist, color: Colors.white),
                  label: Text(
                    widget.atividade.atividadeEncerrada 
                      ? 'Check-in indisponível (Atividade encerrada)' 
                        : 'Fazer Check-in', 
                    style: const TextStyle(fontSize: 18, color: Colors.white)
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

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
}