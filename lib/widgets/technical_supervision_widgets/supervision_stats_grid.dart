import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ibi/models/sensor_iot_model.dart';
import 'package:ibi/models/elemento_estado_model.dart';

class SupervisionStatsGrid extends StatelessWidget {
  final List<SensorIot> sensores;
  final List<ElementoEstado> elementos;

  const SupervisionStatsGrid({
    Key? key,
    required this.sensores,
    required this.elementos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculamos el total de dispositivos (Sensores + Elementos)
    int total = sensores.length + elementos.length;

    // Conteo basado en los IDs de la base de datos:
    // 1 = Operativo, 2 = Inactivo, 3 = Falla, 4 = Mantenimiento
    int operativos =
        sensores.where((s) => s.estadoId == 1).length +
        elementos.where((e) => e.estadoId == 1).length;

    int fallas =
        sensores.where((s) => s.estadoId == 3).length +
        elementos.where((e) => e.estadoId == 3).length;

    int mantenimiento =
        sensores.where((s) => s.estadoId == 4).length +
        elementos.where((e) => e.estadoId == 4).length;

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
