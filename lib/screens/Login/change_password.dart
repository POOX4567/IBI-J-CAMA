import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordPage extends StatefulWidget {
  final String email;
  const ChangePasswordPage({super.key, required this.email});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _message;
  bool _success = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
      _success = false;
    });

    try {
      final response = await http
          .post(
            Uri.parse('https://evidenciasti.com/api/password/reset'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': widget.email,
              'token': _tokenController.text.trim(),
              'password': _passwordController.text.trim(),
              'password_confirmation': _confirmController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      setState(() {
        _message = data['message'] ?? 'Error al cambiar la contraseña.';
        _success = data['success'] ?? false;
      });

      if (_success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña cambiada con éxito')),
        );
        Navigator.pop(context); // Volver al login
      }
    } catch (e) {
      setState(() {
        _message = 'No se pudo conectar al servidor.';
        _success = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cambiar Contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _tokenController,
              decoration: const InputDecoration(labelText: 'Token del correo'),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Ingresa el token'
                          : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Nueva contraseña'),
              obscureText: true,
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Ingresa la contraseña'
                          : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _confirmController,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
              ),
              obscureText: true,
              validator:
                  (value) =>
                      value != _passwordController.text
                          ? 'Las contraseñas no coinciden'
                          : null,
            ),
            const SizedBox(height: 20),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(color: _success ? Colors.green : Colors.red),
              ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _resetPassword,
                  child: const Text('Cambiar contraseña'),
                ),
          ],
        ),
      ),
    );
  }
}
