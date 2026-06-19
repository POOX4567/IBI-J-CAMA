import 'package:flutter/material.dart';

class IncidentModel {
  final String title;
  final String severity; // Alta, Media, Baja
  final String status; // Abierto, En proceso, Resuelto
  final String area;

  IncidentModel({
    required this.title,
    required this.severity,
    required this.status,
    required this.area,
  });

  // Factoría para transformar las respuestas de MongoDB / JSON a objetos tipados
  factory IncidentModel.fromMap(Map<String, dynamic> map) {
    return IncidentModel(
      title: map['title'] ?? '',
      severity: map['severity'] ?? 'Baja',
      status: map['status'] ?? 'Abierto',
      area: map['area'] ?? 'Área general',
    );
  }

  // Regla de colores asignada por Severidad
  Color get severityColor {
    switch (severity) {
      case "Alta":
        return Colors.red.shade900;
      case "Media":
        return Colors.orange.shade800;
      default:
        return Colors.green.shade700;
    }
  }

  // Regla de colores asignada por Estado de resolución
  Color get statusColor {
    switch (status) {
      case "Abierto":
        return Colors.red;
      case "En proceso":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
