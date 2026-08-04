import 'dart:async';
import 'package:ibi/models/attendance_model.dart';

class AttendanceService {
  // Simulación de consulta a la API / MongoDB
  Future<AttendanceReportData> fetchAttendanceReport() async {
    // Simulamos 1 segundo de latencia de red
    await Future.delayed(const Duration(seconds: 1));

    // Datos crudos simulando la respuesta JSON de tu backend
    final List<Map<String, dynamic>> rawEmployees = [
      {"name": "Juan Pérez", "status": "Presente", "puntualidad": "100%"},
      {"name": "Carlos López", "status": "Ausente", "puntualidad": "70%"},
      {"name": "María Gómez", "status": "Tarde", "puntualidad": "85%"},
      {"name": "Ana Torres", "status": "Presente", "puntualidad": "98%"},
      {"name": "Luis Hernández", "status": "Presente", "puntualidad": "95%"},
      {"name": "Sofía Ramírez", "status": "Ausente", "puntualidad": "75%"},
    ];

    final List<Map<String, dynamic>> rawAsistencias = [
      {
        'dia': 'LUN',
        'fecha': '20',
        'mes': 'MAY',
        'estado': 'Presente',
        'hora': '06:00 AM',
      },
      {
        'dia': 'MAR',
        'fecha': '21',
        'mes': 'MAY',
        'estado': 'Presente',
        'hora': '06:05 AM',
      },
      {
        'dia': 'MIÉ',
        'fecha': '22',
        'mes': 'MAY',
        'estado': 'Retardo',
        'hora': '06:20 AM',
      },
      {
        'dia': 'JUE',
        'fecha': '23',
        'mes': 'MAY',
        'estado': 'Presente',
        'hora': '06:02 AM',
      },
      {
        'dia': 'VIE',
        'fecha': '24',
        'mes': 'MAY',
        'estado': 'Falta',
        'hora': '--',
      },
      {
        'dia': 'SÁB',
        'fecha': '25',
        'mes': 'MAY',
        'estado': 'Presente',
        'hora': '06:00 AM',
      },
    ];

    final List<Map<String, dynamic>> rawObservaciones = [
      {
        'fecha': '20/05/2026',
        'texto':
            'Excelente trabajo en la inspección de humedad. Muy detallado.',
        'autor': 'Sup. Juan',
      },
      {
        'fecha': '18/05/2026',
        'texto': 'Recordar llegar puntual al turno matutino.',
        'autor': 'Sup. Juan',
      },
    ];

    // Mapeo e instanciación transformando los mapas a Modelos de Dart
    final employees = rawEmployees
        .map((e) => EmployeeAttendanceModel.fromMap(e))
        .toList();
    final recentAttendance = rawAsistencias
        .map((a) => RecentAttendanceModel.fromMap(a))
        .toList();
    final observations = rawObservaciones
        .map((o) => SupervisorObservationModel.fromMap(o))
        .toList();

    return AttendanceReportData(
      employees: employees,
      recentAttendance: recentAttendance,
      observations: observations,
    );
  }
}
