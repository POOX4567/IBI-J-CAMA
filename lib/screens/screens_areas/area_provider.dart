import 'package:flutter/material.dart';
import 'area.dart';
import 'area_service.dart';

/// PROVIDER: gestión de estado global para el módulo de Áreas.
/// Mismo patrón que HorarioProvider: la fuente de datos es la API,
/// usando AreaService para cada endpoint del AreaController.
class AreaProvider extends ChangeNotifier {
  final AreaService _service = AreaService();

  List<Area> _areas = [];
  List<Area> _historial = [];
  String _filtroEstado = 'Todos';
  String _busqueda = '';
  bool isLoading = false;
  String? error;

  // ── resumen-dia ──────────────────────────────────────────────────
  int? _pendientes;
  int? _enProgresoBackend;
  int? _completadas;
  int? _requierenSupervision;
  double? _productividadGeneral;

  // ── productividad-semanal ────────────────────────────────────────
  List<Map<String, dynamic>> _productividadSemanal = [];

  // ── Dropdowns para el formulario "Nueva Área" ───────────────────
  List<Map<String, dynamic>> empleados = [];
  List<Map<String, dynamic>> areasDisponibles = []; // invernaderos
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

  // ── Conteo de áreas "En progreso" ─────────────────────────────────
  // Ahora /areas/resumen-dia SÍ regresa este dato (actividades_en_progreso).
  // Si por alguna razón no llegara (backend viejo, error de red, etc.),
  // se calcula igual que pendientes/completadas: contando la lista local.
  int get enProgreso =>
      _enProgresoBackend ??
      _areas.where((a) => a.estado.toLowerCase().contains('progreso')).length;

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

  // ── GET /areas ────────────────────────────────────────────────────
  Future<void> cargarAreas() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _areas = await _service.obtenerAreas();
      await cargarEstadisticas();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  // ── GET /areas/resumen-dia + /areas/productividad-semanal ─────────
  Future<void> cargarEstadisticas() async {
    try {
      final resumen = await _service.obtenerResumenDia();
      _pendientes = resumen['actividades_pendientes'];
      _enProgresoBackend = resumen['actividades_en_progreso'];
      _completadas = resumen['actividades_completadas'];
      _requierenSupervision = resumen['areas_requieren_supervision'];
      final prodStr = '${resumen['productividad_general']}'.replaceAll('%', '');
      _productividadGeneral = double.tryParse(prodStr);

      _productividadSemanal = await _service.obtenerProductividadSemanal();

      // Sin ruta dedicada, derivamos cultivos de productividad-semanal
      _actualizarCultivosDesdeProductividad();
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  void _actualizarCultivosDesdeProductividad() {
    final vistos = <String>{};
    final lista = <Map<String, dynamic>>[];

    for (final item in _productividadSemanal) {
      final id = item['cultivo_id'];
      final key = '$id';
      if (id == null || vistos.contains(key)) continue;
      vistos.add(key);
      lista.add({'id': id, 'name': item['cultivo_nombre'] ?? 'Cultivo #$id'});
    }

    // Solo sobreescribe si aún no tenemos cultivos de /cultivos.
    if (cultivos.isEmpty) {
      cultivos = lista;
    }
  }

  // ── GET /areas/historial ───────────────────────────────────────────
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

  // ── POST /areas ──────────────────────────────────────────────────
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

  /// Recibe los ids sueltos del formulario y arma el modelo Area
  /// para enviarlo a la API.
  Future<bool> crearNuevaArea({
    required int empleadoId,
    required int areaId, // invernadero_id
    required int cultivoId,
    required String actividad,
    String estado = 'Pendiente',
    double progreso = 0.0,
  }) async {
    final area = Area(
      empleado: '',
      area: '',
      cultivo: '',
      actividad: actividad,
      estado: estado,
      progreso: progreso,
      empleadoId: empleadoId,
      areaId: areaId,
      cultivoId: cultivoId,
    );
    return agregarArea(area);
  }

  // ── PUT /areas/{id} ──────────────────────────────────────────────
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

  // ── PATCH /areas/{id}/progreso ───────────────────────────────────
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

  // ── PATCH /areas/{id}/estado ─────────────────────────────────────
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

  // ── DELETE /areas/{id} ───────────────────────────────────────────
  //  Ahora recibe el objeto Area completo y borra por `id`, no por
  // nombre. Buscar por nombre (`a.area == areaName`) siempre encontraba
  // la PRIMERA área con ese nombre en la lista, sin importar cuál
  // tarjeta deslizó el usuario, por eso siempre borraba "la de arriba".
  Future<void> eliminarArea(Area area) async {
    if (area.id == null) {
      // Área sin id (creada localmente sin respuesta del server, caso raro):
      // se elimina por identidad de objeto, no por nombre.
      _areas.removeWhere((a) => identical(a, area));
      notifyListeners();
      return;
    }
    try {
      await _service.eliminarArea(area.id!);
      _areas.removeWhere((a) => a.id == area.id);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // ── Dropdowns del formulario "Nueva Área" ────────────────────────
  Future<void> cargarEmpleadosDisponibles() async {
    try {
      empleados = await _service.obtenerEmpleados();
      notifyListeners();
    } catch (e) {
      error = 'No se pudieron cargar empleados: $e';
      notifyListeners();
    }
  }

  Future<void> cargarAreasDisponiblesParaFormulario() async {
    try {
      areasDisponibles = await _service.obtenerInvernaderos();
      notifyListeners();
    } catch (e) {
      error = 'No se pudieron cargar áreas: $e';
      notifyListeners();
    }
  }

  ///  Requiere que exista GET /cultivos en Laravel. Mientras no exista,
  /// esto fallará en silencio (capturado aquí) y se usará el fallback de
  /// _actualizarCultivosDesdeProductividad().
  Future<void> cargarCultivosDisponibles() async {
    try {
      cultivos = await _service.obtenerCultivos();
      notifyListeners();
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
