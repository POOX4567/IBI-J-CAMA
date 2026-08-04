import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'horario.dart';

class HorarioService {
  static final String _envBase = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_envBase.isNotEmpty) return _envBase;
    return 'https://ibijicama.utptics.com/api';
  }

  // Headers comunes: 'Accept' es CLAVE para que Laravel siempre
  // regrese JSON en vez de una página HTML de error/login.
  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static const _timeout = Duration(seconds: 15);

  List _extraerLista(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) return data;
    }
    throw const FormatException(
      'La respuesta del servidor no contiene una lista válida en "data".',
    );
  }

  Map<String, dynamic> _extraerMapa(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) return data;
      return decoded;
    }
    throw const FormatException(
      'La respuesta del servidor no contiene un objeto válido.',
    );
  }

  // ---------------------------------------------------------------------
  // HORARIOS
  // ---------------------------------------------------------------------

  Future<List<Horario>> obtenerHorarios() async {
    final uri = Uri.parse('$baseUrl/horarios');
    debugPrint('GET $uri');
    final res = await http.get(uri, headers: _headers).timeout(_timeout);
    debugPrint('Respuesta (${res.statusCode}): ${res.body}');
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data.map((e) => Horario.fromJson(e)).toList();
    }
    throw Exception(
      'Error al obtener horarios (${res.statusCode}): ${res.body}',
    );
  }

  Future<Horario> obtenerHorarioPorId(int id) async {
    final uri = Uri.parse('$baseUrl/horarios/$id');
    final res = await http.get(uri, headers: _headers).timeout(_timeout);
    if (res.statusCode == 200) {
      return Horario.fromJson(_extraerMapa(res.body));
    }
    throw Exception(
      'Error al obtener horario (${res.statusCode}): ${res.body}',
    );
  }

  Future<List<Horario>> horariosPorTurno(String turno) async {
    final uri = Uri.parse('$baseUrl/horarios/turno/$turno');
    debugPrint('GET $uri');
    final res = await http.get(uri, headers: _headers).timeout(_timeout);
    debugPrint('Respuesta (${res.statusCode}): ${res.body}');
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data.map((e) => Horario.fromJson(e)).toList();
    }
    throw Exception(
      'Error al obtener horarios por turno (${res.statusCode}): ${res.body}',
    );
  }

  Future<List<Horario>> horariosMatutino() => horariosPorTurno('Matutino');
  Future<List<Horario>> horariosVespertino() => horariosPorTurno('Vespertino');

  Future<Map<String, int>> obtenerEstadisticas() async {
    final uri = Uri.parse('$baseUrl/horarios/estadisticas');
    debugPrint('GET $uri');
    final res = await http.get(uri, headers: _headers).timeout(_timeout);
    debugPrint('Respuesta (${res.statusCode}): ${res.body}');
    if (res.statusCode == 200) {
      final data = _extraerMapa(res.body);
      return {
        'total_horarios_activos': data['total_horarios_activos'] ?? 0,
        'total_empleados': data['total_empleados'] ?? 0,
        'total_turnos_registrados': data['total_turnos_registrados'] ?? 0,
      };
    }
    throw Exception(
      'Error al obtener estadísticas (${res.statusCode}): ${res.body}',
    );
  }

  Future<Horario> crearHorario(Horario horario) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/horarios'),
          headers: _headers,
          body: jsonEncode(horario.toJson()),
        )
        .timeout(_timeout);
    if (res.statusCode == 201 || res.statusCode == 200) {
      return Horario.fromJson(_extraerMapa(res.body));
    }
    throw Exception('Error al crear horario (${res.statusCode}): ${res.body}');
  }

  Future<Horario> actualizarHorario(int id, Horario horario) async {
    final res = await http
        .put(
          Uri.parse('$baseUrl/horarios/$id'),
          headers: _headers,
          body: jsonEncode(horario.toJson()),
        )
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return Horario.fromJson(_extraerMapa(res.body));
    }
    throw Exception(
      'Error al actualizar horario (${res.statusCode}): ${res.body}',
    );
  }

  Future<void> eliminarHorario(int id) async {
    final res = await http
        .delete(Uri.parse('$baseUrl/horarios/$id'), headers: _headers)
        .timeout(_timeout);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception(
        'Error al eliminar horario (${res.statusCode}): ${res.body}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> obtenerEmpleados() async {
    final uri = Uri.parse('$baseUrl/employees');
    debugPrint('GET $uri');
    final res = await http.get(uri, headers: _headers).timeout(_timeout);
    debugPrint('Respuesta (${res.statusCode}): ${res.body}');
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data
          .map<Map<String, dynamic>>(
            (e) => {
              'id': e['id'],
              'name': e['nombre'] ?? e['name'] ?? 'Sin nombre',
              'email': e['correo'] ?? e['email'] ?? '',
            },
          )
          .toList();
    }
    throw Exception(
      'Error al obtener empleados (${res.statusCode}): ${res.body}',
    );
  }

  // ---------------------------------------------------------------------
  // ÁREAS (se mantienen igual, solo con headers y timeout agregados)
  // ---------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> obtenerHistorialAreas() async {
    final res = await http
        .get(Uri.parse('$baseUrl/areas/historial'), headers: _headers)
        .timeout(_timeout);
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Error al obtener historial de áreas (${res.statusCode})');
  }

  Future<Map<String, dynamic>> obtenerResumenDia() async {
    final res = await http
        .get(Uri.parse('$baseUrl/areas/resumen-dia'), headers: _headers)
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return _extraerMapa(res.body);
    }
    throw Exception('Error al obtener resumen del día (${res.statusCode})');
  }

  Future<List<Map<String, dynamic>>> obtenerProductividadSemanal() async {
    final res = await http
        .get(
          Uri.parse('$baseUrl/areas/productividad-semanal'),
          headers: _headers,
        )
        .timeout(_timeout);
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception(
      'Error al obtener productividad semanal (${res.statusCode})',
    );
  }

  Future<Map<String, dynamic>> obtenerProgresoArea(int idArea) async {
    final res = await http
        .get(Uri.parse('$baseUrl/areas/$idArea/progreso'), headers: _headers)
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return _extraerMapa(res.body);
    }
    throw Exception(
      'Error al obtener progreso del área $idArea (${res.statusCode})',
    );
  }
}
