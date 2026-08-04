import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ibi/models/incident_model.dart';
import '../services/incident_service.dart';

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

  // Configuración para la API de Empleados
  static const String _baseUrl = 'https://ibijicama.utptics.com/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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

  /// Inicializa con datos vacíos o "placeholders"
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

  /// Método para consultar la API de empleados
  Future<List<dynamic>> _fetchEmpleadosApi() async {
    try {
      final token = await _storage.read(key: 'token');
      final response = await http.get(
        Uri.parse('$_baseUrl/employees'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return body['data'];
        }
      }
    } catch (e) {
      debugPrint("Error al consultar empleados API: $e");
    }
    return [];
  }

  /// Método principal que invoca los servicios y procesa los datos
  Future<void> cargarDatosDesdeServicio() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Llamada asíncrona al servicio de incidentes y a la API de Empleados en paralelo
      final results = await Future.wait([
        _incidentService.fetchIncidents(),
        _fetchEmpleadosApi(),
      ]);

      final List<IncidentModel> incidentes = results[0] as List<IncidentModel>;
      final List<dynamic> empleadosApi = results[1] as List<dynamic>;

      // 2. Procesamos métricas para las tarjetas
      final int totalAlertasActivas = incidentes
          .where((i) => i.status == "Abierto" || i.status == "En proceso")
          .length;

      final int totalMantenimientos = incidentes
          .where((i) => i.status == "Resuelto" || i.severity == "Baja")
          .length;

      // Conteo dinámico traído directamente de la API de Laravel
      final int totalEmpleados = empleadosApi.length;

      tarjetasPrincipales['invernaderos'] = MetricData(
        titulo: "Invernaderos",
        valor: "4/5",
        subtitulo: "Activos",
        detalleAlerta: "Sistemas estables a excepción de fallas reportadas.",
      );

      // ⚡ AHORA SE CONSUME DINÁMICAMENTE DE TU BACKEND
      tarjetasPrincipales['empleados'] = MetricData(
        titulo: "Empleados",
        valor: totalEmpleados > 0 ? "$totalEmpleados" : "0",
        subtitulo: "Registrados",
        detalleAlerta:
            "Se encontraron $totalEmpleados empleados registrados en el sistema.",
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

      // 3. Alertas Importantes
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

      // 4. Actividad Reciente
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

      // 5. Resumen de Actividad
      resumenActividad = [
        MetricData(
          titulo: "Actividad Diaria",
          subtitulo: "${incidentes.length} eventos en total",
          detalleAlerta:
              "Se procesaron exitosamente todos los reportes del día de hoy.",
        ),
      ];
    } catch (e) {
      debugPrint("Error al cargar datos en el Provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
