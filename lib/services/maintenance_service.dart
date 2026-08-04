import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/maintenance_model.dart';

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
}
