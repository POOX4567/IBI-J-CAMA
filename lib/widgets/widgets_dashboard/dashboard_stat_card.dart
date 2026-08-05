import 'package:flutter/material.dart';

class DashboardStatCard extends StatelessWidget {
  final String valor;
  final String titulo;
  final IconData icono;

  const DashboardStatCard({
    super.key,
    required this.valor,
    required this.titulo,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // ⚡ Se remueve el height fijo para que el contenedor se ajuste dinámicamente
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ⚡ Solo toma el espacio necesario
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: const Color(0xFF1B5E20), size: 22),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow
                .ellipsis, // ⚡ Evita saltos de línea si el título es largo
          ),
        ],
      ),
    );
  }
}
