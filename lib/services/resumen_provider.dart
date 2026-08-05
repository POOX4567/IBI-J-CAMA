import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// Importaciones con rutas de paquete absolutas
import 'package:ibi/models/activity_history_model.dart';
import 'package:ibi/models/alerta_model.dart';
import 'package:ibi/models/employee_model.dart';
import 'package:ibi/models/invernadero_model.dart';
import 'package:ibi/models/maintenance_model.dart';

import 'package:ibi/services/activity_history_service.dart';
import 'package:ibi/services/alerta_service.dart';
import 'package:ibi/services/invernadero_service.dart';
import 'package:ibi/services/maintenance_service.dart';

class ResumenProvider with ChangeNotifier {
  final AlertaService _alertaService = AlertaService();
  final ActivityHistoryService _activityService = ActivityHistoryService();
  final InvernaderoService _invernaderoService = InvernaderoService();
  final MaintenanceService _maintenanceService = MaintenanceService();

  static const String _baseUrl = 'https://ibijicama.utptics.com/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Invernadero> _invernaderos = [];
  List<Employee> _empleados = [];
  List<Alerta> _alertas = [];
  List<MaintenanceModel> _mantenimientos = [];
  List<ActivityHistoryModel> _actividades = [];

  List<Invernadero> get invernaderos => _invernaderos;
  List<Employee> get empleados => _empleados;
  List<Alerta> get alertas => _alertas;
  List<MaintenanceModel> get mantenimientos => _mantenimientos;
  List<ActivityHistoryModel> get actividades => _actividades;

  ResumenProvider() {
    cargarDatos();
  }

  Future<List<Employee>> _fetchEmpleadosApi() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null || token.isEmpty) return <Employee>[];

      final response = await http.get(
        Uri.parse('$_baseUrl/employees'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> &&
            body['success'] == true &&
            body['data'] is List) {
          final List listData = body['data'];
          return listData
              .where((e) => e != null)
              .map((e) => Employee.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Error al consultar empleados API: $e");
    }
    return <Employee>[];
  }

  Future<void> cargarDatos() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Usamos .then con cast explícito para asegurar que cada Future devuelva exactamente List<T>
      final results = await Future.wait<dynamic>([
        _invernaderoService
            .obtenerInvernaderos()
            .then((res) => List<Invernadero>.from(res))
            .catchError((e) {
              debugPrint("Error al obtener invernaderos: $e");
              return <Invernadero>[];
            }),
        _fetchEmpleadosApi().then((res) => List<Employee>.from(res)).catchError(
          (e) {
            debugPrint("Error al obtener empleados: $e");
            return <Employee>[];
          },
        ),
        _alertaService
            .obtenerAlertas()
            .then((res) => List<Alerta>.from(res))
            .catchError((e) {
              debugPrint("Error al obtener alertas: $e");
              return <Alerta>[];
            }),
        _maintenanceService
            .fetchMaintenanceTasks()
            .then((res) => List<MaintenanceModel>.from(res))
            .catchError((e) {
              debugPrint("Error al obtener mantenimientos: $e");
              return <MaintenanceModel>[];
            }),
        _activityService
            .obtenerActividades()
            .then((res) => List<ActivityHistoryModel>.from(res))
            .catchError((e) {
              debugPrint("Error al obtener actividades: $e");
              return <ActivityHistoryModel>[];
            }),
      ]);

      _invernaderos = results[0] as List<Invernadero>;
      _empleados = results[1] as List<Employee>;
      _alertas = results[2] as List<Alerta>;
      _mantenimientos = results[3] as List<MaintenanceModel>;
      _actividades = results[4] as List<ActivityHistoryModel>;
    } catch (e, stack) {
      debugPrint("Error general en ResumenProvider: $e");
      debugPrint("Stack trace: $stack");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
