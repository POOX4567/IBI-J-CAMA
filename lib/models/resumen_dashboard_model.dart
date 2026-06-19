// models/resumen_dashboard_model.dart

class MetricaCard {
  final String titulo;
  final String valor;
  final String subtitulo;
  final String detalleAlerta;

  MetricaCard({
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    required this.detalleAlerta,
  });
}

class EventoDashboard {
  final String titulo;
  final String subtitulo;
  final String detalleAlerta;

  EventoDashboard({
    required this.titulo,
    required this.subtitulo,
    required this.detalleAlerta,
  });
}
