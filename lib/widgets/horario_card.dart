import 'package:flutter/material.dart';
import '../screens/screens_horarios/horario.dart';

class HorarioCard extends StatelessWidget {
  final Horario horario;
  final VoidCallback onTap;

  const HorarioCard({super.key, required this.horario, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: horario.colorTurno.withOpacity(.15),
                  child: Icon(
                    Icons.person,
                    color: horario.colorTurno,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        horario.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // 👇 CORREGIDO: 'actividad' (String libre) ya no
                      // existe en el modelo; ahora es 'actividadNombre',
                      // resuelto por el provider a partir de 'activityId'.
                      Text(
                        horario.actividadNombre.isNotEmpty
                            ? horario.actividadNombre
                            : 'Sin actividad',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _tagLabel(horario.turno, horario.colorTurno),
                          const SizedBox(width: 8),
                          _tagLabel('Activo', Colors.green.shade700),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _infoChip(
                            Icons.calendar_today,
                            'Desde ${horario.fechaInicio}',
                          ),
                          _infoChip(
                            Icons.calendar_today,
                            'Hasta ${horario.fechaFin}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _horarioItem(
                    'Entrada',
                    horario.entrada,
                    Icons.login,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _horarioItem(
                    'Salida',
                    horario.salida,
                    Icons.logout,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _horarioItem(String titulo, String hora, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(titulo, style: TextStyle(color: Colors.grey.shade800)),
          const SizedBox(height: 8),
          Text(
            hora,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
