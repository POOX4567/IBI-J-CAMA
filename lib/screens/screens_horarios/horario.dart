import 'package:flutter/material.dart';

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
    if (lower.contains('matutino')) {
      return const Color(0xff1E88E5);
    }
    if (lower.contains('vespertino')) {
      return const Color(0xffFB8C00);
    }
    if (lower.contains('nocturno')) {
      return const Color(0xff6A1B9A);
    }
    return const Color(0xff43A047);
  }
}
