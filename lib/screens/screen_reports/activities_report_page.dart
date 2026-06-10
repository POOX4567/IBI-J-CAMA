import 'package:flutter/material.dart';

class ActivitiesReportPage extends StatelessWidget {
  const ActivitiesReportPage({super.key});

  // Colores corporativos consistentes con tu Centro de Alertas
  static const Color primaryTeal = Color(0xFF004D40);
  static const Color lightTeal = Color(0xFF26A69A);
  static const Color brown = Color(0xFF5D4037);
  static const Color background = Color(0xFFF5F6FA);
  static const Color warning = Color(0xFFF57C00);
  static const Color critical = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    // 1. ORIGEN DE DATOS CRUZADO CON TUS COMPONENTES (Zonas, Encargados y Alertas)
    final List<Map<String, dynamic>> activities = [
      {
        "actividad": "Revisión de extractor de aire",
        "progreso": "Completado",
        "zona": "Zona A",
        "encargado": "Juan Pérez",
        "detalle":
            "Mantenimiento preventivo completado en la Cama 3 para regular el flujo de aire tras aviso de advertencia.",
      },
      {
        "actividad": "Calibración de sensores térmicos",
        "progreso": "En proceso",
        "zona": "Zona C",
        "encargado": "Elena Vance",
        "detalle":
            "Ajuste fino del hardware tras registrar alertas de temperatura crítica (35°C).",
      },
      {
        "actividad": "Monitoreo de aspersores hidráulicos",
        "progreso": "Completado",
        "zona": "Zona A",
        "encargado": "Ana Torres",
        "detalle":
            "Prueba de presión superada con éxito en las tuberías principales.",
      },
      {
        "actividad": "Reconexión de sensor de humedad",
        "progreso": "Pendiente",
        "zona": "Zona A",
        "encargado": "Marcos Chan",
        "detalle":
            "Falla técnica crítica detectada. El sensor sigue sin emitir señal en la Cama 1.",
      },
      {
        "actividad": "Checklist de supervisión diaria",
        "progreso": "Completado",
        "zona": "Zona B",
        "encargado": "Marcos Chan",
        "detalle":
            "Inspección de rutina cerrada. Nota: Se reporta humedad baja general del 28%.",
      },
    ];

    // --- CÁLCULOS EN TIEMPO REAL BASADOS EN TU LISTA ---
    int completadas = activities
        .where((act) => act["progreso"] == "Completado")
        .length;
    int enProceso = activities
        .where((act) => act["progreso"] == "En proceso")
        .length;
    int pendientes = activities
        .where((act) => act["progreso"] == "Pendiente")
        .length;

    Color getStatusColor(String progreso) {
      switch (progreso) {
        case "Completado":
          return Colors.green;
        case "En proceso":
          return warning;
        default:
          return critical;
      }
    }

    // Función interactiva para auditar los detalles de la tarea en un modal limpio
    void _showActivityDetails(Map<String, dynamic> item) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            item["actividad"],
            style: const TextStyle(fontWeight: FontWeight.bold, color: brown),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: primaryTeal, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "Ubicación: ${item['zona']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person, color: primaryTeal, size: 18),
                  const SizedBox(width: 6),
                  Text("Responsable: ${item['encargado']}"),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.info, color: primaryTeal, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "Estado: ${item['progreso']}",
                    style: TextStyle(
                      color: getStatusColor(item['progreso']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                "Bitácora Técnica:",
                style: TextStyle(fontWeight: FontWeight.bold, color: brown),
              ),
              const SizedBox(height: 6),
              Text(
                item["detalle"],
                style: TextStyle(color: Colors.grey.shade800, height: 1.35),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Entendido",
                style: TextStyle(
                  color: primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
              colors: [primaryTeal, lightTeal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Reporte de Actividades",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Seguimiento general de tareas",
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
              "Resumen de actividades",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),
            const SizedBox(height: 12),

            // KPIs DINÁMICOS LOCALES
            Row(
              children: [
                _localKpiCard(
                  title: "Completadas",
                  value: completadas.toString(),
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
                const SizedBox(width: 10),
                _localKpiCard(
                  title: "En proceso",
                  value: enProceso.toString(),
                  color: warning,
                  icon: Icons.timelapse,
                ),
                const SizedBox(width: 10),
                _localKpiCard(
                  title: "Pendientes",
                  value: pendientes.toString(),
                  color: critical,
                  icon: Icons.warning,
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Actividad mensual",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),
            const SizedBox(height: 12),
            _localChartPlaceholder("Distribución operativa de tareas"),

            const SizedBox(height: 24),

            const Text(
              "Detalle de actividades",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),
            const SizedBox(height: 12),

            // TABLA INTERACTIVA CON FILAS SELECCIONABLES (onSelectChanged)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 40,
                  showCheckboxColumn: false,
                  headingRowColor: WidgetStateProperty.all(
                    Colors.grey.shade100,
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        "Ubicación",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: brown,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Tarea / Actividad",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: brown,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Estado Actual",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: brown,
                        ),
                      ),
                    ),
                  ],
                  rows: activities.map((item) {
                    final progreso = item["progreso"]!;
                    final color = getStatusColor(progreso);

                    return DataRow(
                      // Al hacer clic, abre la auditoría completa de la actividad
                      onSelectChanged: (_) => _showActivityDetails(item),
                      cells: [
                        DataCell(
                          Text(
                            item["zona"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: brown,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            item["actividad"],
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
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            child: Text(
                              progreso,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),
            const SizedBox(height: 12),
            _localExportButtons(context),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES AUXILIARES INTEGRADOS LOCALMENTE ---

  Widget _localKpiCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(icon, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 8),
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
      ),
    );
  }

  Widget _localChartPlaceholder(String title) {
    return Container(
      height: 180,
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
            Icons.pie_chart_outline_rounded,
            size: 36,
            color: primaryTeal.withOpacity(0.6),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: brown,
            ),
          ),
          Text(
            "Balance global de rendimiento de tareas",
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _localExportButtons(BuildContext context) {
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Exportando bitácora de actividades a PDF..."),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text("Exportar PDF"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Exportando matriz de tareas a Excel..."),
                ),
              );
            },
            icon: const Icon(Icons.table_chart, size: 18),
            label: const Text("Exportar Excel"),
          ),
        ),
      ],
    );
  }
}
