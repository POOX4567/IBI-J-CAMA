import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SecurityPassword extends StatefulWidget {
  const SecurityPassword({super.key});

  @override
  State<SecurityPassword> createState() => _SecurityPasswordState();
}

class _SecurityPasswordState extends State<SecurityPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Por favor, ingresa tu correo.');
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse(
          "https://tudominio.com/api/reset-password",
        ), // 🔹 Cambia a tu endpoint real
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _showMessage('Correo de recuperación enviado con éxito.');
      } else {
        _showMessage(data['message'] ?? 'Error al enviar el correo.');
      }
    } catch (e) {
      _showMessage('Error de conexión: $e');
    }

    setState(() => _loading = false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ingresa tu correo para restablecer tu contraseña',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _resetPassword,
                  child: const Text('Enviar'),
                ),
          ],
        ),
      ),
    );
  }
}
