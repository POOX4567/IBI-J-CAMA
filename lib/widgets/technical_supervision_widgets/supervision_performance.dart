import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ibi/models/sensor_iot_model.dart';
import 'package:ibi/models/elemento_estado_model.dart';

class SupervisionPerformance extends StatelessWidget {
  final List<SensorIot> sensores;
  final List<ElementoEstado> elementos;

  const SupervisionPerformance({
    Key? key,
    required this.sensores,
    required this.elementos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final operativos = sensores.where((s) => s.estadoId == 1).length +
        elementos.where((e) => e.estadoId == 1).length;
    final inactivos = sensores.where((s) => s.estadoId == 2).length +
        elementos.where((e) => e.estadoId == 2).length;
    final fallas = sensores.where((s) => s.estadoId == 3).length +
        elementos.where((e) => e.estadoId == 3).length;
    final mantenimiento = sensores.where((s) => s.estadoId == 4).length +
        elementos.where((e) => e.estadoId == 4).length;
    final total = sensores.length + elementos.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Distribución de Estados",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF2E3A4B),
            ),
          ),
          const SizedBox(height: 16),
          if (total == 0)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Sin dispositivos",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 36,
                            sections: _buildSections(
                              operativos,
                              inactivos,
                              fallas,
                              mantenimiento,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$total',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'dispositivos',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _legendItem(
                        Colors.green,
                        'Operativos',
                        operativos,
                        total,
                      ),
                      const SizedBox(height: 6),
                      _legendItem(
                        Colors.grey[600]!,
                        'Inactivos',
                        inactivos,
                        total,
                      ),
                      const SizedBox(height: 6),
                      _legendItem(Colors.red, 'Fallas', fallas, total),
                      const SizedBox(height: 6),
                      _legendItem(
                        Colors.orange,
                        'Mantenimiento',
                        mantenimiento,
                        total,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
    int operativos,
    int inactivos,
    int fallas,
    int mantenimiento,
  ) {
    final sections = <PieChartSectionData>[];

    if (operativos > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.green,
          value: operativos.toDouble(),
          radius: 12,
          showTitle: false,
        ),
      );
    }
    if (inactivos > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.grey[600]!,
          value: inactivos.toDouble(),
          radius: 12,
          showTitle: false,
        ),
      );
    }
    if (fallas > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.red,
          value: fallas.toDouble(),
          radius: 12,
          showTitle: false,
        ),
      );
    }
    if (mantenimiento > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.orange,
          value: mantenimiento.toDouble(),
          radius: 12,
          showTitle: false,
        ),
      );
    }

    return sections;
  }

  Widget _legendItem(Color color, String label, int count, int total) {
    final pct = total > 0 ? (count / total * 100).round() : 0;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 36,
          child: Text(
            '$pct%',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
