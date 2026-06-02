import 'package:flutter/material.dart';

import '../../widgets/widgets_dashboard/cards.dart';
import '../../widgets/widgets_dashboard/common_widgets.dart';

class ProduccionPage extends StatelessWidget {
  const ProduccionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "Producción"),

        const SizedBox(height: 20),

        const ProductionCard(
          title: "Jícama Agua",
          value: "1200 KG",
          color: Colors.green,
        ),

        const ProductionCard(
          title: "Jícama Leche",
          value: "980 KG",
          color: Colors.orange,
        ),

        const ProductionCard(
          title: "Pepino",
          value: "640 KG",
          color: Colors.blue,
        ),

        const SizedBox(height: 30),

        const SectionTitle(title: "Rendimiento de Cultivos"),

        const SizedBox(height: 15),

        const PerformanceCard(
          title: "Jícama Agua",
          value: "92%",
          color: Colors.green,
        ),

        const PerformanceCard(
          title: "Jícama Leche",
          value: "81%",
          color: Colors.orange,
        ),

        const PerformanceCard(
          title: "Pepino",
          value: "74%",
          color: Colors.blue,
        ),

        const SizedBox(height: 30),

        const SectionTitle(title: "Estado del Sistema"),

        const SizedBox(height: 15),

        const SystemStatusCard(
          title: "Sensores",
          status: "Funcionando",
          color: Colors.green,
        ),

        const SystemStatusCard(
          title: "Servidor",
          status: "En línea",
          color: Colors.blue,
        ),

        const SystemStatusCard(
          title: "Riego Automático",
          status: "Activo",
          color: Colors.cyan,
        ),

        const SizedBox(height: 30),

        const SectionTitle(title: "Mantenimiento"),

        const SizedBox(height: 15),

        const InfoRow(title: "Mantenimientos realizados", value: "18"),

        const InfoRow(title: "Pendientes", value: "8"),

        const InfoRow(title: "Completados", value: "10"),

        const SizedBox(height: 30),

        const ReportButton(),
      ],
    );
  }
}
