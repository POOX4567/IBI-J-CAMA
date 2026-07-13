import 'package:flutter/material.dart';

class ProductividadCard extends StatelessWidget {
  final String cultivo;
  final double valor;
  final Color color;

  const ProductividadCard({
    super.key,
    required this.cultivo,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cultivo),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: (valor / 100).clamp(0.0, 1.0),
            color: color,
          ),
        ],
      ),
    );
  }
}
