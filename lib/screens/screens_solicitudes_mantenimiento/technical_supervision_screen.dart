import 'dart:async'; // Necesario para el StreamSubscription
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // El nuevo plugin

// --- NUEVOS MODELOS Y SERVICIOS ---
import 'package:ibi/models/sensor_iot_model.dart';
import 'package:ibi/models/elemento_estado_model.dart';
import 'package:ibi/models/lectura_sensor_model.dart';
import 'package:ibi/models/invernadero_model.dart';
import 'package:ibi/services/supervision_service.dart';

// Importaciones seguras y absolutas
import 'package:ibi/widgets/technical_supervision_widgets/supervision_header.dart';
import 'package:ibi/widgets/technical_supervision_widgets/supervision_stats_grid.dart';
import 'package:ibi/widgets/technical_supervision_widgets/supervision_device_list.dart';
import 'package:ibi/widgets/technical_supervision_widgets/supervision_failure_chart.dart';
import 'package:ibi/widgets/technical_supervision_widgets/supervision_performance.dart';
import 'package:ibi/widgets/technical_supervision_widgets/supervision_history.dart';

class TechnicalSupervisionScreen extends StatefulWidget {
  const TechnicalSupervisionScreen({Key? key}) : super(key: key);

  @override
  State<TechnicalSupervisionScreen> createState() =>
      _TechnicalSupervisionScreenState();
}

class _TechnicalSupervisionScreenState
    extends State<TechnicalSupervisionScreen> {
  String deviceFilter = "todos";

  // 1. Declaramos la variable para guardar la suscripción al monitor de red
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // --- VARIABLES DE LA API ---
  final SupervisionService _apiService = SupervisionService();
  bool _isLoading = true;
  String _errorMessage = '';

  List<SensorIot> _sensores = [];
  List<ElementoEstado> _elementos = [];
  List<LecturaSensor> _lecturas = [];
  List<Invernadero> _invernaderos = [];

  @override
  void initState() {
    super.initState();
    // 2. Iniciamos el monitoreo justo cuando la pantalla se abre
    _iniciarMonitoreoDeRed();
    // 3. Cargamos los datos reales desde la API
    _cargarDatosAPI();
  }

  // --- FUNCIÓN PARA TRAER LOS DATOS DE LA API ---
  Future<void> _cargarDatosAPI() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Future.wait permite hacer todas las peticiones HTTP al mismo tiempo
      final resultados = await Future.wait([
        _apiService.getSensores(),
        _apiService.getElementos(),
        _apiService.getLecturas(),
        _apiService.getInvernaderos(),
      ]);

      setState(() {
        _sensores = resultados[0] as List<SensorIot>;
        _elementos = resultados[1] as List<ElementoEstado>;
        _lecturas = resultados[2] as List<LecturaSensor>;
        _invernaderos = resultados[3] as List<Invernadero>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al conectar con el servidor: $e';
        _isLoading = false;
      });
    }
  }

  void _iniciarMonitoreoDeRed() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      // Verificamos si el resultado es "ninguna conexión"
      if (result.contains(ConnectivityResult.none)) {
        _mostrarAlertaSinConexion(true);
      } else {
        // Si hay WiFi o Datos Móviles, ocultamos la alerta
        _mostrarAlertaSinConexion(false);
        // Opcional: Recargar datos automáticamente si regresa la conexión y estaban vacíos
        if (_sensores.isEmpty && _elementos.isEmpty && !_isLoading) {
          _cargarDatosAPI();
        }
      }
    });
  }

  void _mostrarAlertaSinConexion(bool sinConexion) {
    if (sinConexion) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sin conexión a Internet. Los datos de los sensores no están en tiempo real.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          // Le ponemos una duración larguísima para que no se quite sola hasta que regrese el internet
          duration: Duration(days: 1),
          behavior: SnackBarBehavior.floating, // Hace que flote sobre la UI
        ),
      );
    } else {
      // Si la conexión regresa, forzamos a que el SnackBar actual se oculte
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  @override
  void dispose() {
    // Cancelamos la suscripción cuando el usuario sale de esta pantalla
    // para evitar que la app consuma batería o memoria innecesariamente.
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Manejo del estado de Error en la pantalla
    if (!_isLoading && _errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(_errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarDatosAPI,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Filtramos sensores y elementos según el filtro seleccionado
    final filteredSensores = _sensores.where((sensor) {
      if (deviceFilter == "todos") return true;
      return sensor.estadoId.toString() == deviceFilter;
    }).toList();

    final filteredElementos = _elementos.where((elemento) {
      if (deviceFilter == "todos") return true;
      return elemento.estadoId.toString() == deviceFilter;
    }).toList();

    return Column(
      children: [
        // Encabezado superior fijo (sumamos sensores y elementos)
        SupervisionHeader(
          totalDevices: _isLoading ? 0 : (_sensores.length + _elementos.length),
        ),

        // Contenido con scroll envuelto en un Expanded y un RefreshIndicator
        Expanded(
          child: RefreshIndicator(
            onRefresh: _cargarDatosAPI,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(), // Necesario para el RefreshIndicator
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SupervisionStatsGrid(
                          sensores: _sensores,
                          elementos: _elementos,
                        ),
                        const SizedBox(height: 12),

                        SupervisionDeviceList(
                          devices: filteredSensores,
                          elementos: filteredElementos,
                          lecturas: _lecturas,
                          // Si hay al menos un invernadero, enviamos el primero para usar sus coordenadas
                          invernaderoActual: _invernaderos.isNotEmpty
                              ? _invernaderos.first
                              : null,
                          currentFilter: deviceFilter,
                          onFilterChanged: (val) =>
                              setState(() => deviceFilter = val),
                        ),
                        const SizedBox(height: 12),

                        const SupervisionFailureChart(),
                        const SizedBox(height: 12),

                        const SupervisionPerformance(),
                        const SizedBox(height: 12),

                        const SupervisionHistory(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
