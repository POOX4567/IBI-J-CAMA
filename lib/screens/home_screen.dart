import 'package:flutter/material.dart';

import 'resumen_page.dart';
import 'empleados_page.dart';
import 'produccion_page.dart';

import '../widgets/dashboard_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),

      body: SafeArea(
        child: Column(
          children: [
            DashboardHeader(
              selectedTab: selectedTab,
              onTabChanged: (index) {
                setState(() {
                  selectedTab = index;
                });
              },
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: buildCurrentPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCurrentPage() {
    switch (selectedTab) {
      case 0:
        return const ResumenPage();

      case 1:
        return const EmpleadosPage();

      default:
        return const ProduccionPage();
    }
  }
}
