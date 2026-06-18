import 'package:flutter/material.dart';
import 'package:ibi/models/incident_model.dart';
import '../services/incident_service.dart'; // Ajusta la ruta a tu IncidentService

/// Modelo de datos genérico para mapear información hacia las tarjetas de la UI
class MetricData {
  final String titulo;
  final String valor;
  final String subtitulo;
  final String detalleAlerta;

  MetricData({
    required this.titulo,
    this.valor = "",
    required this.subtitulo,
    required this.detalleAlerta,
  });
}

class ResumenProvider with ChangeNotifier {
  final IncidentService _incidentService = IncidentService();

  // Estados de control para la UI
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Listas internas que alimentarán a la interfaz
  Map<String, MetricData> tarjetasPrincipales = {};
  List<MetricData> alertasImportantes = [];
  List<MetricData> resumenActividad = [];
  List<MetricData> actividadReciente = [];

  ResumenProvider() {
    _inicializarDatosPorDefecto();
    cargarDatosDesdeServicio();
  }

  /// Inicializa con datos vacíos o "placeholders" para evitar errores de nulos al arrancar la app
  void _inicializarDatosPorDefecto() {
    tarjetasPrincipales = {
      'invernaderos': MetricData(
        titulo: "Invernaderos",
        valor: "--",
        subtitulo: "Cargando...",
        detalleAlerta: "",
      ),
      'empleados': MetricData(
        titulo: "Empleados",
        valor: "--",
        subtitulo: "Cargando...",
        detalleAlerta: "",
      ),
      'alertas': MetricData(
        titulo: "Alertas",
        valor: "--",
        subtitulo: "Cargando...",
        detalleAlerta: "",
      ),
      'mantenimiento': MetricData(
        titulo: "Mantenimiento",
        valor: "--",
        subtitulo: "Cargando...",
        detalleAlerta: "",
      ),
    };
    alertasImportantes = [];
    resumenActividad = [];
    actividadReciente = [];
  }

  /// Método principal que invoca al IncidentService y procesa los datos
  Future<void> cargarDatosDesdeServicio() async {
    _isLoading = true;
    notifyListeners(); // Notifica a la UI que muestre el spinner de carga

    try {
      // 1. Llamada asíncrona al servicio (espera los 1.2 segundos simulados)
      final List<IncidentModel> incidentes = await _incidentService
          .fetchIncidents();

      // 2. Procesamos métricas para las "Tarjetas Principales" basándonos en los estados del JSON
      final int totalAlertasActivas = incidentes
          .where((i) => i.status == "Abierto" || i.status == "En proceso")
          .length;
      final int totalMantenimientos = incidentes
          .where((i) => i.status == "Resuelto" || i.severity == "Baja")
          .length;

      tarjetasPrincipales['invernaderos'] = MetricData(
        titulo: "Invernaderos",
        valor: "4/5",
        subtitulo: "Activos",
        detalleAlerta: "Sistemas estables a excepción de fallas reportadas.",
      );
      tarjetasPrincipales['empleados'] = MetricData(
        titulo: "Empleados",
        valor: "12",
        subtitulo: "En turno",
        detalleAlerta: "Personal completo asignado a las zonas.",
      );

      tarjetasPrincipales['alertas'] = MetricData(
        titulo: "Alertas Activas",
        valor: totalAlertasActivas.toString(),
        subtitulo: "Requieren atención",
        detalleAlerta:
            "Existen $totalAlertasActivas incidentes pendientes en revisión.",
      );

      tarjetasPrincipales['mantenimiento'] = MetricData(
        titulo: "Mantenimientos",
        valor: totalMantenimientos.toString(),
        subtitulo: "Tareas registradas",
        detalleAlerta:
            "Historial cuenta con $totalMantenimientos registros preventivos/resueltos.",
      );

      // 3. Mapeamos dinámicamente las "Alertas Importantes" (Filtrando incidentes de severidad Alta o Media)
      alertasImportantes = incidentes
          .where((i) => i.severity == "Alta" || i.severity == "Media")
          .map(
            (i) => MetricData(
              titulo: i.title,
              subtitulo: i.area,
              detalleAlerta:
                  "El incidente en ${i.area} se encuentra en estado '${i.status}' con severidad ${i.severity}.",
            ),
          )
          .toList();

      // 4. Mapeamos la "Actividad Reciente" (Muestra todo el historial cronológico del servicio)
      actividadReciente = incidentes
          .map(
            (i) => MetricData(
              titulo: i.title,
              subtitulo: "Estado: ${i.status} - ${i.area}",
              detalleAlerta:
                  "Registro automático: El sistema reporta '${i.title}' en la ubicación ${i.area}.",
            ),
          )
          .toList();

      // 5. Mapeamos el "Resumen de Actividad"
      resumenActividad = [
        MetricData(
          titulo: "Actividad Diaria",
          subtitulo: "${incidentes.length} eventos en total",
          detalleAlerta:
              "Se procesaron exitosamente todos los reportes del día de hoy.",
        ),
      ];
    } catch (e) {
      debugPrint("Error al cargar incidentes en el Provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifica a la UI que ya hay datos disponibles
    }
  }
}
