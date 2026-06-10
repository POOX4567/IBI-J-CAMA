import 'package:flutter/material.dart';

class MaintenanceReportPage extends StatelessWidget {
  const MaintenanceReportPage({super.key});

  static const Color primaryRed = Color(0xFFB71C1C);
  static const Color lightRed = Color(0xFFFF5252);
  static const Color textDark = Color(0xFF263238);
  static const Color background = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    // 1. ORIGEN DE DATOS REALES DE INCIDENCIAS
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

    // --- CÁLCULOS EN TIEMPO REAL ---
    int abiertas = incidents.where((i) => i["status"] == "Abierto").length;
    int enProceso = incidents.where((i) => i["status"] == "En proceso").length;
    int resueltas = incidents.where((i) => i["status"] == "Resuelto").length;
    int criticas = incidents.where((i) => i["severity"] == "Alta").length;

    Color getSeverityColor(String severity) {
      switch (severity) {
        case "Alta":
          return Colors.red.shade900;
        case "Media":
          return Colors.orange.shade800;
        default:
          return Colors.green.shade700;
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

    void mostrarAvisoIncidencia(Map<String, dynamic> inc) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "⚠️ ALERTA: ${inc['title']}\n📍 Ubicación: ${inc['area']} • Estatus: [${inc['status']}]",
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          backgroundColor: textDark,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryRed, lightRed],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Reporte de Incidencias",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Gestión de alertas y problemas",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resumen de incidencias",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),

            // KPIs Calculados dinámicamente
            Row(
              children: [
                _localKpiCard(
                  title: "Abiertas",
                  value: abiertas.toString(),
                  color: Colors.red,
                  icon: Icons.error,
                ),
                const SizedBox(width: 10),
                _localKpiCard(
                  title: "En proceso",
                  value: enProceso.toString(),
                  color: Colors.orange,
                  icon: Icons.autorenew,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _localKpiCard(
                  title: "Resueltas",
                  value: resueltas.toString(),
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
                const SizedBox(width: 10),
                _localKpiCard(
                  title: "Críticas",
                  value: criticas.toString(),
                  color: Colors.deepPurple,
                  icon: Icons.warning,
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              "Incidencias por tipo",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            _localChartPlaceholder("Distribución de incidencias"),

            const SizedBox(height: 24),
            const Text(
              "Registro de incidencias",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
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
                  columnSpacing: 35,
                  showCheckboxColumn: false,
                  headingRowColor: WidgetStateProperty.all(
                    Colors.grey.shade200,
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        "Incidencia",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Severidad",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Estado",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Área",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: incidents.map((i) {
                    final severityColor = getSeverityColor(i["severity"]);
                    final statusColor = getStatusColor(i["status"]);

                    return DataRow(
                      onSelectChanged: (_) => mostrarAvisoIncidencia(i),
                      cells: [
                        DataCell(
                          Text(
                            i["title"],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: severityColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              i["severity"],
                              style: TextStyle(
                                color: severityColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
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
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              i["status"],
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            _localExportButtons(context, "incidencias"),
          ],
        ),
      ),
    );
  }

  Widget _localKpiCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Icon(icon, color: color, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _localChartPlaceholder(String title) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.donut_large_rounded,
            size: 36,
            color: primaryRed.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _localExportButtons(BuildContext context, String modulo) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Exportando reporte de $modulo a PDF...")),
            ),
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text("Exportar PDF"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Exportando reporte de $modulo a Excel..."),
              ),
            ),
            icon: const Icon(Icons.table_chart, size: 18),
            label: const Text("Exportar Excel"),
          ),
        ),
      ],
    );
  }
}
