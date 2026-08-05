import 'package:flutter/material.dart';
import 'horario.dart';
import 'horario_service.dart';

class HorarioProvider extends ChangeNotifier {
  final HorarioService _service = HorarioService();

  List<Horario> _horarios = [];
  List<Map<String, dynamic>> _empleados = [];
  List<Map<String, dynamic>> _actividades = []; // 👈 NUEVO
  String _filtroTurno = 'Todos';
  bool isLoading = false;
  String? error;
  int? _totalHorariosActivos;
  int? _totalEmpleados;
  int? _totalTurnosRegistrados;

  List<Horario> get horarios => _horarios;
  List<Map<String, dynamic>> get empleados => _empleados;
  List<Map<String, dynamic>> get actividades => _actividades; // 👈 NUEVO

  String get filtroTurno => _filtroTurno;
  int get totalHorariosActivos => _totalHorariosActivos ?? _horarios.length;
  int get totalEmpleadosCount =>
      _totalEmpleados ?? _horarios.map((h) => h.empleadoId).toSet().length;
  int get totalTurnosRegistrados =>
      _totalTurnosRegistrados ?? _horarios.map((h) => h.turno).toSet().length;

  /// Busca el nombre del empleado en la lista ya cargada (`_empleados`)
  /// usando el `empleadoId`. Devuelve null si no lo encuentra.
  String? _nombrePorEmpleadoId(int empleadoId) {
    final match = _empleados.firstWhere(
      (e) => '${e['id']}' == '$empleadoId',
      orElse: () => {},
    );
    if (match.isNotEmpty && match['name'] != null) {
      final nombre = match['name'].toString().trim();
      if (nombre.isNotEmpty) return nombre;
    }
    return null;
  }

  /// 👇 NUEVO: igual que `_nombrePorEmpleadoId` pero para actividades.
  /// Sirve para rellenar `actividadNombre` cuando el backend no manda la
  /// relación anidada ('activity') en el listado de horarios.
  String? _nombrePorActivityId(int activityId) {
    final match = _actividades.firstWhere(
      (a) => '${a['id']}' == '$activityId',
      orElse: () => {},
    );
    if (match.isNotEmpty && match['name'] != null) {
      final nombre = match['name'].toString().trim();
      if (nombre.isNotEmpty) return nombre;
    }
    return null;
  }

  /// Recorre una lista de horarios y, para aquellos cuyo nombre venga vacío
  /// o como 'Sin nombre' (porque el backend no incluyó la relación de
  /// empleado en ese endpoint), rellena el nombre cruzando por empleadoId
  /// contra la lista de empleados ya cargada. También rellena el nombre
  /// de la actividad cruzando por activityId.
  List<Horario> _rellenarNombres(List<Horario> lista) {
    return lista.map((h) {
      var horario = h;

      final necesitaNombreEmpleado =
          horario.nombre.isEmpty || horario.nombre == 'Sin nombre';
      if (necesitaNombreEmpleado && _empleados.isNotEmpty) {
        final nombreReal = _nombrePorEmpleadoId(horario.empleadoId);
        if (nombreReal != null) horario = horario.copyWith(nombre: nombreReal);
      }

      final necesitaNombreActividad = horario.actividadNombre.isEmpty;
      if (necesitaNombreActividad && _actividades.isNotEmpty) {
        final actividadReal = _nombrePorActivityId(horario.activityId);
        if (actividadReal != null) {
          horario = horario.copyWith(actividadNombre: actividadReal);
        }
      }

      return horario;
    }).toList();
  }

  List<Horario> _filtrarPorMisEmpleados(List<Horario> lista) {
    if (_empleados.isEmpty) return lista;
    final idsPermitidos = _empleados.map((e) => '${e['id']}').toSet();
    return lista
        .where((h) => idsPermitidos.contains('${h.empleadoId}'))
        .toList();
  }

  void setFiltroTurno(String turno) {
    _filtroTurno = turno;
    notifyListeners();
    if (turno == 'Todos') {
      cargarHorarios();
    } else {
      cargarHorariosPorTurno(turno);
    }
  }

  /// Carga los horarios reales desde la tabla `horarios`
  Future<void> cargarHorarios() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      if (_empleados.isEmpty) {
        await cargarEmpleados();
      }
      if (_actividades.isEmpty) {
        await cargarActividades();
      }
      final lista = await _service.obtenerHorarios();
      final conNombres = _rellenarNombres(lista);
      _horarios = _filtrarPorMisEmpleados(conNombres); // ← NUEVO
      await cargarEstadisticas();
    } catch (e) {
      error = e.toString();
      debugPrint('❌ Error en cargarHorarios: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> cargarHorariosPorTurno(String turno) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      if (_empleados.isEmpty) {
        await cargarEmpleados();
      }
      if (_actividades.isEmpty) {
        await cargarActividades();
      }
      final lista = await _service.horariosPorTurno(turno);
      final conNombres = _rellenarNombres(lista);
      _horarios = _filtrarPorMisEmpleados(conNombres); // ← NUEVO
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> cargarEstadisticas() async {
    try {
      final stats = await _service.obtenerEstadisticas();
      _totalHorariosActivos = stats['total_horarios_activos'];
      _totalEmpleados = stats['total_empleados'];
      _totalTurnosRegistrados = stats['total_turnos_registrados'];
    } catch (e) {
      error = e.toString();
    }
  }

  Future<void> cargarEmpleados() async {
    try {
      _empleados = await _service.obtenerEmpleados();
      // Si ya había horarios cargados sin nombre, los rellenamos ahora
      // que tenemos la lista de empleados disponible.
      if (_horarios.isNotEmpty) {
        _horarios = _rellenarNombres(_horarios);
      }
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  /// 👇 NUEVO: carga la lista de actividades desde /activities.
  /// Se usa para poblar el dropdown de actividad en el formulario y para
  /// resolver 'actividadNombre' cuando el backend no la manda anidada.
  Future<void> cargarActividades() async {
    try {
      _actividades = await _service.obtenerActividades();
      if (_horarios.isNotEmpty) {
        _horarios = _rellenarNombres(_horarios);
      }
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> agregarHorario(Horario h) async {
    final creado = await _service.crearHorario(h);
    final nombreReal = _nombrePorEmpleadoId(creado.empleadoId);
    final actividadReal = _nombrePorActivityId(creado.activityId);
    _horarios.add(
      creado.copyWith(nombre: nombreReal, actividadNombre: actividadReal),
    );
    notifyListeners();
  }

  Future<bool> crearNuevoHorario({
    required int empleadoId,
    required String nombre,
    required String turno,
    required int activityId, // 👈 antes era 'actividad' (String)
    required String fechaInicio,
    required String fechaFin,
    required String horaEntrada,
    required String horaSalida,
  }) async {
    try {
      final horario = Horario(
        empleadoId: empleadoId,
        nombre: nombre,
        turno: turno,
        activityId: activityId,
        entrada: horaEntrada,
        salida: horaSalida,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      await agregarHorario(horario);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Actualiza TODOS los campos de un horario existente (usado por el
  /// formulario de edición en HorarioFormScreen). A diferencia de
  /// `actualizarEntrada` / `actualizarSalida`, este método permite cambiar
  /// empleado, turno, actividad, fechas y horas en una sola llamada.
  Future<bool> actualizarHorarioCompleto({
    required int id,
    required int empleadoId,
    required String nombre,
    required String turno,
    required int activityId, // 👈 antes era 'actividad' (String)
    required String fechaInicio,
    required String fechaFin,
    required String horaEntrada,
    required String horaSalida,
  }) async {
    try {
      final actual = _horarios.firstWhere((h) => h.id == id);
      final horarioEditado = actual.copyWith(
        empleadoId: empleadoId,
        nombre: nombre,
        turno: turno,
        activityId: activityId,
        entrada: horaEntrada,
        salida: horaSalida,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );

      final actualizado = await _service.actualizarHorario(id, horarioEditado);
      final nombreReal = _nombrePorEmpleadoId(actualizado.empleadoId);
      final actividadReal = _nombrePorActivityId(actualizado.activityId);

      final index = _horarios.indexWhere((h) => h.id == id);
      if (index != -1) {
        _horarios[index] = actualizado.copyWith(
          nombre: nombreReal,
          actividadNombre: actividadReal,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> eliminarHorario(int id) async {
    await _service.eliminarHorario(id);
    _horarios.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  Future<void> actualizarEntrada(int id, String nuevaEntrada) async {
    final h = _horarios.firstWhere((h) => h.id == id);
    final actualizado = await _service.actualizarHorario(
      id,
      h.copyWith(entrada: nuevaEntrada),
    );
    final nombreReal = _nombrePorEmpleadoId(actualizado.empleadoId);
    _horarios[_horarios.indexWhere((h) => h.id == id)] = nombreReal != null
        ? actualizado.copyWith(nombre: nombreReal)
        : actualizado;
    notifyListeners();
  }

  Future<void> actualizarSalida(int id, String nuevaSalida) async {
    final h = _horarios.firstWhere((h) => h.id == id);
    final actualizado = await _service.actualizarHorario(
      id,
      h.copyWith(salida: nuevaSalida),
    );
    final nombreReal = _nombrePorEmpleadoId(actualizado.empleadoId);
    _horarios[_horarios.indexWhere((h) => h.id == id)] = nombreReal != null
        ? actualizado.copyWith(nombre: nombreReal)
        : actualizado;
    notifyListeners();
  }

  Horario? obtenerHorario(int id) {
    try {
      return _horarios.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }
}
