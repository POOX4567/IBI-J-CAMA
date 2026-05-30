import 'package:flutter/material.dart';
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

  final List<Empleado> _empleados = [
    Empleado(
      nombre: 'Marcus Rivera',
      rol: 'Responsable de Invernadero',
      zona: 'Invernadero 1',
      estado: 'Activo',
      turno: '06:00 AM - 02:00 PM',
      asistencia: 'Puntual',
      colorEstado: Colors.green,
      fotoUrl:
          'https://i.pinimg.com/originals/72/31/79/723179cb2148f0293eb2aaa8e08a3daa.jpg',
    ),
    Empleado(
      nombre: 'Elena Vance',
      rol: 'Responsable de Invernadero',
      zona: 'Invernadero 2',
      estado: 'Descanso',
      turno: '02:00 PM - 10:00 PM',
      asistencia: 'Programado',
      colorEstado: Colors.orange,
      fotoUrl:
          'https://tse1.mm.bing.net/th/id/OIP.dK-loEFvTG6Cdm9CjU42wAHaLG?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
    ),
    Empleado(
      nombre: 'Carlos Mendoza',
      rol: 'Responsable de Invernadero',
      zona: 'Invernadero 1',
      estado: 'Activo',
      turno: '06:00 AM - 02:00 PM',
      asistencia: 'Puntual',
      colorEstado: Colors.green,
      fotoUrl:
          'https://i.pinimg.com/736x/1d/20/e0/1d20e072722e22dd56f17a51d7809561.jpg',
    ),
    Empleado(
      nombre: 'Laura Fernández',
      rol: 'Responsable de Invernadero',
      zona: 'Invernadero 2',
      estado: 'Activo',
      turno: '02:00 PM - 10:00 PM',
      asistencia: 'Puntual',
      colorEstado: Colors.green,
      fotoUrl:
          'https://i.pinimg.com/originals/e3/9c/da/e39cda0fdd790c019cdb02723178c524.jpg',
    ),
    Empleado(
      nombre: 'Roberto Sánchez',
      rol: 'Responsable de Invernadero',
      zona: 'Invernadero 1',
      estado: 'Descanso',
      turno: '06:00 AM - 02:00 PM',
      asistencia: 'Programado',
      colorEstado: Colors.orange,
      fotoUrl:
          'https://booker-kult.s3.amazonaws.com/library/1137/20210510_165004145_M.JPG',
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header con estadísticas
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
                const SizedBox(height: 8),
                Text(
                  'Administrando ${_empleados.length} especialistas de invernadero en 2 zonas',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Filtros con scroll horizontal
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

          // Lista de empleados
          Expanded(
            child: ListView.builder(
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
                // Foto de perfil + Nombre y estado
                Row(
                  children: [
                    // Foto de perfil
                    ClipOval(
                      child: Image.network(
                        empleado.fotoUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
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
                    // Nombre y estado
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

                // Rol
                Text(
                  empleado.rol,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5D4037),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Zona
                Text(
                  empleado.zona,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF81C784),
                  ),
                ),

                const Divider(height: 24, thickness: 1),

                // Turno actual
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

                // Asistencia
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
                      child: Text(
                        empleado.asistencia,
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

                // Botón Mensaje
                SizedBox(
                  width: double.infinity,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMensajeDialog(BuildContext context, String nombre) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enviar mensaje a $nombre'),
          content: const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Escribe tu mensaje aquí...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mensaje enviado'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
}
