class ElementoEstado {
  final int id;
  final int invernaderoId;
  final int numero;
  final String elemento;
  final String? topic;
  final int estadoId;
  final int moduloId;
  final String ubicacion;
  final String estadoNombre;

  ElementoEstado({
    required this.id,
    required this.invernaderoId,
    required this.numero,
    required this.elemento,
    this.topic,
    required this.estadoId,
    required this.moduloId,
    required this.ubicacion,
    required this.estadoNombre,
  });

  factory ElementoEstado.fromJson(Map<String, dynamic> json) {
    return ElementoEstado(
      id: int.parse(json['id'].toString()),
      invernaderoId: int.parse(json['invernadero_id'].toString()),
      numero: int.parse(json['numero'].toString()),
      elemento: json['elemento'].toString(),
      topic: json['topic']?.toString(),
      estadoId: int.parse(json['estado_id'].toString()),
      moduloId: int.parse(json['modulo_id'].toString()),
      ubicacion: json['ubicacion'].toString(),
      estadoNombre: json['estado_info'] != null
          ? json['estado_info']['estado'].toString()
          : 'Desconocido',
    );
  }
}
