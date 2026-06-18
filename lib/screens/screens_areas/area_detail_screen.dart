import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart'; // PERCENT_INDICATOR
import 'package:animations/animations.dart'; // ANIMATIONS
import 'package:fluttertoast/fluttertoast.dart'; // FLUTTERTOAST
import 'package:flutter_slidable/flutter_slidable.dart'; // FLUTTER_SLIDABLE
import 'package:provider/provider.dart'; // PROVIDER
import 'area.dart';
import 'area_provider.dart';

class AreaDetailScreen extends StatelessWidget {
  final Area area;

  const AreaDetailScreen({super.key, required this.area});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff1B5E20),
        title: Text(area.area),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header con ANIMATIONS: FadeScaleTransition ───────────────────
            PageTransitionSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder:
                  (child, primaryAnimation, secondaryAnimation) =>
                      FadeScaleTransition(
                        animation: primaryAnimation,
                        child: child,
                      ),
              child: Container(
                key: ValueKey(area.area),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff1B5E20), Color(0xff43A047)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(area.icono, color: Colors.white, size: 34),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            area.area,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Supervisor: ${area.empleado}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              area.estado,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Badges info ──────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _infoBadge(
                    icon: Icons.agriculture,
                    title: 'Cultivo',
                    value: area.cultivo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoBadge(
                    icon: Icons.build,
                    title: 'Actividad',
                    value: area.actividad,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── Progreso con PERCENT_INDICATOR ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Progreso actual',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // PERCENT_INDICATOR: círculo de progreso animado
                  Center(
                    child: CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 14.0,
                      animation: true,
                      animationDuration: 1200,
                      percent: area.progreso,
                      center: Text(
                        '${(area.progreso * 100).round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: area.statusColor,
                        ),
                      ),
                      progressColor: area.statusColor,
                      backgroundColor: const Color(0xffE8F5E9),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // PERCENT_INDICATOR: barra lineal de progreso
                  LinearPercentIndicator(
                    lineHeight: 14.0,
                    percent: area.progreso,
                    animation: true,
                    animationDuration: 1000,
                    progressColor: area.statusColor,
                    backgroundColor: const Color(0xffE8F5E9),
                    barRadius: const Radius.circular(14),
                    center: Text(
                      '${(area.progreso * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _detailRow(Icons.person, 'Supervisor', area.empleado),
                  const SizedBox(height: 16),
                  _detailRow(Icons.eco, 'Cultivo', area.cultivo),
                  const SizedBox(height: 16),
                  _detailRow(Icons.agriculture, 'Actividad', area.actividad),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── FLUTTER_SLIDABLE: acciones rápidas sobre el área ─────────────
            Slidable(
              key: ValueKey(area.area),
              startActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      // PROVIDER + FLUTTERTOAST: eliminar área con toast
                      context.read<AreaProvider>().eliminarArea(area.area);
                      Navigator.pop(context);
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Eliminar',
                    borderRadius: BorderRadius.circular(18),
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      // FLUTTERTOAST: confirmación de edición
                      Fluttertoast.showToast(
                        msg: 'Edición de "${area.area}" próximamente',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: const Color(0xff1B5E20),
                        textColor: Colors.white,
                      );
                    },
                    backgroundColor: const Color(0xff1B5E20),
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Editar',
                    borderRadius: BorderRadius.circular(18),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.swipe, color: Color(0xff1B5E20)),
                    SizedBox(width: 12),
                    Text(
                      'Desliza para editar o eliminar esta área',
                      style: TextStyle(
                        color: Color(0xff2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ── Notas ─────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xffE8F5E9),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Notas de supervisión',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Mantén el riego constante, revisa plagas y ajusta las '
                    'tareas de poda en función del progreso actual del cultivo.',
                    style: TextStyle(height: 1.5, color: Color(0xff2E7D32)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBadge({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xffE8F5E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xff1B5E20), size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xffE8F5E9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xff1B5E20), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
