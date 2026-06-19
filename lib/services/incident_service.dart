import 'dart:async';
import 'package:ibi/models/incident_model.dart'; // Ajusta "ibi" al nombre de tu proyecto

class IncidentService {
  // Simulación de respuesta de base de datos / API REST
  Future<List<IncidentModel>> fetchIncidents() async {
    // Simulamos un retraso de red de 1.2 segundos
    await Future.delayed(const Duration(milliseconds: 1200));

    final List<Map<String, dynamic>> rawIncidents = [
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

    // Mapeamos los datos crudos a nuestra lista de modelos robustos
    return rawIncidents.map((json) => IncidentModel.fromMap(json)).toList();
  }
}
