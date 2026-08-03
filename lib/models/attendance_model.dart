import 'package:flutter/material.dart';

// 👥 Modelo para la lista general de empleados
class EmployeeAttendanceModel {
  final String name;
  final String status;
  final String puntualidad;

  EmployeeAttendanceModel({
    required this.name,
    required this.status,
    required this.puntualidad,
  });

  factory EmployeeAttendanceModel.fromMap(Map<String, dynamic> map) {
    return EmployeeAttendanceModel(
      name: map['name'] ?? '',
      status: map['status'] ?? 'Ausente',
      puntualidad: map['puntualidad'] ?? '0%',
    );
  }

  // Helper para asignar colores según el estado actual
  Color get statusColor {
    switch (status) {
      case "Presente":
        return Colors.green;
      case "Tarde":
      case "Retardo":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}

// 🗓️ Modelo para la matriz de entradas recientes
class RecentAttendanceModel {
  final String dia;
  final String fecha;
  final String mes;
  final String estado;
  final String hora;

  RecentAttendanceModel({
    required this.dia,
    required this.fecha,
    required this.mes,
    required this.estado,
    required this.hora,
  });

  factory RecentAttendanceModel.fromMap(Map<String, dynamic> map) {
    return RecentAttendanceModel(
      dia: map['dia'] ?? '',
      fecha: map['fecha'] ?? '',
      mes: map['mes'] ?? '',
      estado: map['estado'] ?? 'Falta',
      hora: map['hora'] ?? '--',
    );
  }

  Color get statusColor {
    switch (estado) {
      case "Presente":
        return Colors.green;
      case "Retardo":
      case "Tarde":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}

// 💬 Modelo para las bitácoras u observaciones del supervisor
class SupervisorObservationModel {
  final String fecha;
  final String texto;
  final String autor;

  SupervisorObservationModel({
    required this.fecha,
    required this.texto,
    required this.autor,
  });

  factory SupervisorObservationModel.fromMap(Map<String, dynamic> map) {
    return SupervisorObservationModel(
      fecha: map['fecha'] ?? '',
      texto: map['texto'] ?? '',
      autor: map['autor'] ?? 'Anónimo',
    );
  }
}

// 📦 Contenedor maestro para agrupar toda la información del reporte en una sola petición
class AttendanceReportData {
  final List<EmployeeAttendanceModel> employees;
  final List<RecentAttendanceModel> recentAttendance;
  final List<SupervisorObservationModel> observations;

  AttendanceReportData({
    required this.employees,
    required this.recentAttendance,
    required this.observations,
  });
}
