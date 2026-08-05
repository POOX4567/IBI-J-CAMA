import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens_empleados/chat_screen.dart';
import 'screens_empleados/empleado_detail_screen.dart';
import 'screens_empleados/empleado.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EmpleadosScreen extends StatefulWidget {
  const EmpleadosScreen({super.key});

  @override
  State<EmpleadosScreen> createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  String _selectedFilter = 'Todo';
  List<Empleado> _empleados = [];
  List<Empleado> _empleadosFiltrados = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
    _searchController.addListener(_filtrarEmpleados);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrarEmpleados);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarEmpleados() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'token');

      final response = await http.get(
        Uri.parse('https://ibijicama.utptics.com/api/employees'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> empleadosData = data['data'];
          final List<Empleado> empleados = empleadosData
              .map((json) => Empleado.fromJson(json))
              .toList();

          setState(() {
            _empleados = empleados;
            _empleadosFiltrados = empleados;
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

  void _filtrarEmpleados() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _empleadosFiltrados = _empleados;
      } else {
        _empleadosFiltrados = _empleados.where((empleado) {
          return empleado.nombre.toLowerCase().contains(query) ||
              empleado.rol.toLowerCase().contains(query) ||
              empleado.correo.toLowerCase().contains(query) ||
              empleado.zona.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  String get _fechaActual {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, d \'de\' MMMM \'de\' yyyy', 'es');
    return formatter.format(now);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: Column(
        children: [
          // ============================================================
          // HEADER RESPONSIVO
          // ============================================================
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            width: double.infinity,
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
                Text(
                  'Directorio de Empleados',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _fechaActual,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _empleadosFiltrados.length == _empleados.length
                      ? 'Administrando ${_empleados.length} especialistas de invernadero'
                      : 'Mostrando ${_empleadosFiltrados.length} de ${_empleados.length} especialistas',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // BARRA DE BÚSQUEDA Y FILTRO "TODO"
          // ============================================================
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
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todo'),
                  selected: _selectedFilter == 'Todo',
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedFilter = 'Todo';
                      _searchController.clear();
                      _empleadosFiltrados = _empleados;
                    });
                  },
                  selectedColor: const Color(0xFF2E7D32),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _selectedFilter == 'Todo'
                        ? Colors.white
                        : const Color(0xFF5D4037),
                    fontWeight: FontWeight.w500,
                  ),
                  backgroundColor: Colors.grey.shade200,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar empleado...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.grey,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _filtrarEmpleados();
                                  setState(() {
                                    _selectedFilter = 'Todo';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                      onChanged: (_) {
                        setState(() {
                          _selectedFilter = 'Búsqueda';
                        });
                      },
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '${_empleadosFiltrados.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ============================================================
          // LISTA DE EMPLEADOS
          // ============================================================
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
                : _empleadosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'No se encontraron empleados con "${_searchController.text}"'
                              : 'No hay empleados registrados',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5D4037),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_searchController.text.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              _filtrarEmpleados();
                            },
                            child: const Text('Limpiar búsqueda'),
                          ),
                      ],
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

  Widget _buildEmpleadoCard(Empleado empleado) {
    String invernaderosTexto = empleado.invernaderos.isEmpty
        ? 'Sin invernadero'
        : empleado.invernaderos.map((e) => e['nombre'].toString()).join(', ');

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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                  invernaderosTexto,
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
                      'TURNO:',
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
                    const Icon(Icons.phone, size: 16, color: Color(0xFF5D4037)),
                    const SizedBox(width: 8),
                    const Text(
                      'TELÉFONO:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        empleado.telefono.isNotEmpty
                            ? empleado.telefono
                            : 'No registrado',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                        ),
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
                                empleadoId: empleado.id,
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
