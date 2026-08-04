import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/maintenance_model.dart';
import '../models/invernadero_model.dart';

class MaintenanceService {
  static const String baseUrl = 'https://ibijicama.utptics.com/api';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<List<MaintenanceModel>> fetchMaintenanceTasks() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/mantenimientos'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => MaintenanceModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error ${response.statusCode}: ${response.reasonPhrase} - ${response.body}',
      );
    }
  }

  Future<MaintenanceModel> createMaintenance({
    required String titulo,
    required String descripcion,
    required String tipo,
    required int invernaderoId,
  }) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/mantenimientos'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'titulo': titulo,
        'descripcion': descripcion,
        'tipo': tipo,
        'invernadero_id': invernaderoId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return MaintenanceModel.fromJson(decoded);
    } else {
      throw Exception(
        'Error ${response.statusCode}: ${response.reasonPhrase} - ${response.body}',
      );
    }
  }

  Future<List<Invernadero>> fetchInvernaderos() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/invernaderos'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        List<dynamic> data = decoded['data'];
        return data.map((json) => Invernadero.fromJson(json)).toList();
      } else {
        throw Exception(
          decoded['message'] ?? 'Fallo al cargar los invernaderos',
        );
      }
    } else {
      throw Exception(
        'Error ${response.statusCode}: ${response.reasonPhrase} - ${response.body}',
      );
    }
  }

  Future<MaintenanceModel> updateMaintenance({
    required int id,
    required String titulo,
    required String descripcion,
    required int invernaderoId,
  }) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/mantenimientos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'titulo': titulo,
        'descripcion': descripcion,
        'invernadero_id': invernaderoId,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return MaintenanceModel.fromJson(decoded);
    } else {
      throw Exception(
        'Error ${response.statusCode}: ${response.reasonPhrase} - ${response.body}',
      );
    }
  }
}
