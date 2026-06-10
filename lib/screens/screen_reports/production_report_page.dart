import 'package:flutter/material.dart';

class ProductionReportPage extends StatelessWidget {
  const ProductionReportPage({super.key});

  // Paleta de colores identitaria del módulo de producción y cultivo
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF66BB6A);
  static const Color brown = Color(0xFF5D4037);
  static const Color warning = Color(0xFFF57C00);
  static const Color critical = Color(0xFFD32F2F);
  static const Color background = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    // 1. ESTRUCTURA DE DATOS ANALÍTICA (Fácilmente conectable a tu backend en Laravel)
    final List<Map<String, dynamic>> produccionData = [
      {
        "ubicacion": "Zona A - Cama 1",
        "cultivo": "Jícama",
        "produccion": "500 Kg",
        "temp": "26.5°C",
        "hum": "45%",
        "estado": "Estable",
        "encargado": "Juan Pérez",
        "tel": "999 123 4567",
      },
      {
        "ubicacion": "Zona A - Cama 2",
        "cultivo": "Jícama",
        "produccion": "450 Kg",
        "temp": "27.1°C",
        "hum": "48%",
        "estado": "Estable",
        "encargado": "Juan Pérez",
        "tel": "999 123 4567",
      },
      {
        "ubicacion": "Zona A - Cama 3",
        "cultivo": "Tomate",
        "produccion": "250 Kg",
        "temp": "29.4°C",
        "hum": "35%",
        "estado": "Advertencia",
        "encargado": "Juan Pérez",
        "tel": "999 123 4567",
      },
      {
        "ubicacion": "Zona B - Cama 1",
        "cultivo": "Jícama",
        "produccion": "310 Kg",
        "temp": "31.2°C",
        "hum": "32%",
        "estado": "Advertencia",
        "encargado": "Marcos Chan",
        "tel": "999 555 7812",
      },
      {
        "ubicacion": "Zona B - Cama 3",
        "cultivo": "Tomate",
        "produccion": "420 Kg",
        "temp": "28.7°C",
        "hum": "41%",
        "estado": "Estable",
        "encargado": "Marcos Chan",
        "tel": "999 555 7812",
      },
      {
        "ubicacion": "Zona C - Cama 1",
        "cultivo": "Jícama",
        "produccion": "180 Kg",
        "temp": "34.8°C",
        "hum": "25%",
        "estado": "Crítico",
        "encargado": "Elena Vance",
        "tel": "999 777 9012",
      },
    ];

    // --- AUTOMATIZACIÓN DE MÉTRICAS (KPIs CORREGIDOS) ---
    int alertasActivas = produccionData
        .where((element) => element["estado"] != "Estable")
        .length;
    int camasEstables = produccionData
        .where((element) => element["estado"] == "Estable")
        .length;
    double eficienciaClimatica = (produccionData.isNotEmpty)
        ? (camasEstables / produccionData.length) * 100
        : 0.0;

    Color getEstadoColor(String estado) {
      switch (estado) {
        case "Estable":
          return primaryGreen;
        case "Advertencia":
          return warning;
        default:
          return critical;
      }
    }

    // Acción rápida al interactuar con las filas de rendimiento
    void mostrarContactoEncargado(Map<String, dynamic> data) {
      String ubicacion = data["ubicacion"];
      String encargado = data["encargado"];
      String estado = data["estado"];
      String tel = data["tel"];

      String mensajeDetalle =
          "📍 $ubicacion • Estatus: $estado\n"
          "👤 Encargado: $encargado (Tel: $tel)\n";

      if (estado == "Advertencia") {
        mensajeDetalle +=
            "⚠️ Acción: Solicitar ajuste manual de riego preventivo.";
      } else if (estado == "Crítico") {
        mensajeDetalle +=
            "🚨 Acción: Desplegar técnico por alto estrés hídrico inmediato.";
      } else {
        mensajeDetalle +=
            "✅ Acción: Mantener automatización activa sin cambios.";
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mensajeDetalle,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          backgroundColor: brown, // Café elegante de supervisión de tierras
          duration: const Duration(seconds: 5),
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
              colors: [primaryGreen, lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Análisis Avanzado de Producción",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Rendimiento operativo, variables ambientales y personal",
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
            // 1. SECCIÓN: RESUMEN DE MÉTRICAS CRUZADAS (CALCULADAS)
            Row(
              children: [
                _localKpiCard(
                  title: "Eficiencia Climática",
                  value: "${eficienciaClimatica.toStringAsFixed(0)}%",
                  subtitle: "Estabilidad en camas",
                  color: primaryGreen,
                  icon: Icons.thermostat_rounded,
                ),
                const SizedBox(width: 12),
                _localKpiCard(
                  title: "Alertas de Impacto",
                  value: "$alertasActivas Activas",
                  subtitle: "Requieren intervención",
                  color: critical,
                  icon: Icons.warning_amber_rounded,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 2. SECCIÓN: TABLA DETALLADA - PRODUCCIÓN VS AMBIENTE VS ALERTAS
            const Text(
              "Rendimiento Analítico por Zona y Camas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 22,
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
                          "Cultivo",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: brown,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Prod. Real",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: brown,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Temp. Prom",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: brown,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Hum. Prom",
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
                    rows: produccionData.map((data) {
                      final String estado = data["estado"]!;
                      final Color estadoColor = getEstadoColor(estado);

                      return DataRow(
                        // Interactividad: Al tocar, cruza y despliega la información del responsable
                        onSelectChanged: (_) => mostrarContactoEncargado(data),
                        cells: [
                          DataCell(
                            Text(
                              data["ubicacion"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: brown,
                              ),
                            ),
                          ),
                          DataCell(Text(data["cultivo"]!)),
                          DataCell(
                            Text(
                              data["produccion"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                          ),
                          DataCell(Text(data["temp"]!)),
                          DataCell(Text(data["hum"]!)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: estadoColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: estadoColor.withOpacity(0.35),
                                ),
                              ),
                              child: Text(
                                estado,
                                style: TextStyle(
                                  color: estadoColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
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
            ),

            const SizedBox(height: 24),

            // 3. SECCIÓN: AUDITORÍA DE PERSONAL Y RESPONSABILIDAD DE COSECHA
            const Text(
              "Supervisión y Eficiencia de Encargados",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),
            const SizedBox(height: 10),
            _buildWorkerAuditCard(
              name: "Juan Pérez (Zona A)",
              phone: "999 123 4567",
              performanceText:
                  "Responsable de 3 camas. Mayor estabilidad térmica registrada en el sector.",
              color: primaryGreen,
            ),
            _buildWorkerAuditCard(
              name: "Marcos Chan (Zona B)",
              phone: "999 555 7812",
              performanceText:
                  "Responsable de 4 camas. Reporta humedad baja persistente en Cama 1 por fallo de aspersor.",
              color: warning,
            ),
            _buildWorkerAuditCard(
              name: "Elena Vance (Zona C)",
              phone: "999 777 9012",
              performanceText:
                  "Responsable de 2 camas. Registra zona en estado crítico por estrés hídrico de mediodía.",
              color: critical,
            ),

            const SizedBox(height: 24),

            // 4. SECCIÓN: HISTORIAL DE INCIDENCIAS QUE AFECTAN LA COSECHA
            const Text(
              "Logs de Eventos con Impacto en Producción",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildLogTile(
                    "Humedad baja detectada en cama 1 (Zona B)",
                    "Hace 15 min",
                    warning,
                  ),
                  const Divider(height: 1),
                  _buildLogTile(
                    "Sensor de humedad requiere revisión (Zona C)",
                    "Hace 45 min",
                    critical,
                  ),
                  const Divider(height: 1),
                  _buildLogTile(
                    "Cama 3 marcada en advertencia por calor (Zona A)",
                    "Hace 1 hora",
                    warning,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 5. SECCIÓN: ACCIONES DE EXPORTACIÓN LOCALES
            _localExportButtons(context),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PRIVADOS TOTALMENTE AUTÓNOMOS ---

  Widget _localKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerAuditCard({
    required String name,
    required String phone,
    required String performanceText,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: brown,
                  fontSize: 15,
                ),
              ),
              Text(
                phone,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            performanceText,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogTile(String titulo, String tiempo, Color color) {
    return ListTile(
      leading: Icon(Icons.history_toggle_off_rounded, color: color),
      title: Text(
        titulo,
        style: const TextStyle(
          fontSize: 13,
          color: brown,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        tiempo,
        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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
                  content: Text(
                    "Exportando auditoría climática y de kg a PDF...",
                  ),
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
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Descargando matriz completa de rendimiento (Excel)...",
                  ),
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
