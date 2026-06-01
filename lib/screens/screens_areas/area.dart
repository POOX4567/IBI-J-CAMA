import 'package:flutter/material.dart';

class Area {
  final String empleado;
  final String area;
  final String cultivo;
  final String actividad;
  final String estado;
  final double progreso;

  const Area({
    required this.empleado,
    required this.area,
    required this.cultivo,
    required this.actividad,
    required this.estado,
    required this.progreso,
  });

  Color get statusColor {
    final lower = estado.toLowerCase();
    if (lower.contains('pendiente')) return const Color(0xffF57C00);
    if (lower.contains('completado')) return const Color(0xff2E7D32);
    return const Color(0xff546E7A);
  }

  IconData get icono {
    if (area.toLowerCase().contains('invernadero')) {
      return Icons.eco;
    }
    return Icons.agriculture;
  }
}
