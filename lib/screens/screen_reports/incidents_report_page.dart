import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // 📊 Plugin inyectado para las gráficas
import 'package:ibi/models/incident_model.dart';
import 'package:ibi/services/incident_service.dart';

class IncidentsReportPage extends StatefulWidget {
  const IncidentsReportPage({super.key});

  @override
  State<IncidentsReportPage> createState() => _IncidentsReportPageState();
}

class _IncidentsReportPageState extends State<IncidentsReportPage> {
  final IncidentService _incidentService = IncidentService();
  late Future<List<IncidentModel>> _incidentsFuture;

  static const Color primaryRed = Color(0xFFB71C1C);
  static const Color lightRed = Color(0xFFFF5252);
  static const Color textDark = Color(0xFF263238);
  static const Color background = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();
    // Inicializamos la carga al crear el estado de la página
    _incidentsFuture = _incidentService.fetchIncidents();
  }

  void _mostrarAvisoIncidencia(IncidentModel incident) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "⚠️ ALERTA: ${incident.title}\n📍 Ubicación: ${incident.area} • Estatus: [${incident.status}]",
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        backgroundColor: textDark,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<IncidentModel>>(
        future: _incidentsFuture,
        builder: (context, snapshot) {
          // ⏳ Cargando datos...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryRed),
            );
          }
          // ❌ Control de excepciones
          if (snapshot.hasError) {
            return Center(
              child: Text("Error al cargar incidencias: ${snapshot.error}"),
            );
          }
          // 🚫 No hay datos disponibles
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No existen incidencias reportadas."),
            );
          }

          final List<IncidentModel> incidents = snapshot.data!;

          // --- CÁLCULOS DINÁMICOS SOBRE MODELOS ---
          int abiertas = incidents.where((i) => i.status == "Abierto").length;
          int enProceso = incidents
              .where((i) => i.status == "En proceso")
              .length;
          int resueltas = incidents.where((i) => i.status == "Resuelto").length;
          int criticas = incidents.where((i) => i.severity == "Alta").length;

          return SingleChildScrollView(
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

                // KPIs
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
                  "Distribución por Estatus",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 12),

                // 📊 Renderizado de la gráfica real usando el plugin fl_chart
                _localRealChart(
                  abiertas: abiertas,
                  enProceso: enProceso,
                  resueltas: resueltas,
                ),

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

                // Data Table de registros
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
                      rows: incidents.map((incident) {
                        return DataRow(
                          onSelectChanged: (_) =>
                              _mostrarAvisoIncidencia(incident),
                          cells: [
                            DataCell(
                              Text(
                                incident.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
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
                                  color: incident.severityColor.withOpacity(
                                    0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  incident.severity,
                                  style: TextStyle(
                                    color: incident.severityColor,
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
                                  color: incident.statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  incident.status,
                                  style: TextStyle(
                                    color: incident.statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(incident.area)),
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
          );
        },
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

  // Widget gráfico con fl_chart implementado usando datos dinámicos reales
  Widget _localRealChart({
    required int abiertas,
    required int enProceso,
    required int resueltas,
  }) {
    int total = abiertas + enProceso + resueltas;
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: total == 0
                ? const Center(child: Text("Sin registros"))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.red,
                          value: abiertas.toDouble(),
                          title: '$abiertas',
                          radius: 18,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.orange,
                          value: enProceso.toDouble(),
                          title: '$enProceso',
                          radius: 18,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.green,
                          value: resueltas.toDouble(),
                          title: '$resueltas',
                          radius: 18,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _chartIndicator(color: Colors.red, text: "Abiertos"),
                const SizedBox(height: 6),
                _chartIndicator(color: Colors.orange, text: "En proceso"),
                const SizedBox(height: 6),
                _chartIndicator(color: Colors.green, text: "Resueltos"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartIndicator({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textDark,
          ),
        ),
      ],
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
