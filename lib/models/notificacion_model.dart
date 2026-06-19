import 'package:equatable/equatable.dart';

class NotificacionModel extends Equatable {
  final String id;
  final String titulo;
  final String detalle;
  final DateTime fecha;
  final bool leida;

  const NotificacionModel({
    required this.id,
    required this.titulo,
    required this.detalle,
    required this.fecha,
    this.leida = false,
  });

  // Copiar objeto modificando campos (útil para marcar como leída)
  NotificacionModel copyWith({bool? leida}) {
    return NotificacionModel(
      id: id,
      titulo: titulo,
      detalle: detalle,
      fecha: fecha,
      leida: leida ?? this.leida,
    );
  }

  @override
  List<Object?> get props => [id, titulo, detalle, fecha, leida];
}
