import 'package:flutter/material.dart';

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
