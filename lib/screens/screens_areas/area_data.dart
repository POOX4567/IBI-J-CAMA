// area_provider.dart — VERSIÓN FINAL, SOLO API, SIN HIVE, SIN areasIniciales
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'area.dart';
import 'area_service.dart';

class AreaProvider extends ChangeNotifier {
  final AreaService _service = AreaService();

  List<Area> _areas = [];
  List<Area> _historial = [];
  String _filtroEstado = 'Todos';
  String _busqueda = '';
  bool isLoading = false;
  String? error;

  int? _pendientes;
  int? _completadas;
  int? _requierenSupervision;
  double? _productividadGeneral;
  List<Map<String, dynamic>> _productividadSemanal = [];

  List<Map<String, dynamic>> empleados = [];
  List<Map<String, dynamic>> areasDisponibles = [];
  List<Map<String, dynamic>> cultivos = [];

  List<Area> get areas {
    return _areas.where((a) {
      final coincideFiltro =
          _filtroEstado == 'Todos' ||
          a.estado.toLowerCase().contains(_filtroEstado.toLowerCase());
      final coincideBusqueda =
          _busqueda.isEmpty ||
          a.area.toLowerCase().contains(_busqueda.toLowerCase()) ||
          a.empleado.toLowerCase().contains(_busqueda.toLowerCase());
      return coincideFiltro && coincideBusqueda;
    }).toList();
  }

  String get filtroEstado => _filtroEstado;
  String get busqueda => _busqueda;
  List<Area> get historial => _historial;
  List<Map<String, dynamic>> get productividadSemanal => _productividadSemanal;

  int get pendientes =>
      _pendientes ??
      _areas.where((a) => a.estado.toLowerCase().contains('pendiente')).length;

  int get completadas =>
      _completadas ??
      _areas.where((a) => a.estado.toLowerCase().contains('completado')).length;

  int get requierenSupervision =>
      _requierenSupervision ?? _areas.where((a) => a.progreso < 0.5).length;

  double get productividadGeneral =>
      _productividadGeneral ??
      (_areas.isEmpty
          ? 0
          : _areas.map((a) => a.progreso).reduce((v, e) => v + e) /
                _areas.length *
                100);

  void setFiltro(String estado) {
    _filtroEstado = estado;
    notifyListeners();
  }

  void setBusqueda(String texto) {
    _busqueda = texto;
    notifyListeners();
  }

  Future<void> cargarAreas() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _areas = await _service.obtenerAreas();
      debugPrint('AREAS CARGADAS DESDE API: ${_areas.length}');
      await cargarEstadisticas();
    } catch (e) {
      error = e.toString();
      debugPrint('ERROR cargarAreas: $error');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> cargarEstadisticas() async {
    try {
      final resumen = await _service.obtenerResumenDia();
      _pendientes = resumen['actividades_pendientes'];
      _completadas = resumen['actividades_completadas'];
      _requierenSupervision = resumen['areas_requieren_supervision'];
      final prodStr = '${resumen['productividad_general']}'.replaceAll('%', '');
      _productividadGeneral = double.tryParse(prodStr);

      _productividadSemanal = await _service.obtenerProductividadSemanal();
    } catch (e) {
      error = e.toString();
      debugPrint('ERROR cargarEstadisticas: $error');
    }
    notifyListeners();
  }

  Future<void> cargarHistorial() async {
    isLoading = true;
    notifyListeners();
    try {
      _historial = await _service.obtenerHistorial();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> agregarArea(Area a) async {
    try {
      final creada = await _service.crearArea(a);
      _areas.add(creada);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarArea(int id, Area area) async {
    try {
      final actualizada = await _service.actualizarArea(id, area);
      final i = _areas.indexWhere((a) => a.id == id);
      if (i != -1) _areas[i] = actualizada;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarProgreso(int id, double progreso) async {
    try {
      final actualizada = await _service.actualizarProgreso(id, progreso);
      final i = _areas.indexWhere((a) => a.id == id);
      if (i != -1) _areas[i] = actualizada;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarEstado(int id, String estado) async {
    try {
      final actualizada = await _service.actualizarEstado(id, estado);
      final i = _areas.indexWhere((a) => a.id == id);
      if (i != -1) _areas[i] = actualizada;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> eliminarArea(String areaName) async {
    Area? area;
    for (final a in _areas) {
      if (a.area == areaName) {
        area = a;
        break;
      }
    }
    if (area == null || area.id == null) {
      _areas.removeWhere((a) => a.area == areaName);
      notifyListeners();
      return;
    }
    try {
      await _service.eliminarArea(area.id!);
      _areas.removeWhere((a) => a.id == area!.id);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> cargarEmpleadosDisponibles() async {
    try {
      final res = await http.get(Uri.parse('${AreaService.baseUrl}/employees'));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List data =
            decoded['data']; // 👈 antes: jsonDecode(res.body) directo
        empleados = data
            .map<Map<String, dynamic>>(
              (e) => {
                'id': e['id'],
                'name': e['nombre'] ?? 'Sin nombre',
              }, // 👈 antes: e['name']
            )
            .toList();
        notifyListeners();
      }
    } catch (e) {
      error = 'No se pudieron cargar empleados: $e';
      notifyListeners();
    }
  }

  Future<void> cargarAreasDisponiblesParaFormulario() async {
    try {
      final res = await http.get(
        Uri.parse('${AreaService.baseUrl}/invernaderos'),
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        areasDisponibles = data
            .map<Map<String, dynamic>>(
              (e) => {'id': e['id'], 'name': e['nombre'] ?? 'Sin nombre'},
            )
            .toList();
        notifyListeners();
      }
    } catch (e) {
      error = 'No se pudieron cargar áreas: $e';
      notifyListeners();
    }
  }

  Future<void> cargarCultivosDisponibles() async {
    try {
      final res = await http.get(Uri.parse('${AreaService.baseUrl}/cultivos'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        cultivos = data
            .map<Map<String, dynamic>>(
              (e) => {'id': e['id'], 'name': e['nombre'] ?? 'Sin nombre'},
            )
            .toList();
        notifyListeners();
      }
    } catch (e) {
      error = 'No se pudieron cargar cultivos (falta ruta /cultivos): $e';
      notifyListeners();
    }
  }

  Future<void> cargarDatosDeFormulario() async {
    await Future.wait([
      cargarEmpleadosDisponibles(),
      cargarAreasDisponiblesParaFormulario(),
    ]);
  }
}
