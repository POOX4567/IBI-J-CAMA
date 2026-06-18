import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // TABLE_CALENDAR
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' // FLUTTER_DATETIME_PICKER
    as picker;
import 'package:intl/intl.dart'; // INTL
import 'package:provider/provider.dart'; // PROVIDER
import 'package:flutter_slidable/flutter_slidable.dart'; // FLUTTER_SLIDABLE
import 'package:fl_chart/fl_chart.dart'; // FL_CHART
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // FLUTTER_STAGGERED_GRID_VIEW
import 'package:percent_indicator/percent_indicator.dart'; // PERCENT_INDICATOR
import 'package:animations/animations.dart'; // ANIMATIONS
import 'package:fluttertoast/fluttertoast.dart'; // FLUTTERTOAST
import 'package:dropdown_search/dropdown_search.dart'; // DROPDOWN_SEARCH

import './screens_horarios/horario.dart';
import './screens_horarios/horario_detail_screen.dart';
import './screens_horarios/horario_provider.dart';
import './screens_areas/area.dart';
import './screens_areas/area_detail_screen.dart';
import './screens_areas/area_provider.dart';
import './screens_areas/area_historial_screen.dart';
import '../widgets/alerta_card.dart';
import '../widgets/horario_card.dart';
import '../widgets/area_card.dart';
import '../widgets/notificacion_card.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/filtro_chip_widget.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  bool mostrarHorarios = true;

  // ── TABLE_CALENDAR: variables de estado ────────────────────────────────────
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // ── Templates ─────────────────────────────────────────────────────────────
  int _nextHorarioTemplate = 0;
  int _nextAreaTemplate = 0;

  final List<Horario> _horarioTemplates = const [
    Horario(
      nombre: 'Laura Ramírez',
      turno: 'Matutino',
      actividad: 'Revisión de cultivos',
      fechaInicio: '12/06/2026',
      fechaFin: '26/06/2026',
      entrada: '07:00',
      salida: '15:30',
    ),
    Horario(
      nombre: 'Pablo Suárez',
      turno: 'Vespertino',
      actividad: 'Cosecha',
      fechaInicio: '14/06/2026',
      fechaFin: '28/06/2026',
      entrada: '13:00',
      salida: '21:00',
    ),
    Horario(
      nombre: 'Elena Torres',
      turno: 'Nocturno',
      actividad: 'Monitoreo de riego',
      fechaInicio: '16/06/2026',
      fechaFin: '30/06/2026',
      entrada: '22:00',
      salida: '06:00',
    ),
  ];

  final List<Area> _areaTemplates = [
    Area(
      empleado: 'Luis Herrera',
      area: 'Invernadero C',
      cultivo: 'Fresa',
      actividad: 'Poda',
      estado: 'Pendiente',
      progreso: 0.35,
    ),
    Area(
      empleado: 'Ana García',
      area: 'Invernadero D',
      cultivo: 'Lechuga',
      actividad: 'Riego',
      estado: 'Pendiente',
      progreso: 0.25,
    ),
    Area(
      empleado: 'Diego Ramírez',
      area: 'Invernadero E',
      cultivo: 'Hierbas',
      actividad: 'Fertilización',
      estado: 'Pendiente',
      progreso: 0.15,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // PROVIDER: lee los horarios y áreas del estado global
    final horarioProvider = context.watch<HorarioProvider>();
    final areaProvider = context.watch<AreaProvider>();
    final horariosActivos = horarioProvider.horarios;
    final areasActivas = areaProvider.areas;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff1B5E20),
        title: Text(
          mostrarHorarios ? 'Gestión de Horarios' : 'Gestión de Áreas',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Resumen rápido ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff1B5E20), Color(0xff2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff1B5E20).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RESUMEN OPERATIVO',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Horarios y Áreas Activas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _resumenChip('Activos: ${horariosActivos.length}'),
                      _resumenChip(
                        'Turnos: ${horariosActivos.map((h) => h.turno).toSet().length}',
                      ),
                      _resumenChip('Registros: ${horariosActivos.length}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Toggle Horarios / Áreas ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => mostrarHorarios = true),
                      icon: const Icon(Icons.schedule_outlined, size: 20),
                      label: const Text(
                        'Horarios',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: mostrarHorarios
                            ? const Color(0xff1B5E20)
                            : Colors.transparent,
                        foregroundColor: mostrarHorarios
                            ? Colors.white
                            : const Color(0xff64748B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => mostrarHorarios = false),
                      icon: const Icon(Icons.agriculture, size: 20),
                      label: const Text(
                        'Áreas',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: !mostrarHorarios
                            ? const Color(0xff1B5E20)
                            : Colors.transparent,
                        foregroundColor: !mostrarHorarios
                            ? Colors.white
                            : const Color(0xff64748B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── EL CALENDARIO AHORA ABAJO DE LOS BOTONES ─────────────────────
            _buildCalendario(),
            const SizedBox(height: 24),

            // ANIMATIONS: transición suave al cambiar de módulo
            PageTransitionSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder:
                  (child, primaryAnimation, secondaryAnimation) =>
                      FadeThroughTransition(
                        animation: primaryAnimation,
                        secondaryAnimation: secondaryAnimation,
                        child: child,
                      ),
              child: mostrarHorarios
                  ? _buildHorarios(context, horariosActivos, horarioProvider)
                  : _buildAreas(context, areasActivas, areaProvider),
            ),
          ],
        ),
      ),
    );
  }

  // ── TABLE_CALENDAR Premium Rediseñado ────────────────────────────────────
  Widget _buildCalendario() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        locale: 'es_ES',
        rowHeight: 46,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          final fechaTexto = DateFormat(
            "EEEE d 'de' MMMM yyyy",
            'es',
          ).format(selectedDay);
          Fluttertoast.showToast(
            msg: 'Seleccionado: $fechaTexto',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: const Color(0xff1B5E20),
            textColor: Colors.white,
          );
        },
        onFormatChanged: (format) => setState(() => _calendarFormat = format),
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: BoxDecoration(
            color: Color(0xff1B5E20),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Color(0xffC8E6C9),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: Color(0xff1B5E20),
            fontWeight: FontWeight.bold,
          ),
          defaultTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xff334155),
          ),
          weekendTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xff94A3B8),
          ),
        ),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xff1E293B),
          ),
          formatButtonDecoration: BoxDecoration(
            color: Color(0xffE2E8F0),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          formatButtonTextStyle: TextStyle(
            color: Color(0xff475569),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xff475569)),
          rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xff475569)),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Color(0xff64748B),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: Color(0xff94A3B8),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ── MÓDULO HORARIOS ───────────────────────────────────────────────────────
  Widget _buildHorarios(
    BuildContext context,
    List<Horario> horarios,
    HorarioProvider provider,
  ) {
    final totalRegistros = horarios.length;
    final totalTurnos = horarios.map((h) => h.turno).toSet().length;

    var dashboardStatCard = DashboardStatCard(
      valor: '$totalRegistros',
      titulo: 'Horarios activos',
      icono: Icons.schedule_outlined,
      color: const Color(0xff2E7D32),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stats
        Row(
          crossAxisAlignment: CrossAxisAlignment
              .start, // Alinea la parte superior por si un texto es más largo
          children: [
            Expanded(child: dashboardStatCard),
            const SizedBox(width: 10),
            Expanded(
              child: DashboardStatCard(
                valor: '$totalRegistros',
                titulo: 'Empleados',
                icono: Icons.people,
                color: const Color(0xff1565C0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DashboardStatCard(
                valor: '$totalTurnos',
                titulo: 'Turnos',
                icono: Icons.calendar_month,
                color: const Color(0xffF57C00),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // FL_CHART: gráfica de horas trabajadas por turno
        _buildGraficaTurnos(horarios),
        const SizedBox(height: 20),

        // PROVIDER: filtros que actualizan la lista en tiempo real
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtros por Turno',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xff1E293B),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Todos', 'Matutino', 'Vespertino', 'Nocturno']
                    .map(
                      (turno) => FiltroChipWidget(
                        texto: turno,
                        seleccionado: provider.filtroTurno == turno,
                        onTap: () => provider.setFiltroTurno(turno),
                        icon: turno == 'Todos'
                            ? Icons.grid_view
                            : turno == 'Matutino'
                            ? Icons.wb_sunny
                            : turno == 'Vespertino'
                            ? Icons.nights_stay
                            : Icons.bedtime,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── TABLA DE EMPLEADOS (Rediseño visual integrado) ───────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.badge_outlined,
                      color: Color(0xff1B5E20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tabla de Empleados',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff1E293B),
                          ),
                        ),
                        Text(
                          '$totalRegistros asignaciones vigentes',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xffF1F5F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xff1B5E20),
                      size: 20,
                    ),
                    tooltip: 'Filtrar Fecha',
                    onPressed: () {
                      picker.DatePicker.showDatePicker(
                        context,
                        locale: picker.LocaleType.es,
                        showTitleActions: true,
                        minTime: DateTime(2020),
                        maxTime: DateTime(2030),
                        onConfirm: (date) {
                          final texto = DateFormat(
                            "d 'de' MMMM yyyy",
                            'es',
                          ).format(date);
                          Fluttertoast.showToast(
                            msg: 'Fecha filtrada: $texto',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: const Color(0xff1B5E20),
                            textColor: Colors.white,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final template =
                      _horarioTemplates[_nextHorarioTemplate %
                          _horarioTemplates.length];
                  _nextHorarioTemplate++;
                  provider.agregarHorario(template);
                  Fluttertoast.showToast(
                    msg: 'Empleado "${template.nombre}" agregado',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: const Color(0xff1B5E20),
                    textColor: Colors.white,
                  );
                },
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text(
                  'Agregar nuevo empleado',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1B5E20),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Lista de tarjetas de empleados/horarios con FLUTTER_SLIDABLE
        ...horarios.map(
          (horario) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Slidable(
              key: ValueKey(horario.nombre),
              endActionPane: ActionPane(
                motion: const BehindMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      provider.eliminarHorario(horario.nombre);
                      Fluttertoast.showToast(
                        msg: '"${horario.nombre}" eliminado',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Eliminar',
                    borderRadius: BorderRadius.circular(18),
                  ),
                ],
              ),
              child: HorarioCard(
                horario: horario,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: context.read<HorarioProvider>(),
                      child: HorarioDetailScreen(horario: horario),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Alertas
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alertas del Sistema',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xff1E293B),
                ),
              ),
              const SizedBox(height: 16),
              AlertaCard(
                color: Colors.orange,
                icon: Icons.warning_amber_rounded,
                texto: 'Horas extra detectadas',
                onTap: () => _showAlerta(
                  context,
                  'Horas extra detectadas',
                  'Juan Pérez registró 4 horas extra durante la semana.',
                ),
              ),
              const SizedBox(height: 12),
              AlertaCard(
                color: Colors.red,
                icon: Icons.error_outline_rounded,
                texto: 'Conflicto de horarios',
                onTap: () => _showAlerta(
                  context,
                  'Conflicto de horarios',
                  'Existe un conflicto entre los horarios asignados a María López.',
                ),
              ),
              const SizedBox(height: 12),
              AlertaCard(
                color: Colors.green,
                icon: Icons.sync_alt_rounded,
                texto: 'Cambio de turno pendiente',
                onTap: () => _showAlerta(
                  context,
                  'Cambio de turno pendiente',
                  'Carlos Mendoza solicitó un cambio de turno para la próxima semana.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── MÓDULO ÁREAS ──────────────────────────────────────────────────────────
  Widget _buildAreas(
    BuildContext context,
    List<Area> areasList,
    AreaProvider areaProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff2E7D32), Color(0xff43A047)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Asignación de Áreas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Supervisión inteligente agrícola',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // DROPDOWN_SEARCH: búsqueda de área/responsable
        DropdownSearch<String>(
          items: (filter, _) {
            final nombres = areasList.map((a) => a.area).toList();
            if (filter.isEmpty) return nombres;
            return nombres
                .where((n) => n.toLowerCase().contains(filter.toLowerCase()))
                .toList();
          },
          onSelected: (value) {
            if (value != null) {
              areaProvider.setBusqueda(value);
            } else {
              areaProvider.setBusqueda('');
            }
          },
          decoratorProps: const DropDownDecoratorProps(
            decoration: InputDecoration(
              labelText: 'Buscar área o responsable',
              labelStyle: TextStyle(color: Color(0xff64748B), fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Color(0xff1B5E20)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          popupProps: const PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(hintText: 'Buscar...'),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // FLUTTER_STAGGERED_GRID_VIEW: resumen con grid dinámico
        StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            StaggeredGridTile.fit(
              crossAxisCellCount: 1,
              child: _summaryCard(
                icon: Icons.pending_actions,
                title:
                    '${areasList.where((a) => a.estado.toLowerCase().contains("pendiente")).length}',
                subtitle: 'Pendientes',
                color: Colors.orange,
              ),
            ),
            StaggeredGridTile.fit(
              crossAxisCellCount: 1,
              child: _summaryCard(
                icon: Icons.check_circle_outline_rounded,
                title:
                    '${areasList.where((a) => a.estado.toLowerCase().contains("completado")).length}',
                subtitle: 'Completadas',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Panel + botón agregar
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Panel de Supervisión',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1E293B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Controla tus invernaderos instalados.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final template =
                      _areaTemplates[_nextAreaTemplate % _areaTemplates.length];
                  _nextAreaTemplate++;
                  areaProvider.agregarArea(template);
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Añadir',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1B5E20),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // FLUTTER_STAGGERED_GRID_VIEW: tarjetas de áreas con FLUTTER_SLIDABLE
        StaggeredGrid.count(
          crossAxisCount: 1,
          mainAxisSpacing: 12,
          children: areasList
              .map(
                (area) => StaggeredGridTile.fit(
                  crossAxisCellCount: 1,
                  child: Slidable(
                    key: ValueKey(area.area),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) =>
                              areaProvider.eliminarArea(area.area),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Eliminar',
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ],
                    ),
                    child: AreaCard(
                      area: area,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: areaProvider,
                            child: AreaDetailScreen(area: area),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),

        // Centro de alertas
        const Text(
          'Centro de Alertas de Monitoreo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xff1E293B),
          ),
        ),
        const SizedBox(height: 12),
        NotificacionCard(
          texto: 'Actividad atrasada detectada',
          descripcion:
              'Revisa el área pendiente para evitar retrasos en la cosecha.',
          color: Colors.red,
          icono: Icons.warning_amber_rounded,
          onTap: () => _showAlerta(
            context,
            'Actividad atrasada detectada',
            'Se ha detectado una actividad atrasada en el Invernadero A.',
          ),
        ),
        NotificacionCard(
          texto: 'Cambio de asignación realizado',
          descripcion: 'La asignación ha sido actualizada correctamente.',
          color: Colors.blue,
          icono: Icons.swap_horiz,
          onTap: () => _showAlerta(
            context,
            'Cambio de asignación realizado',
            'El personal ha sido reasignado y los turnos han sido actualizados.',
          ),
        ),
        NotificacionCard(
          texto: 'Sobrecarga detectada en Área B',
          descripcion: 'El área B tiene más tareas asignadas de las previstas.',
          color: Colors.amber,
          icono: Icons.error_outline,
          onTap: () => _showAlerta(
            context,
            'Sobrecarga detectada en Área B',
            'El área B tiene una asignación excesiva de tareas.',
          ),
        ),
        const SizedBox(height: 24),

        _buildProductividadSemanal(areasList),
        const SizedBox(height: 20),
        _buildResumenDelDia(context, areasList),
      ],
    );
  }

  // ── FL_CHART: gráfica de barras de turnos ──────────────────────────────
  Widget _buildGraficaTurnos(List<Horario> horarios) {
    final Map<String, int> conteo = {};
    for (final h in horarios) {
      conteo[h.turno] = (conteo[h.turno] ?? 0) + 1;
    }
    final turnos = conteo.keys.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución de Turnos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E293B),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (horarios.length + 2).toDouble(),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i < 0 || i >= turnos.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            turnos[i],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff475569),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: turnos.asMap().entries.map((e) {
                  const colors = [
                    Color(0xff1E88E5),
                    Color(0xffFB8C00),
                    Color(0xff6A1B9A),
                  ];
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: conteo[e.value]!.toDouble(),
                        color: colors[e.key % colors.length],
                        width: 24,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Productividad semanal con PERCENT_INDICATOR ────────────────────────
  Widget _buildProductividadSemanal(List<Area> areas) {
    final cultivos = [
      {'nombre': 'Tomate', 'valor': 0.9, 'color': Colors.green},
      {'nombre': 'Pepino', 'valor': 0.6, 'color': Colors.orange},
      {'nombre': 'Chile', 'valor': 0.8, 'color': Colors.blue},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bar_chart, color: Color(0xff1B5E20)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Productividad Semanal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Revisa el rendimiento estimado de cada cultivo.',
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          ...cultivos.map((c) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        c['nombre'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xff334155),
                        ),
                      ),
                      Text(
                        '${((c['valor'] as double) * 100).round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: c['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 10.0,
                    percent: c['valor'] as double,
                    animation: true,
                    animationDuration: 900,
                    progressColor: c['color'] as Color,
                    backgroundColor: const Color(0xffEDF4F0),
                    barRadius: const Radius.circular(10),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Resumen del día ────────────────────────────────────────────────────
  Widget _buildResumenDelDia(BuildContext context, List<Area> areas) {
    final pendientes = areas
        .where((a) => a.estado.toLowerCase().contains('pendiente'))
        .length;
    final completadas = areas
        .where((a) => a.estado.toLowerCase().contains('completado'))
        .length;
    final supervision = areas
        .where((a) => !a.estado.toLowerCase().contains('completado'))
        .length;
    final productividadGeneral = areas.isEmpty
        ? 0
        : (areas.map((a) => a.progreso).reduce((v, e) => v + e) /
                  areas.length *
                  100)
              .round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xffE8F5E9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.dashboard_customize_outlined,
                color: Color(0xff1B5E20),
              ),
              SizedBox(width: 12),
              Text(
                'Resumen del Día',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildResumenRow(
            Icons.pending_actions,
            '$pendientes actividades pendientes',
          ),
          const SizedBox(height: 12),
          _buildResumenRow(
            Icons.check_circle_outline,
            '$completadas actividades completadas',
          ),
          const SizedBox(height: 12),
          _buildResumenRow(
            Icons.warning_amber_rounded,
            '$supervision áreas requieren supervisión',
          ),
          const SizedBox(height: 12),
          _buildResumenRow(
            Icons.moving_rounded,
            'Productividad general: $productividadGeneral%',
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AreaHistorialScreen(areas: areas),
                ),
              );
            },
            icon: const Icon(Icons.history_toggle_off_rounded, size: 20),
            label: const Text(
              'Reporte Completo de Actividades',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1B5E20),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xff1B5E20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff2E7D32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _resumenChip(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
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
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAlerta(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
      ),
    );
  }
}
