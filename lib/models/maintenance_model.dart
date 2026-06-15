import 'package:flutter/material.dart';

class MaintenanceModel {
  final String title;
  final String severity; // Alta, Media, Baja
  final String status; // Abierto, En proceso, Resuelto
  final String area;

  MaintenanceModel({
    required this.title,
    required this.severity,
    required this.status,
    required this.area,
  });

  // Mapeo desde las estructuras de MongoDB o APIs JSON
  factory MaintenanceModel.fromMap(Map<String, dynamic> map) {
    return MaintenanceModel(
      title: map['title'] ?? '',
      severity: map['severity'] ?? 'Baja',
      status: map['status'] ?? 'Abierto',
      area: map['area'] ?? 'Área general',
    );
  }

  // Colores lógicos por Severidad
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

  // Colores lógicos por Estado
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
