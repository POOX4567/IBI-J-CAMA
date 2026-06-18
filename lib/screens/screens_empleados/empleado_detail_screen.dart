import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
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

  final List<Asistencia> _asistencias = [
    Asistencia(
      dia: 'LUN',
      fecha: '20',
      mes: 'MAY',
      estado: 'presente',
      hora: '06:00 AM',
    ),
    Asistencia(
      dia: 'MAR',
      fecha: '21',
      mes: 'MAY',
      estado: 'presente',
      hora: '06:05 AM',
    ),
    Asistencia(
      dia: 'MIÉ',
      fecha: '22',
      mes: 'MAY',
      estado: 'retardo',
      hora: '06:20 AM',
    ),
    Asistencia(
      dia: 'JUE',
      fecha: '23',
      mes: 'MAY',
      estado: 'presente',
      hora: '06:02 AM',
    ),
    Asistencia(
      dia: 'VIE',
      fecha: '24',
      mes: 'MAY',
      estado: 'falta',
      hora: '--',
    ),
    Asistencia(
      dia: 'SÁB',
      fecha: '25',
      mes: 'MAY',
      estado: 'presente',
      hora: '06:00 AM',
    ),
  ];

  final List<Actividad> _actividades = [
    Actividad(
      titulo: 'Inspección de humedad',
      fecha: '20/05/2026',
      estado: 'completada',
      descripcion: 'Revisión de niveles de humedad en Sector 4',
      progreso: 1.0,
    ),
    Actividad(
      titulo: 'Ajuste de riego',
      fecha: '21/05/2026',
      estado: 'completada',
      descripcion: 'Configuración manual del sistema de riego',
      progreso: 1.0,
    ),
    Actividad(
      titulo: 'Mantenimiento de sensores',
      fecha: '22/05/2026',
      estado: 'progreso',
      descripcion: 'Calibración de sensores de temperatura',
      progreso: 0.7,
    ),
    Actividad(
      titulo: 'Fertilización',
      fecha: '23/05/2026',
      estado: 'pendiente',
      descripcion: 'Aplicación de fertilizante orgánico',
      progreso: 0.0,
    ),
    Actividad(
      titulo: 'Poda de plantas',
      fecha: '24/05/2026',
      estado: 'completada',
      descripcion: 'Poda de plantas en Invernadero 1',
      progreso: 1.0,
    ),
  ];

  final List<Observacion> _observaciones = [
    Observacion(
      fecha: '20/05/2026',
      texto: 'Excelente trabajo en la inspección de humedad. Muy detallado.',
      autor: 'Supervisor Juan',
      hora: '10:30 AM',
    ),
    Observacion(
      fecha: '18/05/2026',
      texto: 'Recordar llegar puntual al turno matutino.',
      autor: 'Supervisor Juan',
      hora: '08:15 AM',
    ),
    Observacion(
      fecha: '15/05/2026',
      texto: 'Buen manejo del sistema de riego automático.',
      autor: 'Supervisor Juan',
      hora: '11:45 AM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
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
                  // Botón de retroceso
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
                      ],
                    ),
                  ),
                  // Foto de perfil
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Pestañas con scroll horizontal
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // Contenido de las pestañas (expanded para que ocupe el resto)
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

  Widget _buildAsistenciasTab() {
    int presentes = _asistencias.where((a) => a.estado == 'presente').length;
    int retardos = _asistencias.where((a) => a.estado == 'retardo').length;
    int faltas = _asistencias.where((a) => a.estado == 'falta').length;
    double porcentaje = (presentes / _asistencias.length) * 100;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
                'ASISTENCIA SEMANAL',
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
                  _buildStatItem('${presentes}d', 'Presentes', Colors.white),
                  _buildStatItem('${retardos}d', 'Retardos', Colors.orange),
                  _buildStatItem('${faltas}d', 'Faltas', Colors.red),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 8,
                  child: LinearProgressIndicator(
                    value: porcentaje / 100,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${porcentaje.toStringAsFixed(0)}% de asistencia',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'REGISTRO DIARIO',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        ..._asistencias.map((asistencia) => _buildAsistenciaCard(asistencia)),
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

  Widget _buildAsistenciaCard(Asistencia asistencia) {
    Color color;
    IconData icon;
    switch (asistencia.estado) {
      case 'presente':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'retardo':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      default:
        color = Colors.red;
        icon = Icons.cancel;
    }

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  asistencia.fecha,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  asistencia.mes,
                  style: TextStyle(fontSize: 10, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asistencia.dia,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  asistencia.estado == 'presente'
                      ? 'Presente'
                      : asistencia.estado == 'retardo'
                      ? 'Retardo'
                      : 'Falta',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                asistencia.hora,
                style: const TextStyle(fontSize: 11, color: Color(0xFF5D4037)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActividadesTab() {
    int completadas = _actividades
        .where((a) => a.estado == 'completada')
        .length;
    int enProgreso = _actividades.where((a) => a.estado == 'progreso').length;
    int pendientes = _actividades.where((a) => a.estado == 'pendiente').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActivitySummary(
                'Completadas',
                '$completadas',
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActivitySummary(
                'En Progreso',
                '$enProgreso',
                Colors.orange,
                Icons.hourglass_empty,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActivitySummary(
                'Pendientes',
                '$pendientes',
                Colors.grey,
                Icons.pending,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'HISTORIAL DE TAREAS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        ..._actividades.map((actividad) => _buildActividadCard(actividad)),
      ],
    );
  }

  Widget _buildActivitySummary(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Color(0xFF5D4037)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActividadCard(Actividad actividad) {
    Color color;
    IconData icon;
    String estadoText;
    switch (actividad.estado) {
      case 'completada':
        color = Colors.green;
        icon = Icons.check_circle;
        estadoText = 'Completada';
        break;
      case 'progreso':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        estadoText = 'En progreso';
        break;
      default:
        color = Colors.grey;
        icon = Icons.pending;
        estadoText = 'Pendiente';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showActividadDetalle(actividad),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        actividad.titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        estadoText,
                        style: TextStyle(fontSize: 10, color: color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  actividad.descripcion,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5D4037),
                  ),
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
                      actividad.fecha,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF81C784),
                      ),
                    ),
                  ],
                ),
                if (actividad.estado == 'progreso') ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: actividad.progreso,
                        backgroundColor: Colors.grey.shade200,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(actividad.progreso * 100).toStringAsFixed(0)}% completado',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ],
                if (actividad.estado != 'completada')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _marcarComoCompletada(actividad),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Marcar como completada'),
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

  Widget _buildObservacionesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _agregarObservacion,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Agregar observación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _observaciones.length,
            itemBuilder: (context, index) {
              final obs = _observaciones[index];
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
                    ),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  obs.autor,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${obs.fecha} • ${obs.hora}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF5D4037),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        obs.texto,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReporteCard(
          titulo: 'Reporte Semanal',
          periodo: 'Semana 21 (20-24 Mayo)',
          icon: Icons.calendar_today,
          color: const Color(0xFF2E7D32),
          estadisticas: const [
            'Asistencias: 4/6 días',
            'Retardos: 1',
            'Faltas: 1',
            'Actividades completadas: 3/5',
            'Cumplimiento: 75%',
          ],
        ),
        const SizedBox(height: 16),
        _buildReporteCard(
          titulo: 'Reporte Mensual',
          periodo: 'Mayo 2026',
          icon: Icons.calendar_month,
          color: const Color(0xFF81C784),
          estadisticas: const [
            'Asistencias: 18/22 días',
            'Retardos: 3',
            'Faltas: 2',
            'Actividades completadas: 12/15',
            'Cumplimiento: 82%',
          ],
        ),
        const SizedBox(height: 16),
        _buildReporteCard(
          titulo: 'Cumplimiento de Responsabilidades',
          periodo: 'Evaluación General',
          icon: Icons.assessment,
          color: const Color(0xFF5D4037),
          estadisticas: const [
            'Puntualidad: 85%',
            'Calidad de trabajo: 92%',
            'Trabajo en equipo: 88%',
            'Iniciativa: 90%',
            'Overall: 88.75% - Nivel Excelente',
          ],
        ),
      ],
    );
  }

  Widget _buildReporteCard({
    required String titulo,
    required String periodo,
    required IconData icon,
    required Color color,
    required List<String> estadisticas,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
          ...estadisticas.map(
            (stat) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 6, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stat,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _generarReporte(titulo),
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

  void _marcarComoCompletada(Actividad actividad) {
    setState(() {
      actividad.estado = 'completada';
      actividad.progreso = 1.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Actividad marcada como completada'),
        backgroundColor: Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _agregarObservacion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Nueva Observación'),
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
                  setState(() {
                    _observaciones.insert(
                      0,
                      Observacion(
                        fecha: _getCurrentDate(),
                        texto: controller.text,
                        autor: 'Supervisor Actual',
                        hora: _getCurrentTime(),
                      ),
                    );
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Observación agregada'),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _generarReporte(String tipo) async {
    // Mostrar diálogo de carga
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
      // Calcular estadísticas de asistencia
      int presentes = _asistencias.where((a) => a.estado == 'presente').length;
      int retardos = _asistencias.where((a) => a.estado == 'retardo').length;
      int faltas = _asistencias.where((a) => a.estado == 'falta').length;
      double porcentaje = (presentes / _asistencias.length) * 100;

      // Preparar estadísticas según el tipo de reporte
      List<String> estadisticas;
      Map<String, dynamic> datosAsistencia;
      String periodoTexto;

      if (tipo.contains('Semanal')) {
        periodoTexto = 'Semana 21 (20-24 Mayo 2026)';
        estadisticas = [
          'Asistencias: 4/6 días',
          'Retardos: 1',
          'Faltas: 1',
          'Actividades completadas: 3/5',
          'Cumplimiento: 75%',
          'Puntualidad: 85%',
        ];
        datosAsistencia = {
          'presentes': presentes,
          'retardos': retardos,
          'faltas': faltas,
          'porcentaje': porcentaje.toStringAsFixed(0),
        };
      } else if (tipo.contains('Mensual')) {
        periodoTexto = 'Mayo 2026';
        estadisticas = [
          'Asistencias: 18/22 días',
          'Retardos: 3',
          'Faltas: 2',
          'Actividades completadas: 12/15',
          'Cumplimiento: 82%',
          'Puntualidad: 88%',
        ];
        datosAsistencia = {
          'presentes': 18,
          'retardos': 3,
          'faltas': 2,
          'porcentaje': 82,
        };
      } else {
        periodoTexto = 'Evaluación General';
        estadisticas = [
          'Puntualidad: 85%',
          'Calidad de trabajo: 92%',
          'Trabajo en equipo: 88%',
          'Iniciativa: 90%',
          'Overall: 88.75% - Nivel Excelente',
        ];
        datosAsistencia = {
          'presentes': presentes,
          'retardos': retardos,
          'faltas': faltas,
          'porcentaje': porcentaje.toStringAsFixed(0),
        };
      }

      // Preparar actividades para el PDF
      List<Map<String, dynamic>> actividadesPDF = _actividades.map((a) {
        String estadoTexto;
        switch (a.estado) {
          case 'completada':
            estadoTexto = 'Completada';
            break;
          case 'progreso':
            estadoTexto = 'En progreso';
            break;
          default:
            estadoTexto = 'Pendiente';
        }
        return {'titulo': a.titulo, 'fecha': a.fecha, 'estado': estadoTexto};
      }).toList();

      // Generar el PDF
      final pdfBytes = await PdfReports.generarReporteEmpleado(
        nombre: widget.empleado.nombre,
        rol: widget.empleado.rol,
        zona: widget.empleado.zona,
        periodo: periodoTexto,
        estadisticas: estadisticas,
        datosAsistencia: datosAsistencia,
        actividades: actividadesPDF,
      );

      // Cerrar diálogo de carga
      Navigator.pop(context);

      // Mostrar opciones para compartir o imprimir
      _showReporteOptions(pdfBytes, tipo);
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

  void _showReporteOptions(Uint8List pdfBytes, String tipo) {
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
                        await _compartirReporte(pdfBytes, tipo);
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
                        await _guardarReporte(pdfBytes, tipo);
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

  Future<void> _compartirReporte(Uint8List pdfBytes, String tipo) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName =
        'reporte_${widget.empleado.nombre.replaceAll(' ', '_')}_$timestamp.pdf';

    try {
      await Share.shareXFiles([
        XFile.fromData(pdfBytes, name: fileName),
      ], text: 'Reporte de ${widget.empleado.nombre} - $tipo');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte listo para compartir'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
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

  Future<void> _guardarReporte(Uint8List pdfBytes, String tipo) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'reporte_${widget.empleado.nombre.replaceAll(' ', '_')}_$timestamp.pdf';

      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reporte guardado como $fileName'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
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

  void _showActividadDetalle(Actividad actividad) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(actividad.titulo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha: ${actividad.fecha}'),
              const SizedBox(height: 8),
              Text('Descripción: ${actividad.descripcion}'),
              const SizedBox(height: 8),
              Text('Estado: ${actividad.estado}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}

// Modelos auxiliares
class Asistencia {
  final String dia;
  final String fecha;
  final String mes;
  final String estado;
  final String hora;

  Asistencia({
    required this.dia,
    required this.fecha,
    required this.mes,
    required this.estado,
    required this.hora,
  });
}

class Actividad {
  String titulo;
  String fecha;
  String estado;
  String descripcion;
  double progreso;

  Actividad({
    required this.titulo,
    required this.fecha,
    required this.estado,
    required this.descripcion,
    required this.progreso,
  });
}

class Observacion {
  final String fecha;
  final String texto;
  final String autor;
  final String hora;

  Observacion({
    required this.fecha,
    required this.texto,
    required this.autor,
    required this.hora,
  });
}
