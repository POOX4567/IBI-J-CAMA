import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/invernadero_model.dart';
import '../models/invernadero_detail_model.dart';

class InvernaderoService {
  static const String baseUrl = 'https://ibijicama.utptics.com/api';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<List<Invernadero>> obtenerInvernaderos() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/invernaderos'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener invernaderos');
    }

    final json = jsonDecode(response.body);

    return (json['data'] as List)
        .map((e) => Invernadero.fromJson(e))
        .toList();
  }

  Future<InvernaderoDetail> obtenerDetalle(int id) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/invernaderos/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener detalle');
    }

    final json = jsonDecode(response.body);

    return InvernaderoDetail.fromJson(json['data']);
  }
}