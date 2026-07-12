import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/lectura_sensor.dart';

class HumedadChart extends StatelessWidget {
  final List<LecturaSensor> lecturas;

  const HumedadChart({
    super.key,
    required this.lecturas,
  });

  @override
  Widget build(BuildContext context) {
    final lecturasHumedad = lecturas.where((lectura) {
      final texto =
          '${lectura.nombreSensor} ${lectura.descripcion}'.toLowerCase();

      return texto.contains('humedad');
    }).toList();

    lecturasHumedad.sort(
      (a, b) => DateTime.parse(a.lecturaDatetime)
          .compareTo(DateTime.parse(b.lecturaDatetime)),
    );

    final ultimasTres = lecturasHumedad.length > 3
        ? lecturasHumedad.sublist(lecturasHumedad.length - 3)
        : lecturasHumedad;

    final spots = ultimasTres.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        double.tryParse(entry.value.valor) ?? 0,
      );
    }).toList();

    double minY = 0;
    double maxY = 100;

    if (spots.isNotEmpty) {
      final valores = spots.map((e) => e.y).toList();

      minY = valores.reduce((a, b) => a < b ? a : b) - 5;
      maxY = valores.reduce((a, b) => a > b ? a : b) + 5;

      if (minY < 0) minY = 0;
    }

    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Últimas 3 lecturas de humedad',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: spots.isEmpty
                ? const Center(
                    child: Text(
                      'No hay lecturas de humedad',
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,

                      gridData: const FlGridData(show: true),

                      borderData: FlBorderData(show: true),

                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 35,
                          ),
                        ),

                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),

                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),

                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text("1");
                                case 1:
                                  return const Text("2");
                                case 2:
                                  return const Text("3");
                              }

                              return const SizedBox();
                            },
                          ),
                        ),
                      ),

                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 4,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}