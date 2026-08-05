import 'dart:async';
import 'package:ibi/models/production_model.dart'; // Reemplaza 'ibi' por el nombre de tu app

class ProductionService {
  Future<List<ProductionModel>> fetchProductionData() async {
    // Simulación de retraso de red de 1 segundo
    await Future.delayed(const Duration(milliseconds: 1000));

    final List<Map<String, dynamic>> rawData = [
      {
        "ubicacion": "Z-A C1",
        "cultivo": "Jícama",
        "produccionKg": 500.0,
        "temperatura": 26.5,
        "humedad": 45.0,
        "estado": "Estable",
        "encargado": "Juan Pérez",
        "tel": "999 123 4567",
      },
      {
        "ubicacion": "Z-A C2",
        "cultivo": "Jícama",
        "produccionKg": 450.0,
        "temperatura": 27.1,
        "humedad": 48.0,
        "estado": "Estable",
        "encargado": "Juan Pérez",
        "tel": "999 123 4567",
      },
      {
        "ubicacion": "Z-A C3",
        "cultivo": "Tomate",
        "produccionKg": 250.0,
        "temperatura": 29.4,
        "humedad": 35.0,
        "estado": "Advertencia",
        "encargado": "Juan Pérez",
        "tel": "999 123 4567",
      },
      {
        "ubicacion": "Z-B C1",
        "cultivo": "Jícama",
        "produccionKg": 310.0,
        "temperatura": 31.2,
        "humedad": 32.0,
        "estado": "Advertencia",
        "encargado": "Marcos Chan",
        "tel": "999 555 7812",
      },
      {
        "ubicacion": "Z-B C3",
        "cultivo": "Tomate",
        "produccionKg": 420.0,
        "temperatura": 28.7,
        "humedad": 41.0,
        "estado": "Estable",
        "encargado": "Marcos Chan",
        "tel": "999 555 7812",
      },
      {
        "ubicacion": "Z-C C1",
        "cultivo": "Jícama",
        "produccionKg": 180.0,
        "temperatura": 34.8,
        "humedad": 25.0,
        "estado": "Crítico",
        "encargado": "Elena Vance",
        "tel": "999 777 9012",
      },
    ];

    return rawData.map((json) => ProductionModel.fromMap(json)).toList();
  }
}
