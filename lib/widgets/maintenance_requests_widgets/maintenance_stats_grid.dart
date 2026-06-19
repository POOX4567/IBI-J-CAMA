import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ibi/data/mock_data.dart'; // Ajusta la ruta a donde tengas definido el modelo MaintenanceRequest

class MaintenanceStatsGrid extends StatelessWidget {
  final List<MaintenanceRequest> requests;

  const MaintenanceStatsGrid({Key? key, required this.requests})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculamos las estadísticas basándonos en la lista que recibe el widget
    int total = requests.length;
    int urgentes = requests.where((r) => r.priority == 'alta').length;
    int pendientes = requests.where((r) => r.status == 'pendiente').length;
    int enProgreso = requests.where((r) => r.status == 'en_progreso').length;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Evita scroll interno dentro del SingleChildScrollView
      childAspectRatio: 1.5,
      children: [
        _statCard(
          "Total Solicitudes",
          "$total",
          Colors.grey[100]!,
          Colors.grey[900]!,
          border: Colors.grey[300]!,
        ),
        _statCard(
          "Urgentes",
          "$urgentes",
          Colors.red[50]!,
          Colors.red[800]!,
          border: Colors.red[300]!,
          icon: LucideIcons.alertCircle,
        ),
        _statCard(
          "Pendientes",
          "$pendientes",
          Colors.orange[50]!,
          Colors.orange[800]!,
          border: Colors.orange[300]!,
          icon: LucideIcons.clock,
        ),
        _statCard(
          "En Progreso",
          "$enProgreso",
          Colors.blue[50]!,
          Colors.blue[800]!,
          border: Colors.blue[300]!,
          icon: LucideIcons.alertCircle,
        ),
      ],
    );
  }

  // Método privado para construir cada tarjeta individual
  Widget _statCard(
    String title,
    String value,
    Color bg,
    Color textColor, {
    IconData? icon,
    Color? border,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: border != null ? Border.all(color: border, width: 2) : null,
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
