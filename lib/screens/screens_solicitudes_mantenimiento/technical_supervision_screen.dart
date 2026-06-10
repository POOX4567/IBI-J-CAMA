import 'package:flutter/material.dart';
import 'package:ibi/data/mock_data.dart';

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

  @override
  Widget build(BuildContext context) {
    // Filtramos la lista de dispositivos IoT basándonos en el dropdown seleccionado
    final filteredDevices = mockIotDevices.where((device) {
      if (deviceFilter == "todos") return true;
      return device.status == deviceFilter;
    }).toList();

    return Column(
      children: [
        // 1. Encabezado superior fijo adaptado a la supervisión
        SupervisionHeader(totalDevices: mockIotDevices.length),

        // 2. Contenido con scroll envuelto en un Expanded para evitar desbordamientos
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cuadrícula de contadores/estadísticas en tiempo real
                SupervisionStatsGrid(devices: mockIotDevices),
                const SizedBox(height: 12),

                // Listado y filtro interactivo de dispositivos IoT
                SupervisionDeviceList(
                  devices: filteredDevices,
                  currentFilter: deviceFilter,
                  onFilterChanged: (val) => setState(() => deviceFilter = val),
                ),
                const SizedBox(height: 12),

                // Gráfica de barras de fallas frecuentes (basada en fl_chart)
                const SupervisionFailureChart(),
                const SizedBox(height: 12),

                // Tarjetas de indicadores clave de rendimiento (Uptime, MTTR, etc.)
                const SupervisionPerformance(),
                const SizedBox(height: 12),

                // Historial colapsable de mantenimiento que autogestiona su expansión
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
