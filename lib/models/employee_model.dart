class Employee {
  final int id;
  final String nombre;
  final String correo;
  final String? imagen;
  final String rol;
  final String estadoLaboral;

  Employee({
    required this.id,
    required this.nombre,
    required this.correo,
    this.imagen,
    required this.rol,
    required this.estadoLaboral,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: int.parse(json['id'].toString()),
      nombre: json['nombre'].toString(),
      correo: json['correo'].toString(),
      imagen: json['imagen']?.toString(),
      rol: json['rol'].toString(),
      estadoLaboral: json['estado_laboral']?.toString() ?? 'Activo',
    );
  }
}
