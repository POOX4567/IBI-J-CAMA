class InvernaderoDetail {
  final int id;
  final String nombre;
  final String descripcion;
  final double longitud;
  final double latitud;
  final double ancho;
  final double alto;
  final double largo;
  final List<Cama> camas;

  InvernaderoDetail({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.longitud,
    required this.latitud,
    required this.ancho,
    required this.alto,
    required this.largo,
    required this.camas,
  });

  factory InvernaderoDetail.fromJson(Map<String, dynamic> json) {
    return InvernaderoDetail(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      longitud: double.tryParse(json['longitud'].toString()) ?? 0,
      latitud: double.tryParse(json['latitud'].toString()) ?? 0,
      ancho: double.tryParse(json['ancho'].toString()) ?? 0,
      alto: double.tryParse(json['alto'].toString()) ?? 0,
      largo: double.tryParse(json['largo'].toString()) ?? 0,
      camas: (json['camas'] as List<dynamic>? ?? [])
          .map((e) => Cama.fromJson(e))
          .toList(),
    );
  }
}

class Cama {
  final int id;
  final String nombre;
  final double largo;
  final double ancho;
  final List<Cultivo> cultivos;
  final List<Sensor> sensores;

  Cama({
    required this.id,
    required this.nombre,
    required this.largo,
    required this.ancho,
    required this.cultivos,
    required this.sensores,
  });

  factory Cama.fromJson(Map<String, dynamic> json) {
    return Cama(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      largo: double.tryParse(json['largo'].toString()) ?? 0,
      ancho: double.tryParse(json['ancho'].toString()) ?? 0,
      cultivos: (json['cultivos'] as List<dynamic>? ?? [])
          .map((e) => Cultivo.fromJson(e))
          .toList(),
      sensores: (json['sensores'] as List<dynamic>? ?? [])
          .map((e) => Sensor.fromJson(e))
          .toList(),
    );
  }
}

class Cultivo {
  final String nombre;

  Cultivo({
    required this.nombre,
  });

  factory Cultivo.fromJson(Map<String, dynamic> json) {
    return Cultivo(
      nombre: json['nombre'] ?? '',
    );
  }
}

class Sensor {
  final int id;
  final String nombre;
  final String modelo;
  final String descripcion;
  final String? lectura;

  Sensor({
    required this.id,
    required this.nombre,
    required this.modelo,
    required this.descripcion,
    required this.lectura,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      modelo: json['modelo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      lectura: json['ultima_lectura'] != null
          ? json['ultima_lectura']['peticion']?.toString()
          : null,
    );
  }
}