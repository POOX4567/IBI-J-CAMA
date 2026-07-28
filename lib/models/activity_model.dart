import 'package:flutter/material.dart';

class ActivityModel {
  final String actividad;
  final String progreso;
  final String zona;
  final String encargado;
  final String detalle;

  ActivityModel({
    required this.actividad,
    required this.progreso,
    required this.zona,
    required this.encargado,
    required this.detalle,
  });

  // 🔄 Transforma un mapa (JSON del backend) a un Objeto de Flutter
  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      actividad: map['actividad'] ?? '',
      progreso: map['progreso'] ?? 'Pendiente',
      zona: map['zona'] ?? 'Sin Zona',
      encargado: map['encargado'] ?? 'Sin Asignar',
      detalle: map['detalle'] ?? '',
    );
  }

  // 🎨 Helper dinámico para obtener el color del estado desde el modelo
  Color get statusColor {
    switch (progreso) {
      case "Completado":
        return Colors.green;
      case "En proceso":
        return const Color(0xFFF57C00); // Color warning corporativo
      default:
        return const Color(0xFFD32F2F); // Color critical corporativo
    }
  }
}
