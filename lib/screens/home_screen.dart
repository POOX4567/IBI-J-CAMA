import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Rutas a tus widgets, pantallas y providers
import 'screens_dashboard/resumen_page.dart';
import '../services/resumen_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ChangeNotifierProvider(
        create: (context) => ResumenProvider(),
        child: const ResumenPage(),
      ),
    );
  }
}
