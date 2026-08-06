import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 👈 NUEVO
import 'package:shared_preferences/shared_preferences.dart'; // ← AGREGAR arriba

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
    return 'https://ibijicama.utptics.com/api';
  }

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage(); // 👈 NUEVO

  // 'Accept' es CLAVE: sin este header, Laravel puede regresar una
  // página HTML de error/redirección en vez de JSON, y el jsonDecode()
  // truena con un FormatException que se veía "en silencio".
  // 👇 Ahora es un método async que agrega el token guardado por AuthService.
  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static const _timeout = Duration(seconds: 15);

  // 👇 NUEVO: helper para no repetir "leer id_usuario de SharedPreferences"
  // en cada método. Centraliza la fuente de verdad del usuario logueado.
  Future<int> _idUsuarioActual() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id') ?? 0;
  }

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

  // ---------------------------------------------------------------------
  // ÁREAS
  // ---------------------------------------------------------------------

  /// GET /areas
  Future<List<Area>> obtenerAreas() async {
    final idUsuario = await _idUsuarioActual();

    final uri = Uri.parse(
      '$baseUrl/areas',
    ).replace(queryParameters: {'id_usuario': idUsuario.toString()});

    debugPrint('👉 GET $uri');
    final res = await http
        .get(uri, headers: await _headers())
        .timeout(_timeout);
    debugPrint('👈 (${res.statusCode}) ${res.body}');
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data.map((e) => Area.fromJson(e)).toList();
    }
    throw Exception('Error al obtener áreas (${res.statusCode}): ${res.body}');
  }

  /// GET /areas/{id}
  /// Consulta UNA área específica por su ID. NO confundir con las rutas
  /// PATCH de progreso/estado, que actualizan, no consultan.
  Future<Area> obtenerArea(int id) async {
    final res = await http
        .get(Uri.parse('$baseUrl/areas/$id'), headers: await _headers())
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return Area.fromJson(_extraerMapa(res.body));
    }
    throw Exception('Error al obtener área (${res.statusCode}): ${res.body}');
  }

  /// GET /areas/historial
  Future<List<Area>> obtenerHistorial() async {
    final idUsuario = await _idUsuarioActual();

    final uri = Uri.parse(
      '$baseUrl/areas/historial',
    ).replace(queryParameters: {'id_usuario': idUsuario.toString()});

    debugPrint('👉 GET $uri');
    final res = await http
        .get(uri, headers: await _headers())
        .timeout(_timeout);
    debugPrint('👈 (${res.statusCode}) ${res.body}');
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data.map((e) => Area.fromJson(e)).toList();
    }
    throw Exception(
      'Error al obtener historial (${res.statusCode}): ${res.body}',
    );
  }

  /// GET /areas/resumen-dia
  /// 👇 CORREGIDO: antes no mandaba 'id_usuario', así que el backend
  /// calculaba pendientes/en progreso/completadas sobre TODAS las áreas
  /// de TODOS los usuarios, no solo las tuyas. Ahora manda el mismo
  /// query param que ya usan obtenerAreas()/obtenerHistorial().
  Future<Map<String, dynamic>> obtenerResumenDia() async {
    final idUsuario = await _idUsuarioActual();

    final uri = Uri.parse(
      '$baseUrl/areas/resumen-dia',
    ).replace(queryParameters: {'id_usuario': idUsuario.toString()});

    debugPrint('👉 GET $uri');
    final res = await http
        .get(uri, headers: await _headers())
        .timeout(_timeout);
    debugPrint('👈 (${res.statusCode}) ${res.body}');
    if (res.statusCode == 200) {
      return _extraerMapa(res.body);
    }
    throw Exception(
      'Error al obtener resumen del día (${res.statusCode}): ${res.body}',
    );
  }

  /// GET /areas/productividad-semanal
  /// 👇 CORREGIDO: mismo problema que resumen-dia — faltaba 'id_usuario',
  /// por eso traía cultivos/productividad de todos los usuarios en vez
  /// de solo los tuyos.
  Future<List<Map<String, dynamic>>> obtenerProductividadSemanal() async {
    final idUsuario = await _idUsuarioActual();

    final uri = Uri.parse(
      '$baseUrl/areas/productividad-semanal',
    ).replace(queryParameters: {'id_usuario': idUsuario.toString()});

    debugPrint('👉 GET $uri');
    final res = await http
        .get(uri, headers: await _headers())
        .timeout(_timeout);
    debugPrint('👈 (${res.statusCode}) ${res.body}');
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception(
      'Error al obtener productividad semanal (${res.statusCode}): ${res.body}',
    );
  }

  /// POST /areas
  Future<Area> crearArea(Area area) async {
    debugPrint('👉 POST $baseUrl/areas body=${jsonEncode(area.toJson())}');
    final res = await http
        .post(
          Uri.parse('$baseUrl/areas'),
          headers: await _headers(),
          body: jsonEncode(area.toJson()),
        )
        .timeout(_timeout);
    debugPrint('👈 (${res.statusCode}) ${res.body}');
    if (res.statusCode == 201 || res.statusCode == 200) {
      return Area.fromJson(_extraerMapa(res.body));
    }
    throw Exception('Error al crear área (${res.statusCode}): ${res.body}');
  }

  /// PUT /areas/{id}
  Future<Area> actualizarArea(int id, Area area) async {
    final res = await http
        .put(
          Uri.parse('$baseUrl/areas/$id'),
          headers: await _headers(),
          body: jsonEncode(area.toJson()),
        )
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return Area.fromJson(_extraerMapa(res.body));
    }
    throw Exception(
      'Error al actualizar área (${res.statusCode}): ${res.body}',
    );
  }

  /// DELETE /areas/{id}
  Future<void> eliminarArea(int id) async {
    final res = await http
        .delete(Uri.parse('$baseUrl/areas/$id'), headers: await _headers())
        .timeout(_timeout);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception(
        'Error al eliminar área (${res.statusCode}): ${res.body}',
      );
    }
  }

  /// PATCH /areas/{id}/progreso
  /// El "id" identifica el área a actualizar (ej: /areas/7/progreso).
  Future<Area> actualizarProgreso(int id, double progreso) async {
    final res = await http
        .patch(
          Uri.parse('$baseUrl/areas/$id/progreso'),
          headers: await _headers(),
          body: jsonEncode({'progreso': progreso}),
        )
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return Area.fromJson(_extraerMapa(res.body));
    }
    throw Exception(
      'Error al actualizar progreso (${res.statusCode}): ${res.body}',
    );
  }

  /// PATCH /areas/{id}/estado
  /// El "id" identifica el área a actualizar (ej: /areas/7/estado).
  Future<Area> actualizarEstado(int id, String estado) async {
    final res = await http
        .patch(
          Uri.parse('$baseUrl/areas/$id/estado'),
          headers: await _headers(),
          body: jsonEncode({'estado': estado}),
        )
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return Area.fromJson(_extraerMapa(res.body));
    }
    throw Exception(
      'Error al actualizar estado (${res.statusCode}): ${res.body}',
    );
  }

  /// GET /employees (para el dropdown de "Nueva Área")
  Future<List<Map<String, dynamic>>> obtenerEmpleados() async {
    final idUsuario = await _idUsuarioActual();

    final uri = Uri.parse(
      '$baseUrl/employees',
    ).replace(queryParameters: {'id_usuario': idUsuario.toString()});

    debugPrint('👉 GET $uri');
    final res = await http
        .get(uri, headers: await _headers())
        .timeout(_timeout);
    debugPrint('👈 (${res.statusCode}) ${res.body}');
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
    throw Exception(
      'Error al obtener empleados (${res.statusCode}): ${res.body}',
    );
  }

  /// GET /invernaderos (para el dropdown de "Nueva Área")
  Future<List<Map<String, dynamic>>> obtenerInvernaderos() async {
    final idUsuario = await _idUsuarioActual();

    final uri = Uri.parse(
      '$baseUrl/invernaderos',
    ).replace(queryParameters: {'id_usuario': idUsuario.toString()});

    debugPrint('👉 GET $uri');
    final res = await http
        .get(uri, headers: await _headers())
        .timeout(_timeout);
    debugPrint('👈 (${res.statusCode}) ${res.body}');
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
    throw Exception(
      'Error al obtener invernaderos (${res.statusCode}): ${res.body}',
    );
  }

  /// GET /cultivos (para el dropdown de "Nueva Área")
  /// 👇 CORREGIDO: le agrego 'id_usuario' igual que a /employees e
  /// /invernaderos, para que solo devuelva los cultivos que te
  /// pertenecen. IMPORTANTE: esto solo funciona si el controlador
  /// Laravel de /cultivos realmente FILTRA por ese query param — si el
  /// backend lo ignora, seguirá devolviendo todos los cultivos sin
  /// importar qué mande el Flutter. Revisa el CultivoController.
  Future<List<Map<String, dynamic>>> obtenerCultivos() async {
    final idUsuario = await _idUsuarioActual();
    final uri = Uri.parse(
      '$baseUrl/cultivos',
    ).replace(queryParameters: {'id_usuario': idUsuario.toString()});

    debugPrint('👉 GET $uri');
    final res = await http
        .get(uri, headers: await _headers())
        .timeout(_timeout);
    debugPrint('👈 (${res.statusCode}) ${res.body}');
    if (res.statusCode == 200) {
      final data = _extraerLista(res.body);
      return data
          .map<Map<String, dynamic>>(
            (e) => {
              'id': e['id'],
              'name': e['nombre'] ?? e['name'] ?? 'Sin nombre',
              'user_id':
                  e['user_id'], // 👈 NUEVO: lo guardamos para filtrar después
            },
          )
          .toList();
    }
    debugPrint('⚠️ /cultivos respondió ${res.statusCode}, devolviendo []');
    return [];
  }
}
