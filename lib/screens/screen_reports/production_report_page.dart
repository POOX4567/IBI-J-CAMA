import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:ibi/models/production_model.dart';
import 'package:ibi/services/production_service.dart';
// Importamos tu botón reutilizable universal
import '../../widgets/widgets_dashboard/universal_export_buttons.dart';

class ProductionReportPage extends StatefulWidget {
  const ProductionReportPage({super.key});

  @override
  State<ProductionReportPage> createState() => _ProductionReportPageState();
}

class _ProductionReportPageState extends State<ProductionReportPage> {
  final ProductionService _productionService = ProductionService();
  late Future<List<ProductionModel>> _productionFuture;

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF263238);
  static const Color background = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();
    _productionFuture = _productionService.fetchProductionData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      body: FutureBuilder<List<ProductionModel>>(
        future: _productionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                snapshot.hasError
                    ? "Error: ${snapshot.error}"
                    : "No existen registros de producción reportados.",
              ),
            );
          }

          final List<ProductionModel> productionList = snapshot.data!;

          // Métricas analíticas de producción agrícola
          int estables = productionList
              .where((p) => p.estado == "Estable")
              .length;
          int advertencias = productionList
              .where((p) => p.estado == "Advertencia")
              .length;
          int criticos = productionList
              .where((p) => p.estado != "Estable" && p.estado != "Advertencia")
              .length;

          double totalKg = productionList.fold(
            0,
            (sum, item) => sum + item.produccionKg,
          );

          // 🔥 MATRIZ DE EXPORTACIÓN IMPECABLE (7 Columnas del Modelo)
          final List<List<String>> rawReportData = productionList
              .map(
                (p) => [
                  p.ubicacion,
                  p.cultivo,
                  "${p.produccionKg} Kg",
                  "${p.temperatura}°C",
                  "${p.humedad}%",
                  p.estado,
                  p.encargado,
                ],
              )
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Resumen de rendimiento"),
                const SizedBox(height: 12),

                // Cuadrícula de KPIs de producción
                Row(
                  children: [
                    _localKpiCard(
                      title: "Zonas Estables",
                      value: estables.toString(),
                      color: const Color(0xFF2E7D32),
                      icon: Icons.check_circle,
                    ),
                    const SizedBox(width: 10),
                    _localKpiCard(
                      title: "En Advertencia",
                      value: advertencias.toString(),
                      color: const Color(0xFFF57C00),
                      icon: Icons.gpp_maybe,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _localKpiCard(
                      title: "Zonas Críticas",
                      value: criticos.toString(),
                      color: const Color(0xFFD32F2F),
                      icon: Icons.dangerous,
                    ),
                    const SizedBox(width: 10),
                    _localKpiCard(
                      title: "Total Cosecha",
                      value: "${totalKg.toInt()} Kg",
                      color: Colors.blue,
                      icon: Icons.scale,
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionTitle("Estado Biológico de las Camas"),
                const SizedBox(height: 12),

                // Gráfico sectorial real
                _localRealChart(
                  estables: estables,
                  advertencias: advertencias,
                  criticos: criticos,
                ),

                const SizedBox(height: 24),
                _buildSectionTitle("Monitoreo y Registro de Cosecha"),
                const SizedBox(height: 12),

                // Tabla de datos avanzada
                _buildDataTableCard(productionList),

                const SizedBox(height: 24),
                _buildSectionTitle("Acciones de Reporte"),
                const SizedBox(height: 12),

                // Botón universal configurado exclusivamente para tu data de cultivos
                UniversalExportButtons(
                  title: "Análisis de Rendimiento de Cultivos",
                  subtitle:
                      "Historial de capacidad, volumen de cosecha y métricas ambientales por cama",
                  csvSheetName: "Rendimiento_Cosechas",
                  headers: const [
                    "Ubicación",
                    "Cultivo",
                    "Producción",
                    "Temperatura",
                    "Humedad",
                    "Estado",
                    "Encargado",
                  ],
                  rows: rawReportData,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- COMPONENTES VISUALES TOTALMENTE ADAPTADOS A PRODUCCIÓN ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Módulo Producción",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2),
          Text(
            "Rendimiento analítico por cama de cultivo",
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
                    fontSize: 20,
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
    required int estables,
    required int advertencias,
    required int criticos,
  }) {
    int total = estables + advertencias + criticos;
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
                ? const Center(child: Text("Sin registros activos"))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: const Color(0xFF2E7D32),
                          value: estables.toDouble(),
                          title: '$estables',
                          radius: 18,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        PieChartSectionData(
                          color: const Color(0xFFF57C00),
                          value: advertencias.toDouble(),
                          title: '$advertencias',
                          radius: 18,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        PieChartSectionData(
                          color: const Color(0xFFD32F2F),
                          value: criticos.toDouble(),
                          title: '$criticos',
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
                _chartIndicator(
                  color: const Color(0xFF2E7D32),
                  text: "Cultivo Estable",
                ),
                const SizedBox(height: 6),
                _chartIndicator(
                  color: const Color(0xFFF57C00),
                  text: "En Estrés / Alerta",
                ),
                const SizedBox(height: 6),
                _chartIndicator(
                  color: const Color(0xFFD32F2F),
                  text: "Estado Crítico",
                ),
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

  Widget _buildDataTableCard(List<ProductionModel> productionList) {
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
            DataColumn2(label: Text("Ubicación"), size: ColumnSize.L),
            DataColumn2(label: Text("Cultivo"), size: ColumnSize.M),
            DataColumn2(label: Text("Producción"), size: ColumnSize.S),
            DataColumn2(label: Text("Estado"), size: ColumnSize.M),
          ],
          rows: productionList.map((prod) {
            return DataRow(
              onSelectChanged: (_) => _mostrarDetallesCama(prod),
              cells: [
                DataCell(
                  Text(
                    prod.ubicacion,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(Text(prod.cultivo)),
                DataCell(
                  Text(
                    "${prod.produccionKg.toInt()} Kg",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: prod.estadoColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prod.estado,
                      style: TextStyle(
                        color: prod.estadoColor,
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

  void _mostrarDetallesCama(ProductionModel prod) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "🌱 CULTIVO: ${prod.cultivo} (${prod.ubicacion})\n🌡️ Temp: ${prod.temperatura}°C  •  💧 Humedad: ${prod.humedad}%\n👤 Responsable: ${prod.encargado}  •  📞 Tel: ${prod.tel}",
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        backgroundColor: textDark,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
