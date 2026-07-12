import 'package:flutter/material.dart';

import '../models/invernadero.dart';
import '../models/lectura_sensor.dart';
import '../services/api_service.dart';
import '../widgets/invernaderos/summary_card.dart';
import '../widgets/invernaderos/invernadero_card.dart';
import '../widgets/invernaderos/humedad_chart.dart';

class InvernaderosScreen extends StatefulWidget {
  const InvernaderosScreen({super.key});

  @override
  State<InvernaderosScreen> createState() => _InvernaderosScreenState();
}

class _InvernaderosScreenState extends State<InvernaderosScreen> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF66BB6A);
  static const Color brown = Color(0xFF5D4037);
  static const Color background = Color(0xFFF6F1F7);
  static const Color warning = Color(0xFFF57C00);
  static const Color critical = Color(0xFFD32F2F);
  static const Color infoBlue = Color(0xFF1976D2);

  final ApiService _apiService = ApiService();

  late Future<_InvernaderoData> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  Future<_InvernaderoData> _loadData() async {
    final results = await Future.wait([
      _apiService.obtenerInvernaderos(),
      _apiService.obtenerLecturasSensores(),
    ]);

    return _InvernaderoData(
      invernaderos: results[0] as List<Invernadero>,
      lecturas: results[1] as List<LecturaSensor>,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _futureData = _loadData();
    });
  }

double _ultimaLectura(List<LecturaSensor> lecturas, String filtro) {
  final filtradas = lecturas.where((lectura) {
    final nombre = lectura.nombreSensor.toLowerCase();
    final descripcion = lectura.descripcion.toLowerCase();

    return nombre.contains(filtro) || descripcion.contains(filtro);
  }).toList();

  if (filtradas.isEmpty) return 0;

  filtradas.sort((a, b) => a.id.compareTo(b.id));

  return double.tryParse(filtradas.last.valor) ?? 0;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: FutureBuilder<_InvernaderoData>(
          future: _futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryGreen,
                ),
              );
            }

            if (snapshot.hasError) {
              return _ErrorView(
                message: snapshot.error.toString(),
                onRetry: _refresh,
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text('No hay datos disponibles'),
              );
            }

            final data = snapshot.data!;
            final invernaderos = data.invernaderos;
            final lecturas = data.lecturas;

            final humedadActual = _ultimaLectura(lecturas, 'humedad');
            final temperaturaActual = _ultimaLectura(lecturas, 'temperatura');

            return RefreshIndicator(
              onRefresh: _refresh,
              color: primaryGreen,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 90),
                children: [
                  _Header(totalInvernaderos: invernaderos.length),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Invernaderos',
                          value: '${invernaderos.length}',
                          color: primaryGreen,
                          icon: Icons.grid_view_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: 'Lecturas',
                          value: '${lecturas.length}',
                          color: brown,
                          icon: Icons.sensors,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Humedad actual',
                          value: '${humedadActual.toStringAsFixed(1)}%',
                          color: infoBlue,
                          icon: Icons.water_drop_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: 'Temp. actual.',
                          value: '${temperaturaActual.toStringAsFixed(1)}°C',
                          color: warning,
                          icon: Icons.thermostat,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  HumedadChart(lecturas: lecturas),

                  const SizedBox(height: 22),

                  const Text(
                    'Invernaderos registrados',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (invernaderos.isEmpty)
                    const _EmptyView()
                  else
                    ...invernaderos.map((invernadero) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: InvernaderoCard(
                          invernadero: invernadero,
                          onTap: () {
                            _showInvernaderoDetails(
                              context,
                              invernadero,
                              lecturas,
                            );
                          },
                        ),
                      );
                    }),

                  const SizedBox(height: 24),

                  const Text(
                    'Historial general',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),//////////////////////////

                  const SizedBox(height: 12),

                  _GeneralLogCard(lecturas: lecturas),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showInvernaderoDetails(
    BuildContext context,
    Invernadero invernadero,
    List<LecturaSensor> lecturas,
  ) {
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
                          invernadero.nombre,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: brown,
                          ),
                        ),
                      ),
                      _StatusBadge(label: 'Activo', color: primaryGreen),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _DetailCard(
                    title: 'Información del invernadero',
                    children: [
                      _DetailLine(
                        icon: Icons.description_outlined,
                        label: 'Descripción',
                        value: invernadero.descripcion,
                      ),
                      _DetailLine(
                        icon: Icons.location_on_outlined,
                        label: 'Latitud',
                        value: invernadero.latitud,
                      ),
                      _DetailLine(
                        icon: Icons.location_on_outlined,
                        label: 'Longitud',
                        value: invernadero.longitud,
                      ),
                      _DetailLine(
                        icon: Icons.straighten,
                        label: 'Ancho',
                        value: '${invernadero.ancho} m',
                      ),
                      _DetailLine(
                        icon: Icons.height,
                        label: 'Alto',
                        value: '${invernadero.alto} m',
                      ),
                      _DetailLine(
                        icon: Icons.swap_horiz,
                        label: 'Largo',
                        value: '${invernadero.largo} m',
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _DetailCard(
                    title: 'Lecturas de sensores',
                    children: lecturas.isEmpty
                        ? [
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('No hay lecturas disponibles'),
                            ),
                          ]
                        : lecturas.map((lectura) {
                            return _SensorReadingCard(lectura: lectura);
                          }).toList(),
                  ),

                  const SizedBox(height: 18),

                  _DetailCard(
                    title: 'Encargados de zona',
                    children: const [
                      _StaticWorkerCard(
                        name: 'Encargado del invernadero',
                        phone: 'Sin teléfono asignado',
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _DetailCard(
                    title: 'Historial del invernadero',
                    children: const [
                      _ZoneLogItem(
                        text: 'Información actualizada desde la API',
                      ),
                      _ZoneLogItem(
                        text: 'Lecturas de sensores consultadas correctamente',
                      ),
                      _ZoneLogItem(
                        text: 'Supervisión general del invernadero activa',
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _InvernaderoData {
  final List<Invernadero> invernaderos;
  final List<LecturaSensor> lecturas;

  const _InvernaderoData({
    required this.invernaderos,
    required this.lecturas,
  });
}

class _Header extends StatelessWidget {
  final int totalInvernaderos;

  const _Header({
    required this.totalInvernaderos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _InvernaderosScreenState.primaryGreen,
            _InvernaderosScreenState.lightGreen,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión de\nInvernaderos',
            style: TextStyle(
              fontSize: 29,
              height: 1.25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Supervisando $totalInvernaderos invernadero(s) registrado(s)',
            style: const TextStyle(
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

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: _InvernaderosScreenState.critical,
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudieron cargar los datos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _InvernaderosScreenState.brown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _InvernaderosScreenState.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'No hay invernaderos registrados.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _InvernaderosScreenState.brown,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

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

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: _InvernaderosScreenState.brown,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: _InvernaderosScreenState.primaryGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _InvernaderosScreenState.brown,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _InvernaderosScreenState.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorReadingCard extends StatelessWidget {
  final LecturaSensor lectura;

  const _SensorReadingCard({
    required this.lectura,
  });

  IconData get _icon {
    final text =
        '${lectura.nombreSensor} ${lectura.descripcion}'.toLowerCase();

    if (text.contains('humedad')) {
      return Icons.water_drop_outlined;
    }

    if (text.contains('temp')) {
      return Icons.thermostat;
    }

    return Icons.sensors;
  }

  String get _unidad {
    final text =
        '${lectura.nombreSensor} ${lectura.descripcion}'.toLowerCase();

    if (text.contains('humedad')) {
      return '%';
    }

    if (text.contains('temp')) {
      return '°C';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _InvernaderosScreenState.background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: _InvernaderosScreenState.primaryGreen.withOpacity(.20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _icon,
            color: _InvernaderosScreenState.primaryGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lectura.nombreSensor,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _InvernaderosScreenState.brown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${lectura.descripcion} • ${lectura.modelo}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lectura.lecturaDatetime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${lectura.valor}$_unidad',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _InvernaderosScreenState.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticWorkerCard extends StatelessWidget {
  final String name;
  final String phone;

  const _StaticWorkerCard({
    required this.name,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _InvernaderosScreenState.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: _InvernaderosScreenState.primaryGreen,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _InvernaderosScreenState.brown,
              ),
            ),
          ),
          Text(
            phone,
            style: const TextStyle(
              color: _InvernaderosScreenState.primaryGreen,
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

  const _ZoneLogItem({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _InvernaderosScreenState.background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.history,
            color: _InvernaderosScreenState.primaryGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _InvernaderosScreenState.brown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneralLogCard extends StatelessWidget {
  final List<LecturaSensor> lecturas;

  const _GeneralLogCard({
    required this.lecturas,
  });

  @override
  Widget build(BuildContext context) {
    final ultimasLecturas = lecturas.take(3).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ultimasLecturas.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No hay historial reciente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _InvernaderosScreenState.brown,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : Column(
              children: ultimasLecturas.map((lectura) {
                return ListTile(
                  leading: const Icon(
                    Icons.sensors,
                    color: _InvernaderosScreenState.primaryGreen,
                  ),
                  title: Text(
                    '${lectura.nombreSensor}: ${lectura.valor}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _InvernaderosScreenState.brown,
                    ),
                  ),
                  subtitle: Text(lectura.lecturaDatetime),
                );
              }).toList(),
            ),
    );
  }
}