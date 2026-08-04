import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://ibijicama.utptics.com';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String name, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/loginApi'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'name': name.trim(), 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (kDebugMode) {
        debugPrint('STATUS: ${response.statusCode}');
        debugPrint('BODY: ${response.body}');
      }

      if (response.statusCode == 200 && data['success'] == true) {
        // Guardar token
        await _storage.write(key: 'token', value: data['token']);

        return {'success': true, 'user': data['user'], 'token': data['token']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Error de autenticación',
      };
    } on TimeoutException {
      return {'success': false, 'message': 'Tiempo de espera agotado'};
    } on SocketException {
      return {'success': false, 'message': 'No hay conexión a Internet'};
    } catch (e) {
      return {'success': false, 'message': 'Error inesperado'};
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }
}
