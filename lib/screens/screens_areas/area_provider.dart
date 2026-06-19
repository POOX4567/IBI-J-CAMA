import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // HIVE: lectura/escritura local
import 'package:fluttertoast/fluttertoast.dart'; // FLUTTERTOAST: mensajes de confirmación
import 'area.dart';
import 'area_data.dart';

/// PROVIDER: gestión de estado global para el módulo de Áreas.
/// Sincroniza filtros, búsquedas y datos entre pantallas.
class AreaProvider extends ChangeNotifier {
  List<Area> _areas = List<Area>.from(areasIniciales);
  String _filtroEstado = 'Todos';
  String _busqueda = '';

  static const _boxName = 'areas_box';

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

  void setFiltro(String estado) {
    _filtroEstado = estado;
    notifyListeners();
  }

  void setBusqueda(String texto) {
    _busqueda = texto;
    notifyListeners();
  }

  void agregarArea(Area a) {
    _areas.add(a);
    _guardarEnHive(a);
    // FLUTTERTOAST: confirmación al agregar área
    Fluttertoast.showToast(
      msg: 'Área "${a.area}" agregada correctamente',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xff1B5E20),
      textColor: Colors.white,
    );
    notifyListeners();
  }

  void eliminarArea(String areaName) {
    _areas.removeWhere((a) => a.area == areaName);
    _eliminarDeHive(areaName);
    // FLUTTERTOAST: confirmación al eliminar área
    Fluttertoast.showToast(
      msg: 'Área "$areaName" eliminada',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    notifyListeners();
  }

  // HIVE: persiste un área localmente para uso sin conexión
  Future<void> _guardarEnHive(Area a) async {
    final box = await Hive.openBox<Area>(_boxName);
    await box.put(a.area, a);
  }

  // HIVE: elimina un área del almacenamiento local
  Future<void> _eliminarDeHive(String areaName) async {
    final box = await Hive.openBox<Area>(_boxName);
    await box.delete(areaName);
  }

  /// HIVE: carga áreas guardadas localmente (útil sin conexión)
  Future<void> cargarDesdeHive() async {
    final box = await Hive.openBox<Area>(_boxName);
    if (box.isNotEmpty) {
      _areas = box.values.toList();
      notifyListeners();
    }
  }
}
