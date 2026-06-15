// providers/resumen_provider.dart
import 'package:flutter/material.dart';
import '../models/resumen_dashboard_model.dart';

class ResumenProvider extends ChangeNotifier {
  // 1. Datos de las Tarjetas Superiores
  final Map<String, MetricaCard> _tarjetasPrincipales = {
    'invernaderos': MetricaCard(
      titulo: "Invernaderos",
      valor: "10/12",
      subtitulo: "Activos",
      detalleAlerta:
          "Detalle: 10 invernaderos están en producción óptima. Los invernaderos 4 y 9 están detenidos temporalmente.",
    ),
    'empleados': MetricaCard(
      titulo: "Personal en Turno",
      valor: "28/48",
      subtitulo: "En turno",
      detalleAlerta:
          "Detalle: 28 empleados se encuentran en las instalaciones. Próximo cambio de turno en 2 horas.",
    ),
    'alertas': MetricaCard(
      titulo: "Alertas Críticas",
      valor: "5",
      subtitulo: "Activas",
      detalleAlerta:
          "Detalle: Hay 5 problemas detectados en los sensores. Por favor revisa la sección de Alertas Importantes.",
    ),
    'mantenimiento': MetricaCard(
      titulo: "Tareas Pendientes",
      valor: "8",
      subtitulo: "Pendientes",
      detalleAlerta:
          "Detalle: Hay 8 órdenes de mantenimiento asignadas para el día de hoy. 3 son de alta prioridad.",
    ),
  };

  // 2. Datos de Alertas Importantes
  final List<EventoDashboard> _alertasImportantes = [
    EventoDashboard(
      titulo: "Temperatura Alta",
      subtitulo: "Invernadero 2",
      detalleAlerta:
          "La temperatura superó el umbral permitido alcanzando los 38°C. Sistema de ventilación automática activado.",
    ),
    EventoDashboard(
      titulo: "Falla de Riego",
      subtitulo: "Zona Norte",
      detalleAlerta:
          "Pérdida de presión detectada en la tubería principal de riego sector 3.",
    ),
    EventoDashboard(
      titulo: "Sensor Desconectado",
      subtitulo: "Invernadero 5",
      detalleAlerta:
          "El sensor de humedad del suelo dejó de enviar datos. Posible falla de batería.",
    ),
  ];

  // 3. Resumen de Actividad (Historiales)
  final List<EventoDashboard> _resumenActividad = [
    EventoDashboard(
      titulo: "Actividad Diaria",
      subtitulo: "25 eventos registrados",
      detalleAlerta:
          "Se registraron 12 riegos automáticos, 5 logs de acceso y 8 mediciones climáticas manuales.",
    ),
    EventoDashboard(
      titulo: "Actividad Semanal",
      subtitulo: "148 eventos registrados",
      detalleAlerta:
          "Rendimiento de alertas resueltas esta semana: 92% de efectividad.",
    ),
    EventoDashboard(
      titulo: "Actividad Mensual",
      subtitulo: "620 eventos registrados",
      detalleAlerta:
          "Resumen de producción: 14 toneladas cosechadas y procesadas con éxito durante el mes.",
    ),
  ];

  // 4. Actividad Reciente
  final List<EventoDashboard> _actividadReciente = [
    EventoDashboard(
      titulo: "Mantenimiento realizado",
      subtitulo: "Hace 1 hora",
      detalleAlerta:
          "El técnico cambió el extractor de aire dañado en el Invernadero 1.",
    ),
    EventoDashboard(
      titulo: "Riego automático activado",
      subtitulo: "Hace 3 horas",
      detalleAlerta:
          "Ciclo programado completado con éxito en los Invernaderos 1 al 6.",
    ),
    EventoDashboard(
      titulo: "Producción actualizada",
      subtitulo: "Hoy",
      detalleAlerta:
          "Carga de datos completada: Ingresaron 450 kg de tomate clasificados como Calidad A.",
    ),
  ];

  // Getters para exponer la información de forma limpia a la UI
  Map<String, MetricaCard> get tarjetasPrincipales => _tarjetasPrincipales;
  List<EventoDashboard> get alertasImportantes => _alertasImportantes;
  List<EventoDashboard> get resumenActividad => _resumenActividad;
  List<EventoDashboard> get actividadReciente => _actividadReciente;
}
