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
      id: int.parse(json['id'].toString()),
      nombre: json['nombre'].toString(),
      numeroSerie: json['numero_serie'].toString(),
      modelo: json['modelo'].toString(),
      descripcion: json['descripcion'].toString(),
      topic: json['topic']?.toString(),
      tipoSensorId: int.parse(json['tipo_sensor_id'].toString()),
      estadoId: int.parse(json['estado_id'].toString()),
      cultivoId: int.parse(json['cultivo_id'].toString()),
    );
  }
}
