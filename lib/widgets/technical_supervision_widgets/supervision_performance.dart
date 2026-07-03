import 'package:flutter/material.dart';

class SupervisionPerformance extends StatelessWidget {
  const SupervisionPerformance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _perfCard("Uptime", "94.3%", "30 días", Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: _perfCard("MTTR", "4.2h", "Promedio", Colors.purple)),
        const SizedBox(width: 8),
        Expanded(child: _perfCard("Reparaciones", "12", "Total", Colors.cyan)),
      ],
    );
  }

  // Método auxiliar privado encapsulado en el mismo archivo
  Widget _perfCard(
    String title,
    String value,
    String subtitle,
    MaterialColor color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8), // Padding ajustado
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(color: color[700], fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color[900],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(color: color[600], fontSize: 9),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
