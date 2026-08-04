// lib/data/mock_data.dart
import '../models/maintenance_model.dart';

class MaintenanceRequest {
  final String id;
  final String title;
  final String greenhouse;
  String priority;
  String status;
  final String description;
  final String reportedBy;
  String? assignedTo;
  final DateTime reportedDate;
  final String? device;

  MaintenanceRequest({
    required this.id,
    required this.title,
    required this.greenhouse,
    required this.priority,
    required this.status,
    required this.description,
    required this.reportedBy,
    this.assignedTo,
    required this.reportedDate,
    this.device,
  });

  factory MaintenanceRequest.fromMaintenanceModel(MaintenanceModel model) {
    return MaintenanceRequest(
      id: model.id.toString(),
      title: model.titulo,
      greenhouse: model.invernadero,
      priority: model.tipo,
      status: model.estado,
      description: model.descripcion,
      reportedBy: 'API',
      assignedTo: null,
      reportedDate: model.createdAt ?? DateTime.now(),
      device: null,
    );
  }
}

class IotDevice {
  final String id;
  final String name;
  final String type;
  final String status;
  final String greenhouse;
  final int? batteryLevel;
  final String? lastReading;

  const IotDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.greenhouse,
    this.batteryLevel,
    this.lastReading,
  });
}

class FailureStat {
  final String id;
  final String type;
  final int count;
  final double percentage;

  const FailureStat({
    required this.id,
    required this.type,
    required this.count,
    required this.percentage,
  });
}

// Datos estáticos
final List<MaintenanceRequest> mockMaintenanceRequests = [
  MaintenanceRequest(
    id: "REQ-001",
    title: "Fallo en bomba de riego",
    greenhouse: "Invernadero Poniente",
    priority: "alta",
    status: "pendiente",
    description:
        "La bomba principal del sector 4 no está presurizando el agua correctamente. Se detectó una caída de presión del 40%.",
    reportedBy: "Carlos López",
    reportedDate: DateTime.now().subtract(const Duration(hours: 2)),
    device: "Bomba-Agua-04",
  ),
  MaintenanceRequest(
    id: "REQ-002",
    title: "Calibración de sensor T/H",
    greenhouse: "Sector Casa Rural",
    priority: "media",
    status: "en_progreso",
    description:
        "El sensor muestra lecturas de humedad anormalmente altas (99%) de forma constante. Requiere limpieza y recalibración.",
    reportedBy: "Ana Martínez",
    assignedTo: "Juan Pérez",
    reportedDate: DateTime.now().subtract(const Duration(days: 1)),
    device: "Sensor-TH-02",
  ),
  MaintenanceRequest(
    id: "REQ-003",
    title: "Revisión de panel solar",
    greenhouse: "Invernadero Norte",
    priority: "baja",
    status: "completada",
    description:
        "Limpieza rutinaria del panel solar que alimenta el controlador principal del sector.",
    reportedBy: "Sistema Automatizado",
    assignedTo: "Roberto Gómez",
    reportedDate: DateTime.now().subtract(const Duration(days: 3)),
  ),
];

final List<IotDevice> mockIotDevices = [
  const IotDevice(
    id: "DEV-101",
    name: "Sensor Temp/Hum Principal",
    type: "sensor_temperatura",
    status: "operativo",
    greenhouse: "Invernadero Poniente",
    batteryLevel: 85,
    lastReading: "24.5°C / 65%",
  ),
  const IotDevice(
    id: "DEV-102",
    name: "Válvula Sector 2",
    type: "actuador_riego",
    status: "falla",
    greenhouse: "Invernadero Norte",
    batteryLevel: 12,
    lastReading: "Cerrada (Error)",
  ),
  const IotDevice(
    id: "DEV-103",
    name: "Controlador Central",
    type: "controlador",
    status: "mantenimiento",
    greenhouse: "Sector Casa Rural",
    lastReading: "Modo Servicio",
  ),
  const IotDevice(
    id: "DEV-104",
    name: "Sensor de Luz Nivel 1",
    type: "sensor_luz",
    status: "operativo",
    greenhouse: "Invernadero Poniente",
    batteryLevel: 95,
    lastReading: "45000 lux",
  ),
];

final List<FailureStat> mockFailureStats = [
  const FailureStat(
    id: "FS-1",
    type: "Batería agotada",
    count: 12,
    percentage: 30,
  ),
  const FailureStat(
    id: "FS-2",
    type: "Pérdida de conexión",
    count: 8,
    percentage: 20,
  ),
  const FailureStat(
    id: "FS-3",
    type: "Sensor descalibrado",
    count: 7,
    percentage: 17.5,
  ),
  const FailureStat(id: "FS-4", type: "Daño físico", count: 6, percentage: 15),
  const FailureStat(
    id: "FS-5",
    type: "Falla de software",
    count: 5,
    percentage: 12.5,
  ),
  const FailureStat(id: "FS-6", type: "Otros", count: 2, percentage: 5),
];

class MaintenanceRecord {
  final String id;
  final String deviceName;
  final String deviceId;
  final double cost;
  final String type;
  final String description;
  final List<String> parts;
  final String performedBy;
  final DateTime date;

  const MaintenanceRecord({
    required this.id,
    required this.deviceName,
    required this.deviceId,
    required this.cost,
    required this.type,
    required this.description,
    this.parts = const [],
    required this.performedBy,
    required this.date,
  });
}

// Datos basados en tu imagen
final List<MaintenanceRecord> mockMaintenanceHistory = [
  MaintenanceRecord(
    id: "MH-01",
    deviceName: "Sensor Temperatura 09",
    deviceId: "ST-09",
    cost: 25.50,
    type: "Reemplazo de batería",
    description: "Reemplazo de batería agotada",
    parts: ["Batería Li-ion 3.7V"],
    performedBy: "Carlos Ruiz",
    date: DateTime(2026, 5, 10), // 10 may
  ),
  MaintenanceRecord(
    id: "MH-02",
    deviceName: "Actuador Riego 03",
    deviceId: "AR-03",
    cost: 120.00,
    type: "Reparación de válvula",
    description:
        "Limpieza y reemplazo de empaques por obstrucción en la salida principal",
    parts: ["Empaques de goma", "Válvula solenoide 12V"],
    performedBy: "Ana Martínez",
    date: DateTime(2026, 5, 8), // 8 may
  ),
];
