import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Componentes visuales del Dashboard
import '../../widgets/widgets_dashboard/cards.dart';
import '../../widgets/widgets_dashboard/common_widgets.dart';

// Arquitectura de Providers
import '../../services/resumen_provider.dart';

// Rutas de las Pantallas de Reportes
import 'package:ibi/screens/screen_reports/activities_report_page.dart';
import 'package:ibi/screens/screen_reports/attendance_report_page.dart';
import 'package:ibi/screens/screen_reports/incidents_report_page.dart';
import 'package:ibi/screens/screen_reports/maintenance_report_page.dart';
import 'package:ibi/screens/screen_reports/production_report_page.dart';

class ResumenPage extends StatelessWidget {
  const ResumenPage({super.key});

  /// Diálogo dinámico para desplegar la información devuelta por los endpoints
  void _mostrarDetalles(BuildContext context, String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Entendido",
                style: TextStyle(
                  color: Color(0xFF1B5E20),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos de manera reactiva el proveedor que realiza los http.get a la API
    final resumenData = context.watch<ResumenProvider>();

    final inv = resumenData.tarjetasPrincipales['invernaderos'];
    final emp = resumenData.tarjetasPrincipales['empleados'];
    final ale = resumenData.tarjetasPrincipales['alertas'];
    final mant = resumenData.tarjetasPrincipales['mantenimiento'];

    // Manejo de estado seguro mientras el Provider procesa las llamadas asíncronas
    if (resumenData.isLoading ||
        inv == null ||
        emp == null ||
        ale == null ||
        mant == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
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

          // 1. Grid de Métricas Principales conectadas a la API
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1,
            children: [
              // Invernaderos
              InfoCard(
                title: inv.titulo,
                value: inv.valor,
                subtitle: inv.subtitulo,
                icon: Icons.eco,
                color: Colors.green,
                onTap: () {
                  if (inv.detalleAlerta.isNotEmpty) {
                    _mostrarDetalles(context, inv.titulo, inv.detalleAlerta);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductionReportPage(),
                      ),
                    );
                  }
                },
              ),
              // Empleados (Conexión /api/employees)
              InfoCard(
                title: emp.titulo,
                value: emp.valor,
                subtitle: emp.subtitulo,
                icon: Icons.people,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AttendanceReportPage(),
                    ),
                  );
                },
              ),
              // Alertas (Conexión /api/incidents)
              InfoCard(
                title: ale.titulo,
                value: ale.valor,
                subtitle: ale.subtitulo,
                icon: Icons.warning,
                color: Colors.red,
                onTap: () {
                  if (ale.detalleAlerta.isNotEmpty) {
                    _mostrarDetalles(context, ale.titulo, ale.detalleAlerta);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IncidentsReportPage(),
                      ),
                    );
                  }
                },
              ),
              // Mantenimiento (Conexión /api/mantenimiento)
              InfoCard(
                title: mant.titulo,
                value: mant.valor,
                subtitle: mant.subtitulo,
                icon: Icons.build,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MaintenanceReportPage(),
                    ),
                  );
                },
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
                color:
                    alerta.titulo.contains("Temperatura") ||
                        alerta.detalleAlerta.contains("Alta")
                    ? Colors.red
                    : (alerta.titulo.contains("Riego") ||
                              alerta.detalleAlerta.contains("Media")
                          ? Colors.orange
                          : Colors.blue),
                onTap: () => _mostrarDetalles(
                  context,
                  alerta.titulo,
                  alerta.detalleAlerta,
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

          // 4. Historial Reciente mapeado dinámicamente desde el backend
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
                onTap: () => _mostrarDetalles(
                  context,
                  actividad.titulo,
                  actividad.detalleAlerta,
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
