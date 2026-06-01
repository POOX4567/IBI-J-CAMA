import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text("Reportes y Análisis"),
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          reportMenuCard(
            context,
            Icons.eco,
            "Historial de Producción",
            "Ver producción total por cultivo",
            const ProductionReportPage(),
            Colors.green,
          ),

          reportMenuCard(
            context,
            Icons.people,
            "Asistencia y Horarios",
            "Control de empleados y asistencia",
            const AttendanceReportPage(),
            Colors.blue,
          ),

          reportMenuCard(
            context,
            Icons.build,
            "Mantenimiento",
            "Estado de mantenimiento",
            const MaintenanceReportPage(),
            Colors.orange,
          ),

          reportMenuCard(
            context,
            Icons.compare_arrows,
            "Comparación de Invernaderos",
            "Rendimiento por invernadero",
            const GreenhouseReportPage(),
            Colors.purple,
          ),

          reportMenuCard(
            context,
            Icons.warning,
            "Incidencias y Alertas",
            "Eventos y fallas registradas",
            const IncidentsReportPage(),
            Colors.red,
          ),

          reportMenuCard(
            context,
            Icons.analytics,
            "Análisis de Actividades",
            "Resumen de actividad general",
            const ActivitiesReportPage(),
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget reportMenuCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }
}

//
// ===================== VISTAS INTERNAS =====================
//

class ProductionReportPage extends StatelessWidget {
  const ProductionReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ReportTemplate(
      title: "Producción Total",
      icon: Icons.eco,
      color: Colors.green,
      content: "Jícama Agua: 1200 Kg\nJícama Leche: 980 Kg\nPepino: 640 Kg",
    );
  }
}

class AttendanceReportPage extends StatelessWidget {
  const AttendanceReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ReportTemplate(
      title: "Control de Empleados",
      icon: Icons.people,
      color: Colors.blue,
      content: "48 empleados\n40 presentes\n5 ausentes\n3 retardos",
    );
  }
}

class MaintenanceReportPage extends StatelessWidget {
  const MaintenanceReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ReportTemplate(
      title: "Mantenimiento",
      icon: Icons.build,
      color: Colors.orange,
      content: "18 realizados\n8 pendientes\n10 completados",
    );
  }
}

class GreenhouseReportPage extends StatelessWidget {
  const GreenhouseReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ReportTemplate(
      title: "Comparación de Invernaderos",
      icon: Icons.compare_arrows,
      color: Colors.purple,
      content: "Invernadero 1: 92%\nInvernadero 2: 85%\nInvernadero 3: 88%",
    );
  }
}

class IncidentsReportPage extends StatelessWidget {
  const IncidentsReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ReportTemplate(
      title: "Incidencias y Alertas",
      icon: Icons.warning,
      color: Colors.red,
      content: "5 alertas activas\n2 fallas de riego\n1 sensor desconectado",
    );
  }
}

class ActivitiesReportPage extends StatelessWidget {
  const ActivitiesReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ReportTemplate(
      title: "Análisis de Actividades",
      icon: Icons.analytics,
      color: Colors.teal,
      content: "25 eventos diarios\n148 semanales\n620 mensuales",
    );
  }
}

//
// ===================== TEMPLATE REUTILIZABLE =====================
//

class _ReportTemplate extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String content;

  const _ReportTemplate({
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(content, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
