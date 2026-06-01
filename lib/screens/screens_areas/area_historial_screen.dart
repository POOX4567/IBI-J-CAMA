import 'package:flutter/material.dart';
import 'area.dart';

class AreaHistorialScreen extends StatelessWidget {
  final List<Area> areas;

  const AreaHistorialScreen({super.key, required this.areas});

  @override
  Widget build(BuildContext context) {
    final pendientes = areas
        .where((area) => area.estado.toLowerCase().contains('pendiente'))
        .toList();
    final realizadas = areas
        .where((area) => area.estado.toLowerCase().contains('completado'))
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
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
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
                    'Aquí puedes revisar las actividades completadas y las que todavía están pendientes en tus áreas.',
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (realizadas.isNotEmpty) ...[
              const Text(
                'Actividades realizadas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              ...realizadas.map((area) => _buildHistorialCard(area)),
              const SizedBox(height: 24),
            ],
            const Text(
              'Actividades pendientes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            ...pendientes.map((area) => _buildHistorialCard(area)),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
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

  Widget _buildHistorialCard(Area area) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
                  color: area.statusColor.withOpacity(0.18),
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
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: LinearProgressIndicator(
              value: area.progreso,
              minHeight: 10,
              color: area.statusColor,
              backgroundColor: const Color(0xffEDF4F0),
            ),
          ),
        ],
      ),
    );
  }
}
