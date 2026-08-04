import 'package:flutter/material.dart';

class Area {
  final int? id;
  final int? empleadoId;
  final int? areaId; // corresponde a "invernadero_id" en el backend
  final int? cultivoId;

  final String empleado;
  final String area;
  final String cultivo;
  final String actividad;
  final String estado;
  final double progreso;

  Area({
    required this.empleado,
    required this.area,
    required this.cultivo,
    required this.actividad,
    required this.estado,
    required this.progreso,
    this.id,
    this.empleadoId,
    this.areaId,
    this.cultivoId,
  });

  Color get statusColor {
    final lower = estado.toLowerCase();
    if (lower.contains('pendiente')) return const Color(0xffF57C00);
    if (lower.contains('progreso')) return const Color(0xff1565C0);
    if (lower.contains('completado')) return const Color(0xff2E7D32);
    return const Color(0xff546E7A);
  }

  IconData get icono {
    if (area.toLowerCase().contains('invernadero')) return Icons.eco;
    return Icons.agriculture;
  }

  // en area.dart
  double get progresoNormalizado => progreso.clamp(0.0, 1.0);
  int get progresoPorcentaje => progreso.round();

  /// Construye un Area a partir del JSON de la API.
  /// Soporta tanto relaciones cargadas (->with('empleado','invernadero','cultivo'))
  /// como solo los ids sueltos.
  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      empleadoId: json['empleado_id'] is int
          ? json['empleado_id']
          : int.tryParse('${json['empleado_id']}'),
      areaId: json['invernadero_id'] is int
          ? json['invernadero_id']
          : int.tryParse('${json['invernadero_id']}'),
      cultivoId: json['cultivo_id'] is int
          ? json['cultivo_id']
          : int.tryParse('${json['cultivo_id']}'),
      empleado: json['empleado'] != null && json['empleado'] is Map
          ? (json['empleado']['name'] ?? 'Sin asignar')
          : (json['empleado_nombre'] ?? 'Sin asignar'),
      area: json['invernadero'] != null && json['invernadero'] is Map
          ? (json['invernadero']['nombre'] ?? 'Sin área')
          : (json['invernadero_nombre'] ?? 'Sin área'),
      cultivo: json['cultivo'] != null && json['cultivo'] is Map
          ? (json['cultivo']['nombre'] ?? 'Sin cultivo')
          : (json['cultivo_nombre'] ?? 'Sin cultivo'),
      actividad: json['actividad'] ?? '',
      estado: json['estado'] ?? 'Pendiente',
      progreso: json['progreso'] is num
          ? (json['progreso'] as num).toDouble()
          : double.tryParse('${json['progreso']}') ?? 0.0,
    );
  }

  /// Convierte el modelo a JSON para enviarlo a la API (store/update).
  /// Coincide con las reglas de validación de AreaController@store/update.
  Map<String, dynamic> toJson() {
    return {
      'empleado_id': empleadoId,
      'invernadero_id': areaId,
      'cultivo_id': cultivoId,
      'actividad': actividad,
      'estado': estado,
      'progreso': progreso,
    };
  }

  Area copyWith({
    int? id,
    int? empleadoId,
    int? areaId,
    int? cultivoId,
    String? empleado,
    String? area,
    String? cultivo,
    String? actividad,
    String? estado,
    double? progreso,
  }) {
    return Area(
      id: id ?? this.id,
      empleadoId: empleadoId ?? this.empleadoId,
      areaId: areaId ?? this.areaId,
      cultivoId: cultivoId ?? this.cultivoId,
      empleado: empleado ?? this.empleado,
      area: area ?? this.area,
      cultivo: cultivo ?? this.cultivo,
      actividad: actividad ?? this.actividad,
      estado: estado ?? this.estado,
      progreso: progreso ?? this.progreso,
    );
  }
}
