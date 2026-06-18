import 'package:flutter/material.dart'; // ANIMATIONS
import 'package:percent_indicator/percent_indicator.dart'; // PERCENT_INDICATOR
import 'package:fluttertoast/fluttertoast.dart'; // FLUTTERTOAST
import 'package:dropdown_search/dropdown_search.dart'; // DROPDOWN_SEARCH
import 'area.dart';

class AreaHistorialScreen extends StatefulWidget {
  final List<Area> areas;

  const AreaHistorialScreen({super.key, required this.areas});

  @override
  State<AreaHistorialScreen> createState() => _AreaHistorialScreenState();
}

class _AreaHistorialScreenState extends State<AreaHistorialScreen> {
  String? _areaSeleccionada;
  List<Area> get _areasFiltradas {
    if (_areaSeleccionada == null || _areaSeleccionada!.isEmpty) {
      return widget.areas;
    }
    return widget.areas.where((a) => a.area == _areaSeleccionada).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pendientes = _areasFiltradas
        .where((a) => a.estado.toLowerCase().contains('pendiente'))
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
            // ── DROPDOWN_SEARCH: búsqueda/filtro de área ────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrar por área',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  // DROPDOWN_SEARCH: selector con búsqueda en tiempo real
                  DropdownSearch<String>(
                    items: (filter, _) {
                      final nombres = widget.areas.map((a) => a.area).toList();
                      if (filter.isEmpty) return nombres;
                      return nombres
                          .where(
                            (n) =>
                                n.toLowerCase().contains(filter.toLowerCase()),
                          )
                          .toList();
                    },
                    selectedItem: _areaSeleccionada,
                    onSelected: (value) {
                      setState(() => _areaSeleccionada = value);
                      // FLUTTERTOAST: confirmación de filtro aplicado
                      if (value != null) {
                        Fluttertoast.showToast(
                          msg: 'Filtrando por: $value',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: const Color(0xff1B5E20),
                          textColor: Colors.white,
                        );
                      }
                    },
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: 'Selecciona un área',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xff1B5E20),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff1B5E20)),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                    ),
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Buscar área...',
                          prefixIcon: Icon(Icons.filter_list),
                        ),
                      ),
                    ),
                  ),
                  if (_areaSeleccionada != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            setState(() => _areaSeleccionada = null),
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Limpiar filtro'),
                      ),
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
                    color: Colors.black.withAlpha((0.08 * 255).round()),
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
                  Row(
                    children: [
                      _statusPill(
                        'Realizadas',
                        realizadas.length,
                        Colors.green,
                      ),
                      const SizedBox(width: 10),
                      _statusPill(
                        'Pendientes',
                        pendientes.length,
                        Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aquí puedes revisar las actividades completadas y las '
                    'que todavía están pendientes en tus áreas.',
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
              // ANIMATIONS: cada tarjeta entra con FadeTransition
              ...realizadas.asMap().entries.map(
                (e) => _buildHistorialCard(e.value, e.key),
              ),
              const SizedBox(height: 24),
            ],

            // ── Pendientes ────────────────────────────────────────────────────
            const Text(
              'Actividades pendientes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            ...pendientes.asMap().entries.map(
              (e) => _buildHistorialCard(e.value, e.key),
            ),
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
    // ANIMATIONS: FadeTransition escalonada por índice
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
            // PERCENT_INDICATOR: barra lineal animada
            LinearPercentIndicator(
              lineHeight: 10.0,
              percent: area.progreso,
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
