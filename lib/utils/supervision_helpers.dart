import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SupervisionHelpers {
  static Map<String, dynamic> getStatusBadge(String status) {
    switch (status) {
      case "operativo":
        return {
          'icon': LucideIcons.wifi,
          'bg': Colors.green[100],
          'text': Colors.green[800],
          'label': 'OPERATIVO',
        };
      case "falla":
        return {
          'icon': LucideIcons.wifiOff,
          'bg': Colors.red[100],
          'text': Colors.red[800],
          'label': 'FALLA',
        };
      case "mantenimiento":
        return {
          'icon': LucideIcons.wrench,
          'bg': Colors.orange[100],
          'text': Colors.orange[800],
          'label': 'MANTENIMIENTO',
        };
      default:
        return {
          'icon': LucideIcons.ban,
          'bg': Colors.grey[100],
          'text': Colors.grey[800],
          'label': 'INACTIVO',
        };
    }
  }

  static IconData getDeviceTypeIcon(String type) {
    final lower = type.toLowerCase();

    if (lower.contains('dht') || lower.contains('temperatura') || lower.contains('temp')) {
      return LucideIcons.thermometer;
    }
    if (lower.contains('bh') || lower.contains('luz') || lower.contains('lum')) {
      return LucideIcons.sun;
    }
    if (lower.contains('humedad') || lower.contains('hum')) {
      return LucideIcons.droplets;
    }
    if (lower.contains('ventilador')) {
      return LucideIcons.fan;
    }
    if (lower.contains('bomba') || lower.contains('riego')) {
      return LucideIcons.play;
    }
    if (lower.contains('controlador') || lower.contains('panel')) {
      return LucideIcons.settings;
    }
    return LucideIcons.cpu;
  }

  static String formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  static String relativeTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60) return 'Ahora';
      if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
      if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
      return formatDate(dt);
    } catch (_) {
      return '';
    }
  }

  static Color getStatusBorderColor(int estadoId) {
    switch (estadoId) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.red;
      case 4:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static Color getIconBgColor(String typeKey) {
    final lower = typeKey.toLowerCase();
    if (lower.contains('dht') || lower.contains('temp')) return Colors.orange[50]!;
    if (lower.contains('bh') || lower.contains('luz')) return Colors.amber[50]!;
    if (lower.contains('hum')) return Colors.blue[50]!;
    if (lower.contains('ventilador')) return Colors.cyan[50]!;
    if (lower.contains('bomba') || lower.contains('riego')) return Colors.teal[50]!;
    return Colors.grey[100]!;
  }

  static Color getIconColor(String typeKey) {
    final lower = typeKey.toLowerCase();
    if (lower.contains('dht') || lower.contains('temp')) return Colors.orange[700]!;
    if (lower.contains('bh') || lower.contains('luz')) return Colors.amber[700]!;
    if (lower.contains('hum')) return Colors.blue[700]!;
    if (lower.contains('ventilador')) return Colors.cyan[700]!;
    if (lower.contains('bomba') || lower.contains('riego')) return Colors.teal[700]!;
    return Colors.blueGrey[600]!;
  }
}
