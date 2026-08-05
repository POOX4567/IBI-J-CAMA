import 'package:flutter/material.dart';

import '../models/alerta_model.dart';

class GreenhouseAlertCard extends StatelessWidget {
  final Alerta alerta;

  const GreenhouseAlertCard({
    super.key,
    required this.alerta,
  });

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color brown = Color(0xFF5D4037);

  Color get severityColor {
    switch (alerta.severidad.toLowerCase()) {
      case 'alta':
        return Colors.red;

      case 'media':
        return Colors.orange;

      case 'baja':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: severityColor.withOpacity(.15),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: severityColor,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    alerta.titulo,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Wrap(
              spacing: 10,
              children: [
                Chip(
                  backgroundColor: severityColor.withOpacity(.12),
                  label: Text(
                    alerta.severidad,
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  backgroundColor: primaryGreen.withOpacity(.10),
                  label: Text(
                    alerta.estado,
                    style: const TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                const Icon(
                  Icons.agriculture,
                  color: primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alerta.invernadero,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}