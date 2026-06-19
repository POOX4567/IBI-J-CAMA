import 'package:flutter/material.dart';
import 'horario.dart';
import 'horario_data.dart';

/// PROVIDER: gestión de estado global para el módulo de Horarios.
/// Sincroniza cambios de turnos, filtros y datos mostrados en pantalla.
class HorarioProvider extends ChangeNotifier {
  List<Horario> _horarios = List<Horario>.from(horariosIniciales);
  String _filtroTurno = 'Todos';

  List<Horario> get horarios => _filtroTurno == 'Todos'
      ? _horarios
      : _horarios
            .where(
              (h) => h.turno.toLowerCase().contains(_filtroTurno.toLowerCase()),
            )
            .toList();

  String get filtroTurno => _filtroTurno;

  void setFiltroTurno(String turno) {
    _filtroTurno = turno;
    notifyListeners();
  }

  void agregarHorario(Horario h) {
    _horarios.add(h);
    notifyListeners();
  }

  void eliminarHorario(String nombre) {
    _horarios.removeWhere((h) => h.nombre == nombre);
    notifyListeners();
  }

  /// Actualiza la hora de entrada de un horario por nombre
  void actualizarEntrada(String nombre, String nuevaEntrada) {
    final index = _horarios.indexWhere((h) => h.nombre == nombre);
    if (index == -1) return;
    final h = _horarios[index];
    _horarios[index] = Horario(
      nombre: h.nombre,
      turno: h.turno,
      actividad: h.actividad,
      entrada: nuevaEntrada,
      salida: h.salida,
      fechaInicio: h.fechaInicio,
      fechaFin: h.fechaFin,
    );
    notifyListeners();
  }

  /// Actualiza la hora de salida de un horario por nombre
  void actualizarSalida(String nombre, String nuevaSalida) {
    final index = _horarios.indexWhere((h) => h.nombre == nombre);
    if (index == -1) return;
    final h = _horarios[index];
    _horarios[index] = Horario(
      nombre: h.nombre,
      turno: h.turno,
      actividad: h.actividad,
      entrada: h.entrada,
      salida: nuevaSalida,
      fechaInicio: h.fechaInicio,
      fechaFin: h.fechaFin,
    );
    notifyListeners();
  }

  /// Busca un horario por nombre (para reflejar cambios en detalle)
  Horario? obtenerHorario(String nombre) {
    try {
      return _horarios.firstWhere((h) => h.nombre == nombre);
    } catch (_) {
      return null;
    }
  }
}
