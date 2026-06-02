import 'package:flutter/material.dart';

import '../../widgets/widgets_dashboard/cards.dart';
import '../../widgets/widgets_dashboard/common_widgets.dart';

class ResumenPage extends StatelessWidget {
  const ResumenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Estado General",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1,
          children: const [
            InfoCard(
              title: "Invernaderos",
              value: "10/12",
              subtitle: "Activos",
              icon: Icons.eco,
              color: Colors.green,
            ),

            InfoCard(
              title: "Empleados",
              value: "28/48",
              subtitle: "En turno",
              icon: Icons.people,
              color: Colors.blue,
            ),

            InfoCard(
              title: "Alertas",
              value: "5",
              subtitle: "Activas",
              icon: Icons.warning,
              color: Colors.red,
            ),

            InfoCard(
              title: "Mantenimiento",
              value: "8",
              subtitle: "Pendientes",
              icon: Icons.build,
              color: Colors.orange,
            ),
          ],
        ),

        const SizedBox(height: 30),

        const SectionTitle(title: "Alertas Importantes"),

        const SizedBox(height: 15),

        const AlertCard(
          title: "Temperatura Alta",
          subtitle: "Invernadero 2",
          color: Colors.red,
        ),

        const AlertCard(
          title: "Falla de Riego",
          subtitle: "Zona Norte",
          color: Colors.orange,
        ),

        const AlertCard(
          title: "Sensor Desconectado",
          subtitle: "Invernadero 5",
          color: Colors.blue,
        ),

        const SizedBox(height: 30),

        const SectionTitle(title: "Resumen de Actividad"),

        const SizedBox(height: 15),

        const SummaryCard(
          title: "Actividad Diaria",
          subtitle: "25 eventos registrados",
          icon: Icons.today,
          color: Colors.green,
        ),

        const SummaryCard(
          title: "Actividad Semanal",
          subtitle: "148 eventos registrados",
          icon: Icons.calendar_view_week,
          color: Colors.blue,
        ),

        const SummaryCard(
          title: "Actividad Mensual",
          subtitle: "620 eventos registrados",
          icon: Icons.calendar_month,
          color: Colors.orange,
        ),

        const SizedBox(height: 30),

        const SectionTitle(title: "Actividad Reciente"),

        const SizedBox(height: 15),

        const ActivityCard(
          icon: Icons.build,
          title: "Mantenimiento realizado",
          time: "Hace 1 hora",
          color: Colors.blue,
        ),

        const ActivityCard(
          icon: Icons.water_drop,
          title: "Riego automático activado",
          time: "Hace 3 horas",
          color: Colors.cyan,
        ),

        const ActivityCard(
          icon: Icons.eco,
          title: "Producción actualizada",
          time: "Hoy",
          color: Colors.green,
        ),

        const SizedBox(height: 30),

        const ReportButton(),
      ],
    );
  }
}
