import 'package:flutter/material.dart';
import '../models/notificacion_model.dart';

class NotificationProvider extends ChangeNotifier {
  // Lista inicial estática (Hardcoded de prueba)
  final List<NotificacionModel> _notificaciones = [
    NotificacionModel(
      id: "1",
      titulo: "Temperatura Alta - Invernadero 2",
      detalle: "La temperatura alcanzó los 38°C a las 08:30 AM.",
      fecha: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificacionModel(
      id: "2",
      titulo: "Falla de Riego - Zona Norte",
      detalle: "Pérdida de presión detectada en sector 3.",
      fecha: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  // Getters públicos
  List<NotificacionModel> get todas => _notificaciones;

  // Cuenta cuántas notificaciones no han sido leídas
  int get conteoNoLeidas => _notificaciones.where((n) => !n.leida).length;

  /// Agregar una nueva notificación estática a la lista
  void agregarNotificacion(String titulo, String detalle) {
    final nueva = NotificacionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      detalle: detalle,
      fecha: DateTime.now(),
    );
    _notificaciones.insert(0, nueva); // Insertar al inicio de la lista
    notifyListeners(); // Actualiza la UI de inmediato
  }

  /// Marcar una notificación específica como leída
  void marcarComoLeida(String id) {
    final index = _notificaciones.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notificaciones[index] = _notificaciones[index].copyWith(leida: true);
      notifyListeners();
    }
  }

  /// Limpiar o vaciar todo el historial
  void limpiarHistorial() {
    _notificaciones.clear();
    notifyListeners();
  }
}
