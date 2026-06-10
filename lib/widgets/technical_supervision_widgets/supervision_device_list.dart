import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ibi/data/mock_data.dart';
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
                    const SizedBox(width: 8),
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
