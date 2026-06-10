import 'package:flutter/material.dart';

class AttendanceReportPage extends StatelessWidget {
  const AttendanceReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. LISTA GENERAL DE EMPLEADOS
    final List<Map<String, String>> employees = [
      {"name": "Juan Pérez", "status": "Presente", "puntualidad": "100%"},
      {"name": "Carlos López", "status": "Ausente", "puntualidad": "70%"},
      {"name": "María Gómez", "status": "Tarde", "puntualidad": "85%"},
      {"name": "Ana Torres", "status": "Presente", "puntualidad": "98%"},
      {"name": "Luis Hernández", "status": "Presente", "puntualidad": "95%"},
      {"name": "Sofía Ramírez", "status": "Ausente", "puntualidad": "75%"},
    ];

    // --- FUENTES DE INFORMACIÓN DETALLADA (Visibles en pantalla / Cruzadas al tocar)
    final List<Map<String, String>> asistenciasVisibles = [
      {
        'dia': 'LUN',
        'fecha': '20',
        'mes': 'MAY',
        'estado': 'Presente',
        'hora': '06:00 AM',
      },
      {
        'dia': 'MAR',
        'fecha': '21',
        'mes': 'MAY',
        'estado': 'Presente',
        'hora': '06:05 AM',
      },
      {
        'dia': 'MIÉ',
        'fecha': '22',
        'mes': 'MAY',
        'estado': 'Retardo',
        'hora': '06:20 AM',
      },
      {
        'dia': 'JUE',
        'fecha': '23',
        'mes': 'MAY',
        'estado': 'Presente',
        'hora': '06:02 AM',
      },
      {
        'dia': 'VIE',
        'fecha': '24',
        'mes': 'MAY',
        'estado': 'Falta',
        'hora': '--',
      },
      {
        'dia': 'SÁB',
        'fecha': '25',
        'mes': 'MAY',
        'estado': 'Presente',
        'hora': '06:00 AM',
      },
    ];

    final List<Map<String, String>> observacionesVisibles = [
      {
        'fecha': '20/05/2026',
        'texto':
            'Excelente trabajo en la inspección de humedad. Muy detallado.',
        'autor': 'Sup. Juan',
      },
      {
        'fecha': '18/05/2026',
        'texto': 'Recordar llegar puntual al turno matutino.',
        'autor': 'Sup. Juan',
      },
    ];

    // CÁLCULOS AUTOMÁTICOS DE INDICADORES
    int presentesHoy = employees
        .where((emp) => emp["status"] == "Presente")
        .length;
    int ausentesHoy = employees
        .where((emp) => emp["status"] == "Ausente")
        .length;
    int tardeHoy = employees.where((emp) => emp["status"] == "Tarde").length;
    double porcentajeAsistencia = (employees.isNotEmpty)
        ? ((presentesHoy + tardeHoy) / employees.length) * 100
        : 0;

    Color getStatusColor(String status) {
      switch (status) {
        case "Presente":
          return Colors.green;
        case "Tarde":
        case "Retardo":
          return Colors.orange;
        default:
          return Colors.red;
      }
    }

    // FUNCIÓN INTERACTIVA: Muestra qué días tuvo asistencia y sus detalles en el SnackBar al tocar
    void mostrarDiasAsistencia(String nombre, String puntualidad) {
      StringBuffer buffer = StringBuffer();
      buffer.writeln("🗓️ DÍAS DE ASISTENCIA: $nombre [$puntualidad]");
      buffer.writeln("---------------------------------------");

      for (var asist in asistenciasVisibles) {
        buffer.writeln(
          "• ${asist['dia']} ${asist['fecha']} ${asist['mes']} - ${asist['estado']} (${asist['hora']})",
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
          backgroundColor: const Color(
            0xFF0D47A1,
          ), // Azul corporativo de control
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
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
      body: SingleChildScrollView(
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
                color: Color(0xFF263238),
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
                color: Color(0xFF263238),
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
                  rows: employees.map((emp) {
                    final status = emp["status"]!;
                    final color = getStatusColor(status);

                    return DataRow(
                      // Al tocar al empleado, se le despliegan los días que tuvo asistencia abajo en un snackbar
                      onSelectChanged: (_) => mostrarDiasAsistencia(
                        emp["name"]!,
                        emp["puntualidad"]!,
                      ),
                      cells: [
                        DataCell(
                          Text(
                            emp["name"]!,
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            emp["puntualidad"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
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
                color: Color(0xFF263238),
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
                  rows: asistenciasVisibles.map((asist) {
                    final estado = asist['estado']!;
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            "${asist['dia']} ${asist['fecha']} ${asist['mes']}",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataCell(
                          Text(
                            estado,
                            style: TextStyle(
                              color: getStatusColor(estado),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(Text(asist['hora']!)),
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
                color: Color(0xFF263238),
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
                children: observacionesVisibles.map((obs) {
                  return ListTile(
                    leading: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Color(0xFF0D47A1),
                    ),
                    title: Text(
                      obs['texto']!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    subtitle: Text(
                      "Por: ${obs['autor']} • ${obs['fecha']}",
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
              backgroundColor: const Color(0xFF0D47A1),
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
