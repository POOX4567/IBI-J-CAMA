import 'package:flutter/material.dart';

import '../screens/screens_dashboard/resumen_page.dart';
import '../widgets/dashboard_header.dart';

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
              const DashboardHeader(
                title: "IBI Jícama",
                subtitle: "Dashboard General",
                logoPath: "assets/logo.png",
              ),

              const Padding(padding: EdgeInsets.all(16), child: ResumenPage()),
            ],
          ),
        ),
      ),
    );
  }
}
