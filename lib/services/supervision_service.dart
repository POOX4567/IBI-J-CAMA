import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_iot_model.dart';
import '../models/elemento_estado_model.dart';
import '../models/lectura_sensor_model.dart';
import '../models/invernadero_model.dart';

class SupervisionService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<SensorIot>> getSensores() async {
    final response = await http.get(Uri.parse('$baseUrl/sensores-iot'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(
        response.body,
      ); // Asumiendo que este sigue devolviendo un array directo
      return body.map((json) => SensorIot.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar los sensores');
    }
  }

  Future<List<ElementoEstado>> getElementos() async {
    final response = await http.get(Uri.parse('$baseUrl/elemento-estado'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => ElementoEstado.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar los elementos de estado');
    }
  }

  Future<List<LecturaSensor>> getLecturas() async {
    final response = await http.get(Uri.parse('$baseUrl/lectura-sensores'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> data = decoded['data']; // Extrayendo el array "data"
      return data.map((json) => LecturaSensor.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar las lecturas');
    }
  }

  Future<List<Invernadero>> getInvernaderos() async {
    final response = await http.get(Uri.parse('$baseUrl/invernaderos'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> data = decoded['data']; // Extrayendo el array "data"
      return data.map((json) => Invernadero.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar los invernaderos');
    }
  }
}
