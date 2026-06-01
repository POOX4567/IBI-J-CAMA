import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const InfoCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icono, color: color),
          const SizedBox(height: 10),
          Text(
            valor,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text(titulo),
        ],
      ),
    );
  }
}
