import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:geolocator/geolocator.dart'; // Importamos el plugin de geolocalización
import 'package:ibi/data/mock_data.dart';
import 'package:ibi/utils/notification_service.dart';
import '../../utils/supervision_helpers.dart';

class SupervisionDeviceList extends StatelessWidget {
  final List<IotDevice> devices;
  final String currentFilter;
  final ValueChanged<String> onFilterChanged;

  const SupervisionDeviceList({
    Key? key,
    required this.devices,
    required this.currentFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  // --- NUEVA FUNCIÓN DE GEOLOCALIZACIÓN ---
  Future<void> _ubicarDispositivo(
    BuildContext context,
    IotDevice device,
  ) async {
    // 1. Mostrar un aviso visual de que estamos buscando la señal GPS
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Buscando señal GPS para ubicar ${device.name}...'),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      // 2. Verificar si el servicio GPS está encendido en el teléfono
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Por favor enciende el GPS del teléfono.';
      }

      // 3. Verificar y pedir permisos
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

      // 4. Obtener la posición actual (Tarda unos segundos)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 5. Coordenadas ficticias del invernadero o dispositivo (Ejemplo genérico)
      double latDispositivo = 20.8333;
      double lngDispositivo = -89.9833;

      // 6. Calcular distancia real en metros
      double distanciaMetros = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        latDispositivo,
        lngDispositivo,
      );

      // Convertimos a kilómetros con 2 decimales
      String distanciaKm = (distanciaMetros / 1000).toStringAsFixed(2);

      // Verificamos que el widget siga montado antes de mostrar el resultado
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.mapPin, color: Colors.white),
              const SizedBox(width: 8),
              Text('📍 Estás a $distanciaKm km del dispositivo'),
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

  @override
  Widget build(BuildContext context) {
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
                    value: "operativo",
                    child: Text("Operativos", style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: "falla",
                    child: Text("Fallas", style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: "mantenimiento",
                    child: Text(
                      "Mantenimiento",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "inactivo",
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
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              final status = SupervisionHelpers.getStatusBadge(device.status);

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
                      SupervisionHelpers.getDeviceTypeIcon(device.type),
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
                          Text(
                            device.greenhouse,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // --- NUEVO BOTÓN DE UBICACIÓN ---
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
                        // 1. Pedimos permiso (solo sale la ventana la primera vez)
                        await NotificationService.solicitarPermisos();
                        // 2. Disparamos la alerta
                        await NotificationService.mostrarAlertaFalla(
                          device.name,
                          device.greenhouse,
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
                        if (device.batteryLevel != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                device.batteryLevel! < 20
                                    ? LucideIcons.batteryMedium
                                    : LucideIcons.batteryFull,
                                size: 10,
                                color: device.batteryLevel! < 20
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "${device.batteryLevel}%",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
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
