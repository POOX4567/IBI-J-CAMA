import 'package:flutter/material.dart';

class ResumenItem extends StatelessWidget {
  final String texto;
  final IconData icono;

  const ResumenItem({super.key, required this.texto, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(child: Text(texto)),
      ],
    );
  }
}
