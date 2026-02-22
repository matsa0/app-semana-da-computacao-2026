import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/atividade_model.dart';

class CheckinQrCodeScreen extends StatefulWidget {
  final Atividade atividade;

  const CheckinQrCodeScreen({super.key, required this.atividade});

  @override
  State<CheckinQrCodeScreen> createState() => _CheckinQrCodeScreenState();
}

class _CheckinQrCodeScreenState extends State<CheckinQrCodeScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  Future<void> _processarQRCode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() { _isProcessing = true; });

    //  verifica se o ingresso é dessa atividade específica
    if (!code.startsWith(widget.atividade.id)) {
      _mostrarMensagem('Ingresso inválido para esta atividade.', Colors.red);
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance.collection('inscricoes').doc(code);
      final docSnap = await docRef.get();

      // veifica se a pessoa realmente tá inscrita
      if (!docSnap.exists) {
        _mostrarMensagem('Inscrição não encontrada no sistema.', Colors.red);
        return;
      }

      final data = docSnap.data() as Map<String, dynamic>;
      
      // verifica se já fez checkin antes
      if (data['presente'] == true) {
        _mostrarMensagem('Check-in já foi realizado anteriormente!', Colors.orange);
        return;
      }

      await docRef.update({'presente': true});
      _mostrarMensagem('Check-in realizado com sucesso!', Colors.green);

    } catch (e) {
      _mostrarMensagem('Erro no sistema: $e', Colors.red);
    }
  }

  void _mostrarMensagem(String msg, Color cor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: const TextStyle(fontSize: 16)), backgroundColor: cor),
    );
    
    // espera 2 segundino antes de liberar a câmera para ler o próximo ingresso
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() { _isProcessing = false; });
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Ingresso'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _processarQRCode,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Validando ingresso...', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.black87,
              child: const Text(
                'Aponte a câmera para o QR Code do participante.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}