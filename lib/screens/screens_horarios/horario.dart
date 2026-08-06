import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Horario {
  final int? id;
  final int empleadoId;
  final String
  nombre; // solo para UI, NO se manda al backend (la tabla no tiene esta columna)
  final String turno;

  // Relación con la tabla 'activities'
  final int activityId;
  final String actividadNombre; // solo para UI, NO se manda al backend

  final String entrada;
  final String salida;
  final String fechaInicio;
  final String fechaFin;

  const Horario({
    this.id,
    required this.empleadoId,
    required this.nombre,
    required this.turno,
    required this.activityId,
    this.actividadNombre = '',
    required this.entrada,
    required this.salida,
    required this.fechaInicio,
    required this.fechaFin,
  });

  Color get colorTurno {
    final lower = turno.toLowerCase();
    if (lower.contains('matutino')) return const Color(0xff1E88E5);
    if (lower.contains('vespertino')) return const Color(0xffFB8C00);
    if (lower.contains('nocturno')) return const Color(0xff6A1B9A);
    return const Color(0xff43A047);
  }

  String get fechaInicioFormateada => _formatear(fechaInicio);
  String get fechaFinFormateada => _formatear(fechaFin);

  String _formatear(String fechaIso) {
    try {
      final fecha = DateTime.parse(fechaIso);
      return DateFormat("d 'de' MMMM yyyy", 'es').format(fecha);
    } catch (_) {
      return fechaIso;
    }
  }

  static int _idComoInt(dynamic id) {
    if (id == null) return 0;
    if (id is int) return id;
    return int.tryParse('$id') ?? 0;
  }

  /// Convierte la respuesta JSON del backend Laravel a un Horario
  factory Horario.fromJson(Map<String, dynamic> json) {
    String nombreResuelto = 'Sin nombre';
    final empleado = json['empleado'];
    if (empleado is Map<String, dynamic>) {
      nombreResuelto = empleado['name'] ?? empleado['nombre'] ?? 'Sin nombre';
    } else if (json['empleado_nombre'] != null) {
      nombreResuelto = json['empleado_nombre'];
    } else if (json['nombre'] != null) {
      nombreResuelto = json['nombre'];
    }

    int activityId = 0;
    String actividadNombre = '';
    final activity = json['activity'];
    if (activity is Map<String, dynamic>) {
      activityId = _idComoInt(activity['id']);
      actividadNombre = activity['name'] ?? activity['nombre'] ?? '';
    } else {
      activityId = _idComoInt(json['activity_id']);
      actividadNombre = json['actividad_nombre'] ?? json['activity_name'] ?? '';
    }

    return Horario(
      id: json['id'],
      empleadoId: _idComoInt(json['empleado_id']),
      nombre: nombreResuelto,
      turno: json['turno'] ?? '',
      activityId: activityId,
      actividadNombre: actividadNombre,
      entrada: (json['hora_entrada'] ?? '').toString().length >= 5
          ? (json['hora_entrada'] ?? '').toString().substring(0, 5)
          : '',
      salida: (json['hora_salida'] ?? '').toString().length >= 5
          ? (json['hora_salida'] ?? '').toString().substring(0, 5)
          : '',
      fechaInicio: json['fecha_inicio'] ?? '',
      fechaFin: json['fecha_fin'] ?? '',
    );
  }

  /// Convierte a JSON para enviar al backend (create/update).
  /// IMPORTANTE: solo incluye las columnas que existen en la tabla
  /// `horarios` (empleado_id, turno, activity_id, fecha_inicio, fecha_fin,
  /// hora_entrada, hora_salida). 'nombre' y 'actividadNombre' son solo
  /// para mostrar en pantalla y nunca se mandan.
  Map<String, dynamic> toJson() {
    // Validación defensiva: si algo viene en 0 o vacío, es señal de un
    // bug en el formulario (dropdown no seleccionado, fecha nula, etc.)
    // Mejor fallar aquí con un mensaje claro que mandar un 0/'' al
    // backend y recibir un 500 genérico sin saber por qué.
    assert(empleadoId != 0, 'empleadoId no puede ser 0 al guardar');
    assert(activityId != 0, 'activityId no puede ser 0 al guardar');
    assert(turno.isNotEmpty, 'turno no puede estar vacío al guardar');
    assert(fechaInicio.isNotEmpty, 'fechaInicio no puede estar vacía');
    assert(fechaFin.isNotEmpty, 'fechaFin no puede estar vacía');
    assert(entrada.isNotEmpty, 'hora_entrada no puede estar vacía');
    assert(salida.isNotEmpty, 'hora_salida no puede estar vacía');

    return {
      'empleado_id': empleadoId,
      'turno': turno,
      'activity_id': activityId,
      'fecha_inicio': fechaInicio,
      'fecha_fin': fechaFin,
      'hora_entrada': entrada,
      'hora_salida': salida,
    };
  }

  Horario copyWith({
    int? id,
    int? empleadoId,
    String? nombre,
    String? turno,
    int? activityId,
    String? actividadNombre,
    String? entrada,
    String? salida,
    String? fechaInicio,
    String? fechaFin,
  }) {
    return Horario(
      id: id ?? this.id,
      empleadoId: empleadoId ?? this.empleadoId,
      nombre: nombre ?? this.nombre,
      turno: turno ?? this.turno,
      activityId: activityId ?? this.activityId,
      actividadNombre: actividadNombre ?? this.actividadNombre,
      entrada: entrada ?? this.entrada,
      salida: salida ?? this.salida,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
    );
  }
}
