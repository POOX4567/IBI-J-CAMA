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
    if (kIsWeb) return 'https://ibijicama.utptics.com/api';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'https://ibijicama.utptics.com/api';
      default:
        return 'https://ibijicama.utptics.com/api';
    }
  }

  /// Helper: decodifica el body y extrae la lista real, sin importar si el
  /// backend regresa un arreglo plano `[...]` o la envoltura de Laravel
  /// `{ "success": true, "message": "...", "data": [...] }`.
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

  /// Helper: decodifica el body y extrae el objeto real, sin importar si el
  /// backend regresa un objeto plano `{...}` o la envoltura
  /// `{ "success": true, "message": "...", "data": {...} }`.
  Map<String, dynamic> _extraerMapa(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) return data;
      // Si no hay 'data' anidado, asumimos que el objeto raíz ya es el dato.
      return decoded;
    }
    throw const FormatException(
      'La respuesta del servidor no contiene un objeto válido.',
    );
  }

  Future<List<Horario>> obtenerHorarios() async {
    final res = await http.get(Uri.parse('$baseUrl/horarios'));
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data.map((e) => Horario.fromJson(e)).toList();
    }
    throw Exception('Error al obtener horarios (${res.statusCode})');
  }

  Future<List<Horario>> horariosPorTurno(String turno) async {
    final res = await http.get(Uri.parse('$baseUrl/horarios/turno/$turno'));
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data.map((e) => Horario.fromJson(e)).toList();
    }
    throw Exception('Error al obtener horarios por turno (${res.statusCode})');
  }

  Future<Map<String, int>> obtenerEstadisticas() async {
    final res = await http.get(Uri.parse('$baseUrl/horarios/estadisticas'));
    if (res.statusCode == 200) {
      final data = _extraerMapa(res.body);
      return {
        'total_horarios_activos': data['total_horarios_activos'] ?? 0,
        'total_empleados': data['total_empleados'] ?? 0,
        'total_turnos_registrados': data['total_turnos_registrados'] ?? 0,
      };
    }
    throw Exception('Error al obtener estadísticas (${res.statusCode})');
  }

  Future<Horario> crearHorario(Horario horario) async {
    final res = await http.post(
      Uri.parse('$baseUrl/horarios'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(horario.toJson()),
    );
    if (res.statusCode == 201) {
      return Horario.fromJson(_extraerMapa(res.body));
    }
    throw Exception('Error al crear horario (${res.statusCode}): ${res.body}');
  }

  Future<Horario> actualizarHorario(int id, Horario horario) async {
    final res = await http.put(
      Uri.parse('$baseUrl/horarios/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(horario.toJson()),
    );
    if (res.statusCode == 200) {
      return Horario.fromJson(_extraerMapa(res.body));
    }
    throw Exception(
      'Error al actualizar horario (${res.statusCode}): ${res.body}',
    );
  }

  Future<void> eliminarHorario(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/horarios/$id'));
    if (res.statusCode != 200) {
      throw Exception('Error al eliminar horario (${res.statusCode})');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerEmpleados() async {
    final res = await http.get(Uri.parse('$baseUrl/employees'));
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data
          .map<Map<String, dynamic>>(
            (e) => {
              'id': e['id'],
              'name': e['nombre'] ?? 'Sin nombre',
              'email': e['correo'] ?? '',
            },
          )
          .toList();
    }
    throw Exception('Error al obtener empleados (${res.statusCode})');
  }
}
