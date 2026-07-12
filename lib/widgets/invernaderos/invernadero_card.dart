import 'package:flutter/material.dart';
import '../../models/invernadero.dart';

class InvernaderoCard extends StatelessWidget {
  final Invernadero invernadero;
  final VoidCallback onTap;

  const InvernaderoCard({
    super.key,
    required this.invernadero,
    required this.onTap,
  });

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color brown = Color(0xFF5D4037);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          left: BorderSide(color: primaryGreen, width: 5),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.09),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    invernadero.nombre,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),
                ),
                const _StatusBadge(label: 'Activo', color: primaryGreen),
              ],
            ),
            const SizedBox(height: 14),
            _InfoLine(
              icon: Icons.location_on_outlined,
              label: 'Ubicación',
              value: '${invernadero.latitud}, ${invernadero.longitud}',
            ),
            _InfoLine(
              icon: Icons.straighten,
              label: 'Medidas',
              value:
                  '${invernadero.ancho}m x ${invernadero.largo}m x ${invernadero.alto}m',
            ),
            _InfoLine(
              icon: Icons.description_outlined,
              label: 'Descripción',
              value: invernadero.descripcion,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Ver detalles'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: InvernaderoCard.brown),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: InvernaderoCard.brown,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: InvernaderoCard.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}