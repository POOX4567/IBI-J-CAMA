class Invernadero {
  final int id;
  final int userId;
  final String nombre;
  final String longitud;
  final String latitud;
  final String ancho;
  final String alto;
  final String largo;
  final String descripcion;

  Invernadero({
    required this.id,
    required this.userId,
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
      id: json['id'],
      userId: json['user_id'],
      nombre: json['nombre'],
      longitud: json['longitud'],
      latitud: json['latitud'],
      ancho: json['ancho'],
      alto: json['alto'],
      largo: json['largo'],
      descripcion: json['descripcion'],
    );
  }
}