import 'dart:async';
import 'package:ibi/models/maintenance_model.dart'; // Cambia 'ibi' por el name de tu app

class MaintenanceService {
  Future<List<MaintenanceModel>> fetchMaintenanceTasks() async {
    // Simulando consulta a la base de datos (1.2 segundos de delay)
    await Future.delayed(const Duration(milliseconds: 1200));

    final List<Map<String, dynamic>> rawData = [
      {
        "title": "Falla en sistema eléctrico",
        "severity": "Alta",
        "status": "Abierto",
        "area": "Invernadero Norte",
      },
      {
        "title": "Sensor de humedad desconectado",
        "severity": "Media",
        "status": "En proceso",
        "area": "Invernadero Sur",
      },
      {
        "title": "Fuga de agua detectada",
        "severity": "Alta",
        "status": "Abierto",
        "area": "Zona de riego",
      },
      {
        "title": "Mantenimiento preventivo",
        "severity": "Baja",
        "status": "Resuelto",
        "area": "Área general",
      },
      {
        "title": "Temperatura fuera de rango",
        "severity": "Media",
        "status": "En proceso",
        "area": "Invernadero Este",
      },
    ];

    return rawData.map((json) => MaintenanceModel.fromMap(json)).toList();
  }
}
