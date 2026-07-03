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
      id: json['id'],
      invernaderoId: json['invernadero_id'],
      numero: json['numero'],
      elemento: json['elemento'],
      topic: json['topic'],
      estadoId: json['estado_id'],
      moduloId: json['modulo_id'],
      ubicacion: json['ubicacion'],
      // Extraemos directamente el nombre del estado de la relación anidada
      estadoNombre: json['estado_info'] != null
          ? json['estado_info']['estado']
          : 'Desconocido',
    );
  }
}
