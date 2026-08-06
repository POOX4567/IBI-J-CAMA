import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // INTL
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker; // FLUTTER_DATETIME_PICKER
import 'package:provider/provider.dart'; // PROVIDER
import 'package:fluttertoast/fluttertoast.dart'; // FLUTTERTOAST

import 'horario.dart';
import 'horario_provider.dart';

class HorarioFormScreen extends StatefulWidget {
  final Horario? horario;

  const HorarioFormScreen({super.key, this.horario});

  bool get esEdicion => horario != null;

  static Future<bool?> show(
    BuildContext context, {
    Horario? horario,
    required HorarioProvider provider,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: HorarioFormScreen(horario: horario),
      ),
    );
  }

  @override
  State<HorarioFormScreen> createState() => _HorarioFormScreenState();
}

class _HorarioFormScreenState extends State<HorarioFormScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _empleadoId;
  String? _empleadoNombre;
  String? _turno;

  // 👇 CAMBIO: ya no hay un TextEditingController de actividad, ahora es
  // un id que se selecciona de un dropdown (tabla 'activities').
  int? _activityId;

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  TimeOfDay? _horaEntrada;
  TimeOfDay? _horaSalida;
  bool _guardando = false;

  // ── estado propio para saber si la carga de empleados falló ──────
  bool _cargandoEmpleados = false;
  String? _errorEmpleados;

  // ── NUEVO: estado propio para saber si la carga de actividades falló ──
  bool _cargandoActividades = false;
  String? _errorActividades;

  final _turnos = const ['Matutino', 'Vespertino'];

  @override
  void initState() {
    super.initState();

    final h = widget.horario;

    if (h != null) {
      // ── Precarga de TODOS los campos en modo edición ──────────────────
      _empleadoId = h.empleadoId;
      _empleadoNombre = h.nombre;
      _turno = h.turno;
      _activityId = h.activityId == 0 ? null : h.activityId;
      _fechaInicio = _parsearFecha(h.fechaInicio);
      _fechaFin = _parsearFecha(h.fechaFin);
      _horaEntrada = _parsearHora(h.entrada);
      _horaSalida = _parsearHora(h.salida);
    }

    // Asegura que los dropdowns de empleados y actividades tengan datos
    // frescos.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _cargarEmpleados();
        _cargarActividades();
      }
    });
  }

  // ── carga los empleados y captura/expone cualquier error ────────
  Future<void> _cargarEmpleados() async {
    setState(() {
      _cargandoEmpleados = true;
      _errorEmpleados = null;
    });
    try {
      final provider = context.read<HorarioProvider>();
      await provider.cargarEmpleados();
      // Si el provider guardó un error internamente durante la carga,
      // lo mostramos aquí en vez de dejarlo oculto.
      if (provider.error != null && provider.empleados.isEmpty) {
        _errorEmpleados = provider.error;
      } else if (provider.empleados.isEmpty) {
        _errorEmpleados =
            'El servidor respondió correctamente pero no devolvió ningún '
            'empleado. Verifica el endpoint "/employees" en el backend.';
      }
    } catch (e) {
      _errorEmpleados = 'No se pudo conectar con el servidor: $e';
    }
    if (mounted) {
      setState(() => _cargandoEmpleados = false);
    }
  }

  // ── carga las actividades (tabla 'activities') y captura/expone
  // cualquier error, igual que se hace con empleados. ──────────────────
  Future<void> _cargarActividades() async {
    setState(() {
      _cargandoActividades = true;
      _errorActividades = null;
    });
    try {
      final provider = context.read<HorarioProvider>();
      await provider.cargarActividades();
      if (provider.error != null && provider.actividades.isEmpty) {
        _errorActividades = provider.error;
      } else if (provider.actividades.isEmpty) {
        _errorActividades =
            'El servidor respondió correctamente pero no devolvió ninguna '
            'actividad. Verifica el endpoint "/activities" en el backend.';
      }
    } catch (e) {
      _errorActividades = 'No se pudo conectar con el servidor: $e';
    }
    if (mounted) {
      setState(() => _cargandoActividades = false);
    }
  }

  // ── Diálogo rápido para crear una actividad sin salir del formulario
  // de horario. Hace POST a /activities (con user_id, activity,
  // description y date, tal cual la tabla real) vía el provider y, si
  // sale bien, la deja preseleccionada en el dropdown. ────────────────
  Future<void> _agregarActividadRapida(HorarioProvider provider) async {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    DateTime fecha = DateTime.now();

    final creada = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nueva actividad'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nombreController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Actividad',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descripcionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    picker.DatePicker.showDatePicker(
                      ctx,
                      locale: picker.LocaleType.es,
                      showTitleActions: true,
                      minTime: DateTime(2020),
                      maxTime: DateTime(2030),
                      currentTime: fecha,
                      onConfirm: (date) {
                        setDialogState(() => fecha = date);
                      },
                    );
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    child: Text(
                      DateFormat("d 'de' MMMM yyyy", 'es').format(fecha),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nombre = nombreController.text.trim();
                if (nombre.isEmpty) return;

                // 👇 NUEVO: si no hay empleado seleccionado en el form principal,
                // no se puede crear la actividad (el backend la necesita ligada
                // a un empleado, no al jefe).
                if (_empleadoId == null) {
                  Fluttertoast.showToast(
                    msg: 'Selecciona primero un empleado arriba',
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return;
                }

                final nueva = await provider.crearNuevaActividad(
                  actividad: nombre,
                  empleadoId: _empleadoId!, // 👈 NUEVO
                  descripcion: descripcionController.text.trim(),
                  fecha: fecha,
                );
                if (ctx.mounted) Navigator.pop(ctx, nueva);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1B5E20),
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (creada != null && mounted) {
      setState(() => _activityId = _idComoInt(creada['id']));
      Fluttertoast.showToast(
        msg: '"${creada['name']}" agregada',
        backgroundColor: const Color(0xff1B5E20),
        textColor: Colors.white,
      );
    } else if (provider.error != null && mounted) {
      Fluttertoast.showToast(
        msg: provider.error ?? 'Error al crear la actividad',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // ── Parsers robustos para precargar datos existentes ────────────────────
  DateTime? _parsearFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return null;
    for (final formato in ['yyyy-MM-dd', 'dd/MM/yyyy']) {
      try {
        return DateFormat(formato).parseStrict(fecha);
      } catch (_) {}
    }
    return DateTime.tryParse(fecha);
  }

  TimeOfDay? _parsearHora(String? hora) {
    if (hora == null || hora.isEmpty) return null;
    final partes = hora.split(':');
    if (partes.length < 2) return null;
    final h = int.tryParse(partes[0]);
    final m = int.tryParse(partes[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _fmtFecha(DateTime? d) => d == null
      ? 'Seleccionar'
      : DateFormat("d 'de' MMMM yyyy", 'es').format(d);

  String _fmtHora(TimeOfDay? t) =>
      t == null ? 'Seleccionar' : t.format(context);

  String _horaParaApi(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  int? _idComoInt(dynamic id) {
    if (id == null) return null;
    if (id is int) return id;
    return int.tryParse('$id');
  }

  Future<void> _elegirFecha({required bool esInicio}) async {
    picker.DatePicker.showDatePicker(
      context,
      locale: picker.LocaleType.es,
      showTitleActions: true,
      minTime: DateTime(2020),
      maxTime: DateTime(2030),
      currentTime: (esInicio ? _fechaInicio : _fechaFin) ?? DateTime.now(),
      onConfirm: (date) {
        setState(() {
          if (esInicio) {
            _fechaInicio = date;
          } else {
            _fechaFin = date;
          }
        });
      },
    );
  }

  Future<void> _elegirHora({required bool esEntrada}) async {
    final resultado = await showTimePicker(
      context: context,
      initialTime: (esEntrada ? _horaEntrada : _horaSalida) ?? TimeOfDay.now(),
    );
    if (resultado != null) {
      setState(() {
        if (esEntrada) {
          _horaEntrada = resultado;
        } else {
          _horaSalida = resultado;
        }
      });
    }
  }

  Future<void> _guardar(HorarioProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    if (_empleadoId == null ||
        _turno == null ||
        _activityId == null ||
        _fechaInicio == null ||
        _fechaFin == null ||
        _horaEntrada == null ||
        _horaSalida == null) {
      Fluttertoast.showToast(
        msg: 'Completa todos los campos',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (_fechaFin!.isBefore(_fechaInicio!)) {
      Fluttertoast.showToast(
        msg: 'La fecha fin no puede ser anterior a la fecha inicio',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _guardando = true);

    final bool ok;
    if (widget.esEdicion) {
      // ── MODO EDICIÓN: actualiza el horario existente ────────────────
      ok = await provider.actualizarHorarioCompleto(
        id: widget.horario!.id!,
        empleadoId: _empleadoId!,
        nombre: _empleadoNombre ?? '',
        turno: _turno!,
        activityId: _activityId!,
        fechaInicio: DateFormat('yyyy-MM-dd').format(_fechaInicio!),
        fechaFin: DateFormat('yyyy-MM-dd').format(_fechaFin!),
        horaEntrada: _horaParaApi(_horaEntrada!),
        horaSalida: _horaParaApi(_horaSalida!),
      );
    } else {
      // ── MODO CREACIÓN: crea un horario nuevo ────────────────────────
      ok = await provider.crearNuevoHorario(
        empleadoId: _empleadoId!,
        nombre: _empleadoNombre ?? '',
        turno: _turno!,
        activityId: _activityId!,
        fechaInicio: DateFormat('yyyy-MM-dd').format(_fechaInicio!),
        fechaFin: DateFormat('yyyy-MM-dd').format(_fechaFin!),
        horaEntrada: _horaParaApi(_horaEntrada!),
        horaSalida: _horaParaApi(_horaSalida!),
      );
    }

    setState(() => _guardando = false);

    if (ok && mounted) {
      Navigator.pop(
        context,
        true,
      ); // devuelve true para refrescar la pantalla anterior
      Fluttertoast.showToast(
        msg: widget.esEdicion
            ? 'Horario actualizado con éxito'
            : 'Horario creado con éxito',
        backgroundColor: const Color(0xff1B5E20),
        textColor: Colors.white,
      );
    } else if (mounted) {
      Fluttertoast.showToast(
        msg: provider.error ?? 'Error al guardar el horario',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HorarioProvider>();
    final size = MediaQuery.of(context).size;

    // ── Dialog centrado: el resto de la pantalla se ve detrás, oscurecida ──
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: size.width > 520 ? 480 : size.width - 40,
        constraints: BoxConstraints(maxHeight: size.height * 0.85),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header del modal ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              decoration: const BoxDecoration(
                color: Color(0xff1B5E20),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.esEdicion ? 'Editar horario' : 'Nuevo horario',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _guardando
                        ? null
                        : () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),

            // ── Contenido con scroll (por si el teclado tapa campos) ───────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── aviso visible si falló la carga de
                      // empleados, en vez de quedar en silencio ──────────
                      if (_cargandoEmpleados)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: LinearProgressIndicator(
                            color: Color(0xff1B5E20),
                          ),
                        ),
                      if (!_cargandoEmpleados && _errorEmpleados != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xffFDECEA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'No se pudieron cargar los empleados',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _errorEmpleados!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _cargarEmpleados,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Reintentar'),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── aviso visible si falló la carga de
                      // actividades ──────────────────────────────────────
                      if (_cargandoActividades)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: LinearProgressIndicator(
                            color: Color(0xff1B5E20),
                          ),
                        ),
                      if (!_cargandoActividades && _errorActividades != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xffFDECEA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'No se pudieron cargar las actividades',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _errorActividades!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _cargarActividades,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Reintentar'),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── Dropdown de empleado ─────────────────────────
                      DropdownButtonFormField<int>(
                        value: _empleadoId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Empleado',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: provider.empleados.map((e) {
                          final id = _idComoInt(e['id']);
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(e['name'] ?? 'Sin nombre'),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            _empleadoId = v;
                            final emp = provider.empleados.firstWhere(
                              (e) => _idComoInt(e['id']) == v,
                              orElse: () => {},
                            );
                            _empleadoNombre = emp['name'];
                          });
                        },
                        validator: (v) =>
                            v == null ? 'Selecciona un empleado' : null,
                      ),
                      const SizedBox(height: 14),

                      // Turno
                      DropdownButtonFormField<String>(
                        value: _turno,
                        decoration: InputDecoration(
                          labelText: 'Turno',
                          prefixIcon: const Icon(Icons.schedule),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _turnos
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _turno = v),
                        validator: (v) =>
                            v == null ? 'Selecciona un turno' : null,
                      ),
                      const SizedBox(height: 14),

                      // ── Actividad: dropdown + botón para agregar una
                      // nueva al vuelo sin salir del formulario ───────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _activityId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Actividad',
                                prefixIcon: const Icon(Icons.task_alt),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: provider.actividades.map((a) {
                                final id = _idComoInt(a['id']);
                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text(a['name'] ?? 'Sin nombre'),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => _activityId = v),
                              validator: (v) =>
                                  v == null ? 'Selecciona una actividad' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xffE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Color(0xff1B5E20),
                              ),
                              tooltip: 'Nueva actividad',
                              onPressed: () =>
                                  _agregarActividadRapida(provider),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Fechas
                      Row(
                        children: [
                          Expanded(
                            child: _CampoSeleccionable(
                              label: 'Fecha inicio',
                              valor: _fmtFecha(_fechaInicio),
                              icono: Icons.calendar_today_rounded,
                              onTap: () => _elegirFecha(esInicio: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CampoSeleccionable(
                              label: 'Fecha fin',
                              valor: _fmtFecha(_fechaFin),
                              icono: Icons.calendar_today_rounded,
                              onTap: () => _elegirFecha(esInicio: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Horas
                      Row(
                        children: [
                          Expanded(
                            child: _CampoSeleccionable(
                              label: 'Hora entrada',
                              valor: _fmtHora(_horaEntrada),
                              icono: Icons.login,
                              onTap: () => _elegirHora(esEntrada: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CampoSeleccionable(
                              label: 'Hora salida',
                              valor: _fmtHora(_horaSalida),
                              icono: Icons.logout,
                              onTap: () => _elegirHora(esEntrada: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _guardando ? null : () => _guardar(provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1B5E20),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _guardando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.esEdicion
                                    ? 'Guardar cambios'
                                    : 'Guardar horario',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ],
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

class _CampoSeleccionable extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icono;
  final VoidCallback onTap;

  const _CampoSeleccionable({
    required this.label,
    required this.valor,
    required this.icono,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icono, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(valor, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
