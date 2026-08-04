import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Login/login_form.dart';
import '../Login/snake_clipper.dart';
import '../Login/login_styles.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.login(
        _userController.text.trim(),
        _passwordController.text,
      );

      if (result['success'] == true) {
        final userData = Map<String, dynamic>.from(result['user'] ?? {});

        final String token = result['token']?.toString() ?? '';

        final prefs = await SharedPreferences.getInstance();

        // Guardar token de Sanctum
        await _secureStorage.write(key: 'token', value: token);

        // Guardar datos del usuario
        await prefs.setInt('id', userData['id'] ?? 0);

        await prefs.setString('name', userData['name']?.toString() ?? '');

        await prefs.setString('email', userData['email']?.toString() ?? '');

        await prefs.setInt('rol_id', userData['rol_id'] ?? 0);

        await prefs.setInt('parent_id', userData['parent_id'] ?? 0);

        await prefs.setString(
          'telephone',
          userData['telephone']?.toString() ?? '',
        );

        // Guardar URL completa de la imagen
        await prefs.setString('image', userData['image']?.toString() ?? '');

        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/home');

        return;
      }

      if (!mounted) return;

      final msg = (result['message'] ?? '').toString().toLowerCase();

      setState(() {
        if (msg.contains('usuario')) {
          _errorMessage = 'Usuario no encontrado.';
        } else if (msg.contains('contraseña') || msg.contains('credenciales')) {
          _errorMessage = 'Contraseña incorrecta.';
        } else {
          _errorMessage =
              result['message']?.toString() ?? 'Credenciales inválidas.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'No se pudo conectar con el servidor.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _navigateForgotPassword() {
    Navigator.pushNamed(context, '/Securitypassword');
  }

  @override
  Widget build(BuildContext context) {
    final windowView = View.of(context);
    final displayWidth =
        windowView.physicalSize.width / windowView.devicePixelRatio;
    final displayHeight =
        windowView.physicalSize.height / windowView.devicePixelRatio;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: primaryGreen,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // ================================================================
            // 1. CAPA DE FONDO INMÓVIL
            // ================================================================
            Positioned(
              top: 0,
              left: 0,
              width: displayWidth,
              height: displayHeight,
              child: Stack(
                children: [
                  ClipPath(
                    clipper: SnakeClipper(),
                    child: Stack(
                      children: [
                        Container(
                          width: displayWidth,
                          height: displayHeight * 0.55,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/wheat_background.jpg',
                              ),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black26,
                                BlendMode.darken,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: displayWidth,
                          height: displayHeight * 0.55,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryGreen.withOpacity(0.98),
                                primaryGreen.withOpacity(0.65),
                                primaryGreen.withOpacity(0.10),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(painter: MultipleSnakePainter()),
                  ),
                ],
              ),
            ),

            // ================================================================
            // 2. BLOQUE UNIFICADO (Logo + Formulario juntos y centrados)
            // ================================================================
            SafeArea(
              child: Center(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: primaryGreen,
                      primary: primaryGreen,
                    ),
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: primaryGreen,
                      selectionColor: primaryGreen.withOpacity(0.3),
                      selectionHandleColor: primaryGreen,
                    ),
                    progressIndicatorTheme: const ProgressIndicatorThemeData(
                      linearTrackColor: Colors.transparent,
                      strokeWidth: 4.5,
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: displayWidth * 0.09,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 230),
                          curve: Curves.easeOutCubic,
                          height: isKeyboardOpen
                              ? displayHeight * 0.16
                              : displayHeight * 0.32,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        // TARJETA DEL FORMULARIO
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 226, 211, 171),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.20),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 22,
                          ),
                          child: LoginForm(
                            formKey: _formKey,
                            userController: _userController,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            togglePasswordVisibility: _togglePasswordVisibility,
                            isLoading: _isLoading,
                            errorMessage: _errorMessage,
                            onSubmit: _login,
                            onForgotPassword: _navigateForgotPassword,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
