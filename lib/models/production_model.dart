import 'package:flutter/material.dart';

class ProductionModel {
  final String ubicacion;
  final String cultivo;
  final double produccionKg;
  final double temperatura;
  final double humedad;
  final String estado; // Estable, Advertencia, Crítico
  final String encargado;
  final String tel;

  ProductionModel({
    required this.ubicacion,
    required this.cultivo,
    required this.produccionKg,
    required this.temperatura,
    required this.humedad,
    required this.estado,
    required this.encargado,
    required this.tel,
  });

  factory ProductionModel.fromMap(Map<String, dynamic> map) {
    return ProductionModel(
      ubicacion: map['ubicacion'] ?? '',
      cultivo: map['cultivo'] ?? 'Desconocido',
      produccionKg: map['produccionKg']?.toDouble() ?? 0.0,
      temperatura: map['temperatura']?.toDouble() ?? 0.0,
      humedad: map['humedad']?.toDouble() ?? 0.0,
      estado: map['estado'] ?? 'Estable',
      encargado: map['encargado'] ?? 'Sin asignar',
      tel: map['tel'] ?? '',
    );
  }

  // Colores lógicos de estado del cultivo
  Color get estadoColor {
    switch (estado) {
      case "Estable":
        return const Color(0xFF2E7D32); // primaryGreen
      case "Advertencia":
        return const Color(0xFFF57C00); // warning
      default:
        return const Color(0xFFD32F2F); // critical
    }
  }
}
