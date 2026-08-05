class Invernadero {
  final int id;
  final String nombre;
  final double longitud;
  final double latitud;
  final double ancho;
  final double alto;
  final double largo;
  final String descripcion;

  Invernadero({
    required this.id,
    required this.nombre,
    required this.longitud,
    required this.latitud,
    required this.ancho,
    required this.alto,
    required this.largo,
    required this.descripcion,
  });

  factory Invernadero.fromJson(Map<String, dynamic> json) {
    return Invernadero(
      id: int.parse(json['id'].toString()),
      nombre: json['nombre'].toString(),
      longitud: double.parse(json['longitud'].toString()),
      latitud: double.parse(json['latitud'].toString()),
      ancho: double.parse(json['ancho'].toString()),
      alto: double.parse(json['alto'].toString()),
      largo: double.parse(json['largo'].toString()),
      descripcion: json['descripcion']?.toString() ?? '',
    );
  }
}