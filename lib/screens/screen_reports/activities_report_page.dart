import 'package:flutter/material.dart';
import '../screen_reports/report_widgets.dart';

class ActivitiesReportPage extends StatelessWidget {
  const ActivitiesReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activities = [
      {"actividad": "Revisión de documentos", "progreso": "Completado"},
      {"actividad": "Capacitación equipo", "progreso": "En proceso"},
      {"actividad": "Reunión semanal", "progreso": "Completado"},
      {"actividad": "Auditoría interna", "progreso": "Pendiente"},
      {"actividad": "Reporte mensual", "progreso": "Completado"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Reporte de Actividades"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resumen de actividades",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                kpiCard(
                  title: "Completadas",
                  value: "18",
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
                kpiCard(
                  title: "En proceso",
                  value: "7",
                  color: Colors.orange,
                  icon: Icons.timelapse,
                ),
                kpiCard(
                  title: "Pendientes",
                  value: "4",
                  color: Colors.red,
                  icon: Icons.warning,
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Actividad mensual",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            chartPlaceholder("Distribución de actividades"),

            const SizedBox(height: 24),

            const Text(
              "Detalle de actividades",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 30,
                  headingRowColor: WidgetStateProperty.all(
                    Colors.grey.shade200,
                  ),
                  columns: const [
                    DataColumn(label: Text("Actividad")),
                    DataColumn(label: Text("Estado")),
                  ],
                  rows: activities.map((item) {
                    Color color;

                    switch (item["progreso"]) {
                      case "Completado":
                        color = Colors.green;
                        break;
                      case "En proceso":
                        color = Colors.orange;
                        break;
                      default:
                        color = Colors.red;
                    }

                    return DataRow(
                      cells: [
                        DataCell(Text(item["actividad"])),
                        DataCell(
                          Text(
                            item["progreso"],
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Acciones",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            exportButtons(),
          ],
        ),
      ),
    );
  }
}
