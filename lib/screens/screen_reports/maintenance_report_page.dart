import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Modelos y Servicio de Mantenimiento
import '../../models/maintenance_model.dart';
import '../../models/invernadero_model.dart';
import '../../services/maintenance_service.dart';

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

  final MaintenanceService _service = MaintenanceService();
  late Future<List<MaintenanceModel>> _maintenanceFuture;
  List<Invernadero> _invernaderos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    setState(() {
      _maintenanceFuture = _service.fetchMaintenanceTasks();
    });
    _service
        .fetchInvernaderos()
        .then((invs) {
          if (mounted) {
            setState(() => _invernaderos = invs);
          }
        })
        .catchError((e) {
          debugPrint("Error al cargar invernaderos: $e");
        });
  }

  // Generación e impresión de PDF con datos reales
  Future<void> _exportarPdf(List<MaintenanceModel> datos) async {
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
                headers: ["Título", "Tipo", "Descripción", "Estado"],
                data: datos
                    .map(
                      (e) => [
                        e.titulo,
                        e.tipo ?? 'N/A',
                        e.descripcion,
                        e.estado ?? 'Pendiente',
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
    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "NUEVO MANTENIMIENTO",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => _mostrarDialogoNuevoMantenimiento(),
      ),
      body: FutureBuilder<List<MaintenanceModel>>(
        future: _maintenanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: statusCritical,
                    size: 50,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Error al cargar los datos:\n${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: statusCritical),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                    ),
                    onPressed: _cargarDatos,
                    child: const Text(
                      "Reintentar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final maintenanceData = snapshot.data ?? [];

          // Cálculo dinámico con datos de la API
          int completados = maintenanceData
              .where(
                (m) =>
                    (m.estado ?? '').toLowerCase() == "completado" ||
                    (m.estado ?? '').toLowerCase() == "resuelto",
              )
              .length;
          int pendientes = maintenanceData
              .where(
                (m) =>
                    (m.estado ?? '').toLowerCase() == "pendiente" ||
                    (m.estado ?? '').toLowerCase() == "abierto",
              )
              .length;
          int criticos = maintenanceData
              .where(
                (m) =>
                    (m.estado ?? '').toLowerCase() == "crítico" ||
                    (m.estado ?? '').toLowerCase() == "critico",
              )
              .length;

          // Si el modelo incluye un campo de costo, sumarlo dinámicamente
          double costoTotal = 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Resumen de Órdenes"),
                const SizedBox(height: 12),

                // Cuadrícula simétrica de 4 KPIs
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

                // Tabla optimizada con DataTable2
                SizedBox(
                  height: 310,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: maintenanceData.isEmpty
                        ? const Center(
                            child: Text(
                              "No hay registros de mantenimiento disponibles.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : DataTable2(
                            columnSpacing: 10,
                            minWidth: 550,
                            headingRowColor: WidgetStateProperty.all(
                              Colors.grey.shade200,
                            ),
                            columns: const [
                              DataColumn2(
                                label: Text("Título"),
                                size: ColumnSize.L,
                              ),
                              DataColumn2(
                                label: Text("Tipo"),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: Text("Descripción"),
                                size: ColumnSize.L,
                              ),
                              DataColumn2(
                                label: Text("Estado"),
                                size: ColumnSize.M,
                              ),
                            ],
                            rows: maintenanceData.map((data) {
                              Color stateColor;
                              final estadoStr = (data.estado ?? '')
                                  .toLowerCase();

                              if (estadoStr == "completado" ||
                                  estadoStr == "resuelto") {
                                stateColor = statusComplete;
                              } else if (estadoStr == "crítico" ||
                                  estadoStr == "critico") {
                                stateColor = statusCritical;
                              } else {
                                stateColor = statusPending;
                              }

                              return DataRow(
                                onSelectChanged: (_) =>
                                    _mostrarDetallesEquipo(data),
                                cells: [
                                  DataCell(
                                    Text(
                                      data.titulo,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(data.tipo ?? 'General')),
                                  DataCell(
                                    Text(
                                      data.descripcion,
                                      overflow: TextOverflow.ellipsis,
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
                                        data.estado ?? 'Pendiente',
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

                // Botón para exportar reporte PDF
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
          );
        },
      ),
    );
  }

  // --- COMPONENTES DE INTERFAZ ---

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

  void _mostrarDetallesEquipo(MaintenanceModel data) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "⚙️ TÍTULO: ${data.titulo}\n🔧 Tipo: ${data.tipo ?? 'General'}  •  📝 Desc: ${data.descripcion}\n📊 Estado: [${data.estado ?? 'Pendiente'}]",
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        backgroundColor: textDark,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Dialogo para la creación de un nuevo mantenimiento vía API
  void _mostrarDialogoNuevoMantenimiento() {
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String tipoSeleccionado = 'Preventivo';
    int? invernaderoIdSeleccionado = _invernaderos.isNotEmpty
        ? _invernaderos.first.id
        : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Nuevo Mantenimiento"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tituloCtrl,
                    decoration: const InputDecoration(labelText: "Título"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: "Descripción"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: tipoSeleccionado,
                    items: ['Preventivo', 'Correctivo', 'Calibración']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null)
                        setDialogState(() => tipoSeleccionado = val);
                    },
                    decoration: const InputDecoration(labelText: "Tipo"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: invernaderoIdSeleccionado,
                    items: _invernaderos
                        .map(
                          (inv) => DropdownMenuItem(
                            value: inv.id,
                            child: Text(inv.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setDialogState(() => invernaderoIdSeleccionado = val);
                    },
                    decoration: const InputDecoration(labelText: "Invernadero"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                onPressed: () async {
                  if (tituloCtrl.text.isEmpty ||
                      invernaderoIdSeleccionado == null)
                    return;
                  try {
                    await _service.createMaintenance(
                      titulo: tituloCtrl.text,
                      descripcion: descCtrl.text,
                      tipo: tipoSeleccionado,
                      invernaderoId: invernaderoIdSeleccionado!,
                    );
                    Navigator.pop(ctx);
                    _cargarDatos(); // Recargar la lista tras crear el elemento
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error al crear: $e")),
                    );
                  }
                },
                child: const Text(
                  "Guardar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
