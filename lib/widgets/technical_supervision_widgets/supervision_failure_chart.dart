import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ibi/models/sensor_iot_model.dart';
import 'package:ibi/models/elemento_estado_model.dart';

class SupervisionFailureChart extends StatelessWidget {
  final List<SensorIot> sensores;
  final List<ElementoEstado> elementos;

  const SupervisionFailureChart({
    Key? key,
    required this.sensores,
    required this.elementos,
  }) : super(key: key);

  String _normalizeLabel(String label) {
    label = label.replaceAll(RegExp(r'\s*\d+\s*$'), '').trim();

    if (label.endsWith('es') && label.length > 4) {
      return label.substring(0, label.length - 2);
    }
    if (label.endsWith('s') && label.length > 3) {
      return label.substring(0, label.length - 1);
    }
    return label;
  }

  List<Map<String, dynamic>> _buildGroupedData() {
    final Map<String, int> counts = {};

    for (final s in sensores) {
      final key = s.modelo.isNotEmpty ? s.modelo : 'Sensor';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    for (final e in elementos) {
      var key = e.elemento.isNotEmpty ? e.elemento : 'Elemento';
      key = _normalizeLabel(key);
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.map((e) {
      return {'label': e.key, 'count': e.value};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = _buildGroupedData();
    final total = sensores.length + elementos.length;

    final List<Color> chartColors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFF6B7280),
    ];

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
            "Dispositivos por Tipo",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF2E3A4B),
            ),
          ),
          const SizedBox(height: 16),
          if (groupedData.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  "Sin datos disponibles",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (groupedData
                            .map((e) => e['count'] as int)
                            .reduce((a, b) => a > b ? a : b) *
                          1.3)
                      .toDouble(),
                  barTouchData: BarTouchData(enabled: true),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: Colors.grey, width: 1),
                      left: BorderSide(color: Colors.grey, width: 1),
                      top: BorderSide.none,
                      right: BorderSide.none,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= groupedData.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              groupedData[idx]['label'].toString(),
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: groupedData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: (entry.value['count'] as int).toDouble(),
                          color: chartColors[entry.key % chartColors.length],
                          width: 32,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 8),
            ...groupedData.asMap().entries.map((entry) {
              final item = entry.value;
              final count = item['count'] as int;
              final pct = total > 0 ? (count / total * 100).round() : 0;
              final color = chartColors[entry.key % chartColors.length];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['label'].toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                        ),
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
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}
