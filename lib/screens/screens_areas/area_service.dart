import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'area.dart';

class AreaService {
  // Permite sobreescribir la URL en tiempo de compilación:
  // `flutter run --dart-define=API_BASE_URL=http://192.168.100.209:8000/api`
  static final String _envBase = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_envBase.isNotEmpty) return _envBase;
    if (kIsWeb) return 'https://ibijicama.utptics.com/api';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // 👇 FIX: faltaba el puerto ":8000". Sin él, la petición iba al
        // puerto 80 (HTTP default), donde Laravel no está escuchando.
        return 'https://ibijicama.utptics.com/api';
      default:
        return 'https://ibijicama.utptics.com/api';
    }
  }

  /// Helper: decodifica el body y extrae la lista real, sin importar si el
  /// backend regresa un arreglo plano `[...]` o la envoltura de Laravel
  /// `{ "success"/"status": true, "message": "...", "data": [...] }`.
  List _extraerLista(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) return data;
    }
    throw FormatException(
      'La respuesta del servidor no contiene una lista válida en "data". Body: $body',
    );
  }

  /// Helper: decodifica el body y extrae el objeto real, sin importar si el
  /// backend regresa un objeto plano `{...}` o la envoltura
  /// `{ "success"/"status": true, "message": "...", "data": {...} }`.
  Map<String, dynamic> _extraerMapa(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) return data;
      return decoded;
    }
    throw FormatException(
      'La respuesta del servidor no contiene un objeto válido. Body: $body',
    );
  }

  /// GET /areas
  Future<List<Area>> obtenerAreas() async {
    final res = await http.get(Uri.parse('$baseUrl/areas'));
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data.map((e) => Area.fromJson(e)).toList();
    }
    throw Exception('Error al obtener áreas (${res.statusCode})');
  }

  /// GET /areas/{id}
  Future<Area> obtenerArea(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/areas/$id'));
    if (res.statusCode == 200) {
      return Area.fromJson(_extraerMapa(res.body));
    }
    throw Exception('Error al obtener área (${res.statusCode})');
  }

  /// GET /areas/historial
  Future<List<Area>> obtenerHistorial() async {
    final res = await http.get(Uri.parse('$baseUrl/areas/historial'));
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data.map((e) => Area.fromJson(e)).toList();
    }
    throw Exception('Error al obtener historial (${res.statusCode})');
  }

  /// GET /areas/resumen-dia
  Future<Map<String, dynamic>> obtenerResumenDia() async {
    final res = await http.get(Uri.parse('$baseUrl/areas/resumen-dia'));
    if (res.statusCode == 200) {
      return _extraerMapa(res.body);
    }
    throw Exception('Error al obtener resumen del día (${res.statusCode})');
  }

  /// GET /areas/productividad-semanal
  Future<List<Map<String, dynamic>>> obtenerProductividadSemanal() async {
    final res = await http.get(
      Uri.parse('$baseUrl/areas/productividad-semanal'),
    );
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception(
      'Error al obtener productividad semanal (${res.statusCode})',
    );
  }

  /// POST /areas
  Future<Area> crearArea(Area area) async {
    final res = await http.post(
      Uri.parse('$baseUrl/areas'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(area.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return Area.fromJson(_extraerMapa(res.body));
    }
    throw Exception('Error al crear área (${res.statusCode}): ${res.body}');
  }

  /// PUT /areas/{id}
  Future<Area> actualizarArea(int id, Area area) async {
    final res = await http.put(
      Uri.parse('$baseUrl/areas/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(area.toJson()),
    );
    if (res.statusCode == 200) {
      return Area.fromJson(_extraerMapa(res.body));
    }
    throw Exception(
      'Error al actualizar área (${res.statusCode}): ${res.body}',
    );
  }

  /// DELETE /areas/{id}
  Future<void> eliminarArea(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/areas/$id'));
    if (res.statusCode != 200) {
      throw Exception('Error al eliminar área (${res.statusCode})');
    }
  }

  /// PATCH /areas/{id}/progreso
  Future<Area> actualizarProgreso(int id, double progreso) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/areas/$id/progreso'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'progreso': progreso}),
    );
    if (res.statusCode == 200) {
      return Area.fromJson(_extraerMapa(res.body));
    }
    throw Exception(
      'Error al actualizar progreso (${res.statusCode}): ${res.body}',
    );
  }

  /// PATCH /areas/{id}/estado
  Future<Area> actualizarEstado(int id, String estado) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/areas/$id/estado'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'estado': estado}),
    );
    if (res.statusCode == 200) {
      return Area.fromJson(_extraerMapa(res.body));
    }
    throw Exception(
      'Error al actualizar estado (${res.statusCode}): ${res.body}',
    );
  }

  /// GET /employees (para el dropdown de "Nueva Área")
  Future<List<Map<String, dynamic>>> obtenerEmpleados() async {
    final res = await http.get(Uri.parse('$baseUrl/employees'));
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data
          .map<Map<String, dynamic>>(
            (e) => {
              'id': e['id'],
              'name': e['nombre'] ?? e['name'] ?? 'Sin nombre',
            },
          )
          .toList();
    }
    throw Exception('Error al obtener empleados (${res.statusCode})');
  }

  /// GET /invernaderos (para el dropdown de "Nueva Área")
  Future<List<Map<String, dynamic>>> obtenerInvernaderos() async {
    final res = await http.get(Uri.parse('$baseUrl/invernaderos'));
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data
          .map<Map<String, dynamic>>(
            (e) => {
              'id': e['id'],
              'name': e['nombre'] ?? e['name'] ?? 'Sin nombre',
            },
          )
          .toList();
    }
    throw Exception('Error al obtener invernaderos (${res.statusCode})');
  }

  /// GET /cultivos (para el dropdown de "Nueva Área")
  /// ⚠️ Si esta ruta aún no existe en tu Laravel, siempre lanzará una
  /// excepción con statusCode 404, que queda capturada por el provider.
  Future<List<Map<String, dynamic>>> obtenerCultivos() async {
    final res = await http.get(Uri.parse('$baseUrl/cultivos'));
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data
          .map<Map<String, dynamic>>(
            (e) => {
              'id': e['id'],
              'name': e['nombre'] ?? e['name'] ?? 'Sin nombre',
            },
          )
          .toList();
    }
    throw Exception('Error al obtener cultivos (${res.statusCode})');
  }
}
