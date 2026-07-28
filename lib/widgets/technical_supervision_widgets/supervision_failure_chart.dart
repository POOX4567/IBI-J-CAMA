import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ibi/data/mock_data.dart'; // Ajusta la ruta a tus mocks

class SupervisionFailureChart extends StatelessWidget {
  const SupervisionFailureChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Colores exactos extraídos de la gráfica
    final List<Color> chartColors = [
      const Color(0xFF3B82F6), // Azul
      const Color(0xFFEF4444), // Rojo
      const Color(0xFFF59E0B), // Naranja
      const Color(0xFF10B981), // Verde
      const Color(0xFF8B5CF6), // Morado
      const Color(0xFF6B7280), // Gris
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Row(
            children: [
              Icon(LucideIcons.alertCircle, size: 18, color: Colors.red[600]),
              const SizedBox(width: 8),
              const Text(
                "Fallas Frecuentes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Gráfica de Barras
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    12.5, // Límite superior para dar un ligero respiro al máximo de 12
                barTouchData: BarTouchData(enabled: true),
                gridData: const FlGridData(
                  show: false,
                ), // Oculta la cuadrícula de fondo
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
                      interval: 3, // Muestra los números 0, 3, 6, 9, 12
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
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
                      reservedSize: 70, // Espacio para el texto rotado
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= mockFailureStats.length)
                          return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Transform.rotate(
                            angle: -0.7, // Rotación diagonal
                            child: Text(
                              mockFailureStats[value.toInt()].type,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: mockFailureStats.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.count.toDouble(),
                        color: chartColors[entry.key % chartColors.length],
                        width: 40, // Barras anchas
                        borderRadius:
                            BorderRadius.zero, // Sin bordes redondeados
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

          // Lista/Leyenda inferior
          ...mockFailureStats.asMap().entries.map((entry) {
            final stat = entry.value;
            final color = chartColors[entry.key % chartColors.length];

            // Lógica para los colores del pill de porcentaje
            Color badgeBgColor;
            Color badgeTextColor;
            Color badgeBorderColor;

            if (stat.percentage >= 20) {
              badgeBgColor = Colors.red[50]!;
              badgeTextColor = Colors.red[800]!;
              badgeBorderColor = Colors.red[200]!;
            } else if (stat.percentage >= 15) {
              badgeBgColor = Colors.orange[50]!;
              badgeTextColor = Colors.orange[800]!;
              badgeBorderColor = Colors.orange[300]!;
            } else {
              badgeBgColor = Colors.blueGrey[50]!;
              badgeTextColor = Colors.blueGrey[700]!;
              badgeBorderColor = Colors.blueGrey[200]!;
            }

            String formattedPercentage =
                stat.percentage.truncateToDouble() == stat.percentage
                ? stat.percentage.toInt().toString()
                : stat.percentage.toString();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stat.type,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const Spacer(),
                  Text(
                    stat.count.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: badgeBorderColor),
                    ),
                    child: Text(
                      "$formattedPercentage%",
                      style: TextStyle(color: badgeTextColor, fontSize: 11),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
