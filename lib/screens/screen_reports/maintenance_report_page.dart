import 'package:flutter/material.dart';
import '../screen_reports/report_widgets.dart';

class MaintenanceReportPage extends StatelessWidget {
  const MaintenanceReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> equipment = [
      {
        "name": "Sensor de humedad #1",
        "status": "Pendiente",
        "priority": "Alta",
      },
      {
        "name": "Bomba de riego Norte",
        "status": "Completado",
        "priority": "Media",
      },
      {
        "name": "Sistema de ventilación",
        "status": "En proceso",
        "priority": "Alta",
      },
      {
        "name": "Controlador térmico",
        "status": "Pendiente",
        "priority": "Baja",
      },
      {
        "name": "Sensor de temperatura",
        "status": "Completado",
        "priority": "Media",
      },
    ];

    Color getStatusColor(String status) {
      switch (status) {
        case "Completado":
          return Colors.green;
        case "En proceso":
          return Colors.orange;
        default:
          return Colors.red;
      }
    }

    Color getPriorityColor(String priority) {
      switch (priority) {
        case "Alta":
          return Colors.red;
        case "Media":
          return Colors.orange;
        default:
          return Colors.green;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Reporte de Mantenimiento"),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resumen de mantenimiento",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                kpiCard(
                  title: "Pendientes",
                  value: "6",
                  color: Colors.red,
                  icon: Icons.build,
                ),
                kpiCard(
                  title: "En proceso",
                  value: "3",
                  color: Colors.orange,
                  icon: Icons.autorenew,
                ),
                kpiCard(
                  title: "Completados",
                  value: "14",
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
                kpiCard(
                  title: "Críticos",
                  value: "2",
                  color: Colors.deepPurple,
                  icon: Icons.warning,
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Tendencia de mantenimiento",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            chartPlaceholder("Mantenimientos por semana"),

            const SizedBox(height: 24),

            const Text(
              "Equipos y estado",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 30,
                  headingRowColor: WidgetStateProperty.all(
                    Colors.grey.shade200,
                  ),
                  columns: const [
                    DataColumn(label: Text("Equipo")),
                    DataColumn(label: Text("Estado")),
                    DataColumn(label: Text("Prioridad")),
                  ],
                  rows: equipment.map((e) {
                    final statusColor = getStatusColor(e["status"]);
                    final priorityColor = getPriorityColor(e["priority"]);

                    return DataRow(
                      cells: [
                        DataCell(Text(e["name"])),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              e["status"],
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              e["priority"],
                              style: TextStyle(
                                color: priorityColor,
                                fontWeight: FontWeight.w600,
                              ),
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
