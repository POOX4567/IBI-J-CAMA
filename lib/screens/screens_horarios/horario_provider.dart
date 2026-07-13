import 'package:flutter/material.dart';
import 'horario.dart';
import 'horario_service.dart';

class HorarioProvider extends ChangeNotifier {
  final HorarioService _service = HorarioService();

  List<Horario> _horarios = [];
  List<Map<String, dynamic>> _empleados = [];
  String _filtroTurno = 'Todos';
  bool isLoading = false;
  String? error;
  int? _totalHorariosActivos;
  int? _totalEmpleados;
  int? _totalTurnosRegistrados;

  List<Horario> get horarios => _horarios;
  List<Map<String, dynamic>> get empleados => _empleados;

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

  /// Recorre una lista de horarios y, para aquellos cuyo nombre venga vacío
  /// o como 'Sin nombre' (porque el backend no incluyó la relación de
  /// empleado en ese endpoint), rellena el nombre cruzando por empleadoId
  /// contra la lista de empleados ya cargada.
  List<Horario> _rellenarNombres(List<Horario> lista) {
    if (_empleados.isEmpty) return lista;
    debugPrint('DEBUG empleados: $_empleados');
    return lista.map((h) {
      debugPrint(
        'DEBUG horario id=${h.id} empleadoId=${h.empleadoId} nombreActual=${h.nombre}',
      );
      final necesitaNombre = h.nombre.isEmpty || h.nombre == 'Sin nombre';
      if (!necesitaNombre) return h;
      final nombreReal = _nombrePorEmpleadoId(h.empleadoId);
      debugPrint(
        'DEBUG nombreReal para empleadoId=${h.empleadoId}: $nombreReal',
      );
      if (nombreReal != null) return h.copyWith(nombre: nombreReal);
      return h;
    }).toList();
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
      // Aseguramos tener la lista de empleados fresca para poder
      // rellenar nombres si el backend no los trae en este endpoint.
      if (_empleados.isEmpty) {
        await cargarEmpleados();
      }
      final lista = await _service.obtenerHorarios();
      _horarios = _rellenarNombres(lista);
      await cargarEstadisticas();
    } catch (e) {
      error = e.toString();
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
      final lista = await _service.horariosPorTurno(turno);
      _horarios = _rellenarNombres(lista);
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

  Future<void> agregarHorario(Horario h) async {
    final creado = await _service.crearHorario(h);
    final nombreReal = _nombrePorEmpleadoId(creado.empleadoId);
    _horarios.add(
      nombreReal != null ? creado.copyWith(nombre: nombreReal) : creado,
    );
    notifyListeners();
  }

  Future<bool> crearNuevoHorario({
    required int empleadoId,
    required String nombre,
    required String turno,
    required String actividad,
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
        actividad: actividad,
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
    required String actividad,
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
        actividad: actividad,
        entrada: horaEntrada,
        salida: horaSalida,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );

      final actualizado = await _service.actualizarHorario(id, horarioEditado);
      final nombreReal = _nombrePorEmpleadoId(actualizado.empleadoId);

      final index = _horarios.indexWhere((h) => h.id == id);
      if (index != -1) {
        _horarios[index] = nombreReal != null
            ? actualizado.copyWith(nombre: nombreReal)
            : actualizado;
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
