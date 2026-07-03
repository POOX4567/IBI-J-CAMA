import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // INTL: formateo de fechas en español

class Horario {
  final String nombre;
  final String turno;
  final String actividad;
  final String entrada;
  final String salida;
  final String fechaInicio;
  final String fechaFin;

  const Horario({
    required this.nombre,
    required this.turno,
    required this.actividad,
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

  /// INTL: Convierte fechaInicio (dd/MM/yyyy) a texto en español
  String get fechaInicioFormateada {
    try {
      final fecha = DateFormat('dd/MM/yyyy').parse(fechaInicio);
      return DateFormat("d 'de' MMMM yyyy", 'es').format(fecha);
    } catch (_) {
      return fechaInicio;
    }
  }

  /// INTL: Convierte fechaFin (dd/MM/yyyy) a texto en español
  String get fechaFinFormateada {
    try {
      final fecha = DateFormat('dd/MM/yyyy').parse(fechaFin);
      return DateFormat("d 'de' MMMM yyyy", 'es').format(fecha);
    } catch (_) {
      return fechaFin;
    }
  }
}
