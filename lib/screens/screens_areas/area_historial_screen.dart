import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart'; // PERCENT_INDICATOR
import 'package:fluttertoast/fluttertoast.dart'; // FLUTTERTOAST
import 'area.dart'; // Importa correctamente el archivo de arriba sin duplicarlo

class AreaHistorialScreen extends StatefulWidget {
  final List<Area> areas;

  const AreaHistorialScreen({super.key, required this.areas});

  @override
  State<AreaHistorialScreen> createState() => _AreaHistorialScreenState();
}

class _AreaHistorialScreenState extends State<AreaHistorialScreen> {
  //  Filtro por ESTADO (antes era por nombre de área).
  // 'Todos' muestra las tres categorías; cualquier otro valor filtra
  // exclusivamente por ese estado.
  static const List<String> _estados = [
    'Todos',
    'Pendiente',
    'En progreso',
    'Completado',
  ];

  String _estadoSeleccionado = 'Todos';

  List<Area> get _areasFiltradas {
    if (_estadoSeleccionado == 'Todos') return widget.areas;
    return widget.areas
        .where(
          (a) => a.estado.toLowerCase() == _estadoSeleccionado.toLowerCase(),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pendientes = _areasFiltradas
        .where((a) => a.estado.toLowerCase().contains('pendiente'))
        .toList();
    final enProgreso = _areasFiltradas
        .where(
          (a) =>
              a.estado.toLowerCase().contains('progreso') &&
              !a.estado.toLowerCase().contains('pendiente'),
        )
        .toList();
    final realizadas = _areasFiltradas
        .where((a) => a.estado.toLowerCase().contains('completado'))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xff1B5E20),
        title: const Text('Historial de Actividades'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Filtro por ESTADO (ChoiceChip) ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrar por estado',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _estados.map((estado) {
                      final seleccionado = _estadoSeleccionado == estado;
                      return ChoiceChip(
                        label: Text(estado),
                        selected: seleccionado,
                        onSelected: (_) {
                          setState(() => _estadoSeleccionado = estado);
                          if (estado != 'Todos') {
                            Fluttertoast.showToast(
                              msg: 'Filtrando por: $estado',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: const Color(0xff1B5E20),
                              textColor: Colors.white,
                            );
                          }
                        },
                        selectedColor: const Color(0xff1B5E20),
                        labelStyle: TextStyle(
                          color: seleccionado
                              ? Colors.white
                              : const Color(0xff334155),
                          fontWeight: FontWeight.w600,
                        ),
                        avatar: estado == 'Todos'
                            ? null
                            : Icon(
                                estado == 'Pendiente'
                                    ? Icons.pending_actions
                                    : estado == 'En progreso'
                                    ? Icons.autorenew_rounded
                                    : Icons.check_circle_outline_rounded,
                                size: 18,
                                color: seleccionado
                                    ? Colors.white
                                    : const Color(0xff1B5E20),
                              ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Resumen ───────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reporte de actividad',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _statusPill(
                        'Realizadas',
                        realizadas.length,
                        Colors.green,
                      ),
                      _statusPill(
                        'En progreso',
                        enProgreso.length,
                        Colors.blue,
                      ),
                      _statusPill(
                        'Pendientes',
                        pendientes.length,
                        Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aquí puedes revisar las actividades completadas, en '
                    'progreso y las que todavía están pendientes en tus áreas.',
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Realizadas ────────────────────────────────────────────────────
            if (realizadas.isNotEmpty) ...[
              const Text(
                'Actividades realizadas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              ...realizadas.asMap().entries.map(
                (e) => _buildHistorialCard(e.value, e.key),
              ),
              const SizedBox(height: 24),
            ],

            // ── En progreso ───────────────────────────────────────────────────
            if (enProgreso.isNotEmpty) ...[
              const Text(
                'Actividades en progreso',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              ...enProgreso.asMap().entries.map(
                (e) => _buildHistorialCard(e.value, e.key),
              ),
              const SizedBox(height: 24),
            ],

            // ── Pendientes ────────────────────────────────────────────────────
            if (pendientes.isNotEmpty) ...[
              const Text(
                'Actividades pendientes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              ...pendientes.asMap().entries.map(
                (e) => _buildHistorialCard(e.value, e.key),
              ),
            ] else if (realizadas.isEmpty && enProgreso.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('No hay actividades registradas.'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha((0.12 * 255).round()),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $count',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialCard(Area area, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 80),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.04 * 255).round()),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    area.area,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: area.statusColor.withAlpha((0.18 * 255).round()),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    area.estado,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: area.statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Actividad: ${area.actividad}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Supervisor: ${area.empleado}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            LinearPercentIndicator(
              lineHeight: 10.0,
              percent:
                  area.progresoNormalizado, // ✅ normalizado, usando el getter
              animation: true,
              animationDuration: 800,
              progressColor: area.statusColor,
              backgroundColor: const Color(0xffEDF4F0),
              barRadius: const Radius.circular(14),
            ),
          ],
        ),
      ),
    );
  }
}
