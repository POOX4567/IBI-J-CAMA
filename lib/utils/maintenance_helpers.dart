import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MaintenanceHelpers {
  static Map<String, dynamic> getPriorityBadge(String priority) {
    switch (priority) {
      case "alta":
        return {
          'bg': Colors.red[100],
          'text': Colors.red[800],
          'border': Colors.red[300],
          'label': 'URGENTE',
        };
      case "media":
        return {
          'bg': Colors.yellow[100],
          'text': Colors.yellow[800],
          'border': Colors.yellow[300],
          'label': 'MEDIA',
        };
      case "baja":
        return {
          'bg': Colors.green[100],
          'text': Colors.green[800],
          'border': Colors.green[300],
          'label': 'BAJA',
        };
      default:
        return {
          'bg': Colors.grey[100],
          'text': Colors.grey[800],
          'border': Colors.grey[300],
          'label': 'N/A',
        };
    }
  }

  static Map<String, dynamic> getStatusBadge(String status) {
    switch (status) {
      case "pendiente":
        return {
          'icon': LucideIcons.clock,
          'bg': Colors.orange[100],
          'text': Colors.orange[800],
          'border': Colors.orange[300],
          'label': 'Pendiente',
        };
      case "en_progreso":
        return {
          'icon': LucideIcons.alertCircle,
          'bg': Colors.blue[100],
          'text': Colors.blue[800],
          'border': Colors.blue[300],
          'label': 'En Progreso',
        };
      case "completada":
        return {
          'icon': LucideIcons.checkCircle,
          'bg': Colors.green[100],
          'text': Colors.green[800],
          'border': Colors.green[300],
          'label': 'Completada',
        };
      case "cancelada":
        return {
          'icon': LucideIcons.xCircle,
          'bg': Colors.grey[100],
          'text': Colors.grey[800],
          'border': Colors.grey[300],
          'label': 'Cancelada',
        };
      default:
        return {
          'icon': null,
          'bg': Colors.grey[100],
          'text': Colors.grey[800],
          'border': Colors.grey[300],
          'label': status,
        };
    }
  }

  static Widget buildBadge(
    String label,
    Color bg,
    Color text,
    Color border, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
