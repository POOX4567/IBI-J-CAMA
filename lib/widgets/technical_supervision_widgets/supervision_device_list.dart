import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ibi/models/sensor_iot_model.dart';
import 'package:ibi/models/invernadero_model.dart';
import 'package:ibi/models/lectura_sensor_model.dart';
import 'package:ibi/models/elemento_estado_model.dart';
import 'package:ibi/utils/notification_service.dart';
import '../../utils/supervision_helpers.dart';

class _DeviceDisplayData {
  final int id;
  final String name;
  final String description;
  final String typeKey;
  final int estadoId;
  final bool hasLectura;

  _DeviceDisplayData.fromSensor(SensorIot s)
    : id = s.id,
      name = s.nombre,
      description = s.descripcion,
      typeKey = s.modelo,
      estadoId = s.estadoId,
      hasLectura = true;

  _DeviceDisplayData.fromElemento(ElementoEstado e)
    : id = e.id,
      name = '${e.elemento} ${e.numero}',
      description = e.ubicacion,
      typeKey = e.elemento,
      estadoId = e.estadoId,
      hasLectura = false;
}

class SupervisionDeviceList extends StatelessWidget {
  final List<SensorIot> devices;
  final List<ElementoEstado> elementos;
  final List<LecturaSensor> lecturas;
  final Invernadero? invernaderoActual;
  final String currentFilter;
  final ValueChanged<String> onFilterChanged;

  const SupervisionDeviceList({
    Key? key,
    required this.devices,
    required this.elementos,
    required this.lecturas,
    this.invernaderoActual,
    required this.currentFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  Future<void> _ubicarDispositivo(
    BuildContext context,
    _DeviceDisplayData device,
  ) async {
    if (invernaderoActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay coordenadas del invernadero en la API.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Buscando señal GPS para ubicar ${device.name}...'),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Por favor enciende el GPS del teléfono.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Los permisos de ubicación fueron denegados.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Los permisos están denegados permanentemente en la configuración.';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latDispositivo = invernaderoActual!.latitud;
      double lngDispositivo = invernaderoActual!.longitud;

      double distanciaMetros = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        latDispositivo,
        lngDispositivo,
      );

      String distanciaKm = (distanciaMetros / 1000).toStringAsFixed(2);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.mapPin, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                '📌 Estás a $distanciaKm km del ${invernaderoActual!.nombre}',
              ),
            ],
          ),
          backgroundColor: Colors.green[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red[800]),
      );
    }
  }

  String _mapEstadoIdToString(int estadoId) {
    switch (estadoId) {
      case 1:
        return 'operativo';
      case 2:
        return 'inactivo';
      case 3:
        return 'falla';
      case 4:
        return 'mantenimiento';
      default:
        return 'desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sensoresData = devices
        .map((d) => _DeviceDisplayData.fromSensor(d))
        .toList();
    final elementosData = elementos
        .map((e) => _DeviceDisplayData.fromElemento(e))
        .toList();
    final allDevices = [...sensoresData, ...elementosData];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Dispositivos IoT",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              DropdownButton<String>(
                value: currentFilter,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: "todos",
                    child: Text("Todos", style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: "1",
                    child: Text("Operativos", style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: "3",
                    child: Text("Fallas", style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: "4",
                    child: Text(
                      "Mantenimiento",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "2",
                    child: Text("Inactivos", style: TextStyle(fontSize: 12)),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) onFilterChanged(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allDevices.length,
            itemBuilder: (context, index) {
              final device = allDevices[index];
              final statusString = _mapEstadoIdToString(device.estadoId);
              final status = SupervisionHelpers.getStatusBadge(statusString);

              final LecturaSensor? lecturaAsociada = device.hasLectura
                  ? lecturas
                      .where((l) => l.sensorId == device.id)
                      .firstOrNull
                  : null;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      SupervisionHelpers.getDeviceTypeIcon(device.typeKey),
                      size: 20,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  device.description,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (lecturaAsociada != null)
                                Text(
                                  "Val: ${lecturaAsociada.valor}",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.mapPin,
                        size: 18,
                        color: Colors.blue,
                      ),
                      onPressed: () => _ubicarDispositivo(context, device),
                      tooltip: "Ubicar dispositivo",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.bellRing,
                        size: 18,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        await NotificationService.solicitarPermisos();
                        await NotificationService.mostrarAlertaFalla(
                          device.name,
                          device.description,
                        );
                      },
                      tooltip: "Simular Alerta Crítica",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: status['bg'],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status['label'],
                            style: TextStyle(
                              color: status['text'],
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
