class LecturaSensor {
  final int id;
  final int sensorId;
  final String lecturaDatetime;
  final String valor;

  final String nombreSensor;
  final String modelo;
  final String descripcion;

  LecturaSensor({
    required this.id,
    required this.sensorId,
    required this.lecturaDatetime,
    required this.valor,
    required this.nombreSensor,
    required this.modelo,
    required this.descripcion,
  });

  factory LecturaSensor.fromJson(Map<String, dynamic> json) {
    return LecturaSensor(
      id: json['id'],
      sensorId: json['sensor_id'],
      lecturaDatetime: json['lectura_datetime'],
      valor: json['valor'],
      nombreSensor: json['sensor']['nombre'],
      modelo: json['sensor']['modelo'],
      descripcion: json['sensor']['descripcion'],
    );
  }
}