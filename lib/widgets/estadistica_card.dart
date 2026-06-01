import 'package:flutter/material.dart';

class EstadisticaCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const EstadisticaCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color),
          const SizedBox(height: 15),
          Text(
            valor,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Text(titulo),
        ],
      ),
    );
  }
}
