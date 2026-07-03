class Invernadero {
  final int id;
  final String nombre;
  final double longitud;
  final double latitud;
  final String descripcion;

  Invernadero({
    required this.id,
    required this.nombre,
    required this.longitud,
    required this.latitud,
    required this.descripcion,
  });

  factory Invernadero.fromJson(Map<String, dynamic> json) {
    return Invernadero(
      id: json['id'],
      nombre: json['nombre'],
      // Parsemos a double porque la API los devuelve como String ("20.12345678")
      longitud: double.parse(json['longitud'].toString()),
      latitud: double.parse(json['latitud'].toString()),
      descripcion: json['descripcion'] ?? '',
    );
  }
}
