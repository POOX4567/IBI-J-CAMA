import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ibi/models/production_model.dart';
import 'package:ibi/services/production_service.dart';

class ProductionReportPage extends StatefulWidget {
  const ProductionReportPage({super.key});

  @override
  State<ProductionReportPage> createState() => _ProductionReportPageState();
}

class _ProductionReportPageState extends State<ProductionReportPage> {
  final ProductionService _productionService = ProductionService();
  late Future<List<ProductionModel>> _productionFuture;

  // Paleta de colores identitaria del módulo
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF66BB6A);
  static const Color brown = Color(0xFF5D4037);
  static const Color background = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();
    _productionFuture = _productionService.fetchProductionData();
  }

  void _mostrarContactoEncargado(ProductionModel data) {
    String mensajeDetalle =
        "📍 ${data.ubicacion} • Estatus: ${data.estado}\n"
        "👤 Encargado: ${data.encargado} (Tel: ${data.tel})\n";

    if (data.estado == "Advertencia") {
      mensajeDetalle +=
          "⚠️ Acción: Solicitar ajuste manual de riego preventivo.";
    } else if (data.estado == "Crítico") {
      mensajeDetalle +=
          "🚨 Acción: Desplegar técnico por alto estrés hídrico inmediato.";
    } else {
      mensajeDetalle += "✅ Acción: Mantener automatización activa sin cambios.";
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
        backgroundColor: brown,
        duration: const Duration(seconds: 5),
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
      body: FutureBuilder<List<ProductionModel>>(
        future: _productionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error al cargar producción: ${snapshot.error}"),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No hay datos de producción actuales."),
            );
          }

          final List<ProductionModel> productionList = snapshot.data!;

          // Cómputos dinámicos en tiempo real
          int alertasActivas = productionList
              .where((e) => e.estado != "Estable")
              .length;
          int camasEstables = productionList
              .where((e) => e.estado == "Estable")
              .length;
          double eficienciaClimatica = (productionList.isNotEmpty)
              ? (camasEstables / productionList.length) * 100
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. KPIs Automatizados
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
                      color: const Color(0xFFD32F2F),
                      icon: Icons.warning_amber_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Gráfica de Tendencia Climática
                const Text(
                  "Historial de Temperatura vs Humedad por Cama",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: brown,
                  ),
                ),
                const SizedBox(height: 10),
                _localLineChart(productionList),
                const SizedBox(height: 24),

                // 3. Tabla de Rendimiento
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
                        rows: productionList.map((data) {
                          return DataRow(
                            onSelectChanged: (_) =>
                                _mostrarContactoEncargado(data),
                            cells: [
                              DataCell(
                                Text(
                                  data.ubicacion,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: brown,
                                  ),
                                ),
                              ),
                              DataCell(Text(data.cultivo)),
                              DataCell(
                                Text(
                                  "${data.produccionKg.toStringAsFixed(0)} Kg",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                ),
                              ),
                              DataCell(Text("${data.temperatura}°C")),
                              DataCell(Text("${data.humedad}%")),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: data.estadoColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: data.estadoColor.withOpacity(0.35),
                                    ),
                                  ),
                                  child: Text(
                                    data.estado,
                                    style: TextStyle(
                                      color: data.estadoColor,
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

                // 4. Supervisión de Encargados
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
                  color: const Color(0xFFF57C00),
                ),
                _buildWorkerAuditCard(
                  name: "Elena Vance (Zona C)",
                  phone: "999 777 9012",
                  performanceText:
                      "Responsable de 2 camas. Registra zona en estado crítico por estrés hídrico de mediodía.",
                  color: const Color(0xFFD32F2F),
                ),
                const SizedBox(height: 24),

                // 5. Logs de Eventos
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
                        const Color(0xFFF57C00),
                      ),
                      const Divider(height: 1),
                      _buildLogTile(
                        "Sensor de humedad requiere revisión (Zona C)",
                        "Hace 45 min",
                        const Color(0xFFD32F2F),
                      ),
                      const Divider(height: 1),
                      _buildLogTile(
                        "Cama 3 marcada en advertencia por calor (Zona A)",
                        "Hace 1 hora",
                        const Color(0xFFF57C00),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 6. Botonera de Exportación
                _localExportButtons(context),
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

  // Gráfica Lineal Avanzada Interactiva
  Widget _localLineChart(List<ProductionModel> datasets) {
    List<FlSpot> tempSpots = [];
    List<FlSpot> humSpots = [];

    for (int i = 0; i < datasets.length; i++) {
      tempSpots.add(FlSpot(i.toDouble(), datasets[i].temperatura));
      humSpots.add(FlSpot(i.toDouble(), datasets[i].humedad));
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.only(right: 22, top: 20, bottom: 8, left: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx >= 0 && idx < datasets.length) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        datasets[idx].ubicacion,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 35),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: tempSpots,
              isCurved: true,
              color: const Color(0xFFF57C00),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFF57C00).withOpacity(0.1),
              ),
            ),
            LineChartBarData(
              spots: humSpots,
              isCurved: true,
              color: Colors.blue.shade700,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.shade700.withOpacity(0.05),
              ),
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
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Exportando auditoría climática y de kg a PDF...",
                ),
              ),
            ),
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
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Descargando matriz completa de rendimiento (Excel)...",
                ),
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
