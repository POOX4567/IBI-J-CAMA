import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Tus rutas de componentes importadas
import '../../widgets/widgets_dashboard/cards.dart';
import '../../widgets/widgets_dashboard/common_widgets.dart';
// Nuevas importaciones de arquitectura
import '../../services/resumen_provider.dart';

class ResumenPage extends StatelessWidget {
  const ResumenPage({super.key});

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
    // Escuchamos de manera reactiva el proveedor de datos local
    final resumenData = context.watch<ResumenProvider>();

    final inv = resumenData.tarjetasPrincipales['invernaderos']!;
    final emp = resumenData.tarjetasPrincipales['empleados']!;
    final ale = resumenData.tarjetasPrincipales['alertas']!;
    final mant = resumenData.tarjetasPrincipales['mantenimiento']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Estado General",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // 1. Grid de Métricas Principales consumiendo del Provider
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1,
          children: [
            InfoCard(
              title: inv.titulo,
              value: inv.valor,
              subtitle: inv.subtitulo,
              icon: Icons.eco,
              color: Colors.green,
              onTap: () => _mostrarDetalles(
                context,
                "Invernaderos Activos",
                inv.detalleAlerta,
              ),
            ),
            InfoCard(
              title: emp.titulo,
              value: emp.valor,
              subtitle: emp.subtitulo,
              icon: Icons.people,
              color: Colors.blue,
              onTap: () =>
                  _mostrarDetalles(context, emp.titulo, emp.detalleAlerta),
            ),
            InfoCard(
              title: ale.titulo,
              value: ale.valor,
              subtitle: ale.subtitulo,
              icon: Icons.warning,
              color: Colors.red,
              onTap: () =>
                  _mostrarDetalles(context, ale.titulo, ale.detalleAlerta),
            ),
            InfoCard(
              title: mant.titulo,
              value: mant.valor,
              subtitle: mant.subtitulo,
              icon: Icons.build,
              color: Colors.orange,
              onTap: () =>
                  _mostrarDetalles(context, mant.titulo, mant.detalleAlerta),
            ),
          ],
        ),
        const SizedBox(height: 30),

        const SectionTitle(title: "Alertas Importantes"),
        const SizedBox(height: 15),

        // 2. Alertas Importantes mapeadas dinámicamente
        ...resumenData.alertasImportantes.map(
          (alerta) => AlertCard(
            title: alerta.titulo,
            subtitle: alerta.subtitulo,
            color: alerta.titulo.contains("Temperatura")
                ? Colors.red
                : (alerta.titulo.contains("Riego")
                      ? Colors.orange
                      : Colors.blue),
            onTap: () => _mostrarDetalles(
              context,
              "Alerta: ${alerta.subtitulo}",
              alerta.detalleAlerta,
            ),
          ),
        ),
        const SizedBox(height: 30),

        const SectionTitle(title: "Resumen de Actividad"),
        const SizedBox(height: 15),

        // 3. Resumen de Actividades mapeado dinámicamente
        ...resumenData.resumenActividad.map(
          (resumen) => SummaryCard(
            title: resumen.titulo,
            subtitle: resumen.subtitulo,
            icon: resumen.titulo.contains("Diaria")
                ? Icons.today
                : (resumen.titulo.contains("Semanal")
                      ? Icons.calendar_view_week
                      : Icons.calendar_month),
            color: resumen.titulo.contains("Diaria")
                ? Colors.green
                : (resumen.titulo.contains("Semanal")
                      ? Colors.blue
                      : Colors.orange),
            onTap: () => _mostrarDetalles(
              context,
              resumen.titulo,
              resumen.detalleAlerta,
            ),
          ),
        ),
        const SizedBox(height: 30),

        const SectionTitle(title: "Actividad Reciente"),
        const SizedBox(height: 15),

        // 4. Historial Reciente mapeado dinámicamente
        ...resumenData.actividadReciente.map(
          (actividad) => ActivityCard(
            icon: actividad.titulo.contains("Mantenimiento")
                ? Icons.build
                : (actividad.titulo.contains("Riego")
                      ? Icons.water_drop
                      : Icons.eco),
            title: actividad.titulo,
            time: actividad.subtitulo,
            color: actividad.titulo.contains("Mantenimiento")
                ? Colors.blue
                : (actividad.titulo.contains("Riego")
                      ? Colors.cyan
                      : Colors.green),
            onTap: () => _mostrarDetalles(
              context,
              actividad.titulo,
              actividad.detalleAlerta,
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
