import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ibi/models/attendance_model.dart';

class AttendanceService {
  static const String baseUrl = 'https://ibijicama.utptics.com/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<AttendanceReportData> fetchAttendanceReport() async {
    final token = await _getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // 1. Petición para obtener la lista real de empleados
      final employeesResponse = await http.get(
        Uri.parse('$baseUrl/employees'),
        headers: headers,
      );

      List<EmployeeAttendanceModel> employees = [];
      if (employeesResponse.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(employeesResponse.body);
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];

          // ⚡ MAPEAMOS LAS LLAVES REALES DE TU JSON
          employees = data.map((e) {
            return EmployeeAttendanceModel.fromMap({
              'name': e['nombre'] ?? 'Sin nombre', // 'nombre' viene de tu API
              'status': e['estado_laboral'] == 'Activo'
                  ? 'Presente'
                  : 'Ausente', // Traducimos a tu UI
              'puntualidad':
                  e['turno'] ??
                  'Matutino', // Usamos turno o '100%' si prefieres
            });
          }).toList();
        }
      }

      // 2. Petición para obtener asistencias
      final attendanceResponse = await http.get(
        Uri.parse('$baseUrl/attendance'),
        headers: headers,
      );

      List<RecentAttendanceModel> recentAttendance = [];
      if (attendanceResponse.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(attendanceResponse.body);
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          recentAttendance = data.map((a) {
            return RecentAttendanceModel.fromMap({
              'dia': a['dia'] ?? 'LUN',
              'fecha': a['fecha'] ?? '',
              'mes': a['mes'] ?? '',
              'estado': a['type'] ?? a['estado'] ?? 'Presente',
              'hora': a['hora'] ?? a['date_time'] ?? '--',
            });
          }).toList();
        }
      }

      // 3. Petición para obtener observaciones
      final observationsResponse = await http.get(
        Uri.parse('$baseUrl/observations'),
        headers: headers,
      );

      List<SupervisorObservationModel> observations = [];
      if (observationsResponse.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(observationsResponse.body);
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          observations = data.map((o) {
            return SupervisorObservationModel.fromMap({
              'fecha': o['created_at'] ?? o['fecha'] ?? '',
              'texto': o['observation'] ?? o['texto'] ?? '',
              'autor': o['author'] ?? o['autor'] ?? 'Supervisor',
            });
          }).toList();
        }
      }

      return AttendanceReportData(
        employees: employees,
        recentAttendance: recentAttendance,
        observations: observations,
      );
    } catch (e) {
      throw Exception('Error al conectar con la API de empleados: $e');
    }
  }
}
