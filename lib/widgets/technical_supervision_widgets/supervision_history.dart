import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ibi/models/lectura_sensor_model.dart';
import '../../utils/supervision_helpers.dart';

class SupervisionHistory extends StatefulWidget {
  final List<LecturaSensor> lecturas;

  const SupervisionHistory({Key? key, required this.lecturas})
    : super(key: key);

  @override
  State<SupervisionHistory> createState() => _SupervisionHistoryState();
}

class _SupervisionHistoryState extends State<SupervisionHistory> {
  bool showHistory = false;

  List<LecturaSensor> get _sortedLecturas {
    final sorted = List<LecturaSensor>.from(widget.lecturas)
      ..sort((a, b) => b.lecturaDatetime.compareTo(a.lecturaDatetime));
    return sorted.take(15).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lecturas = _sortedLecturas;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => showHistory = !showHistory),
            child: Container(
              padding: const EdgeInsets.all(14),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Historial de Lecturas",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF2E3A4B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lecturas.isEmpty
                            ? "Sin lecturas registradas"
                            : "Últimas ${lecturas.length} lecturas",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  Icon(
                    showHistory
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 20,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          if (showHistory)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
              child: Column(
                children: lecturas.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            "No hay lecturas disponibles",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      ]
                    : lecturas.map((lectura) {
                        final model = lectura.sensor?.modelo ?? '';
                        final isDht = model.toLowerCase().contains('dht');
                        final isBh = model.toLowerCase().contains('bh');

                        IconData icon;
                        Color iconBg;
                        Color iconColor;
                        String unit;

                        if (isDht) {
                          icon = LucideIcons.thermometer;
                          iconBg = Colors.orange[50]!;
                          iconColor = Colors.orange[700]!;
                          unit = '°C';
                        } else if (isBh) {
                          icon = LucideIcons.sun;
                          iconBg = Colors.amber[50]!;
                          iconColor = Colors.amber[700]!;
                          unit = ' lux';
                        } else if (model
                            .toLowerCase()
                            .contains('hum')) {
                          icon = LucideIcons.droplets;
                          iconBg = Colors.blue[50]!;
                          iconColor = Colors.blue[700]!;
                          unit = '%';
                        } else {
                          icon = LucideIcons.cpu;
                          iconBg = Colors.grey[100]!;
                          iconColor = Colors.blueGrey[600]!;
                          unit = '';
                        }

                        final relTime = SupervisionHelpers.relativeTime(
                          lectura.lecturaDatetime,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: iconBg,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Icon(icon, size: 16, color: iconColor),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lectura.sensor?.nombre ??
                                            'Sensor #${lectura.sensorId}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Color(0xFF1E293B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          if (model.isNotEmpty)
                                            Text(
                                              model,
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 11,
                                              ),
                                            ),
                                          if (model.isNotEmpty && relTime.isNotEmpty)
                                            Text(
                                              '  ·  ',
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                                fontSize: 11,
                                              ),
                                            ),
                                          if (relTime.isNotEmpty)
                                            Text(
                                              relTime,
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 11,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${lectura.valor}$unit',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
