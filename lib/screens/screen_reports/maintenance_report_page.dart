import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MaintenanceReportPage extends StatefulWidget {
  const MaintenanceReportPage({super.key});

  @override
  State<MaintenanceReportPage> createState() => _MaintenanceReportPageState();
}

class _MaintenanceReportPageState extends State<MaintenanceReportPage> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF263238);
  static const Color background = Color(0xFFF5F6FA);

  // Paleta de colores para los estados del equipamiento
  static const Color statusPending = Color(0xFFF57C00); // Naranja
  static const Color statusComplete = Color(0xFF2E7D32); // Verde
  static const Color statusCritical = Color(0xFFD32F2F); // Rojo

  // Función profesional para generar e imprimir el PDF con la data real
  Future<void> _exportarPdf(List<Map<String, dynamic>> datos) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Reporte de Mantenimiento de Equipos - Gestión de Invernadero",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green900,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                "Historial analítico de órdenes de servicio, calibraciones y costos operativos.",
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: [
                  "Equipo",
                  "Tipo de Servicio",
                  "Costo Op.",
                  "Fecha",
                  "Estado Actual",
                ],
                data: datos
                    .map(
                      (e) => [
                        e["equipo"].toString(),
                        e["tipo"].toString(),
                        "\$${e["costo"]}",
                        e["fecha"].toString(),
                        e["estado"].toString(),
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 11,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.green800,
                ),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dataset local simulado/fijo del inventario técnico
    final List<Map<String, dynamic>> maintenanceData = [
      {
        "equipo": "Extractor E-101",
        "tipo": "Correctivo",
        "costo": 1250.00,
        "fecha": "15/06/2026",
        "estado": "Pendiente",
      },
      {
        "equipo": "Bomba Riego B-2",
        "tipo": "Preventivo",
        "costo": 450.00,
        "fecha": "14/06/2026",
        "estado": "Completado",
      },
      {
        "equipo": "Sensor Humedad S-3",
        "tipo": "Calibración",
        "costo": 180.00,
        "fecha": "12/06/2026",
        "estado": "Completado",
      },
      {
        "equipo": "Panel Solar P-1",
        "tipo": "Preventivo",
        "costo": 3200.00,
        "fecha": "10/06/2026",
        "estado": "Pendiente",
      },
      {
        "equipo": "Motor Aspersor M-4",
        "tipo": "Correctivo",
        "costo": 850.00,
        "fecha": "09/06/2026",
        "estado": "Crítico",
      },
    ];

    // Lógica Analítica en tiempo real para poblar la matriz de KPIs
    int completados = maintenanceData
        .where((m) => m["estado"] == "Completado")
        .length;
    int pendientes = maintenanceData
        .where((m) => m["estado"] == "Pendiente")
        .length;
    int criticos = maintenanceData
        .where((m) => m["estado"] == "Crítico")
        .length;

    double costoTotal = maintenanceData.fold(
      0.0,
      (sum, item) => sum + (item["costo"] as double),
    );

    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Resumen de Órdenes"),
            const SizedBox(height: 12),

            // Cuadrícula simétrica de 4 KPIs corporativos
            Row(
              children: [
                _localKpiCard(
                  title: "Completados",
                  value: completados.toString(),
                  color: statusComplete,
                  icon: Icons.task_alt,
                ),
                const SizedBox(width: 10),
                _localKpiCard(
                  title: "Pendientes",
                  value: pendientes.toString(),
                  color: statusPending,
                  icon: Icons.pending_actions,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _localKpiCard(
                  title: "Críticos",
                  value: criticos.toString(),
                  color: statusCritical,
                  icon: Icons.report_problem,
                ),
                const SizedBox(width: 10),
                _localKpiCard(
                  title: "Gasto Total",
                  value: NumberFormat.simpleCurrency(
                    locale: 'es_MX',
                    decimalDigits: 0,
                  ).format(costoTotal),
                  color: Colors.blue.shade800,
                  icon: Icons.payments,
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle("Historial de Órdenes de Servicio"),
            const SizedBox(height: 12),

            // Tabla optimizada avanzada con DataTable2
            SizedBox(
              height: 310,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DataTable2(
                  columnSpacing: 10,
                  minWidth: 550,
                  headingRowColor: WidgetStateProperty.all(
                    Colors.grey.shade200,
                  ),
                  columns: const [
                    DataColumn2(label: Text("Equipo"), size: ColumnSize.L),
                    DataColumn2(label: Text("Tipo"), size: ColumnSize.M),
                    DataColumn2(label: Text("Costo"), size: ColumnSize.S),
                    DataColumn2(label: Text("Estado"), size: ColumnSize.M),
                  ],
                  rows: maintenanceData.map((data) {
                    // Obtener dinámicamente el color del badge del renglón
                    Color stateColor;
                    if (data["estado"] == "Completado") {
                      stateColor = statusComplete;
                    } else if (data["estado"] == "Pendiente") {
                      stateColor = statusPending;
                    } else {
                      stateColor = statusCritical;
                    }

                    return DataRow(
                      onSelectChanged: (_) => _mostrarDetallesEquipo(data),
                      cells: [
                        DataCell(
                          Text(
                            data["equipo"]!,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataCell(Text(data["tipo"]!)),
                        DataCell(
                          Text(
                            NumberFormat.simpleCurrency(
                              locale: 'es_MX',
                            ).format(data["costo"]),
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
                              color: stateColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              data["estado"]!,
                              style: TextStyle(
                                color: stateColor,
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
            _buildSectionTitle("Acciones de Infraestructura"),
            const SizedBox(height: 12),

            // Botón estilizado y expandido para la exportación PDF
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusCritical,
                  foregroundColor: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _exportarPdf(maintenanceData),
                icon: const Icon(Icons.picture_as_pdf, size: 20),
                label: const Text(
                  "GENERAR REPORTE PDF OFICIAL",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ESTRUCTURALES ---

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
            "Módulo Mantenimiento",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2),
          Text(
            "Control operativo de infraestructura y activos",
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

  void _mostrarDetallesEquipo(Map<String, dynamic> data) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "⚙️ EQUIPO: ${data["equipo"]}\n🔧 Servicio: ${data["tipo"]}  •  📅 Registro: ${data["fecha"]}\n💵 Costo: \$${data["costo"]} MXN  •  📊 Estado: [${data["estado"]}]",
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
