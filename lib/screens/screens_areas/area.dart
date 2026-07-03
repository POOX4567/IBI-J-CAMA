import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // HIVE: almacenamiento local offline

part 'area.g.dart'; // generado por hive_generator

@HiveType(typeId: 0) // HIVE: anotación del tipo
class Area extends HiveObject {
  @HiveField(0)
  final String empleado;

  @HiveField(1)
  final String area;

  @HiveField(2)
  final String cultivo;

  @HiveField(3)
  final String actividad;

  @HiveField(4)
  final String estado;

  @HiveField(5)
  final double progreso;

  Area({
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
    if (area.toLowerCase().contains('invernadero')) return Icons.eco;
    return Icons.agriculture;
  }
}
