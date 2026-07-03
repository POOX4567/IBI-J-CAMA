import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ibi/data/mock_data.dart';

class SupervisionStatsGrid extends StatelessWidget {
  final List<IotDevice> devices;
  const SupervisionStatsGrid({Key? key, required this.devices})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    int total = devices.length;
    int operativos = devices.where((d) => d.status == 'operativo').length;
    int fallas = devices.where((d) => d.status == 'falla').length;
    int mantenimiento = devices
        .where((d) => d.status == 'mantenimiento')
        .length;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _statCard(
          "Total Dispositivos",
          "$total",
          Colors.grey[100]!,
          Colors.grey[900]!,
        ),
        _statCard(
          "Operativos",
          "$operativos",
          Colors.green[50]!,
          Colors.green[800]!,
          icon: LucideIcons.wifi,
        ),
        _statCard(
          "Con Fallas",
          "$fallas",
          Colors.red[50]!,
          Colors.red[800]!,
          icon: LucideIcons.wifiOff,
        ),
        _statCard(
          "Mantenimiento",
          "$mantenimiento",
          Colors.orange[50]!,
          Colors.orange[800]!,
          icon: LucideIcons.wrench,
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    Color bg,
    Color textColor, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: textColor),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
