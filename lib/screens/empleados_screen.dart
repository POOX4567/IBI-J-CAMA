import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens_empleados/chat_screen.dart';
import 'screens_empleados/empleado_detail_screen.dart';
import 'screens_empleados/empleado.dart';

class EmpleadosScreen extends StatefulWidget {
  const EmpleadosScreen({super.key});

  @override
  State<EmpleadosScreen> createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  String _selectedFilter = 'Todo el Personal';
  List<Empleado> _empleados = [];
  bool _isLoading = true;
  String? _errorMessage;

  String get _fechaActual {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, d \'de\' MMMM \'de\' yyyy', 'es');
    return formatter.format(now);
  }

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Obtener empleados
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/employees'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> empleadosData = data['data'];
          final List<Empleado> empleados = empleadosData
              .map((json) => Empleado.fromJson(json))
              .toList();

          // 2. Obtener asistencia para cada empleado
          for (var empleado in empleados) {
            await _cargarAsistencia(empleado);
          }

          setState(() {
            _empleados = empleados;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Error al cargar empleados';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error ${response.statusCode}: ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al conectar con el servidor: $e';
        _isLoading = false;
      });
    }
  }

  // Función para cargar asistencia de un empleado
  Future<void> _cargarAsistencia(Empleado empleado) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/attendance/${empleado.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final asistenciaData = data['data'] ?? {};
          // Asignar valores al empleado
          empleado.asistencia = asistenciaData['status'] ?? 'No registrado';
          empleado.horaEntrada = asistenciaData['check_in'] ?? '';
          empleado.horaSalida = asistenciaData['check_out'] ?? '';
          empleado.fechaAsistencia = asistenciaData['date'] ?? '';
        }
      }
    } catch (e) {
      // Si falla la asistencia, dejar valores por defecto
      empleado.asistencia = 'No registrado';
    }
  }

  // Obtener texto de asistencia formateado
  String _getAsistenciaText(Empleado empleado) {
    if (empleado.asistencia == null || empleado.asistencia!.isEmpty) {
      return 'No registrado';
    }
    switch (empleado.asistencia!.toLowerCase()) {
      case 'presente':
        return 'Puntual';
      case 'retardo':
        return 'Retardo';
      case 'falta':
        return 'Falta';
      case 'justificado':
        return 'Justificado';
      default:
        return empleado.asistencia!;
    }
  }

  // Obtener color de asistencia
  Color _getAsistenciaColor(Empleado empleado) {
    if (empleado.asistencia == null || empleado.asistencia!.isEmpty) {
      return Colors.grey;
    }
    switch (empleado.asistencia!.toLowerCase()) {
      case 'presente':
        return Colors.green;
      case 'retardo':
        return Colors.orange;
      case 'falta':
        return Colors.red;
      case 'justificado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  List<Empleado> get _empleadosFiltrados {
    if (_selectedFilter == 'Todo el Personal') {
      return _empleados;
    } else if (_selectedFilter == 'Invernadero 1') {
      return _empleados.where((e) => e.zona == 'Invernadero 1').toList();
    } else if (_selectedFilter == 'Invernadero 2') {
      return _empleados.where((e) => e.zona == 'Invernadero 2').toList();
    }
    return _empleados;
  }

  Future<void> _hacerLlamada(String numero) async {
    if (numero.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay número de teléfono disponible'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final Uri telUri = Uri(scheme: 'tel', path: numero);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se puede llamar a $numero'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Directorio de Empleados',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _fechaActual,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  'Administrando ${_empleados.length} especialistas de invernadero',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todo el Personal'),
                  const SizedBox(width: 12),
                  _buildFilterChip('Invernadero 1'),
                  const SizedBox(width: 12),
                  _buildFilterChip('Invernadero 2'),
                ],
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  )
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5D4037),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _cargarEmpleados,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : _empleados.isEmpty
                ? const Center(
                    child: Text(
                      'No hay empleados registrados',
                      style: TextStyle(fontSize: 16, color: Color(0xFF5D4037)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _empleadosFiltrados.length,
                    itemBuilder: (context, index) {
                      final empleado = _empleadosFiltrados[index];
                      return _buildEmpleadoCard(empleado);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == label,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: const Color(0xFF2E7D32),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: _selectedFilter == label
            ? Colors.white
            : const Color(0xFF5D4037),
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Colors.grey.shade200,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildEmpleadoCard(Empleado empleado) {
    final asistenciaText = _getAsistenciaText(empleado);
    final asistenciaColor = _getAsistenciaColor(empleado);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmpleadoDetailScreen(empleado: empleado),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF5F5F5)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: Image.network(
                        empleado.fotoUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF81C784),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF81C784),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            empleado.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: empleado.colorEstado.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: empleado.colorEstado,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  empleado.estado,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: empleado.colorEstado,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: asistenciaColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: asistenciaColor,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  asistenciaText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: asistenciaColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  empleado.rol,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5D4037),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Text(
                  empleado.zona,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF81C784),
                  ),
                ),

                const Divider(height: 24, thickness: 1),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: Color(0xFF5D4037),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'TURNO ACTUAL:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        empleado.turno,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Color(0xFF5D4037),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ASISTENCIA:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asistenciaText,
                            style: TextStyle(
                              fontSize: 12,
                              color: asistenciaColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (empleado.horaEntrada != null &&
                              empleado.horaEntrada!.isNotEmpty)
                            Text(
                              'Entrada: ${empleado.horaEntrada}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF5D4037),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                nombre: empleado.nombre,
                                rol: empleado.rol,
                                fotoUrl: empleado.fotoUrl,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.message, size: 18),
                        label: const Text('Mensaje'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _hacerLlamada(empleado.telefono);
                        },
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Llamar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
