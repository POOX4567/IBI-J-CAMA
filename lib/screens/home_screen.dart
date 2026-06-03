import 'package:flutter/material.dart';

import '../screens/screens_dashboard/resumen_page.dart';
import '../screens/screens_dashboard/empleados_page.dart';
import '../screens/screens_dashboard/produccion_page.dart';
import '../widgets/dashboard_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;

  Widget buildCurrentPage() {
    switch (selectedTab) {
      case 0:
        return const ResumenPage();

      case 1:
        return const EmpleadosPage();

      case 2:
        return const ProduccionPage();

      default:
        return const ResumenPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              DashboardHeader(
                title: "IBI Jícama",
                subtitle: "Dashboard General",
                logoPath: "assets/logo.png",

                selectedTab: selectedTab,

                onTabChanged: (index) {
                  setState(() {
                    selectedTab = index;
                  });
                },

                tabs: const ["Resumen", "Empleados", "Producción"],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: buildCurrentPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
