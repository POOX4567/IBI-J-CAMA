import 'package:flutter/material.dart';

class FiltroChipWidget extends StatelessWidget {
  final String texto;
  final bool seleccionado;
  final VoidCallback onTap;
  final IconData? icon; // Agregamos soporte para iconos opcionales

  const FiltroChipWidget({
    super.key,
    required this.texto,
    required this.seleccionado,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos AnimatedContainer para que el cambio de color sea fluido
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? Colors.green.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(
            20,
          ), // Bordes más redondeados (Moderno)
          border: Border.all(
            color: seleccionado
                ? Colors.transparent
                : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            if (seleccionado)
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: seleccionado ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              texto,
              style: TextStyle(
                color: seleccionado ? Colors.white : Colors.black87,
                fontWeight: seleccionado ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
