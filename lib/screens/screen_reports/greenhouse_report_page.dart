import 'package:flutter/material.dart';
import '../screen_reports/report_widgets.dart';

class GreenhouseReportPage extends StatelessWidget {
  const GreenhouseReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> greenhouses = [
      {
        "name": "Invernadero Norte",
        "status": "Óptimo",
        "temp": "24°C",
        "humidity": "60%",
      },
      {
        "name": "Invernadero Sur",
        "status": "Alerta",
        "temp": "30°C",
        "humidity": "75%",
      },
      {
        "name": "Invernadero Este",
        "status": "Crítico",
        "temp": "34°C",
        "humidity": "85%",
      },
      {
        "name": "Invernadero Oeste",
        "status": "Óptimo",
        "temp": "22°C",
        "humidity": "58%",
      },
    ];

    Color getStatusColor(String status) {
      switch (status) {
        case "Óptimo":
          return Colors.green;
        case "Alerta":
          return Colors.orange;
        default:
          return Colors.red;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Reporte de Invernaderos"),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resumen de producción",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                kpiCard(
                  title: "Producción total",
                  value: "1,240 kg",
                  color: Colors.green,
                  icon: Icons.agriculture,
                ),
                kpiCard(
                  title: "Temperatura promedio",
                  value: "27°C",
                  color: Colors.orange,
                  icon: Icons.thermostat,
                ),
                kpiCard(
                  title: "Humedad media",
                  value: "68%",
                  color: Colors.blue,
                  icon: Icons.water_drop,
                ),
                kpiCard(
                  title: "Invernaderos activos",
                  value: "4",
                  color: Colors.purple,
                  icon: Icons.spa,
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Rendimiento semanal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            chartPlaceholder("Producción por semana (kg)"),

            const SizedBox(height: 24),

            const Text(
              "Estado de invernaderos",
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
                    DataColumn(label: Text("Invernadero")),
                    DataColumn(label: Text("Estado")),
                    DataColumn(label: Text("Temp")),
                    DataColumn(label: Text("Humedad")),
                  ],
                  rows: greenhouses.map((g) {
                    final color = getStatusColor(g["status"]);

                    return DataRow(
                      cells: [
                        DataCell(Text(g["name"])),
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
                              g["status"],
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(g["temp"])),
                        DataCell(Text(g["humidity"])),
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
