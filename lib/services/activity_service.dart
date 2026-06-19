import 'dart:async';
import 'package:ibi/models/activity_model.dart';

class ActivityService {
  // Simula la obtención de datos (Hoy local, mañana desde Mongo/API con Dio)
  Future<List<ActivityModel>> fetchActivities() async {
    // Simulamos un retraso de red de 1 segundo para que sea realista
    await Future.delayed(const Duration(seconds: 1));

    final List<Map<String, dynamic>> rawData = [
      {
        "actividad": "Revisión de extractor de aire",
        "progreso": "Completado",
        "zona": "Zona A",
        "encargado": "Juan Pérez",
        "detalle":
            "Mantenimiento preventivo completado en la Cama 3 para regular el flujo de aire.",
      },
      {
        "actividad": "Calibración de sensores térmicos",
        "progreso": "En proceso",
        "zona": "Zona C",
        "encargado": "Elena Vance",
        "detalle":
            "Ajuste fino del hardware tras registrar alertas de temperatura crítica (35°C).",
      },
      {
        "actividad": "Monitoreo de aspersores hidráulicos",
        "progreso": "Completado",
        "zona": "Zona A",
        "encargado": "Ana Torres",
        "detalle":
            "Prueba de presión superada con éxito en las tuberías principales.",
      },
      {
        "actividad": "Reconexión de sensor de humedad",
        "progreso": "Pendiente",
        "zona": "Zona A",
        "encargado": "Marcos Chan",
        "detalle":
            "Falla técnica crítica detectada. El sensor sigue sin emitir señal en la Cama 1.",
      },
      {
        "actividad": "Checklist de supervisión diaria",
        "progreso": "Completado",
        "zona": "Zona B",
        "encargado": "Marcos Chan",
        "detalle":
            "Inspección de rutina cerrada. Nota: Se reporta humedad baja general del 28%.",
      },
    ];

    // Convertimos la lista de mapas en una lista de objetos ActivityModel
    return rawData.map((json) => ActivityModel.fromMap(json)).toList();
  }
}
