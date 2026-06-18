import 'package:flutter/material.dart';
import '../../screens/screen_reports/reports_page.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap; // <-- 1. Agregamos el callback para detectar clics

  const InfoRow({
    super.key,
    required this.title,
    required this.value,
    this.onTap, // <-- 2. Lo sumamos al constructor opcional
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent, // Mantiene el fondo blanco del Container
        child: InkWell(
          onTap: onTap, // <-- 3. Asignamos la acción al tocar la fila
          borderRadius: BorderRadius.circular(
            18,
          ), // Evita que el efecto visual se salga de las esquinas
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16)),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportButton extends StatelessWidget {
  const ReportButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Cambié GestureDetector por InkWell para que al pulsar el botón principal
    // también muestre el feedback visual de pulsación nativo de Android/iOS.
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xff1B5E20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsPage()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Ver Reportes Detallados",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
