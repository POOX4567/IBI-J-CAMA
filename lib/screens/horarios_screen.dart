import 'package:flutter/material.dart';
import '../screens/screens_horarios/horario.dart';
import '../screens/screens_horarios/horario_data.dart';
import '../screens/screens_horarios/horario_detail_screen.dart';
import '../widgets/alerta_card.dart';
import '../widgets/horario_card.dart';

import 'screens_areas/area.dart';
import 'screens_areas/area_data.dart';
import 'screens_areas/area_detail_screen.dart';

import '../widgets/area_card.dart';
import '../widgets/notificacion_card.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/filtro_chip_widget.dart';
import 'screens_areas/area_historial_screen.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  bool mostrarHorarios = true;
  late List<Horario> _horarios;
  late List<Area> _areas;
  int _nextHorarioTemplate = 0;
  int _nextAreaTemplate = 0;

  final List<Horario> _horarioTemplates = const [
    Horario(
      nombre: 'Laura Ramírez',
      turno: 'Matutino',
      actividad: 'Revisión de cultivos',
      fechaInicio: '12/06/2026',
      fechaFin: '26/06/2026',
      entrada: '07:00',
      salida: '15:30',
    ),
    Horario(
      nombre: 'Pablo Suárez',
      turno: 'Vespertino',
      actividad: 'Cosecha',
      fechaInicio: '14/06/2026',
      fechaFin: '28/06/2026',
      entrada: '13:00',
      salida: '21:00',
    ),
    Horario(
      nombre: 'Elena Torres',
      turno: 'Nocturno',
      actividad: 'Monitoreo de riego',
      fechaInicio: '16/06/2026',
      fechaFin: '30/06/2026',
      entrada: '22:00',
      salida: '06:00',
    ),
  ];

  final List<Area> _areaTemplates = const [
    Area(
      empleado: 'Luis Herrera',
      area: 'Invernadero C',
      cultivo: 'Fresa',
      actividad: 'Poda',
      estado: 'Pendiente',
      progreso: 0.35,
    ),
    Area(
      empleado: 'Ana García',
      area: 'Invernadero D',
      cultivo: 'Lechuga',
      actividad: 'Riego',
      estado: 'Pendiente',
      progreso: 0.25,
    ),
    Area(
      empleado: 'Diego Ramírez',
      area: 'Invernadero E',
      cultivo: 'Hierbas',
      actividad: 'Fertilización',
      estado: 'Pendiente',
      progreso: 0.15,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _horarios = List<Horario>.from(horarios);
    _areas = List<Area>.from(areas);
  }

  void _addHorario() {
    setState(() {
      final Horario template =
          _horarioTemplates[_nextHorarioTemplate % _horarioTemplates.length];
      _horarios.add(template);
      _nextHorarioTemplate++;
    });
  }

  void _addInvernadero() {
    setState(() {
      final Area template =
          _areaTemplates[_nextAreaTemplate % _areaTemplates.length];
      _areas.add(template);
      _nextAreaTemplate++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int horariosActivos = _horarios.length;
    final int turnosDistintos = _horarios
        .map((horario) => horario.turno)
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff1B5E20),
        title: Text(
          mostrarHorarios ? 'Gestión de Horarios' : 'Gestión de Áreas',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff1B5E20), Color(0xff43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Resumen Rápido',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Horarios y horarios activos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Activos: $horariosActivos',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Turnos: $turnosDistintos',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Registros: $horariosActivos',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          mostrarHorarios = true;
                        });
                      },
                      icon: const Icon(Icons.schedule_outlined),
                      label: const Text('Horarios'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: mostrarHorarios
                            ? const Color(0xff1B5E20)
                            : Colors.white,
                        foregroundColor: mostrarHorarios
                            ? Colors.white
                            : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          mostrarHorarios = false;
                        });
                      },
                      icon: const Icon(Icons.agriculture),
                      label: const Text('Áreas'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: !mostrarHorarios
                            ? const Color(0xff1B5E20)
                            : Colors.white,
                        foregroundColor: !mostrarHorarios
                            ? Colors.white
                            : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            if (mostrarHorarios)
              _buildHorarios(context)
            else
              _buildAreas(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHorarios(BuildContext context) {
    final int totalRegistros = _horarios.length;
    final int totalTurnos = _horarios
        .map((horario) => horario.turno)
        .toSet()
        .length;
    final int horariosActivos = _horarios.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 170,
              child: DashboardStatCard(
                valor: '$horariosActivos',
                titulo: 'Horarios Activos',
                icono: Icons.check_circle_outline,
              ),
            ),
            SizedBox(
              width: 170,
              child: DashboardStatCard(
                valor: '$totalRegistros',
                titulo: 'Empleados',
                icono: Icons.people,
              ),
            ),
            SizedBox(
              width: 170,
              child: DashboardStatCard(
                valor: '$totalTurnos',
                titulo: 'Turnos',
                icono: Icons.calendar_month,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FiltroChipWidget(
                    texto: 'Todos',
                    seleccionado: true,
                    onTap: () {},
                    icon: Icons.grid_view,
                  ),
                  FiltroChipWidget(
                    texto: 'Matutino',
                    seleccionado: false,
                    onTap: () {},
                    icon: Icons.wb_sunny,
                  ),
                  FiltroChipWidget(
                    texto: 'Vespertino',
                    seleccionado: false,
                    onTap: () {},
                    icon: Icons.nights_stay,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.table_chart, color: Color(0xff1B5E20)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tabla de Empleados',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Text(
                '$totalRegistros registros',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _addHorario,
            icon: const Icon(Icons.add),
            label: const Text('Agregar empleado'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1B5E20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alertas importantes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              AlertaCard(
                color: Colors.orange,
                icon: Icons.warning_amber_rounded,
                texto: 'Horas extra detectadas',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text('Horas extra detectadas'),
                      content: Text(
                        'Juan Pérez registró 4 horas extra durante la semana.',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              AlertaCard(
                color: Colors.red,
                icon: Icons.error_outline_rounded,
                texto: 'Conflicto de horarios',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text('Conflicto de horarios'),
                      content: Text(
                        'Existe un conflicto entre los horarios asignados a María López.',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              AlertaCard(
                color: Colors.green,
                icon: Icons.sync_alt_rounded,
                texto: 'Cambio de turno pendiente',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text('Cambio de turno pendiente'),
                      content: Text(
                        'Carlos Mendoza solicitó un cambio de turno para la próxima semana.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ..._horarios.map(
          (horario) => HorarioCard(
            horario: horario,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HorarioDetailScreen(horario: horario),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAreas(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff1B5E20), Color(0xff43A047)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 24,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.grid_view,
                  size: 34,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Asignación de Áreas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Supervisión inteligente agrícola',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.dashboard, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _summaryCard(
              icon: Icons.pending_actions,
              title:
                  '${_areas.where((area) => area.estado.toLowerCase().contains("pendiente")).length}',
              subtitle: 'Pendientes',
              color: Colors.orange,
            ),
            _summaryCard(
              icon: Icons.check_circle,
              title:
                  '${_areas.where((area) => area.estado.toLowerCase().contains("completado")).length}',
              subtitle: 'Completadas',
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Centro de alertas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        NotificacionCard(
          texto: 'Actividad atrasada detectada',
          descripcion:
              'Revisa el área pendiente para evitar retrasos en la cosecha.',
          color: Colors.red,
          icono: Icons.warning_amber_rounded,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const AlertDialog(
                title: Text('Actividad atrasada detectada'),
                content: Text(
                  'Se ha detectado una actividad atrasada en el Invernadero A. Coordina con el equipo para recuperar el tiempo.',
                ),
              ),
            );
          },
        ),
        NotificacionCard(
          texto: 'Cambio de asignación realizado',
          descripcion: 'La asignación ha sido actualizada correctamente.',
          color: Colors.blue,
          icono: Icons.swap_horiz,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const AlertDialog(
                title: Text('Cambio de asignación realizado'),
                content: Text(
                  'El personal ha sido reasignado y los turnos han sido actualizados en el sistema.',
                ),
              ),
            );
          },
        ),
        NotificacionCard(
          texto: 'Sobrecarga detectada en Área B',
          descripcion: 'El área B tiene más tareas asignadas de las previstas.',
          color: Colors.amber,
          icono: Icons.error_outline,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const AlertDialog(
                title: Text('Sobrecarga detectada en Área B'),
                content: Text(
                  'El área B tiene una asignación excesiva de tareas. Revisa las prioridades y redistribuye el trabajo.',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Panel de supervisión',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Controla tus invernaderos y agrega nuevos espacios rápidamente.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addInvernadero,
                icon: const Icon(Icons.add),
                label: const Text('Agregar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1B5E20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Column(
          children: _areas
              .map(
                (area) => AreaCard(
                  area: area,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AreaDetailScreen(area: area),
                      ),
                    );
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        _buildProductividadSemanal(context),
        const SizedBox(height: 20),
        _buildResumenDelDia(context),
      ],
    );
  }

  Widget _buildProductividadSemanal(BuildContext context) {
    final List<Map<String, dynamic>> cultivos = [
      {'nombre': 'Tomate', 'valor': 0.9, 'color': Colors.green},
      {'nombre': 'Pepino', 'valor': 0.6, 'color': Colors.orange},
      {'nombre': 'Chile', 'valor': 0.8, 'color': Colors.blue},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.bar_chart, color: Color(0xff1B5E20)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Productividad semanal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Revisa el rendimiento de cada cultivo y detecta áreas que requieren atención.',
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 18),
          ...cultivos.map((cultivo) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildProductividadRow(
                cultivo['nombre'] as String,
                cultivo['valor'] as double,
                cultivo['color'] as Color,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductividadRow(String cultivo, double valor, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(cultivo, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '${(valor * 100).round()}%',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: LinearProgressIndicator(
            value: valor,
            minHeight: 10,
            color: color,
            backgroundColor: const Color(0xffEDF4F0),
          ),
        ),
      ],
    );
  }

  Widget _buildResumenDelDia(BuildContext context) {
    final int pendientes = _areas
        .where((area) => area.estado.toLowerCase().contains('pendiente'))
        .length;
    final int completadas = _areas
        .where((area) => area.estado.toLowerCase().contains('completado'))
        .length;
    final int supervision = _areas
        .where((area) => !area.estado.toLowerCase().contains('completado'))
        .length;
    final int productividadGeneral = _areas.isEmpty
        ? 0
        : (_areas
                      .map((area) => area.progreso)
                      .reduce((value, element) => value + element) /
                  _areas.length *
                  100)
              .round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xffE8F5E9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.dashboard, color: Color(0xff1B5E20)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Resumen del día',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildResumenRow(
            Icons.pending_actions,
            '$pendientes actividades pendientes',
          ),
          const SizedBox(height: 12),
          _buildResumenRow(
            Icons.check_circle,
            '$completadas actividades completadas',
          ),
          const SizedBox(height: 12),
          _buildResumenRow(
            Icons.warning_amber_rounded,
            '$supervision áreas requieren supervisión',
          ),
          const SizedBox(height: 12),
          _buildResumenRow(
            Icons.bar_chart,
            'Productividad general: $productividadGeneral%',
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AreaHistorialScreen(areas: _areas),
                ),
              );
            },
            icon: const Icon(Icons.history),
            label: const Text('Reporte de actividades'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1B5E20),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 18, color: const Color(0xff1B5E20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
