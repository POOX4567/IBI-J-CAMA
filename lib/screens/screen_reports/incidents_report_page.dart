import 'package:flutter/material.dart';
import '../../widgets/widgets_dashboard/report_widgets.dart';

class IncidentsReportPage extends StatelessWidget {
  const IncidentsReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> incidents = [
      {
        "title": "Falla en sistema eléctrico",
        "severity": "Alta",
        "status": "Abierto",
        "area": "Invernadero Norte",
      },
      {
        "title": "Sensor de humedad desconectado",
        "severity": "Media",
        "status": "En proceso",
        "area": "Invernadero Sur",
      },
      {
        "title": "Fuga de agua detectada",
        "severity": "Alta",
        "status": "Abierto",
        "area": "Zona de riego",
      },
      {
        "title": "Mantenimiento preventivo",
        "severity": "Baja",
        "status": "Resuelto",
        "area": "Área general",
      },
      {
        "title": "Temperatura fuera de rango",
        "severity": "Media",
        "status": "En proceso",
        "area": "Invernadero Este",
      },
    ];

    Color getSeverityColor(String severity) {
      switch (severity) {
        case "Alta":
          return Colors.red;
        case "Media":
          return Colors.orange;
        default:
          return Colors.green;
      }
    }

    Color getStatusColor(String status) {
      switch (status) {
        case "Abierto":
          return Colors.red;
        case "En proceso":
          return Colors.orange;
        default:
          return Colors.green;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Reporte de Incidencias"),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resumen de incidencias",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                kpiCard(
                  title: "Abiertas",
                  value: "5",
                  color: Colors.red,
                  icon: Icons.error,
                ),
                kpiCard(
                  title: "En proceso",
                  value: "3",
                  color: Colors.orange,
                  icon: Icons.autorenew,
                ),
                kpiCard(
                  title: "Resueltas",
                  value: "12",
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
                kpiCard(
                  title: "Críticas",
                  value: "2",
                  color: Colors.deepPurple,
                  icon: Icons.warning,
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Incidencias por tipo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            chartPlaceholder("Distribución de incidencias"),

            const SizedBox(height: 24),

            const Text(
              "Registro de incidencias",
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
                    DataColumn(label: Text("Incidencia")),
                    DataColumn(label: Text("Severidad")),
                    DataColumn(label: Text("Estado")),
                    DataColumn(label: Text("Área")),
                  ],
                  rows: incidents.map((i) {
                    final severityColor = getSeverityColor(i["severity"]);
                    final statusColor = getStatusColor(i["status"]);

                    return DataRow(
                      cells: [
                        DataCell(Text(i["title"])),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: severityColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              i["severity"],
                              style: TextStyle(
                                color: severityColor,
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
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              i["status"],
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(i["area"])),
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
