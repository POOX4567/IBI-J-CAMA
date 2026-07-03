import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ibi/models/activity_model.dart';
import 'package:ibi/services/activity_service.dart';
// Importamos tu nuevo componente reutilizable
import '../../widgets/widgets_dashboard/universal_export_buttons.dart';

class ActivitiesReportPage extends StatefulWidget {
  const ActivitiesReportPage({super.key});

  @override
  State<ActivitiesReportPage> createState() => _ActivitiesReportPageState();
}

class _ActivitiesReportPageState extends State<ActivitiesReportPage> {
  final ActivityService _activityService = ActivityService();
  late Future<List<ActivityModel>> _activitiesFuture;

  static const Color primaryTeal = Color(0xFF004D40);
  static const Color lightTeal = Color(0xFF26A69A);
  static const Color brown = Color(0xFF5D4037);
  static const Color background = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _activityService.fetchActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      body: FutureBuilder<List<ActivityModel>>(
        future: _activitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryTeal),
            );
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                snapshot.hasError
                    ? "Error: ${snapshot.error}"
                    : "No hay datos disponibles.",
              ),
            );
          }

          final List<ActivityModel> activities = snapshot.data!;

          double completadas = activities
              .where((act) => act.progreso == "Completado")
              .length
              .toDouble();
          double enProceso = activities
              .where((act) => act.progreso == "En proceso")
              .length
              .toDouble();
          double pendientes = activities
              .where((act) => act.progreso == "Pendiente")
              .length
              .toDouble();

          // 🔥 Mapeamos los datos crudos una sola vez aquí para el componente reutilizable
          final List<List<String>> exportData = activities
              .map((act) => [act.zona, act.actividad, act.progreso])
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Resumen de actividades"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _localKpiCard(
                      title: "Completadas",
                      value: completadas.toInt().toString(),
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),
                    const SizedBox(width: 10),
                    _localKpiCard(
                      title: "En proceso",
                      value: enProceso.toInt().toString(),
                      color: const Color(0xFFF57C00),
                      icon: Icons.timelapse,
                    ),
                    const SizedBox(width: 10),
                    _localKpiCard(
                      title: "Pendientes",
                      value: pendientes.toInt().toString(),
                      color: const Color(0xFFD32F2F),
                      icon: Icons.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionTitle("Distribución Operativa"),
                const SizedBox(height: 12),
                _localRealChart(
                  completadas: completadas,
                  enProceso: enProceso,
                  pendientes: pendientes,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle("Detalle de actividades"),
                const SizedBox(height: 12),
                _buildDataTableCard(activities),
                const SizedBox(height: 24),
                _buildSectionTitle("Acciones"),
                const SizedBox(height: 12),

                // 🔥 LLAMADA IMPECABLE AL BOTÓN UNIVERSAL:
                UniversalExportButtons(
                  title: "Reporte de Actividades Operativas",
                  subtitle:
                      "Listado de tareas, ubicaciones y estados de ejecución",
                  csvSheetName: "Actividades_Bitacora",
                  headers: const ['Ubicación', 'Actividad / Tarea', 'Estado'],
                  rows: exportData,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- COMPONENTES LOCALES FIJOS ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    );
  }

  Widget _buildSectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: brown,
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

  Widget _localRealChart({
    required double completadas,
    required double enProceso,
    required double pendientes,
  }) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 35,
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: completadas,
                    title: '${completadas.toInt()}',
                    radius: 40,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFF57C00),
                    value: enProceso,
                    title: '${enProceso.toInt()}',
                    radius: 40,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFD32F2F),
                    value: pendientes,
                    title: '${pendientes.toInt()}',
                    radius: 40,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
                _chartLegend(Colors.green, "Completadas"),
                const SizedBox(height: 6),
                _chartLegend(const Color(0xFFF57C00), "En proceso"),
                const SizedBox(height: 6),
                _chartLegend(const Color(0xFFD32F2F), "Pendientes"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: brown,
          ),
        ),
      ],
    );
  }

  Widget _buildDataTableCard(List<ActivityModel> activities) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 40,
          showCheckboxColumn: false,
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(
              label: Text(
                "Ubicación",
                style: TextStyle(fontWeight: FontWeight.bold, color: brown),
              ),
            ),
            DataColumn(
              label: Text(
                "Tarea / Actividad",
                style: TextStyle(fontWeight: FontWeight.bold, color: brown),
              ),
            ),
            DataColumn(
              label: Text(
                "Estado Actual",
                style: TextStyle(fontWeight: FontWeight.bold, color: brown),
              ),
            ),
          ],
          rows: activities.map((item) {
            return DataRow(
              onSelectChanged: (_) => _showActivityDetails(item),
              cells: [
                DataCell(
                  Text(
                    item.zona,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    item.actividad,
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
                      color: item.statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: item.statusColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      item.progreso,
                      style: TextStyle(
                        color: item.statusColor,
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
    );
  }

  void _showActivityDetails(ActivityModel item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          item.actividad,
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
                  "Ubicación: ${item.zona}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person, color: primaryTeal, size: 18),
                const SizedBox(width: 6),
                Text("Responsable: ${item.encargado}"),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.info, color: primaryTeal, size: 18),
                const SizedBox(width: 6),
                Text(
                  "Estado: ${item.progreso}",
                  style: TextStyle(
                    color: item.statusColor,
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
              item.detalle,
              style: TextStyle(color: Colors.grey.shade800, height: 1.35),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Entendido",
              style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
