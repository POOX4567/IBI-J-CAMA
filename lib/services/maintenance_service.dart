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
      Uri.parse('$baseUrl/mantenimiento'),
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
      Uri.parse('$baseUrl/mantenimiento'),
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
      final data = decoded['data'] ?? decoded;
      return MaintenanceModel.fromJson(data);
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
    required String tipo,
    String? estado,
  }) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/mantenimiento/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'titulo': titulo,
        'descripcion': descripcion,
        'tipo': tipo,
        if (estado != null) 'estado': estado,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? decoded;
      return MaintenanceModel.fromJson(data);
    } else {
      throw Exception(
        'Error ${response.statusCode}: ${response.reasonPhrase} - ${response.body}',
      );
    }
  }

  Future<void> deleteMaintenance(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/mantenimiento/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Error ${response.statusCode}: ${response.reasonPhrase} - ${response.body}',
      );
    }
  }
}
