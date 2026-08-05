import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/sensor_iot_model.dart';
import '../models/elemento_estado_model.dart';
import '../models/lectura_sensor_model.dart';
import '../models/invernadero_model.dart';

class SupervisionService {
  static const String baseUrl = 'https://ibijicama.utptics.com/api';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<List<SensorIot>> getSensores() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/sensores'),
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
        return data.map((json) => SensorIot.fromJson(json)).toList();
      } else {
        throw Exception(decoded['message'] ?? 'Fallo al cargar los sensores');
      }
    } else {
      throw Exception(
        'Error ${response.statusCode}: ${response.reasonPhrase} - ${response.body}',
      );
    }
  }

  Future<List<ElementoEstado>> getElementos() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/elemento-estado'),
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
        return data.map((json) => ElementoEstado.fromJson(json)).toList();
      } else {
        throw Exception(decoded['message'] ?? 'Fallo al cargar los elementos');
      }
    } else {
      throw Exception(
        'Error ${response.statusCode}: ${response.reasonPhrase} - ${response.body}',
      );
    }
  }

  Future<List<LecturaSensor>> getLecturas() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/lectura-sensores'),
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
        return data.map((json) => LecturaSensor.fromJson(json)).toList();
      } else {
        throw Exception(decoded['message'] ?? 'Fallo al cargar las lecturas');
      }
    } else {
      throw Exception(
        'Error ${response.statusCode}: ${response.reasonPhrase} - ${response.body}',
      );
    }
  }

  Future<List<Invernadero>> getInvernaderos() async {
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
}
