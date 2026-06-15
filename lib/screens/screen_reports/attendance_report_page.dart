import 'package:flutter/material.dart';
import 'package:ibi/models/attendance_model.dart';
import 'package:ibi/services/attendance_service.dart';

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  final AttendanceService _attendanceService = AttendanceService();
  late Future<AttendanceReportData> _reportFuture;

  // Colores corporativos del módulo de control
  static const Color corporateBlue = Color(0xFF0D47A1);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color textDark = Color(0xFF263238);
  static const Color background = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();
    // Lanzamos la consulta al iniciar la vista
    _reportFuture = _attendanceService.fetchAttendanceReport();
  }

  // Función interactiva adaptada para consumir el modelo RecentAttendanceModel
  void _mostrarDiasAsistencia(
    String nombre,
    String puntualidad,
    List<RecentAttendanceModel> asistencias,
  ) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln("🗓️ DÍAS DE ASISTENCIA: $nombre [$puntualidad]");
    buffer.writeln("---------------------------------------");

    for (var asist in asistencias) {
      buffer.writeln(
        "• ${asist.dia} ${asist.fecha} ${asist.mes} - ${asist.estado} (${asist.hora})",
      );
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          buffer.toString(),
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            height: 1.4,
          ),
        ),
        backgroundColor: corporateBlue,
        duration: const Duration(seconds: 6),
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
              colors: [corporateBlue, lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Reporte General de Asistencia",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Historial operativo e indicadores de asistencia",
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
      body: FutureBuilder<AttendanceReportData>(
        future: _reportFuture,
        builder: (context, snapshot) {
          // ⏳ Estado de Carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: corporateBlue),
            );
          }
          // ❌ Estado de Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Error al cargar control de asistencia: ${snapshot.error}",
                ),
              ),
            );
          }
          // 🚫 Estado Vacío
          if (!snapshot.hasData) {
            return const Center(
              child: Text("No se encontraron registros de asistencia."),
            );
          }

          // 🧠 Datos listos para procesar de manera tipada
          final data = snapshot.data!;

          // Cálculos de KPI automáticos basados en la lista de objetos del modelo
          int presentesHoy = data.employees
              .where((emp) => emp.status == "Presente")
              .length;
          int ausentesHoy = data.employees
              .where((emp) => emp.status == "Ausente")
              .length;
          int tardeHoy = data.employees
              .where((emp) => emp.status == "Tarde")
              .length;

          double porcentajeAsistencia = (data.employees.isNotEmpty)
              ? ((presentesHoy + tardeHoy) / data.employees.length) * 100
              : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. INDICADORES GENERALES DEL DÍA
                const Text(
                  "Resumen General",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _localKpiCard(
                      title: "Presentes hoy",
                      value: presentesHoy.toString(),
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),
                    const SizedBox(width: 12),
                    _localKpiCard(
                      title: "Ausentes",
                      value: ausentesHoy.toString(),
                      color: Colors.red,
                      icon: Icons.cancel,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _localKpiCard(
                      title: "Tarde",
                      value: tardeHoy.toString(),
                      color: Colors.orange,
                      icon: Icons.access_time,
                    ),
                    const SizedBox(width: 12),
                    _localKpiCard(
                      title: "Asistencia %",
                      value: "${porcentajeAsistencia.toStringAsFixed(0)}%",
                      color: Colors.blue,
                      icon: Icons.pie_chart,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 2. TABLA CENTRAL DE EMPLEADOS
                const Text(
                  "Control de Asistencia General",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 45,
                      showCheckboxColumn: false,
                      headingRowColor: WidgetStateProperty.all(
                        Colors.grey.shade100,
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            "Empleado",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Estado Hoy",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Puntualidad Semanal",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: data.employees.map((emp) {
                        return DataRow(
                          onSelectChanged: (_) => _mostrarDiasAsistencia(
                            emp.name,
                            emp.puntualidad,
                            data.recentAttendance,
                          ),
                          cells: [
                            DataCell(
                              Text(
                                emp.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
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
                                  color: emp.statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  emp.status,
                                  style: TextStyle(
                                    color: emp.statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                emp.puntualidad,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: corporateBlue,
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

                // 3. TABLA DEL HISTORIAL DE ENTRADAS GENERALES
                const Text(
                  "Matriz de Entradas Recientes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 45,
                      headingRowColor: WidgetStateProperty.all(
                        Colors.grey.shade100,
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            "Fecha",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Registro",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Hora Entrada",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: data.recentAttendance.map((asist) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                "${asist.dia} ${asist.fecha} ${asist.mes}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                asist.estado,
                                style: TextStyle(
                                  color: asist.statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(Text(asist.hora)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 4. BITÁCORA DE OBSERVACIONES DEL SUPERVISOR
                const Text(
                  "Observaciones del Supervisor",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
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
                    children: data.observations.map((obs) {
                      return ListTile(
                        leading: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: corporateBlue,
                        ),
                        title: Text(
                          obs.texto,
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        subtitle: Text(
                          "Por: ${obs.autor} • ${obs.fecha}",
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 30),
                _localExportButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- COMPONENTES AUXILIARES LOCALES ---

  Widget _localKpiCard({
    required String title,
    required String value,
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
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(icon, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
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
                  content: Text("Exportando reporte completo a PDF..."),
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
              backgroundColor: corporateBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Exportando reporte completo a Excel..."),
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
