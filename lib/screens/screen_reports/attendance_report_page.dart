import 'package:flutter/material.dart';
import '../screen_reports/report_widgets.dart';

class AttendanceReportPage extends StatelessWidget {
  const AttendanceReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> employees = [
      {"name": "Juan Pérez", "status": "Presente"},
      {"name": "Carlos López", "status": "Ausente"},
      {"name": "María Gómez", "status": "Tarde"},
      {"name": "Ana Torres", "status": "Presente"},
      {"name": "Luis Hernández", "status": "Presente"},
      {"name": "Sofía Ramírez", "status": "Ausente"},
    ];

    Color getStatusColor(String status) {
      switch (status) {
        case "Presente":
          return Colors.green;
        case "Tarde":
          return Colors.orange;
        default:
          return Colors.red;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Reporte de Asistencia"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resumen general",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // KPI SECTION
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                kpiCard(
                  title: "Presentes hoy",
                  value: "42",
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
                kpiCard(
                  title: "Ausentes",
                  value: "6",
                  color: Colors.red,
                  icon: Icons.cancel,
                ),
                kpiCard(
                  title: "Tarde",
                  value: "3",
                  color: Colors.orange,
                  icon: Icons.access_time,
                ),
                kpiCard(
                  title: "Asistencia",
                  value: "87%",
                  color: Colors.blue,
                  icon: Icons.pie_chart,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // CHART SECTION
            const Text(
              "Tendencia semanal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            chartPlaceholder("Asistencia últimos 7 días"),

            const SizedBox(height: 24),

            // TABLE SECTION
            const Text(
              "Detalle de empleados",
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
                    DataColumn(label: Text("Empleado")),
                    DataColumn(label: Text("Estado")),
                  ],
                  rows: employees.map((emp) {
                    final status = emp["status"]!;
                    final color = getStatusColor(status);

                    return DataRow(
                      cells: [
                        DataCell(Text(emp["name"]!)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: color,
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

            // EXPORT SECTION
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
