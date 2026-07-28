import 'package:flutter/material.dart';

import 'production_report_page.dart';
import 'attendance_report_page.dart';
import 'maintenance_report_page.dart';
import 'incidents_report_page.dart';
import 'activities_report_page.dart';

import '../../widgets/dashboard_header.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),

      // ✅ BOTÓN DE REGRESO BIEN UBICADO
      appBar: AppBar(
        backgroundColor: const Color(0xff1B5E20),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            const DashboardHeader(
              title: "IBI Jícama",
              subtitle: "Dashboard General",
              logoPath: "assets/logo.png",
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildReportsGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsGrid() {
    final items = [
      _ReportItem(
        icon: Icons.eco,
        color: Colors.green,
        title: "Producción",
        subtitle: "Rendimiento por cultivo",
        page: const ProductionReportPage(),
      ),
      _ReportItem(
        icon: Icons.people,
        color: Colors.blue,
        title: "Asistencia",
        subtitle: "Control de empleados",
        page: const AttendanceReportPage(),
      ),
      _ReportItem(
        icon: Icons.build,
        color: Colors.orange,
        title: "Mantenimiento",
        subtitle: "Equipos y reparaciones",
        page: const MaintenanceReportPage(),
      ),

      _ReportItem(
        icon: Icons.warning,
        color: Colors.red,
        title: "Incidencias",
        subtitle: "Alertas del sistema",
        page: const IncidentsReportPage(),
      ),
      _ReportItem(
        icon: Icons.analytics,
        color: Colors.teal,
        title: "Actividades",
        subtitle: "Bitácora del sistema",
        page: const ActivitiesReportPage(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.95,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _reportGridCard(context, item);
          },
        ),
      ],
    );
  }

  Widget _reportGridCard(BuildContext context, _ReportItem item) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => item.page));
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),

            const Spacer(),

            Text(
              item.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              item.subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.bottomRight,
              child: Icon(Icons.arrow_forward_ios, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget page;

  _ReportItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.page,
  });
}
