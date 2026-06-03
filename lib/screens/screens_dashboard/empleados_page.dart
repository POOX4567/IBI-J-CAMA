import 'package:flutter/material.dart';

import '../../widgets/widgets_dashboard/cards.dart';
import '../../widgets/widgets_dashboard/common_widgets.dart';

class EmpleadosPage extends StatelessWidget {
  const EmpleadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "Control de Empleados"),

        const SizedBox(height: 20),

        const EmployeeCard(
          name: "Juan Pérez",
          status: "Presente",
          color: Colors.green,
        ),

        const EmployeeCard(
          name: "Carlos López",
          status: "Ausente",
          color: Colors.red,
        ),

        const EmployeeCard(
          name: "María Torres",
          status: "Retardo",
          color: Colors.orange,
        ),

        const EmployeeCard(
          name: "Luis Martínez",
          status: "Presente",
          color: Colors.green,
        ),

        const SizedBox(height: 30),

        const SectionTitle(title: "Horarios Activos"),

        const SizedBox(height: 15),

        const ScheduleCard(
          title: "Turno Matutino",
          subtitle: "06:00 AM - 02:00 PM",
        ),

        const ScheduleCard(
          title: "Turno Vespertino",
          subtitle: "02:00 PM - 10:00 PM",
        ),

        const ScheduleCard(
          title: "Turno Nocturno",
          subtitle: "10:00 PM - 06:00 AM",
        ),

        const SizedBox(height: 30),

        const SectionTitle(title: "Asistencia General"),

        const SizedBox(height: 15),

        const InfoRow(title: "Total empleados", value: "48"),

        const InfoRow(title: "Presentes", value: "40"),

        const InfoRow(title: "Ausentes", value: "5"),

        const InfoRow(title: "Retardos", value: "3"),

        const SizedBox(height: 30),

        const ReportButton(),
      ],
    );
  }
}
