import 'sensor_iot_model.dart';

class LecturaSensor {
  final int id;
  final int sensorId;
  final String lecturaDatetime;
  final String valor;
  final SensorIot? sensor;

  LecturaSensor({
    required this.id,
    required this.sensorId,
    required this.lecturaDatetime,
    required this.valor,
    this.sensor,
  });

  factory LecturaSensor.fromJson(Map<String, dynamic> json) {
    return LecturaSensor(
      id: json['id'],
      sensorId: json['sensor_id'],
      lecturaDatetime: json['lectura_datetime'],
      valor: json['valor'].toString(),
      sensor: json['sensor'] != null
          ? SensorIot.fromJson(json['sensor'])
          : null,
    );
  }
}
