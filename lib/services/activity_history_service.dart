import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/activity_history_model.dart';

class ActivityHistoryService {
  static const String baseUrl = "https://ibijicama.utptics.com/api";

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: "token");
  }

  Future<List<ActivityHistoryModel>> obtenerActividades() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/activities"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Error ${response.statusCode}");
    }

    final decoded = jsonDecode(response.body);

    if (decoded["success"] != true) {
      throw Exception(decoded["message"] ?? "Error al obtener actividades");
    }

    final List lista = decoded["data"];

    return lista
        .map((e) => ActivityHistoryModel.fromJson(e))
        .toList();
  }
}