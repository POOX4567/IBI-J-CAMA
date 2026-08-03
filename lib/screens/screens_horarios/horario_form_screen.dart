import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // INTL
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker; // FLUTTER_DATETIME_PICKER
import 'package:provider/provider.dart'; // PROVIDER
import 'package:fluttertoast/fluttertoast.dart'; // FLUTTERTOAST

import 'horario.dart';
import 'horario_provider.dart';

/// Modal (Dialog) para CREAR o EDITAR un horario.
/// Si [horario] es null -> modo creación (todos los campos vacíos).
/// Si [horario] viene con datos -> modo edición (todos los campos
/// precargados y editables, incluyendo empleado, turno, actividad,
/// fechas y horas).
///
/// Úsalo con el helper estático `HorarioFormScreen.show(...)`, que ya
/// se encarga de mostrarlo centrado sobre el resto de la pantalla
/// (con el fondo oscurecido) usando showDialog.
class HorarioFormScreen extends StatefulWidget {
  final Horario? horario;

  const HorarioFormScreen({super.key, this.horario});

  bool get esEdicion => horario != null;

  /// Muestra el formulario como modal centrado.
  /// Devuelve `true` si se guardó algo (para que la pantalla que llama
  /// pueda refrescar), o `null`/`false` si se canceló.
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
  late final TextEditingController _actividadCtrl;

  int? _empleadoId;
  String? _empleadoNombre;
  String? _turno;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  TimeOfDay? _horaEntrada;
  TimeOfDay? _horaSalida;
  bool _guardando = false;

  // ── NUEVO: estado propio para saber si la carga de empleados falló ──────
  bool _cargandoEmpleados = false;
  String? _errorEmpleados;

  final _turnos = const ['Matutino', 'Vespertino', 'Nocturno'];

  @override
  void initState() {
    super.initState();

    final h = widget.horario;
    _actividadCtrl = TextEditingController(text: h?.actividad ?? '');

    if (h != null) {
      // ── Precarga de TODOS los campos en modo edición ──────────────────
      _empleadoId = h.empleadoId;
      _empleadoNombre = h.nombre;
      _turno = h.turno;
      _fechaInicio = _parsearFecha(h.fechaInicio);
      _fechaFin = _parsearFecha(h.fechaFin);
      _horaEntrada = _parsearHora(h.entrada);
      _horaSalida = _parsearHora(h.salida);
    }

    // Asegura que el dropdown de empleados tenga datos frescos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cargarEmpleados();
    });
  }

  // ── NUEVO: carga los empleados y captura/expone cualquier error ────────
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
        actividad: _actividadCtrl.text.trim(),
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
        actividad: _actividadCtrl.text.trim(),
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
  void dispose() {
    _actividadCtrl.dispose();
    super.dispose();
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
                      // ── NUEVO: aviso visible si falló la carga de
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

                      // Actividad
                      TextFormField(
                        controller: _actividadCtrl,
                        decoration: InputDecoration(
                          labelText: 'Actividad',
                          prefixIcon: const Icon(Icons.task_alt),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
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
