import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'login_styles.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback togglePasswordVisibility;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.userController,
    required this.passwordController,
    required this.obscurePassword,
    required this.togglePasswordVisibility,
    required this.isLoading,
    this.errorMessage,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Iniciar sesión',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 25, 88, 27),
            ),
          ),

          const SizedBox(height: 36),

          if (errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          TextFormField(
            controller: userController,
            enabled: !isLoading,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            decoration: inputDecoration('Usuario', Icons.person),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingrese su usuario';
              }

              if (value.trim().length < 3) {
                return 'Usuario inválido';
              }

              return null;
            },
          ),

          const SizedBox(height: 30),

          TextFormField(
            controller: passwordController,
            enabled: !isLoading,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            decoration: inputDecoration('Contraseña', Icons.lock).copyWith(
              suffixIcon: IconButton(
                onPressed: isLoading ? null : togglePasswordVisibility,
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese su contraseña';
              }

              if (value.length < 5) {
                return 'Debe tener mínimo 5 caracteres';
              }

              return null;
            },
            onFieldSubmitted: (_) {
              FocusScope.of(context).unfocus();

              if (!isLoading) {
                onSubmit();
              }
            },
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isLoading ? null : onForgotPassword,
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: Color.fromARGB(255, 29, 76, 31)),
              ),
            ),
          ),

          const SizedBox(height: 15),

          if (isLoading)
            SizedBox(
              width: 100,
              height: 100,
              child: Lottie.asset('/lottie/extras/leaf_loading.json'),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 40, 70, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(65),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
