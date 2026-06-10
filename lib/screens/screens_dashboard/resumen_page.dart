import 'package:flutter/material.dart';

import '../../widgets/widgets_dashboard/cards.dart';
import '../../widgets/widgets_dashboard/common_widgets.dart';

class ResumenPage extends StatelessWidget {
  const ResumenPage({super.key});

  // Función privada para mostrar la alerta con los datos al tocar la tarjeta
  void _mostrarDetalles(BuildContext context, String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Entendido",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Estado General",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1,
          children: [
            InfoCard(
              title: "Invernaderos",
              value: "10/12",
              subtitle: "Activos",
              icon: Icons.eco,
              color: Colors.green,
              onTap: () => _mostrarDetalles(
                context,
                "Invernaderos Activos",
                "Detalle: 10 invernaderos están en producción óptima. Los invernaderos 4 y 9 están detenidos temporalmente.",
              ),
            ),

            InfoCard(
              title: "Empleados",
              value: "28/48",
              subtitle: "En turno",
              icon: Icons.people,
              color: Colors.blue,
              onTap: () => _mostrarDetalles(
                context,
                "Personal en Turno",
                "Detalle: 28 empleados se encuentran en las instalaciones. Próximo cambio de turno en 2 horas.",
              ),
            ),

            InfoCard(
              title: "Alertas",
              value: "5",
              subtitle: "Activas",
              icon: Icons.warning,
              color: Colors.red,
              onTap: () => _mostrarDetalles(
                context,
                "Alertas Críticas",
                "Detalle: Hay 5 problemas detectados en los sensores. Por favor revisa la sección de Alertas Importantes.",
              ),
            ),

            InfoCard(
              title: "Mantenimiento",
              value: "8",
              subtitle: "Pendientes",
              icon: Icons.build,
              color: Colors.orange,
              onTap: () => _mostrarDetalles(
                context,
                "Tareas Pendientes",
                "Detalle: Hay 8 órdenes de mantenimiento asignadas para el día de hoy. 3 son de alta prioridad.",
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        const SectionTitle(title: "Alertas Importantes"),

        const SizedBox(height: 15),

        AlertCard(
          title: "Temperatura Alta",
          subtitle: "Invernadero 2",
          color: Colors.red,
          onTap: () => _mostrarDetalles(
            context,
            "Alerta: Invernadero 2",
            "La temperatura superó el umbral permitido alcanzando los 38°C. Sistema de ventilación automática activado.",
          ),
        ),

        AlertCard(
          title: "Falla de Riego",
          subtitle: "Zona Norte",
          color: Colors.orange,
          onTap: () => _mostrarDetalles(
            context,
            "Alerta: Zona Norte",
            "Pérdida de presión detectada en la tubería principal de riego sector 3.",
          ),
        ),

        AlertCard(
          title: "Sensor Desconectado",
          subtitle: "Invernadero 5",
          color: Colors.blue,
          onTap: () => _mostrarDetalles(
            context,
            "Alerta: Invernadero 5",
            "El sensor de humedad del suelo dejó de enviar datos. Posible falla de batería.",
          ),
        ),

        const SizedBox(height: 30),

        const SectionTitle(title: "Resumen de Actividad"),

        const SizedBox(height: 15),

        SummaryCard(
          title: "Actividad Diaria",
          subtitle: "25 eventos registrados",
          icon: Icons.today,
          color: Colors.green,
          onTap: () => _mostrarDetalles(
            context,
            "Historial Diario",
            "Se registraron 12 riegos automáticos, 5 logs de acceso y 8 mediciones climáticas manuales.",
          ),
        ),

        SummaryCard(
          title: "Actividad Semanal",
          subtitle: "148 eventos registrados",
          icon: Icons.calendar_view_week,
          color: Colors.blue,
          onTap: () => _mostrarDetalles(
            context,
            "Historial Semanal",
            "Rendimiento de alertas resueltas esta semana: 92% de efectividad.",
          ),
        ),

        SummaryCard(
          title: "Actividad Mensual",
          subtitle: "620 eventos registrados",
          icon: Icons.calendar_month,
          color: Colors.orange,
          onTap: () => _mostrarDetalles(
            context,
            "Historial Mensual",
            "Resumen de producción: 14 toneladas cosechadas y procesadas con éxito durante el mes.",
          ),
        ),

        const SizedBox(height: 30),

        const SectionTitle(title: "Actividad Reciente"),

        const SizedBox(height: 15),

        ActivityCard(
          icon: Icons.build,
          title: "Mantenimiento realizado",
          time: "Hace 1 hora",
          color: Colors.blue,
          onTap: () => _mostrarDetalles(
            context,
            "Log de Mantenimiento",
            "El técnico cambió el extractor de aire dañado en el Invernadero 1.",
          ),
        ),

        ActivityCard(
          icon: Icons.water_drop,
          title: "Riego automático activado",
          time: "Hace 3 horas",
          color: Colors.cyan,
          onTap: () => _mostrarDetalles(
            context,
            "Log de Riego",
            "Ciclo programado completado con éxito en los Invernaderos 1 al 6.",
          ),
        ),

        ActivityCard(
          icon: Icons.eco,
          title: "Producción actualizada",
          time: "Hoy",
          color: Colors.green,
          onTap: () => _mostrarDetalles(
            context,
            "Log de Producción",
            "Carga de datos completada: Ingresaron 450 kg de tomate clasificados como Calidad A.",
          ),
        ),

        const SizedBox(height: 30),

        const ReportButton(),
      ],
    );
  }
}
