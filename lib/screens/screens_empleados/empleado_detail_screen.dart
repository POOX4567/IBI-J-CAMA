import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'empleado.dart';
import 'pdf_reports.dart';

class EmpleadoDetailScreen extends StatefulWidget {
  final Empleado empleado;

  const EmpleadoDetailScreen({super.key, required this.empleado});

  @override
  State<EmpleadoDetailScreen> createState() => _EmpleadoDetailScreenState();
}

class _EmpleadoDetailScreenState extends State<EmpleadoDetailScreen> {
  int _selectedTab = 0;
  bool _isLoading = true;

  // Datos desde la API
  Map<String, dynamic> _empleadoData = {};
  List<dynamic> _asistencias = [];
  List<dynamic> _actividades = [];
  List<dynamic> _observaciones = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosEmpleado();
  }

  Future<void> _cargarDatosEmpleado() async {
    setState(() => _isLoading = true);

    try {
      // 1. Obtener datos del empleado
      final empleadoResponse = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/employees/${widget.empleado.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (empleadoResponse.statusCode == 200) {
        final Map<String, dynamic> empleadoData = json.decode(
          empleadoResponse.body,
        );
        if (empleadoData['success'] == true) {
          _empleadoData = empleadoData['data'] ?? {};
        }
      }

      // 2. Obtener asistencia
      await _cargarAsistencias();

      // 3. Obtener actividades
      await _cargarActividades();

      // 4. Obtener observaciones
      await _cargarObservaciones();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==== ASISTENCIAS ====
  Future<void> _cargarAsistencias() async {
    final asistenciaResponse = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/attendance/${widget.empleado.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (asistenciaResponse.statusCode == 200) {
      final Map<String, dynamic> asistenciaData = json.decode(
        asistenciaResponse.body,
      );
      if (asistenciaData['success'] == true) {
        setState(() {
          _asistencias = asistenciaData['data'] ?? [];
        });
      }
    }
  }

  Future<void> _registrarAsistencia(String tipo) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'user_id': widget.empleado.id, 'type': tipo}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${tipo} registrada correctamente'),
              backgroundColor: const Color(0xFF2E7D32),
            ),
          );
          await _cargarAsistencias();
        } else {
          throw Exception(data['message'] ?? 'Error al registrar');
        }
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _mostrarDialogoAsistencia() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registrar Asistencia'),
          content: const Text('¿Qué tipo de registro deseas hacer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _registrarAsistencia('Entrada');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text('Entrada'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _registrarAsistencia('Salida');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Salida'),
            ),
          ],
        );
      },
    );
  }

  // ==== ACTIVIDADES ====
  Future<void> _cargarActividades() async {
    final actividadesResponse = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/activities/${widget.empleado.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (actividadesResponse.statusCode == 200) {
      final Map<String, dynamic> actividadesData = json.decode(
        actividadesResponse.body,
      );
      if (actividadesData['success'] == true) {
        setState(() {
          _actividades = actividadesData['data'] ?? [];
        });
      }
    }
  }

  Future<void> _registrarActividad(String actividad, String descripcion) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/activities'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'user_id': widget.empleado.id,
          'activity': actividad,
          'description': descripcion,
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Actividad registrada correctamente'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
          await _cargarActividades();
        } else {
          throw Exception(data['message'] ?? 'Error al registrar');
        }
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _mostrarDialogoActividad() {
    final TextEditingController actividadController = TextEditingController();
    final TextEditingController descripcionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registrar Actividad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: actividadController,
                decoration: const InputDecoration(
                  labelText: 'Actividad',
                  hintText: 'Ej: Supervisión de cultivos',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe la actividad realizada...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (actividadController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _registrarActividad(
                    actividadController.text,
                    descripcionController.text,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El campo actividad es obligatorio'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  // ==== OBSERVACIONES ====
  Future<void> _cargarObservaciones() async {
    final observacionesResponse = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/observations/${widget.empleado.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (observacionesResponse.statusCode == 200) {
      final Map<String, dynamic> observacionesData = json.decode(
        observacionesResponse.body,
      );
      if (observacionesData['success'] == true) {
        setState(() {
          _observaciones = observacionesData['data'] ?? [];
        });
      }
    }
  }

  Future<void> _registrarObservacion(String texto) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/observations'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'user_id': widget.empleado.id,
          'observation': texto,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Observación registrada correctamente'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
          await _cargarObservaciones();
        } else {
          throw Exception(data['message'] ?? 'Error al registrar');
        }
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _editarObservacion(int id, String nuevoTexto) async {
    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/observations/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'observation': nuevoTexto}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Observación actualizada correctamente'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
          await _cargarObservaciones();
        } else {
          throw Exception(data['message'] ?? 'Error al actualizar');
        }
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _mostrarDialogoObservacion() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Observación'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Escribe tu observación...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.pop(context);
                  _registrarObservacion(controller.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El campo es obligatorio'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEditarObservacion(Map<String, dynamic> observacion) {
    final TextEditingController controller = TextEditingController(
      text: observacion['observation'] ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Observación'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Edita tu observación...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.pop(context);
                  _editarObservacion(observacion['id'], controller.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El campo es obligatorio'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  // ==== ESTADÍSTICAS ====
  Map<String, dynamic> _getEstadisticasAsistencia() {
    int entradas = 0;
    int salidas = 0;

    for (var item in _asistencias) {
      if (item['type'] == 'Entrada') entradas++;
      if (item['type'] == 'Salida') salidas++;
    }

    final total = _asistencias.length;
    final porcentaje = total > 0 ? (entradas / total * 100) : 0;

    return {
      'entradas': entradas,
      'salidas': salidas,
      'total': total,
      'porcentaje': porcentaje.toStringAsFixed(0),
    };
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final estadisticas = _getEstadisticasAsistencia();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            )
          : Column(
              children: [
                // Header personalizado
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => _generarReporte(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              widget.empleado.fotoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.white,
                                  child: const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Color(0xFF2E7D32),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.empleado.nombre,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.empleado.rol,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Pestañas
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTab('Asistencias', 0),
                          const SizedBox(width: 12),
                          _buildTab('Actividades', 1),
                          const SizedBox(width: 12),
                          _buildTab('Observaciones', 2),
                          const SizedBox(width: 12),
                          _buildTab('Reportes', 3),
                        ],
                      ),
                    ),
                  ),
                ),

                // Contenido
                Expanded(child: _buildCurrentTab()),
              ],
            ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFF2E7D32),
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF2E7D32),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedTab) {
      case 0:
        return _buildAsistenciasTab();
      case 1:
        return _buildActividadesTab();
      case 2:
        return _buildObservacionesTab();
      case 3:
        return _buildReportesTab();
      default:
        return _buildAsistenciasTab();
    }
  }

  // ============================================================
  // TAB: ASISTENCIAS
  // ============================================================
  Widget _buildAsistenciasTab() {
    final estadisticas = _getEstadisticasAsistencia();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Tarjeta de resumen con gráfica
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'RESUMEN DE ASISTENCIA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    '${estadisticas['entradas']}',
                    'Entradas',
                    Colors.white,
                  ),
                  _buildStatItem(
                    '${estadisticas['salidas']}',
                    'Salidas',
                    Colors.orange,
                  ),
                  _buildStatItem(
                    '${estadisticas['total']}',
                    'Total',
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 8,
                  child: LinearProgressIndicator(
                    value: double.tryParse(estadisticas['porcentaje']) != null
                        ? double.parse(estadisticas['porcentaje']) / 100
                        : 0,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${estadisticas['porcentaje']}% de asistencia',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Botón para registrar asistencia
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _mostrarDialogoAsistencia,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Registrar Asistencia'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'HISTORIAL DE ASISTENCIA',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        if (_asistencias.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No hay registros de asistencia',
                style: TextStyle(color: Color(0xFF5D4037)),
              ),
            ),
          )
        else
          ..._asistencias.reversed.map((item) => _buildAsistenciaCard(item)),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildAsistenciaCard(Map<String, dynamic> item) {
    final isEntrada = item['type'] == 'Entrada';
    final color = isEntrada ? Colors.green : Colors.orange;
    final icon = isEntrada ? Icons.login : Icons.logout;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['type'] ?? 'Sin tipo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['date_time'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5D4037),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFF5D4037),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB: ACTIVIDADES
  // ============================================================
  Widget _buildActividadesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Botón para registrar actividad
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _mostrarDialogoActividad,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Registrar Actividad'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'ACTIVIDADES REALIZADAS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        if (_actividades.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No hay actividades registradas',
                style: TextStyle(color: Color(0xFF5D4037)),
              ),
            ),
          )
        else
          ..._actividades.map((item) => _buildActividadCard(item)),
      ],
    );
  }

  Widget _buildActividadCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assignment,
                  size: 20,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['activity'] ?? 'Sin actividad',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (item['description'] != null && item['description'].isNotEmpty)
            Text(
              item['description'],
              style: const TextStyle(fontSize: 13, color: Color(0xFF5D4037)),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 12,
                color: Color(0xFF81C784),
              ),
              const SizedBox(width: 4),
              Text(
                item['date'] ?? '',
                style: const TextStyle(fontSize: 11, color: Color(0xFF81C784)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB: OBSERVACIONES
  // ============================================================
  Widget _buildObservacionesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Botón para agregar observación
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _mostrarDialogoObservacion,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Agregar Observación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'OBSERVACIONES',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        if (_observaciones.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No hay observaciones registradas',
                style: TextStyle(color: Color(0xFF5D4037)),
              ),
            ),
          )
        else
          ..._observaciones.map((item) => _buildObservacionCard(item)),
      ],
    );
  }

  Widget _buildObservacionCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.comment,
                      size: 16,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Observación #${item['id']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                    onPressed: () => _mostrarDialogoEditarObservacion(item),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['observation'] ?? '',
            style: const TextStyle(fontSize: 14, color: Color(0xFF5D4037)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 12,
                color: Color(0xFF81C784),
              ),
              const SizedBox(width: 4),
              Text(
                item['created_at'] ?? '',
                style: const TextStyle(fontSize: 11, color: Color(0xFF81C784)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB: REPORTES
  // ============================================================
  Widget _buildReportesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReporteCard(
          titulo: 'Reporte Semanal',
          periodo: 'Semana Actual',
          icon: Icons.calendar_today,
          color: const Color(0xFF2E7D32),
        ),
        const SizedBox(height: 16),
        _buildReporteCard(
          titulo: 'Reporte Mensual',
          periodo: 'Mes Actual',
          icon: Icons.calendar_month,
          color: const Color(0xFF81C784),
        ),
        const SizedBox(height: 16),
        _buildReporteCard(
          titulo: 'Cumplimiento de Responsabilidades',
          periodo: 'Evaluación General',
          icon: Icons.assessment,
          color: const Color(0xFF5D4037),
        ),
      ],
    );
  }

  Widget _buildReporteCard({
    required String titulo,
    required String periodo,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      periodo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text('• Asistencias: ${_asistencias.length} registros'),
          Text('• Actividades: ${_actividades.length} realizadas'),
          Text('• Observaciones: ${_observaciones.length} registradas'),
          Text('• Estado: ${widget.empleado.estado}'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _generarReporte(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Generar Reporte'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GENERAR REPORTE PDF
  // ============================================================
  Future<void> _generarReporte() async {
    final estadisticas = _getEstadisticasAsistencia();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        );
      },
    );

    try {
      final List<String> estadisticasList = [
        'Entradas: ${estadisticas['entradas']}',
        'Salidas: ${estadisticas['salidas']}',
        'Total registros: ${estadisticas['total']}',
        'Actividades realizadas: ${_actividades.length}',
        'Observaciones: ${_observaciones.length}',
        'Estado: ${widget.empleado.estado}',
      ];

      final List<Map<String, dynamic>> actividadesList = _actividades.map((
        item,
      ) {
        return {
          'actividad': item['activity'] ?? 'Sin actividad',
          'fecha': item['date'] ?? '',
          'estado': 'Completada',
        };
      }).toList();

      final pdfBytes = await PdfReports.generarReporteEmpleado(
        nombre: widget.empleado.nombre,
        rol: widget.empleado.rol,
        zona: widget.empleado.zona,
        periodo: DateFormat('MMMM yyyy', 'es').format(DateTime.now()),
        estadisticas: estadisticasList,
        datosAsistencia: {
          'presentes': estadisticas['entradas'],
          'retardos': 0,
          'faltas': 0,
          'porcentaje': estadisticas['porcentaje'],
        },
        actividades: actividadesList,
      );

      Navigator.pop(context);
      _showReporteOptions(pdfBytes);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar reporte: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReporteOptions(Uint8List pdfBytes) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Opciones del Reporte',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionButton(
                      icon: Icons.share,
                      label: 'Compartir',
                      color: const Color(0xFF2E7D32),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _compartirReporte(pdfBytes);
                      },
                    ),
                    _buildOptionButton(
                      icon: Icons.print,
                      label: 'Imprimir',
                      color: const Color(0xFF81C784),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _imprimirReporte(pdfBytes);
                      },
                    ),
                    _buildOptionButton(
                      icon: Icons.save,
                      label: 'Guardar',
                      color: const Color(0xFF5D4037),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _guardarReporte(pdfBytes);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.1),
          child: IconButton(
            icon: Icon(icon, color: color, size: 28),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _compartirReporte(Uint8List pdfBytes) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName =
        'reporte_${widget.empleado.nombre.replaceAll(' ', '_')}_$timestamp.pdf';

    try {
      await Share.shareXFiles([
        XFile.fromData(pdfBytes, name: fileName),
      ], text: 'Reporte de ${widget.empleado.nombre}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte listo para compartir'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _imprimirReporte(Uint8List pdfBytes) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Reporte_Empleado',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al imprimir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _guardarReporte(Uint8List pdfBytes) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'reporte_${widget.empleado.nombre.replaceAll(' ', '_')}_$timestamp.pdf';

      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reporte guardado como $fileName'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
