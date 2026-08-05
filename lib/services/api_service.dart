import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/invernadero.dart';
import '../models/lectura_sensor.dart';

class ApiService {

  // Cambia la IP por la de tu computadora cuando pruebes en un celular
  static const String baseUrl = "http://127.0.0.1:8000/api";

  Future<List<Invernadero>> obtenerInvernaderos() async {

    final response = await http.get(
      Uri.parse("$baseUrl/invernaderos"),
    );

    if (response.statusCode == 200) {

      final jsonData = json.decode(response.body);

      List datos = jsonData["data"];

      return datos
          .map((e) => Invernadero.fromJson(e))
          .toList();

    } else {

      throw Exception("Error al obtener los invernaderos");

    }

  }

  Future<List<LecturaSensor>> obtenerLecturasSensores() async {

    final response = await http.get(
      Uri.parse("$baseUrl/lectura-sensores"),
    );

    if (response.statusCode == 200) {

      final jsonData = json.decode(response.body);

      List datos = jsonData["data"];

      return datos
          .map((e) => LecturaSensor.fromJson(e))
          .toList();

    } else {

      throw Exception("Error al obtener las lecturas");

    }

  }

}