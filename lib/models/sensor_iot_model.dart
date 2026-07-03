class SensorIot {
  final int id;
  final String nombre;
  final String numeroSerie;
  final String modelo;
  final String descripcion;
  final String? topic;
  final int tipoSensorId;
  final int estadoId;
  final int cultivoId;

  SensorIot({
    required this.id,
    required this.nombre,
    required this.numeroSerie,
    required this.modelo,
    required this.descripcion,
    this.topic,
    required this.tipoSensorId,
    required this.estadoId,
    required this.cultivoId,
  });

  factory SensorIot.fromJson(Map<String, dynamic> json) {
    return SensorIot(
      id: json['id'],
      nombre: json['nombre'],
      numeroSerie: json['numero_serie'],
      modelo: json['modelo'],
      descripcion: json['descripcion'],
      topic: json['topic'],
      tipoSensorId: json['tipo_sensor_id'],
      estadoId: json['estado_id'],
      cultivoId: json['cultivo_id'],
    );
  }
}
