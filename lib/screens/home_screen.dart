import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Rutas de tus pantallas y componentes corporativos
import '../screens/screens_dashboard/resumen_page.dart';
import '../widgets/dashboard_header.dart';
// Ruta corregida a la carpeta donde decidiste guardar tu Provider local
import '../../services/resumen_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Encabezado corporativo del invernadero
              const DashboardHeader(
                title: "IBI Jícama",
                subtitle: "Dashboard General",
                logoPath: "assets/logo.png",
              ),

              // Envoltura con Padding para que las tarjetas y secciones respiren
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ChangeNotifierProvider(
                  // Adaptado: Se crea el provider de forma directa en memoria
                  // Ya no necesita el "..fetchSummaryData()" porque los datos se cargan solitos al nacer
                  create: (context) => ResumenProvider(),
                  child: const ResumenPage(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
