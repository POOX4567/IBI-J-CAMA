import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 👈 1. IMPORTA ESTO
import 'screens/login_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'package:ibi/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🛡️ 2. PONLE ESTE CANDADO: Si NO es web, inicializa las notificaciones
  if (!kIsWeb) {
    await NotificationService.init();
  } else {
    print("Corriendo en Web: Se desactivaron las notificaciones locales.");
  }

  runApp(const MyApp()); // 🚀 Ahora sí llegará aquí de inmediato en Edge/Chrome
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IBI-Jícama',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const BottomNavBar(),
      },
    );
  }
}
