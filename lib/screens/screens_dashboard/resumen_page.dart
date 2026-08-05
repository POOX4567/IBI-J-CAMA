import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

// Modelos de la app
import '../../models/activity_history_model.dart';
import '../../models/alerta_model.dart';
import '../../models/employee_model.dart';
import '../../models/invernadero_model.dart';

import '../../services/resumen_provider.dart';

// Vistas activas
import '../alertas_screen.dart';
import '../empleados_screen.dart';
import '../horarios_screen.dart';
import '../invernaderos_screen.dart';

class ResumenPage extends StatefulWidget {
  const ResumenPage({super.key});

  @override
  State<ResumenPage> createState() => _ResumenPageState();
}

class _ResumenPageState extends State<ResumenPage> {
  void _navegarA(BuildContext context, Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => pantalla));
  }

  void _mostrarDetalles(
    BuildContext context,
    String titulo,
    String descripcion,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(descripcion),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Entendido",
                style: TextStyle(
                  color: Color(0xFF1B5E20),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String get _fechaFormateada {
    final now = DateTime.now();
    return DateFormat('EEEE, d \'de\' MMMM', 'es').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final resumenData = context.watch<ResumenProvider>();

    if (resumenData.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
        ),
      );
    }

    final List<Invernadero> invernaderos = resumenData.invernaderos;
    final List<Employee> empleados = resumenData.empleados;
    final List<Alerta> alertas = resumenData.alertas;
    final List<ActivityHistoryModel> actividades = resumenData.actividades;

    // --- CÁLCULOS DEDUCIDOS DE LOS DATOS DE LAS APIS ---
    final int alertasCriticas = alertas
        .where(
          (a) =>
              a.severidad.toLowerCase() == 'alta' ||
              a.severidad.toLowerCase() == 'critica',
        )
        .length;

    final int alertasMedias = alertas
        .where((a) => a.severidad.toLowerCase() == 'media')
        .length;

    final int alertasBajas = alertas.length - (alertasCriticas + alertasMedias);

    final String estadoSistema = alertasCriticas > 0
        ? "Atención Requerida"
        : "Sistema Estabilizado";

    final Color colorEstado = alertasCriticas > 0
        ? const Color(0xFFDC2626)
        : const Color(0xFF16A34A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        color: const Color(0xFF1B5E20),
        onRefresh: () async {
          await context.read<ResumenProvider>().cargarDatos();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // 1. ENCABEZADO CON ALTURA AJUSTADA SIN OVERFLOW
            _buildSliverHeader(
              estadoSistema: estadoSistema,
              colorEstado: colorEstado,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. KPIS PRINCIPALES
                    _buildSectionTitle("Métricas Clave"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            title: "Invernaderos",
                            value: "${invernaderos.length}",
                            subtitle: "Sectores",
                            icon: Icons.eco_rounded,
                            color: const Color(0xFF15803D),
                            onTap: () =>
                                _navegarA(context, const InvernaderosScreen()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildKpiCard(
                            title: "Personal",
                            value: "${empleados.length}",
                            subtitle: "Especialistas",
                            icon: Icons.people_alt_rounded,
                            color: const Color(0xFF0369A1),
                            onTap: () =>
                                _navegarA(context, const EmpleadosScreen()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildKpiCard(
                            title: "Alertas",
                            value: "${alertas.length}",
                            subtitle: "$alertasCriticas críticas",
                            icon: Icons.notifications_active_rounded,
                            color: alertas.isNotEmpty
                                ? const Color(0xFFB91C1C)
                                : const Color(0xFF15803D),
                            onTap: () =>
                                _navegarA(context, const AlertasScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 3. GRÁFICA DE BARRAS: BALANCE DE RECURSOS
                    _buildSectionTitle("Balance de Infraestructura"),
                    const SizedBox(height: 12),
                    _buildBarChartCard(
                      invCount: invernaderos.length,
                      empCount: empleados.length,
                      aleCount: alertas.length,
                    ),
                    const SizedBox(height: 24),

                    // 4. GRÁFICA DE PASTEL: DESGLOSE DE ALERTAS POR SEVERIDAD
                    if (alertas.isNotEmpty) ...[
                      _buildSectionTitle(
                        "Distribución de Severidad en Alertas",
                      ),
                      const SizedBox(height: 12),
                      _buildPieChartCard(
                        criticas: alertasCriticas,
                        medias: alertasMedias,
                        bajas: alertasBajas < 0 ? 0 : alertasBajas,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // 5. GRÁFICA DE LÍNEA: TENDENCIA DE ACTIVIDADES
                    if (actividades.isNotEmpty) ...[
                      _buildSectionTitle("Frecuencia de Actividades"),
                      const SizedBox(height: 12),
                      _buildLineChartCard(actividades.length),
                      const SizedBox(height: 24),
                    ],

                    // 6. ACCESOS DIRECTOS A MÓDULOS
                    _buildSectionTitle("Módulos de Gestión"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionTile(
                            title: "Horarios y Turnos",
                            subtitle: "Planificación",
                            icon: Icons.calendar_today_rounded,
                            color: const Color(0xFF0284C7),
                            onTap: () =>
                                _navegarA(context, const HorariosScreen()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionTile(
                            title: "Centro de Alertas",
                            subtitle: "Monitoreo",
                            icon: Icons.warning_amber_rounded,
                            color: const Color(0xFF7C3AED),
                            onTap: () =>
                                _navegarA(context, const AlertasScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 7. BITÁCORA / LISTA DE ACTIVIDADES
                    if (actividades.isNotEmpty) ...[
                      _buildSectionTitle("Últimas Actividades Registradas"),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: actividades.length > 5
                              ? 5
                              : actividades.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (context, index) {
                            final act = actividades[index];
                            return ListTile(
                              onTap: () => _mostrarDetalles(
                                context,
                                act.activity,
                                "${act.description}\n\nRealizado por: ${act.userName}\nFecha: ${act.date}",
                              ),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFDCFCE7),
                                child: Text(
                                  act.userName.isNotEmpty
                                      ? act.userName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Color(0xFF15803D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                act.activity,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              subtitle: Text(
                                "${act.description}\n${act.userName} • ${act.date}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              isThreeLine: true,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
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

  // --- COMPONENTES DE GRÁFICAS ---

  Widget _buildBarChartCard({
    required int invCount,
    required int empCount,
    required int aleCount,
  }) {
    final double maxY =
        [
          invCount,
          empCount,
          aleCount,
        ].reduce((curr, next) => curr > next ? curr : next).toDouble() +
        2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxY < 5 ? 5 : maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => const Color(0xFF1E293B),
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
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text(
                              'Invernaderos',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          case 1:
                            return const Text(
                              'Personal',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          case 2:
                            return const Text(
                              'Alertas',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: invCount.toDouble(),
                        color: const Color(0xFF15803D),
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: empCount.toDouble(),
                        color: const Color(0xFF0369A1),
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: aleCount.toDouble(),
                        color: const Color(0xFFB91C1C),
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard({
    required int criticas,
    required int medias,
    required int bajas,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 130,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 30,
                  sections: [
                    if (criticas > 0)
                      PieChartSectionData(
                        value: criticas.toDouble(),
                        color: const Color(0xFFDC2626),
                        title: '$criticas',
                        radius: 35,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    if (medias > 0)
                      PieChartSectionData(
                        value: medias.toDouble(),
                        color: const Color(0xFFD97706),
                        title: '$medias',
                        radius: 35,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    if (bajas > 0)
                      PieChartSectionData(
                        value: bajas.toDouble(),
                        color: const Color(0xFF2563EB),
                        title: '$bajas',
                        radius: 35,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _legendDot("Alta / Crítica ($criticas)", const Color(0xFFDC2626)),
              const SizedBox(height: 6),
              _legendDot("Media ($medias)", const Color(0xFFD97706)),
              const SizedBox(height: 6),
              _legendDot("Baja ($bajas)", const Color(0xFF2563EB)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartCard(int totalActividades) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SizedBox(
        height: 130,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  const FlSpot(0, 1),
                  const FlSpot(1, 3),
                  const FlSpot(2, 2),
                  FlSpot(3, totalActividades.toDouble()),
                ],
                isCurved: true,
                color: const Color(0xFF16A34A),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFF16A34A).withOpacity(0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ELEMENTOS VISUALES COMPLEMENTARIOS ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildSliverHeader({
    required String estadoSistema,
    required Color colorEstado,
  }) {
    return SliverAppBar(
      expandedHeight: 170.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF14532D),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF14532D), Color(0xFF166534)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _fechaFormateada.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Panel Operativo IBI-JICAMA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.read<ResumenProvider>().cargarDatos(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorEstado,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      estadoSistema,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
