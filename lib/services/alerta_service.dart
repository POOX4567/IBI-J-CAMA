import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/alerta_model.dart';

class AlertaService {
  static const String baseUrl = "https://ibijicama.utptics.com/api";

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: "token");
  }

  Future<List<Alerta>> obtenerAlertas() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/alertas"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Error ${response.statusCode}");
    }

    final List<dynamic> decoded = jsonDecode(response.body);

    return decoded
        .map((json) => Alerta.fromJson(json))
        .toList();
  }
}