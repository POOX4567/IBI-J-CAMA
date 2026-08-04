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
      id: int.parse(json['id'].toString()),
      sensorId: int.parse(json['sensor_id'].toString()),
      lecturaDatetime: json['lectura_datetime'].toString(),
      valor: json['peticion'].toString(),
      sensor: json['sensor'] != null
          ? SensorIot.fromJson(json['sensor'])
          : null,
    );
  }
}
