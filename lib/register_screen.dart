import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Color primaryColor = const Color(0xFFB1124C);

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();
  final TextEditingController _cursoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmSenhaController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _cursoController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Logo
              Center(
                child: Image.asset(
                  'assets/semana_da_computacao_logo.png',
                  height: 160,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Realize o cadastro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              _input('Nome', Icons.person, controller: _nomeController),
              const SizedBox(height: 12),

              _input('Sobrenome', Icons.person_outline, controller: _sobrenomeController),
              const SizedBox(height: 12),

              _input('Curso', Icons.school, controller: _cursoController),
              const SizedBox(height: 12),

              _input('Email', Icons.email, controller: _emailController),
              const SizedBox(height: 12),

              _input('Senha', Icons.lock, controller: _senhaController, obscure: true),
              const SizedBox(height: 12),

              _input('Confirmar senha', Icons.lock_outline, controller: _confirmSenhaController, obscure: true),
              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _registrarUsuario,
                      child: const Text(
                        'Registrar-se',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar para login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _input(String hint, IconData icon,
      {required TextEditingController controller, bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _registrarUsuario() async {
    String nome = _nomeController.text.trim();
    String sobrenome = _sobrenomeController.text.trim();
    String curso = _cursoController.text.trim();
    String email = _emailController.text.trim();
    String senha = _senhaController.text.trim();
    String confirmSenha = _confirmSenhaController.text.trim();

    if (nome.isEmpty || sobrenome.isEmpty || curso.isEmpty || email.isEmpty || senha.isEmpty || confirmSenha.isEmpty) {
      _showSnackbar('Preencha todos os campos');
      return;
    }

    if (senha.length < 8) {
      _showSnackbar('A senha deve ter pelo menos 8 caracteres');
      return;
    }

    if (senha != confirmSenha) {
      _showSnackbar('As senhas não coincidem');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Criar usuário no Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: senha);

      // Salvar dados adicionais no Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'nome': nome,
        'sobrenome': sobrenome,
        'curso': curso,
        'email': email,
        'uid': userCredential.user!.uid,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      _showSnackbar('Usuário registrado com sucesso!');
      Navigator.pop(context); // Volta para login
    } on FirebaseAuthException catch (e) {
      _showSnackbar('Erro: ${e.code} - ${e.message}');
    } catch (e) {
      _showSnackbar('Erro inesperado: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
