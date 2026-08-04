import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // INTL: fechas en español
import 'package:provider/provider.dart'; // PROVIDER
import 'package:flutter_slidable/flutter_slidable.dart'; // FLUTTER_SLIDABLE
import 'package:fl_chart/fl_chart.dart'; // FL_CHART
import 'horario.dart';
import 'horario_provider.dart';
import 'horario_form_screen.dart';

class HorarioDetailScreen extends StatefulWidget {
  final Horario horario;

  const HorarioDetailScreen({super.key, required this.horario});

  @override
  State<HorarioDetailScreen> createState() => _HorarioDetailScreenState();
}

class _HorarioDetailScreenState extends State<HorarioDetailScreen> {
  late Horario _horario;

  @override
  void initState() {
    super.initState();
    _horario = widget.horario;

    Future.microtask(() {
      context.read<HorarioProvider>().cargarHorarios();
    });
  }

  // INTL: formatea una fecha en español
  String _formatearFecha(String fecha) {
    try {
      final d = DateFormat('dd/MM/yyyy').parse(fecha);
      return DateFormat("d 'de' MMMM yyyy", 'es').format(d);
    } catch (_) {
      return fecha;
    }
  }

  // ── Único punto de edición: abre el formulario COMPLETO ─────────────────
  // Se usa tanto desde el botón de editar del AppBar como desde los
  // deslizables de Entrada/Salida, para que TODO se edite siempre desde
  // el mismo modal (empleado, turno, actividad, fechas y horas).
  Future<void> _editarHorarioCompleto(
    BuildContext context,
    Horario horarioActual,
  ) async {
    final actualizado = await HorarioFormScreen.show(
      context,
      horario: horarioActual,
      provider: context.read<HorarioProvider>(),
    );
    if (actualizado == true && mounted) {
      setState(() {}); // fuerza refresco del detalle con los datos nuevos
    }
  }

  @override
  Widget build(BuildContext context) {
    // PROVIDER: escucha cambios globales en horarios
    final provider = context.watch<HorarioProvider>();
    final horarioActual = (_horario.id != null)
        ? (provider.obtenerHorario(_horario.id!) ?? _horario)
        : _horario;

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff1B5E20),
        title: const Text('Detalle de Horario'),
        centerTitle: false,
        actions: [
          // ── Botón para editar TODOS los campos del horario ──────────────
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar horario',
            onPressed: () => _editarHorarioCompleto(context, horarioActual),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff1B5E20), Color(0xff43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              horarioActual.nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              horarioActual.turno,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // INTL: muestra fechas en español
                        _headerInfo(
                          'Inicio',
                          _formatearFecha(horarioActual.fechaInicio),
                        ),
                        _headerInfo(
                          'Fin',
                          _formatearFecha(horarioActual.fechaFin),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Info del turno con FLUTTER_SLIDABLE ──────────────────────────
            const Text(
              'Información del turno',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // FLUTTER_SLIDABLE: desliza para editar TODO el horario (ya no
            // solo la hora de entrada — abre el formulario completo)
            Slidable(
              key: const ValueKey('entrada'),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) =>
                        _editarHorarioCompleto(context, horarioActual),
                    backgroundColor: const Color(0xff1B5E20),
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Editar',
                    borderRadius: BorderRadius.circular(18),
                  ),
                ],
              ),
              child: _detailCard(
                icon: Icons.login,
                label: 'Entrada',
                value: horarioActual.entrada,
                color: Colors.green,
                hint: 'Desliza para editar',
              ),
            ),
            const SizedBox(height: 10),

            // FLUTTER_SLIDABLE: desliza para editar TODO el horario (ya no
            // solo la hora de salida — abre el formulario completo)
            Slidable(
              key: const ValueKey('salida'),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) =>
                        _editarHorarioCompleto(context, horarioActual),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Editar',
                    borderRadius: BorderRadius.circular(18),
                  ),
                ],
              ),
              child: _detailCard(
                icon: Icons.logout,
                label: 'Salida',
                value: horarioActual.salida,
                color: Colors.red,
                hint: 'Desliza para editar',
              ),
            ),
            const SizedBox(height: 10),

            _detailCard(
              icon: Icons.construction,
              label: 'Actividad',
              value: horarioActual.actividad,
              color: const Color(0xff43A047),
            ),
            const SizedBox(height: 10),
            _detailCard(
              icon: Icons.event_available,
              label: 'Turno',
              value: horarioActual.turno,
              color: const Color(0xff1B5E20),
            ),
            const SizedBox(height: 10),
            _detailCard(
              icon: Icons.date_range,
              label: 'Período',
              value:
                  '${_formatearFecha(horarioActual.fechaInicio)} — ${_formatearFecha(horarioActual.fechaFin)}',
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 24),

            // ── FL_CHART: gráfica de horas trabajadas por turno ──────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Horas trabajadas por turno',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Distribución semanal estimada',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 10,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}h',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const dias = [
                                  'Lun',
                                  'Mar',
                                  'Mié',
                                  'Jue',
                                  'Vie',
                                ];
                                final i = value.toInt();
                                if (i < 0 || i >= dias.length) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  dias[i],
                                  style: const TextStyle(fontSize: 11),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          _barGroup(0, 8, horarioActual.colorTurno),
                          _barGroup(1, 9, horarioActual.colorTurno),
                          _barGroup(2, 7.5, horarioActual.colorTurno),
                          _barGroup(3, 8.5, horarioActual.colorTurno),
                          _barGroup(4, 6, horarioActual.colorTurno),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Notas ─────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Revisa los horarios con antelación para evitar solapamientos. '
                    'Este turno es el más importante para coordinar con el equipo.',
                    style: TextStyle(color: Colors.black87, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 18,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _detailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? hint,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (hint != null)
                  Text(
                    hint,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerInfo(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
