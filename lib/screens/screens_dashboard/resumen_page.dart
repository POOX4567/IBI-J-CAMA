import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Componentes visuales del Dashboard
import '../../widgets/widgets_dashboard/cards.dart';
import '../../widgets/widgets_dashboard/common_widgets.dart';

// Arquitectura de Providers
import '../../services/resumen_provider.dart';

// ⚡ IMPORTACIONES ABSOLUTAS CON RUTAS DEL PAQUETE (Sin errores de rutas relativas)
import 'package:ibi/screens/screen_reports/activities_report_page.dart';
import 'package:ibi/screens/screen_reports/attendance_report_page.dart';
import 'package:ibi/screens/screen_reports/incidents_report_page.dart';
import 'package:ibi/screens/screen_reports/maintenance_report_page.dart';
import 'package:ibi/screens/screen_reports/production_report_page.dart';

class ResumenPage extends StatelessWidget {
  const ResumenPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos de manera reactiva el proveedor de datos
    final resumenData = context.watch<ResumenProvider>();

    final inv = resumenData.tarjetasPrincipales['invernaderos'];
    final emp = resumenData.tarjetasPrincipales['empleados'];
    final ale = resumenData.tarjetasPrincipales['alertas'];
    final mant = resumenData.tarjetasPrincipales['mantenimiento'];

    // Manejo de estado seguro en caso de que los datos aún no hayan inicializado
    if (inv == null || emp == null || ale == null || mant == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0D47A1)),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Estado General",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // 1. Grid de Métricas Principales
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1,
            children: [
              InfoCard(
                title: inv.titulo,
                value: inv.valor,
                subtitle: inv.subtitulo,
                icon: Icons.eco,
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductionReportPage(),
                  ),
                ),
              ),
              InfoCard(
                title: emp.titulo,
                value: emp.valor,
                subtitle: emp.subtitulo,
                icon: Icons.people,
                color: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceReportPage(),
                  ),
                ),
              ),
              InfoCard(
                title: ale.titulo,
                value: ale.valor,
                subtitle: ale.subtitulo,
                icon: Icons.warning,
                color: Colors.red,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IncidentsReportPage(),
                  ),
                ),
              ),
              InfoCard(
                title: mant.titulo,
                value: mant.valor,
                subtitle: mant.subtitulo,
                icon: Icons.build,
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MaintenanceReportPage(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // 2. Alertas Importantes mapeadas dinámicamente
          if (resumenData.alertasImportantes.isNotEmpty) ...[
            const SectionTitle(title: "Alertas Importantes"),
            const SizedBox(height: 15),
            ...resumenData.alertasImportantes.map(
              (alerta) => AlertCard(
                title: alerta.titulo,
                subtitle: alerta.subtitulo,
                color: alerta.titulo.contains("Temperatura")
                    ? Colors.red
                    : (alerta.titulo.contains("Riego")
                          ? Colors.orange
                          : Colors.blue),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IncidentsReportPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          // 3. Resumen de Actividades mapeado dinámicamente
          if (resumenData.resumenActividad.isNotEmpty) ...[
            const SectionTitle(title: "Resumen de Actividad"),
            const SizedBox(height: 15),
            ...resumenData.resumenActividad.map(
              (resumen) => SummaryCard(
                title: resumen.titulo,
                subtitle: resumen.subtitulo,
                icon: resumen.titulo.contains("Diaria")
                    ? Icons.today
                    : (resumen.titulo.contains("Semanal")
                          ? Icons.calendar_view_week
                          : Icons.calendar_month),
                color: resumen.titulo.contains("Diaria")
                    ? Colors.green
                    : (resumen.titulo.contains("Semanal")
                          ? Colors.blue
                          : Colors.orange),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivitiesReportPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          // 4. Historial Reciente mapeado dinámicamente
          if (resumenData.actividadReciente.isNotEmpty) ...[
            const SectionTitle(title: "Actividad Reciente"),
            const SizedBox(height: 15),
            ...resumenData.actividadReciente.map(
              (actividad) => ActivityCard(
                icon: actividad.titulo.contains("Mantenimiento")
                    ? Icons.build
                    : (actividad.titulo.contains("Riego")
                          ? Icons.water_drop
                          : Icons.eco),
                title: actividad.titulo,
                time: actividad.subtitulo,
                color: actividad.titulo.contains("Mantenimiento")
                    ? Colors.blue
                    : (actividad.titulo.contains("Riego")
                          ? Colors.cyan
                          : Colors.green),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivitiesReportPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }
}
