import 'package:flutter/material.dart';

import '../models/alerta_model.dart';
import '../models/activity_history_model.dart';

import '../services/alerta_service.dart';
import '../services/activity_history_service.dart';

import '../widgets/greenhouse_alert_card.dart';
import '../widgets/activity_history_card.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color brown = Color(0xFF5D4037);
  static const Color lightBackground = Color(0xFFF7F8FA);

  final AlertaService _alertaService = AlertaService();
  final ActivityHistoryService _activityService =
      ActivityHistoryService();

  List<Alerta> _alertas = [];
  List<ActivityHistoryModel> _activities = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final alertas = await _alertaService.obtenerAlertas();
      final actividades = await _activityService.obtenerActividades();

      if (!mounted) return;

      setState(() {
        _alertas = alertas;
        _activities = actividades;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No fue posible obtener la información.",
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        onPressed: cargarDatos,
        child: const Icon(Icons.refresh),
      ),

      body: RefreshIndicator(
        onRefresh: cargarDatos,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [            SliverAppBar(
              expandedHeight: 190,
              pinned: true,
              elevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: primaryGreen,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2E7D32),
                      Color(0xFF388E3C),
                      Color(0xFF66BB6A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(
                    left: 20,
                    bottom: 20,
                  ),
                  title: Text(
                    "Alertas",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Centro de monitoreo",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: brown,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Consulta las alertas y las actividades más recientes.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [

                        Expanded(
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                              ),
                              child: Column(
                                children: [

                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                    size: 34,
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    "${_alertas.length}",
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  const Text(
                                    "Alertas",
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                              ),
                              child: Column(
                                children: [

                                  const Icon(
                                    Icons.history,
                                    color: primaryGreen,
                                    size: 34,
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    "${_activities.length}",
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  const Text(
                                    "Actividades",
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),

                                       const SizedBox(height: 30),

                    if (_loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    if (!_loading) ...[
                      const Text(
                        "Alertas",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: brown,
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (_alertas.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                "No hay alertas disponibles.",
                              ),
                            ),
                          ),
                        ),

                      for (final alerta in _alertas)
                        GreenhouseAlertCard(
                          alerta: alerta,
                        ),

                      const SizedBox(height: 30),

                      const Divider(),

                      const SizedBox(height: 30),

                      const Text(
                        "Actividades recientes",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: brown,
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (_activities.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                "No hay actividades registradas.",
                              ),
                            ),
                          ),
                        ),

                                            for (final activity in _activities)
                        ActivityHistoryCard(
                          activity: activity,
                        ),

                      const SizedBox(height: 100),
                    ],
                  
                      ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}