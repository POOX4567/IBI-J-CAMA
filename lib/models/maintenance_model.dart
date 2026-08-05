import 'package:flutter/material.dart';

class MaintenanceModel {
  final int id;
  final String titulo;
  final String descripcion;
  final String tipo;
  final String estado;
  final String invernadero;
  final String? imagen;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MaintenanceModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.estado,
    required this.invernadero,
    this.imagen,
    this.createdAt,
    this.updatedAt,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      id: int.parse(json['id'].toString()),
      titulo: json['titulo'].toString(),
      descripcion: json['descripcion'].toString(),
      tipo: json['tipo'].toString(),
      estado: json['estado'].toString(),
      invernadero: json['invernadero'].toString(),
      imagen: json['imagen']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  Color get tipoColor {
    switch (tipo) {
      case 'Preventivo':
        return Colors.blue.shade700;
      case 'Correctivo':
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  Color get estadoColor {
    switch (estado) {
      case 'Pendiente':
        return Colors.orange;
      case 'En proceso':
        return Colors.blue;
      case 'Resuelto':
        return Colors.green;
      case 'Abierto':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
