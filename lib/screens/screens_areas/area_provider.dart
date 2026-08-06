import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'area.dart';
import 'area_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // ── Bandera para saber si YA intentamos cargar los datos del
  // formulario al menos una vez (evita reintentos infinitos y permite
  // que la UI sepa cuándo mostrar el loader). ─────────────────────────
  bool cargandoDatosFormulario = false;
  bool datosFormularioCargados = false;

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

  // ── Relleno de nombres por ID ───────────────────────────────────────
  // El backend a veces no manda las relaciones ('invernadero', 'cultivo',
  // 'empleado') embebidas en /areas, así que Area.fromJson cae en sus
  // valores por defecto ('Sin área', 'Sin cultivo', 'Sin asignar').
  // Estas funciones cruzan por ID contra las listas de dropdowns
  // (empleados, areasDisponibles, cultivos) que YA cargamos para el
  // formulario, y rellenan el nombre real si lo encuentran.
  String? _buscarNombrePorId(List<Map<String, dynamic>> lista, int? id) {
    if (id == null) return null;
    final match = lista.firstWhere(
      (e) => '${e['id']}' == '$id',
      orElse: () => {},
    );
    if (match.isNotEmpty && match['name'] != null) {
      final nombre = match['name'].toString().trim();
      if (nombre.isNotEmpty) return nombre;
    }
    return null;
  }

  List<Area> _rellenarNombres(List<Area> lista) {
    if (empleados.isEmpty && areasDisponibles.isEmpty && cultivos.isEmpty) {
      return lista;
    }
    return lista.map((a) {
      String? nuevoEmpleado;
      String? nuevaArea;
      String? nuevoCultivo;

      final necesitaEmpleado =
          a.empleado.isEmpty || a.empleado == 'Sin asignar';
      final necesitaArea = a.area.isEmpty || a.area == 'Sin área';
      final necesitaCultivo = a.cultivo.isEmpty || a.cultivo == 'Sin cultivo';

      if (necesitaEmpleado) {
        nuevoEmpleado = _buscarNombrePorId(empleados, a.empleadoId);
      }
      if (necesitaArea) {
        nuevaArea = _buscarNombrePorId(areasDisponibles, a.areaId);
      }
      if (necesitaCultivo) {
        nuevoCultivo = _buscarNombrePorId(cultivos, a.cultivoId);
      }

      if (nuevoEmpleado == null && nuevaArea == null && nuevoCultivo == null) {
        return a;
      }

      return a.copyWith(
        empleado: nuevoEmpleado ?? a.empleado,
        area: nuevaArea ?? a.area,
        cultivo: nuevoCultivo ?? a.cultivo,
      );
    }).toList();
  }

  /// Filtra una lista de áreas dejando SOLO las que pertenecen a algún
  /// empleado del catálogo `empleados` (ya filtrado por id_usuario y por
  /// parent_id). Esto protege la UI aunque el backend no filtre bien
  /// `/areas` por su cuenta.
  List<Area> _filtrarPorMisEmpleados(List<Area> lista) {
    if (empleados.isEmpty) return lista;
    final idsPermitidos = empleados.map((e) => '${e['id']}').toSet();
    return lista
        .where((a) => idsPermitidos.contains('${a.empleadoId}'))
        .toList();
  }

  Future<void> cargarAreas() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      if (!datosFormularioCargados && !cargandoDatosFormulario) {
        await cargarDatosDeFormulario();
      }
      final lista = await _service.obtenerAreas();
      final conNombres = _rellenarNombres(lista);
      _areas = _filtrarPorMisEmpleados(conNombres); // ← NUEVO
      await cargarEstadisticas();
    } catch (e) {
      error = e.toString();
      _log('cargarAreas', e);
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
    } catch (e) {
      error = e.toString();
      _log('cargarEstadisticas', e);
    }

    // 👇 El backend no está filtrando bien por id_usuario en
    // resumen-dia / productividad-semanal, así que sobreescribimos con
    // números calculados sobre `_areas`, que YA está filtrada por
    // `_filtrarPorMisEmpleados`. Esto es la fuente de verdad real.
    _recalcularLocalmente();

    notifyListeners();
  }

  void _recalcularLocalmente() {
    _pendientes = _areas
        .where((a) => a.estado.toLowerCase().contains('pendiente'))
        .length;
    _enProgresoBackend = _areas
        .where((a) => a.estado.toLowerCase().contains('progreso'))
        .length;
    _completadas = _areas
        .where((a) => a.estado.toLowerCase().contains('completado'))
        .length;
    _requierenSupervision = _areas.where((a) => a.progreso < 0.5).length;
    _productividadGeneral = _areas.isEmpty
        ? 0
        : _areas.map((a) => a.progresoNormalizado).reduce((v, e) => v + e) /
              _areas.length *
              100;

    // Solo dejamos en productividadSemanal los cultivos que de verdad
    // aparecen en tus propias áreas (evita mostrar cultivos de otros
    // usuarios que vienen del endpoint sin filtrar).
    final misCultivoIds = _areas
        .map((a) => a.cultivoId)
        .whereType<int>()
        .toSet();
    if (misCultivoIds.isNotEmpty) {
      _productividadSemanal = _productividadSemanal
          .where((item) => misCultivoIds.contains(item['cultivo_id']))
          .toList();
    }
  }

  void _actualizarCultivosDesdeProductividad() {
    if (cultivos.isNotEmpty) return; // ya llegó de /cultivos, no lo pisamos

    final vistos = <String>{};
    final lista = <Map<String, dynamic>>[];

    // 👇 Se arma desde tus propias `_areas`, que sí están filtradas por
    // `_filtrarPorMisEmpleados`.
    for (final a in _areas) {
      final id = a.cultivoId;
      if (id == null || vistos.contains('$id')) continue;
      vistos.add('$id');
      lista.add({'id': id, 'name': a.cultivo});
    }

    cultivos = lista;
  }

  Future<void> cargarHistorial() async {
    isLoading = true;
    notifyListeners();
    try {
      if (!datosFormularioCargados && !cargandoDatosFormulario) {
        await cargarDatosDeFormulario();
      }
      final lista = await _service.obtenerHistorial();
      final conNombres = _rellenarNombres(lista);
      _historial = _filtrarPorMisEmpleados(conNombres);
    } catch (e) {
      error = e.toString();
      _log('cargarHistorial', e);
    }
    isLoading = false;
    notifyListeners();
  }

  // ── POST /areas ──────────────────────────────────────────────────
  Future<bool> agregarArea(Area a) async {
    try {
      final creada = await _service.crearArea(a);
      final rellenada = _rellenarNombres([creada]).first;
      _areas.add(rellenada);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      _log('agregarArea', e);
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
      final rellenada = _rellenarNombres([actualizada]).first;
      final i = _areas.indexWhere((a) => a.id == id);
      if (i != -1) _areas[i] = rellenada;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      _log('actualizarArea', e);
      notifyListeners();
      return false;
    }
  }

  // ── PATCH /areas/{id}/progreso ───────────────────────────────────
  Future<bool> actualizarProgreso(int id, double progreso) async {
    try {
      final actualizada = await _service.actualizarProgreso(id, progreso);
      final rellenada = _rellenarNombres([actualizada]).first;
      final i = _areas.indexWhere((a) => a.id == id);
      if (i != -1) _areas[i] = rellenada;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      _log('actualizarProgreso', e);
      notifyListeners();
      return false;
    }
  }

  // ── PATCH /areas/{id}/estado ─────────────────────────────────────
  Future<bool> actualizarEstado(int id, String estado) async {
    try {
      final actualizada = await _service.actualizarEstado(id, estado);
      final rellenada = _rellenarNombres([actualizada]).first;
      final i = _areas.indexWhere((a) => a.id == id);
      if (i != -1) _areas[i] = rellenada;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      _log('actualizarEstado', e);
      notifyListeners();
      return false;
    }
  }

  // ── DELETE /areas/{id} ───────────────────────────────────────────
  Future<void> eliminarArea(Area area) async {
    if (area.id == null) {
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
      _log('eliminarArea', e);
      notifyListeners();
    }
  }

  /// 👇 ACTUALIZADO: filtra por parent_id contra el id del jefe logueado
  /// como respaldo, por si /employees no filtra bien en el backend. Si
  /// un empleado NO trae parent_id (viene null), se deja pasar (todavía
  /// no confirmamos si el backend siempre lo manda). Los prints muestran
  /// exactamente qué se descartó y por qué, para poder validarlo en vivo.
  Future<void> cargarEmpleadosDisponibles() async {
    try {
      final idUsuario = await _idUsuarioActualParaFiltro();
      final data = await _service.obtenerEmpleados();

      empleados = data.where((e) {
        final pid = e['parent_id'];
        final coincide = pid == null || '$pid' == '$idUsuario';
        if (!coincide) {
          debugPrint(
            '🚫 [AreaProvider] excluido empleado id=${e['id']} '
            'parent_id=$pid (jefe logueado=$idUsuario)',
          );
        }
        return coincide;
      }).toList();

      _log(
        'cargarEmpleadosDisponibles',
        'OK -> ${empleados.length}/${data.length} empleados (jefe=$idUsuario)',
      );
      notifyListeners();
    } catch (e) {
      error = 'No se pudieron cargar empleados: $e';
      _log('cargarEmpleadosDisponibles', e);
      notifyListeners();
    }
  }

  /// 👇 ACTUALIZADO: mismo filtro que cultivos — solo deja invernaderos
  /// cuyo user_id sea el del jefe logueado o el de alguno de sus
  /// empleados. Requiere que `empleados` ya esté cargado (ver el nuevo
  /// orden en `cargarDatosDeFormulario`).
  Future<void> cargarAreasDisponiblesParaFormulario() async {
    try {
      final idUsuario = await _idUsuarioActualParaFiltro();
      final data = await _service.obtenerInvernaderos();

      final idsPermitidos = <String>{
        '$idUsuario',
        ...empleados.map((e) => '${e['id']}'),
      };

      areasDisponibles = data.where((a) {
        final uid = a['user_id'];
        final coincide = uid == null || idsPermitidos.contains('$uid');
        if (!coincide) {
          debugPrint(
            '🚫 [AreaProvider] excluido invernadero id=${a['id']} '
            'user_id=$uid (permitidos=$idsPermitidos)',
          );
        }
        return coincide;
      }).toList();

      _log(
        'cargarAreasDisponiblesParaFormulario',
        'OK -> ${areasDisponibles.length}/${data.length} áreas (jefe=$idUsuario)',
      );
      notifyListeners();
    } catch (e) {
      error = 'No se pudieron cargar áreas: $e';
      _log('cargarAreasDisponiblesParaFormulario', e);
      notifyListeners();
    }
  }

  Future<int> _idUsuarioActualParaFiltro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id') ?? 0;
  }

  /// 👇 ACTUALIZADO: filtra cultivos por user_id, aceptando solo los que
  /// pertenecen al jefe logueado o a alguno de sus empleados (asumiendo
  /// que `empleados` YA está cargado antes de llamar este método — ver
  /// el nuevo orden en `cargarDatosDeFormulario`). Si un cultivo no trae
  /// user_id, se deja pasar (respaldo por si el campo no siempre viene).
  Future<void> cargarCultivosDisponibles() async {
    try {
      final idUsuario = await _idUsuarioActualParaFiltro();
      final data = await _service.obtenerCultivos();

      final idsPermitidos = <String>{
        '$idUsuario',
        ...empleados.map((e) => '${e['id']}'),
      };

      cultivos = data.where((c) {
        final uid = c['user_id'];
        final coincide = uid == null || idsPermitidos.contains('$uid');
        if (!coincide) {
          debugPrint(
            '🚫 [AreaProvider] excluido cultivo id=${c['id']} '
            'user_id=$uid (permitidos=$idsPermitidos)',
          );
        }
        return coincide;
      }).toList();

      _log(
        'cargarCultivosDisponibles',
        'OK -> ${cultivos.length}/${data.length} cultivos (jefe=$idUsuario)',
      );
      notifyListeners();
    } catch (e) {
      error = 'No se pudieron cargar cultivos: $e';
      _log('cargarCultivosDisponibles', e);
      notifyListeners();
    }
  }

  /// Carga empleados + áreas (+ intenta cultivos) en paralelo.
  /// Expone `cargandoDatosFormulario` para que la UI (el modal) pueda
  /// mostrar un loader mientras espera, en vez de abrirse con los
  /// dropdowns vacíos.
  ///
  /// 👇 Además, una vez cargados los catálogos, vuelve a rellenar los
  /// nombres de las áreas ya cargadas (`_areas`) por si llegaron antes
  /// que este método terminara.
  Future<void> cargarDatosDeFormulario({bool forzar = false}) async {
    if (cargandoDatosFormulario) return;
    if (datosFormularioCargados && !forzar) return;

    cargandoDatosFormulario = true;
    notifyListeners();

    // 👇 Empleados primero (sin await Future.wait): cargarCultivosDisponibles
    // necesita la lista `empleados` ya llena para poder filtrar por
    // user_id. Antes se cargaban los 3 en paralelo y cultivos siempre
    // llegaba con `empleados` vacío, por lo que nunca filtraba nada.
    await cargarEmpleadosDisponibles();

    await Future.wait([
      cargarAreasDisponiblesParaFormulario(),
      cargarCultivosDisponibles(),
    ]);

    // Si ya había áreas cargadas sin nombre, las rellenamos ahora
    // que tenemos los catálogos disponibles.
    if (_areas.isNotEmpty) {
      _areas = _rellenarNombres(_areas);
    }

    cargandoDatosFormulario = false;
    datosFormularioCargados = true;
    notifyListeners();
  }

  void _log(String metodo, Object mensaje) {
    if (kDebugMode) {
      debugPrint('[AreaProvider] $metodo -> $mensaje');
    }
  }
}
