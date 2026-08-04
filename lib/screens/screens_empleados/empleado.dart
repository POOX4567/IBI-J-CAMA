import 'package:flutter/material.dart';

class Empleado {
  final int id;
  final String nombre;
  final String correo;
  final String telefono;
  final String? fotografia;
  final String cargo;
  final String turno;
  final List<Map<String, dynamic>> invernaderos;
  final String estadoLaboral;

  // Campos de asistencia (se llenan después)
  String? asistencia;
  String? horaEntrada;
  String? horaSalida;
  String? fechaAsistencia;

  Empleado({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    this.fotografia,
    required this.cargo,
    required this.turno,
    required this.invernaderos,
    required this.estadoLaboral,
    this.asistencia,
    this.horaEntrada,
    this.horaSalida,
    this.fechaAsistencia,
  });

  // Mapear desde JSON de empleados
  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? 'Sin nombre',
      correo: json['correo'] ?? '',
      telefono: json['telephone'] ?? '',
      fotografia: json['imagen'], // La API devuelve "imagen"
      cargo: json['rol'] ?? 'Sin rol', // La API devuelve "rol"
      turno: json['turno'] ?? 'No especificado',
      invernaderos: List<Map<String, dynamic>>.from(json['invernaderos'] ?? []),
      estadoLaboral: json['estado_laboral'] ?? 'Activo',
    );
  }

  /// Devuelve todos los nombres de los invernaderos separados por coma
  String get invernadero {
    if (invernaderos.isEmpty) {
      return 'Sin invernadero';
    }

    return invernaderos.map((e) => e['nombre'].toString()).join(', ');
  }

  // Propiedades derivadas para la UI
  String get fotoUrl {
    if (fotografia != null && fotografia!.isNotEmpty) {
      return fotografia!;
    }

    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(nombre)}&background=2E7D32&color=fff&size=128';
  }

  Color get colorEstado {
    switch (estadoLaboral.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'descanso':
        return Colors.orange;
      case 'inactivo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get estado {
    switch (estadoLaboral.toLowerCase()) {
      case 'activo':
        return 'Activo';
      case 'descanso':
        return 'Descanso';
      case 'inactivo':
        return 'Inactivo';
      default:
        return estadoLaboral;
    }
  }

  String get rol => cargo.isNotEmpty ? cargo : 'Sin rol';

  String get zona => invernadero;
}
