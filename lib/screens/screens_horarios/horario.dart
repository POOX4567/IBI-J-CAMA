import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Horario {
  final int? id;
  final int empleadoId;
  final String nombre;
  final String turno;

  // 👇 CAMBIO: 'actividad' (texto libre) fue reemplazado por la relación
  // con la tabla 'activities'. Guardamos el id (obligatorio para
  // crear/editar) y el nombre resuelto (solo para mostrar en pantalla).
  final int activityId;
  final String actividadNombre;

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
      // El backend regresa fechas tipo 'yyyy-MM-dd'
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
    //  el nombre del empleado puede venir anidado en 'empleado' con la
    // llave 'name' o 'nombre' según el endpoint; probamos ambas antes de
    // rendirnos.
    String nombreResuelto = 'Sin nombre';
    final empleado = json['empleado'];
    if (empleado is Map<String, dynamic>) {
      nombreResuelto = empleado['name'] ?? empleado['nombre'] ?? 'Sin nombre';
    } else if (json['empleado_nombre'] != null) {
      nombreResuelto = json['empleado_nombre'];
    } else if (json['nombre'] != null) {
      nombreResuelto = json['nombre'];
    }

    // 👇 NUEVO: la actividad ahora viene como relación. El backend puede
    // mandarla anidada como 'activity' (objeto con id/name), o como
    // 'activity_id' + 'actividad_nombre' sueltos. Probamos todas las
    // variantes razonables.
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
      empleadoId: json['empleado_id'] is int
          ? json['empleado_id']
          : int.tryParse('${json['empleado_id']}') ?? 0,
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

  /// Convierte a JSON para enviar al backend (create/update)
  Map<String, dynamic> toJson() {
    return {
      'empleado_id': empleadoId,
      'turno': turno,
      'activity_id': activityId, // 👈 antes era 'actividad': actividad
      'fecha_inicio': fechaInicio,
      'fecha_fin': fechaFin,
      'hora_entrada': entrada,
      'hora_salida': salida,
    };
  }

  /// IMPORTANTE: todos los parámetros son OPCIONALES y usan `this.campo`
  /// como valor por defecto. Así puedes llamar copyWith pasando solo el
  /// campo que quieras cambiar (ej. copyWith(entrada: '08:00')) sin tener
  /// que repetir el resto de los valores.
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
