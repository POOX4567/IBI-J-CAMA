import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ibi/models/incident_model.dart';
import 'package:ibi/services/incident_service.dart';
import 'package:data_table_2/data_table_2.dart';
// Importamos tu botón reutilizable universal
import '../../widgets/widgets_dashboard/universal_export_buttons.dart';

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
    _incidentsFuture = _incidentService.fetchIncidents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      body: FutureBuilder<List<IncidentModel>>(
        future: _incidentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryRed),
            );
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                snapshot.hasError
                    ? "Error: ${snapshot.error}"
                    : "No existen incidencias reportadas.",
              ),
            );
          }

          final List<IncidentModel> incidents = snapshot.data!;

          int abiertas = incidents.where((i) => i.status == "Abierto").length;
          int enProceso = incidents
              .where((i) => i.status == "En proceso")
              .length;
          int resueltas = incidents.where((i) => i.status == "Resuelto").length;
          int criticas = incidents.where((i) => i.severity == "Alta").length;

          // 🔥 MATRIZ DE DATOS CRUDA: Se genera una sola vez de forma eficiente
          final List<List<String>> rawReportData = incidents
              .map((i) => [i.title, i.severity, i.status, i.area])
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Resumen de incidencias"),
                const SizedBox(height: 12),
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
                _buildSectionTitle("Distribución por Estatus"),
                const SizedBox(height: 12),
                _localRealChart(
                  abiertas: abiertas,
                  enProceso: enProceso,
                  resueltas: resueltas,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle("Registro de incidencias"),
                const SizedBox(height: 12),
                _buildDataTableCard(incidents),
                const SizedBox(height: 24),
                _buildSectionTitle("Acciones"),
                const SizedBox(height: 12),

                // 🔥 TU BOTÓN UNIVERSAL: Conectado al CSV nativo y limpio de lógica pesada
                UniversalExportButtons(
                  title: "Bitacora Oficial de Incidencias",
                  subtitle: "Reporte histórico del Invernadero Inteligente",
                  csvSheetName: "Incidencias_Invernadero",
                  headers: const ["Incidencia", "Severidad", "Estado", "Área"],
                  rows: rawReportData,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UI COMPONENTS LOCALES ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: textDark,
    ),
  );

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

  Widget _buildDataTableCard(List<IncidentModel> incidents) {
    return SizedBox(
      height: 280,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: DataTable2(
          columnSpacing: 10,
          minWidth: 550,
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
          columns: const [
            DataColumn2(label: Text("Incidencia"), size: ColumnSize.L),
            DataColumn2(label: Text("Severidad"), size: ColumnSize.S),
            DataColumn2(label: Text("Estado"), size: ColumnSize.M),
            DataColumn2(label: Text("Área"), size: ColumnSize.M),
          ],
          rows: incidents
              .map(
                (incident) => DataRow(
                  onSelectChanged: (_) => _mostrarAvisoIncidencia(incident),
                  cells: [
                    DataCell(
                      Text(
                        incident.title,
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
                          color: incident.severityColor.withOpacity(0.12),
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
                ),
              )
              .toList(),
        ),
      ),
    );
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
}
