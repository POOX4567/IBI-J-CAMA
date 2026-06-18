import 'package:flutter/material.dart';

class DashboardStatCard extends StatelessWidget {
  final String valor;
  final String titulo;
  final IconData icono;
  final Color color;

  const DashboardStatCard({
    super.key,
    required this.valor,
    required this.titulo,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 🚀 SE QUITÓ EL HEIGHT FIJO PARA EVITAR EL OVERFLOW VERTICAL
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al mínimo requerido
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            valor,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          // 🚀 Flexible previene overflow si el texto llega a ocupar dos líneas
          Flexible(
            child: Text(
              titulo,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
