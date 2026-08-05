class Alerta {
  final String titulo;
  final String severidad;
  final String estado;
  final String invernadero;

  Alerta({
    required this.titulo,
    required this.severidad,
    required this.estado,
    required this.invernadero,
  });

  factory Alerta.fromJson(Map<String, dynamic> json) {
    return Alerta(
      titulo: json['titulo'] ?? '',
      severidad: json['severidad'] ?? '',
      estado: json['estado'] ?? '',
      invernadero: json['invernadero'] ?? '',
    );
  }
}