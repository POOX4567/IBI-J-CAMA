import 'package:flutter/material.dart';

class Empleado {
  final String id;  // 👈 Nuevo campo
  final String nombre;
  final String rol;
  final String zona;
  final String estado;
  final String turno;
  final String asistencia;
  final Color colorEstado;
  final String fotoUrl;
  final String telefono;

  Empleado({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.zona,
    required this.estado,
    required this.turno,
    required this.asistencia,
    required this.colorEstado,
    required this.fotoUrl,
    required this.telefono,
  });
}