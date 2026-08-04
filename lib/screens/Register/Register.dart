// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  String? _errorMessage;

  final Map<String, TextEditingController> _controllers = {
    'user': TextEditingController(),
    'name': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
    'street': TextEditingController(),
    'number': TextEditingController(),
    'suburb': TextEditingController(),
    'town': TextEditingController(),
    'postal_code': TextEditingController(),
    'facebook': TextEditingController(),
    'github': TextEditingController(),
    'linkedin': TextEditingController(),
    'profession': TextEditingController(),
    'description': TextEditingController(),
    'telephone': TextEditingController(),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_controllers['password']!.text !=
          _controllers['confirmPassword']!.text) {
        setState(() => _errorMessage = "Las contraseñas no coinciden");
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await http.post(
          Uri.parse('https://evidenciasti.com/api/smartgreen/register_api.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user': _controllers['user']!.text.trim(),
            'name': _controllers['name']!.text.trim(),
            'email': _controllers['email']!.text.trim(),
            'password': _controllers['password']!.text.trim(),
            'street': _controllers['street']!.text.trim(),
            'number': _controllers['number']!.text.trim(),
            'suburb': _controllers['suburb']!.text.trim(),
            'town': _controllers['town']!.text.trim(),
            'postal_code': _controllers['postal_code']!.text.trim(),
            'facebook': _controllers['facebook']!.text.trim(),
            'github': _controllers['github']!.text.trim(),
            'linkedin': _controllers['linkedin']!.text.trim(),
            'profession': _controllers['profession']!.text.trim(),
            'description': _controllers['description']!.text.trim(),
            'telephone': _controllers['telephone']!.text.trim(),
          }),
        );

        Map<String, dynamic> responseData;
        try {
          responseData = json.decode(response.body);
        } catch (_) {
          setState(() => _errorMessage = 'Respuesta inesperada del servidor.');
          return;
        }

        if (response.statusCode == 200 && responseData['success']) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Registro exitoso')));
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          setState(() {
            _errorMessage = responseData['message'] ?? 'Error al registrar';
          });
        }
      } catch (e) {
        setState(() => _errorMessage = 'Error de conexión');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _buildPage("Cuenta", [
                  _buildTextField("user", "Usuario", Icons.person),
                  _buildTextField("name", "Nombre", Icons.badge),
                  _buildTextField("email", "Correo", Icons.email),
                  _buildTextField(
                    "password",
                    "Contraseña",
                    Icons.lock,
                    isPassword: true,
                  ),
                  _buildTextField(
                    "confirmPassword",
                    "Confirmar Contraseña",
                    Icons.lock,
                    isPassword: true,
                  ),
                ]),
                _buildPage("Dirección", [
                  _buildTextField("street", "Calle", Icons.location_on),
                  _buildTextField("number", "Número", Icons.pin),
                  _buildTextField("suburb", "Colonia", Icons.map),
                  _buildTextField("town", "Ciudad", Icons.location_city),
                  _buildTextField(
                    "postal_code",
                    "Código Postal",
                    Icons.markunread_mailbox,
                  ),
                ]),
                _buildPage("Redes Sociales", [
                  _buildTextField("facebook", "Facebook", Icons.facebook),
                  _buildTextField("github", "GitHub", Icons.code),
                  _buildTextField("linkedin", "LinkedIn", Icons.work),
                ]),
                _buildPage("Profesional", [
                  _buildTextField("profession", "Profesión", Icons.school),
                  _buildTextField(
                    "description",
                    "Descripción",
                    Icons.description,
                  ),
                  _buildTextField("telephone", "Teléfono", Icons.phone),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (_currentPage > 0)
                _navButton("Atrás", Icons.arrow_back, _previousPage),
              if (_currentPage < 3)
                _navButton("Siguiente", Icons.arrow_forward, _nextPage),
              if (_currentPage == 3)
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: _greenButtonStyle(),
                      child: const Text("Registrarse"),
                    ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPage(String title, List<Widget> fields) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Text(title, style: _sectionTitle),
          const SizedBox(height: 10),
          ...fields.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: f,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String key,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: _controllers[key],
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3F3D46)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Color(0xFF3F3D46)),
      validator: (value) {
        if (value == null || value.isEmpty) return "Por favor, ingrese $label";
        if (key == 'email' && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return "Ingrese un correo válido";
        }
        if (key == 'telephone' && !RegExp(r'^\d{10,}$').hasMatch(value)) {
          return "Teléfono inválido";
        }
        return null;
      },
    );
  }

  ElevatedButton _navButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white)),
      style: _greenButtonStyle(),
    );
  }

  ButtonStyle _greenButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF34A853),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}

const TextStyle _sectionTitle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Color(0xFF34A853),
);
