import 'dart:async'; // Necesario para el StreamSubscription
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // El nuevo plugin
import 'package:ibi/data/mock_data.dart';

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

  @override
  void initState() {
    super.initState();
    // 2. Iniciamos el monitoreo justo cuando la pantalla se abre
    _iniciarMonitoreoDeRed();
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
    // 3. ¡Paso crítico! Cancelamos la suscripción cuando el usuario sale de esta pantalla
    // para evitar que la app consuma batería o memoria innecesariamente.
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filtramos la lista de dispositivos IoT basándonos en el dropdown seleccionado
    final filteredDevices = mockIotDevices.where((device) {
      if (deviceFilter == "todos") return true;
      return device.status == deviceFilter;
    }).toList();

    return Column(
      children: [
        // Encabezado superior fijo
        SupervisionHeader(totalDevices: mockIotDevices.length),

        // Contenido con scroll envuelto en un Expanded
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SupervisionStatsGrid(devices: mockIotDevices),
                const SizedBox(height: 12),

                SupervisionDeviceList(
                  devices: filteredDevices,
                  currentFilter: deviceFilter,
                  onFilterChanged: (val) => setState(() => deviceFilter = val),
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
      ],
    );
  }
}
