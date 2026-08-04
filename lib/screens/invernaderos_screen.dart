import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvernaderosScreen extends StatelessWidget {
  const InvernaderosScreen({super.key});

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF66BB6A);
  static const Color brown = Color(0xFF5D4037);
  static const Color background = Color(0xFFF6F1F7);
  static const Color warning = Color(0xFFF57C00);
  static const Color critical = Color(0xFFD32F2F);
  static const Color infoBlue = Color(0xFF1976D2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 90),
          children: [
            _Header(),

            const SizedBox(height: 16),

            const Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Zonas activas',
                    value: '3',
                    color: primaryGreen,
                    icon: Icons.grid_view_rounded,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Total de camas',
                    value: '9',
                    color: brown,
                    icon: Icons.grass,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Cultivos',
                    value: '2',
                    color: warning,
                    icon: Icons.eco,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Alertas',
                    value: '2',
                    color: critical,
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
              ],
            ),

            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Humedad promedio semanal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),

                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const dias = [
                                  'L',
                                  'M',
                                  'M',
                                  'J',
                                  'V',
                                  'S',
                                  'D',
                                ];

                                if (value.toInt() >= 0 &&
                                    value.toInt() < dias.length) {
                                  return Text(dias[value.toInt()]);
                                }

                                return const Text('');
                              },
                            ),
                          ),
                        ),

                        borderData: FlBorderData(show: true),

                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            spots: const [
                              FlSpot(0, 45),
                              FlSpot(1, 50),
                              FlSpot(2, 47),
                              FlSpot(3, 60),
                              FlSpot(4, 55),
                              FlSpot(5, 62),
                              FlSpot(6, 58),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Zonas del invernadero',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),

            const SizedBox(height: 12),

            _ZoneCard(
              zoneName: 'Zona A',
              beds: '3 camas',
              crops: 'Jícama, Tomate',
              status: 'Estable',
              statusColor: primaryGreen,
              responsible: '2 encargados',
              lastReview: 'Hoy, 08:30 AM',
              onTap: () {
                _showZoneDetails(
                  context,
                  zoneName: 'Zona A',
                  status: 'Estable',
                  statusColor: primaryGreen,
                  beds: const [
                    _BedData(
                      'Cama 1',
                      'Jícama',
                      '26.5°C',
                      '45%',
                      'Estable',
                      primaryGreen,
                    ),
                    _BedData(
                      'Cama 2',
                      'Jícama',
                      '27.1°C',
                      '48%',
                      'Estable',
                      primaryGreen,
                    ),
                    _BedData(
                      'Cama 3',
                      'Tomate',
                      '29.4°C',
                      '35%',
                      'Advertencia',
                      warning,
                    ),
                  ],
                  workers: const [
                    _WorkerData('Juan Pérez', '999 123 4567'),
                    _WorkerData('Ana López', '999 222 3344'),
                  ],
                  logs: const [
                    'Revisión completada por encargado',
                    'Cama 3 marcada en advertencia',
                    'Actualización de sensores registrada',
                  ],
                );
              },
            ),

            const SizedBox(height: 14),

            _ZoneCard(
              zoneName: 'Zona B',
              beds: '4 camas',
              crops: 'Jícama, tomate',
              status: 'Advertencia',
              statusColor: warning,
              responsible: '1 encargado',
              lastReview: 'Hoy, 09:10 AM',
              onTap: () {
                _showZoneDetails(
                  context,
                  zoneName: 'Zona B',
                  status: 'Advertencia',
                  statusColor: warning,
                  beds: const [
                    _BedData(
                      'Cama 1',
                      'Jícama',
                      '31.2°C',
                      '32%',
                      'Advertencia',
                      warning,
                    ),
                    _BedData(
                      'Cama 2',
                      'Jícama',
                      '30.8°C',
                      '34%',
                      'Advertencia',
                      warning,
                    ),
                    _BedData(
                      'Cama 3',
                      'tomate',
                      '28.7°C',
                      '41%',
                      'Estable',
                      primaryGreen,
                    ),
                    _BedData(
                      'Cama 4',
                      'Jícama',
                      '29.9°C',
                      '37%',
                      'Estable',
                      primaryGreen,
                    ),
                  ],
                  workers: const [_WorkerData('Marcos Chan', '999 555 7812')],
                  logs: const [
                    'Humedad baja detectada en cama 1',
                    'Revisión pendiente de aspersores',
                    'Zona marcada como advertencia',
                  ],
                );
              },
            ),

            const SizedBox(height: 14),

            _ZoneCard(
              zoneName: 'Zona C',
              beds: '2 camas',
              crops: 'Jícama',
              status: 'Crítico',
              statusColor: critical,
              responsible: '1 encargado',
              lastReview: 'Hoy, 07:45 AM',
              onTap: () {
                _showZoneDetails(
                  context,
                  zoneName: 'Zona C',
                  status: 'Crítico',
                  statusColor: critical,
                  beds: const [
                    _BedData(
                      'Cama 1',
                      'Jícama',
                      '34.8°C',
                      '25%',
                      'Crítico',
                      critical,
                    ),
                    _BedData(
                      'Cama 2',
                      'Jícama',
                      '33.9°C',
                      '28%',
                      'Crítico',
                      critical,
                    ),
                  ],
                  workers: const [_WorkerData('Elena Vance', '999 777 9012')],
                  logs: const [
                    'Alerta crítica generada',
                    'Sensor de humedad requiere revisión',
                    'Se notificó al área de mantenimiento',
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Historial general',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),

            const SizedBox(height: 12),

            const _GeneralLogCard(),
          ],
        ),
      ),
    );
  }

  static void _showZoneDetails(
    BuildContext context, {
    required String zoneName,
    required String status,
    required Color statusColor,
    required List<_BedData> beds,
    required List<_WorkerData> workers,
    required List<String> logs,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.86,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              decoration: const BoxDecoration(
                color: background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Detalle de $zoneName',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: brown,
                          ),
                        ),
                      ),
                      _StatusBadge(label: status, color: statusColor),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Camas de cultivo',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...beds.map((bed) => _BedCard(bed: bed)),

                  const SizedBox(height: 18),

                  const Text(
                    'Encargados de zona',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...workers.map((worker) => _WorkerCard(worker: worker)),

                  const SizedBox(height: 18),

                  const Text(
                    'Historial de la zona',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...logs.map((log) => _ZoneLogItem(text: log)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            InvernaderosScreen.primaryGreen,
            InvernaderosScreen.lightGreen,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión de\nInvernaderos',
            style: TextStyle(
              fontSize: 29,
              height: 1.25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Supervisando 3 zonas y 9 camas de cultivo',
            style: TextStyle(
              fontSize: 17,
              height: 1.4,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.75), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final String zoneName;
  final String beds;
  final String crops;
  final String status;
  final Color statusColor;
  final String responsible;
  final String lastReview;
  final VoidCallback onTap;

  const _ZoneCard({
    required this.zoneName,
    required this.beds,
    required this.crops,
    required this.status,
    required this.statusColor,
    required this.responsible,
    required this.lastReview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: statusColor, width: 5)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.09),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    zoneName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: InvernaderosScreen.brown,
                    ),
                  ),
                ),
                _StatusBadge(label: status, color: statusColor),
              ],
            ),

            const SizedBox(height: 14),

            _InfoLine(
              icon: Icons.view_agenda_outlined,
              label: 'Cantidad de camas',
              value: beds,
            ),
            _InfoLine(
              icon: Icons.eco_outlined,
              label: 'Cultivos',
              value: crops,
            ),
            _InfoLine(
              icon: Icons.people_alt_outlined,
              label: 'Encargados',
              value: responsible,
            ),
            _InfoLine(
              icon: Icons.access_time,
              label: 'Última revisión',
              value: lastReview,
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Ver detalles'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: InvernaderosScreen.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, size: 20, color: InvernaderosScreen.brown),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: InvernaderosScreen.brown,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: InvernaderosScreen.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _BedData {
  final String name;
  final String crop;
  final String temperature;
  final String humidity;
  final String status;
  final Color statusColor;

  const _BedData(
    this.name,
    this.crop,
    this.temperature,
    this.humidity,
    this.status,
    this.statusColor,
  );
}

class _WorkerData {
  final String name;
  final String phone;

  const _WorkerData(this.name, this.phone);
}

class _BedCard extends StatelessWidget {
  final _BedData bed;

  const _BedCard({required this.bed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: bed.statusColor, width: 4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bed.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: InvernaderosScreen.brown,
                  ),
                ),
              ),
              _StatusBadge(label: bed.status, color: bed.statusColor),
            ],
          ),
          const SizedBox(height: 10),
          _InfoLine(icon: Icons.eco, label: 'Cultivo', value: bed.crop),
          _InfoLine(
            icon: Icons.thermostat,
            label: 'Temperatura',
            value: bed.temperature,
          ),
          _InfoLine(
            icon: Icons.water_drop_outlined,
            label: 'Humedad',
            value: bed.humidity,
          ),
        ],
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  final _WorkerData worker;

  const _WorkerCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: InvernaderosScreen.primaryGreen,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              worker.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: InvernaderosScreen.brown,
              ),
            ),
          ),
          Text(
            worker.phone,
            style: const TextStyle(
              color: InvernaderosScreen.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneLogItem extends StatelessWidget {
  final String text;

  const _ZoneLogItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: InvernaderosScreen.primaryGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: InvernaderosScreen.brown),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneralLogCard extends StatelessWidget {
  const _GeneralLogCard();

  @override
  Widget build(BuildContext context) {
    final logs = [
      [
        'Zona B marcada en advertencia',
        'Hace 15 min',
        Icons.warning_amber_rounded,
        InvernaderosScreen.warning,
      ],
      [
        'Sensores actualizados en Zona A',
        'Hace 30 min',
        Icons.sensors,
        InvernaderosScreen.primaryGreen,
      ],
      [
        'Alerta crítica generada en Zona C',
        'Hace 1 hora',
        Icons.error_outline,
        InvernaderosScreen.critical,
      ],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: logs.map((log) {
          return ListTile(
            leading: Icon(log[2] as IconData, color: log[3] as Color),
            title: Text(
              log[0] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: InvernaderosScreen.brown,
              ),
            ),
            subtitle: Text(log[1] as String),
          );
        }).toList(),
      ),
    );
  }
}
