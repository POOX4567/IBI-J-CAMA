import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart'; // DROPDOWN_SEARCH
import 'package:fluttertoast/fluttertoast.dart'; // FLUTTERTOAST

import 'area.dart';
import 'area_provider.dart';

/// Muestra el modal para crear una nueva Área, conectado a la API
/// a través de AreaProvider.
///
/// Uso (por ejemplo, en el botón "Añadir" de HorariosScreen):
///
///   mostrarModalNuevaArea(context, areaProvider);
///
/// 👇 CAMBIO IMPORTANTE: ya NO es necesario (ni recomendable) llamar
/// `areaProvider.cargarDatosDeFormulario()` manualmente antes de abrir
/// el modal. Esta función ahora se asegura, ella misma, de que los
/// datos de empleados/áreas/cultivos estén cargados ANTES de construir
/// el formulario. Si aún no lo están, muestra un loader breve mientras
/// llegan de la API, en vez de abrir el modal con los dropdowns vacíos
/// (que era la causa de que "no cargaran los empleados").
///
/// 👇 CAMBIO NUEVO (progreso): el backend valida `progreso` como un
/// número ENTRE 0 Y 1 ("The progreso field must not be greater than
/// 1"), así que el Slider (que ya trabaja en 0.0-1.0) se manda TAL
/// CUAL, sin multiplicar por 100. Antes se mandaba `progreso * 100`,
/// lo cual disparaba un 422 en el POST y la creación NUNCA se
/// completaba (por eso seguías viendo solo el registro viejo "Sin
/// área").
///
/// 👇 CAMBIO NUEVO (dropdowns Área/Cultivo): antes, si
/// `areasDisponibles` o `cultivos` venían vacíos (por timeout, CORS,
/// o falla del backend), el DropdownSearch se abría igual y mostraba
/// "No data found" sin ninguna explicación ni forma de reintentar.
/// Ahora, igual que ya pasaba con "Empleado", se muestra un aviso rojo
/// con botón "Reintentar" que vuelve a llamar solo a ese endpoint.
Future<void> mostrarModalNuevaArea(
  BuildContext context,
  AreaProvider provider,
) async {
  // ── Aseguramos los datos del formulario ANTES de construir el diálogo ──
  if (!provider.datosFormularioCargados) {
    // Mini-loader mientras llegan los datos de la API.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await provider.cargarDatosDeFormulario();

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // cierra el loader
    }

    if (provider.empleados.isEmpty && provider.error != null) {
      // Avisamos si, aun así, no llegaron datos (backend caído, ruta
      // incorrecta, etc.) en vez de abrir un formulario inservible.
      if (context.mounted) {
        Fluttertoast.showToast(
          msg:
              provider.error ??
              'No se pudieron cargar los datos del formulario',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  if (!context.mounted) return;

  Map<String, dynamic>? empleadoSeleccionado;
  Map<String, dynamic>? areaSeleccionada; // antes "invernaderoSeleccionado"
  Map<String, dynamic>? cultivoSeleccionado;
  String actividadTexto = '';
  String estadoSeleccionado = 'Pendiente';
  // El Slider trabaja internamente en 0.0-1.0, y el backend TAMBIÉN
  // espera 0.0-1.0 (valida `progreso <= 1`). Ya no hace falta ninguna
  // conversión antes de enviarlo.
  double progreso = 0.0;
  bool guardando = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateModal) {
          Future<void> guardar() async {
            if (empleadoSeleccionado == null ||
                areaSeleccionada == null ||
                cultivoSeleccionado == null ||
                actividadTexto.trim().isEmpty) {
              Fluttertoast.showToast(
                msg: 'Completa todos los campos antes de guardar',
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
              return;
            }

            setStateModal(() => guardando = true);

            final nuevaArea = Area(
              empleadoId: empleadoSeleccionado!['id'],
              empleado: empleadoSeleccionado!['name'],
              areaId: areaSeleccionada!['id'],
              area: areaSeleccionada!['name'],
              cultivoId: cultivoSeleccionado!['id'],
              cultivo: cultivoSeleccionado!['name'],
              actividad: actividadTexto.trim(),
              estado: estadoSeleccionado,
              // ✅ SIN conversión: el backend espera 0.0-1.0, igual que
              // el Slider. Antes era `(progreso * 100).round().toDouble()`
              // y eso disparaba un 422 ("must not be greater than 1").
              progreso: progreso,
            );

            final exito = await provider.agregarArea(nuevaArea);

            setStateModal(() => guardando = false);

            if (exito && context.mounted) {
              Navigator.pop(context);
            } else if (context.mounted) {
              // 👇 Feedback visible si el backend rechaza la creación
              // (por ejemplo, otro error de validación 422/500). Antes
              // el modal se quedaba "quieto" sin avisar qué pasó.
              Fluttertoast.showToast(
                msg: provider.error ?? 'Error al crear el área',
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
            }
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── TÍTULO ─────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xffE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          color: Color(0xff1B5E20),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Nueva Área',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1E293B),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── EMPLEADO ────────────────────────────────
                  const Text(
                    'Empleado',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xff475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (provider.empleados.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.red.shade50,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade400,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No hay empleados disponibles. Verifica la conexión con el servidor.',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await provider.cargarEmpleadosDisponibles();
                              setStateModal(() {});
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownSearch<Map<String, dynamic>>(
                      popupProps: const PopupProps.menu(showSearchBox: true),
                      items: (filter, loadProps) {
                        if (filter.isEmpty) return provider.empleados;
                        return provider.empleados
                            .where(
                              (e) => (e['name'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains(filter.toLowerCase()),
                            )
                            .toList();
                      },
                      compareFn: (a, b) => a['id'] == b['id'],
                      selectedItem: empleadoSeleccionado,
                      itemAsString: (e) => e['name'] ?? '',
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          hintText: 'Seleccionar empleado',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      onSelected: (value) {
                        setStateModal(() => empleadoSeleccionado = value);
                      },
                    ),
                  const SizedBox(height: 16),

                  // ── ÁREA (antes "Invernadero") ───────────────
                  const Text(
                    'Área',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xff475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 👇 NUEVO: si areasDisponibles llegó vacía (timeout,
                  // CORS, backend caído), mostramos aviso + reintentar en
                  // vez de abrir un DropdownSearch mudo con "No data found".
                  if (provider.areasDisponibles.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.red.shade50,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade400,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No se pudieron cargar las áreas. Verifica la conexión con el servidor.',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await provider
                                  .cargarAreasDisponiblesParaFormulario();
                              setStateModal(() {});
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownSearch<Map<String, dynamic>>(
                      popupProps: const PopupProps.menu(showSearchBox: true),
                      items: (filter, loadProps) {
                        if (filter.isEmpty) return provider.areasDisponibles;
                        return provider.areasDisponibles
                            .where(
                              (e) => (e['name'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains(filter.toLowerCase()),
                            )
                            .toList();
                      },
                      compareFn: (a, b) => a['id'] == b['id'],
                      selectedItem: areaSeleccionada,
                      itemAsString: (e) => e['name'] ?? '',
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          hintText: 'Seleccionar área',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      onSelected: (value) {
                        setStateModal(() => areaSeleccionada = value);
                      },
                    ),
                  const SizedBox(height: 16),

                  // ── CULTIVO ──────────────────────────────────
                  const Text(
                    'Cultivo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xff475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 👇 NUEVO: mismo patrón para Cultivo. Antes /cultivos
                  // podía fallar en silencio y el usuario solo veía
                  // "No data found" sin saber que era un error de red.
                  if (provider.cultivos.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.red.shade50,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade400,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No se pudieron cargar los cultivos. Verifica la conexión con el servidor.',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await provider.cargarCultivosDisponibles();
                              setStateModal(() {});
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownSearch<Map<String, dynamic>>(
                      popupProps: const PopupProps.menu(showSearchBox: true),
                      items: (filter, loadProps) {
                        if (filter.isEmpty) return provider.cultivos;
                        return provider.cultivos
                            .where(
                              (e) => (e['name'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains(filter.toLowerCase()),
                            )
                            .toList();
                      },
                      compareFn: (a, b) => a['id'] == b['id'],
                      selectedItem: cultivoSeleccionado,
                      itemAsString: (e) => e['name'] ?? '',
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          hintText: 'Seleccionar cultivo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      onSelected: (value) {
                        setStateModal(() => cultivoSeleccionado = value);
                      },
                    ),
                  const SizedBox(height: 16),

                  // ── ACTIVIDAD ────────────────────────────────
                  const Text(
                    'Actividad',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xff475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) => actividadTexto = value,
                    decoration: InputDecoration(
                      hintText: 'Ej: Poda, riego, fertilización...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── ESTADO ───────────────────────────────────
                  const Text(
                    'Estado',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xff475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Pendiente', 'En progreso', 'Completado']
                        .map(
                          (estado) => ChoiceChip(
                            label: Text(estado),
                            selected: estadoSeleccionado == estado,
                            onSelected: (_) {
                              setStateModal(() => estadoSeleccionado = estado);
                            },
                            selectedColor: const Color(0xff1B5E20),
                            labelStyle: TextStyle(
                              color: estadoSeleccionado == estado
                                  ? Colors.white
                                  : const Color(0xff334155),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // ── PROGRESO ─────────────────────────────────
                  Text(
                    'Progreso: ${(progreso * 100).round()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xff475569),
                    ),
                  ),
                  Slider(
                    value: progreso,
                    activeColor: const Color(0xff1B5E20),
                    onChanged: (value) {
                      setStateModal(() => progreso = value);
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── BOTONES ──────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xff1B5E20)),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Color(0xff1B5E20),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: guardando ? null : guardar,
                          icon: guardando
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(guardando ? 'Guardando...' : 'Guardar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1B5E20),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Muestra el modal para EDITAR un área existente, conectado a la API
/// a través de AreaProvider (PUT /areas/{id}).
///
/// Uso (por ejemplo, desde el botón "Editar" en AreaDetailScreen):
///
///   mostrarModalEditarArea(context, areaProvider, area);
///
/// 👇 Mismo cambio que en `mostrarModalNuevaArea`: se asegura de que los
/// datos de los dropdowns estén cargados antes de construir el formulario,
/// y ahora también muestra aviso + reintentar en Área y Cultivo si vienen
/// vacíos.
///
/// 👇 CAMBIO NUEVO (progreso): igual que al crear, el Slider ahora
/// SIEMPRE trabaja y envía en escala 0.0-1.0 porque así lo exige el
/// backend. Como `area.progreso` puede venir en 0-100 (registros viejos
/// creados antes de este fix) o en 0.0-1.0 (registros nuevos), se
/// normaliza al cargar el formulario para que el Slider siempre
/// arranque en el valor correcto sin importar cómo haya quedado
/// guardado el registro original.
Future<void> mostrarModalEditarArea(
  BuildContext context,
  AreaProvider provider,
  Area area,
) async {
  if (!provider.datosFormularioCargados) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await provider.cargarDatosDeFormulario();

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  if (!context.mounted) return;

  // Intentamos preseleccionar el item exacto de cada lista del provider
  // (por id). Si el provider aún no cargó esa lista, usamos un mapa
  // "sintético" armado con los datos que ya trae el Area, para que al
  // menos se vea el valor actual en el campo aunque no esté en la lista.
  Map<String, dynamic>? _buscarEnLista(
    List<Map<String, dynamic>> lista,
    int? id,
    String nombreFallback,
  ) {
    if (id == null) return null;
    for (final item in lista) {
      if ('${item['id']}' == '$id') return item;
    }
    return {'id': id, 'name': nombreFallback};
  }

  Map<String, dynamic>? empleadoSeleccionado = _buscarEnLista(
    provider.empleados,
    area.empleadoId,
    area.empleado,
  );
  Map<String, dynamic>? areaSeleccionada = _buscarEnLista(
    provider.areasDisponibles,
    area.areaId,
    area.area,
  );
  Map<String, dynamic>? cultivoSeleccionado = _buscarEnLista(
    provider.cultivos,
    area.cultivoId,
    area.cultivo,
  );
  String estadoSeleccionado = area.estado;

  // ── NORMALIZACIÓN DE PROGRESO AL CARGAR ────────────────────────────
  // Si `area.progreso` viene mayor a 1 (ej. 45, 100), asumimos que es
  // un registro viejo guardado en escala 0-100 y lo convertimos a
  // 0.0-1.0 para el Slider. Si ya viene <= 1, se usa tal cual.
  double progreso = area.progreso > 1
      ? (area.progreso / 100).clamp(0.0, 1.0)
      : area.progreso.clamp(0.0, 1.0);
  bool guardando = false;

  final actividadCtrl = TextEditingController(text: area.actividad);

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateModal) {
          Future<void> guardar() async {
            if (empleadoSeleccionado == null ||
                areaSeleccionada == null ||
                cultivoSeleccionado == null ||
                actividadCtrl.text.trim().isEmpty) {
              Fluttertoast.showToast(
                msg: 'Completa todos los campos antes de guardar',
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
              return;
            }

            setStateModal(() => guardando = true);

            final areaActualizada = Area(
              id: area.id,
              empleadoId: empleadoSeleccionado!['id'],
              empleado: empleadoSeleccionado!['name'],
              areaId: areaSeleccionada!['id'],
              area: areaSeleccionada!['name'],
              cultivoId: cultivoSeleccionado!['id'],
              cultivo: cultivoSeleccionado!['name'],
              actividad: actividadCtrl.text.trim(),
              estado: estadoSeleccionado,
              // ✅ SIN conversión: el backend espera 0.0-1.0. Antes era
              // `(progreso * 100).round().toDouble()` y provocaba el
              // mismo 422 ("must not be greater than 1") al editar.
              progreso: progreso,
            );

            final exito = await provider.actualizarArea(
              area.id!,
              areaActualizada,
            );

            setStateModal(() => guardando = false);

            if (exito && context.mounted) {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Área actualizada con éxito',
                backgroundColor: const Color(0xff1B5E20),
                textColor: Colors.white,
              );
            } else if (context.mounted) {
              Fluttertoast.showToast(
                msg: provider.error ?? 'Error al actualizar el área',
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
            }
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── TÍTULO ─────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xffE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Color(0xff1B5E20),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Editar Área',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1E293B),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── EMPLEADO ────────────────────────────────
                  const Text(
                    'Empleado',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xff475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (provider.empleados.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.red.shade50,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade400,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No hay empleados disponibles. Verifica la conexión con el servidor.',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await provider.cargarEmpleadosDisponibles();
                              setStateModal(() {});
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownSearch<Map<String, dynamic>>(
                      popupProps: const PopupProps.menu(showSearchBox: true),
                      items: (filter, loadProps) {
                        if (filter.isEmpty) return provider.empleados;
                        return provider.empleados
                            .where(
                              (e) => (e['name'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains(filter.toLowerCase()),
                            )
                            .toList();
                      },
                      compareFn: (a, b) => a['id'] == b['id'],
                      selectedItem: empleadoSeleccionado,
                      itemAsString: (e) => e['name'] ?? '',
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          hintText: 'Seleccionar empleado',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      onSelected: (value) {
                        setStateModal(() => empleadoSeleccionado = value);
                      },
                    ),
                  const SizedBox(height: 16),

                  // ── ÁREA ─────────────────────────────────────
                  const Text(
                    'Área',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xff475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 👇 NUEVO: aviso + reintentar si areasDisponibles vino
                  // vacía (mismo problema que causaba "No data found").
                  if (provider.areasDisponibles.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.red.shade50,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade400,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No se pudieron cargar las áreas. Verifica la conexión con el servidor.',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await provider
                                  .cargarAreasDisponiblesParaFormulario();
                              setStateModal(() {});
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownSearch<Map<String, dynamic>>(
                      popupProps: const PopupProps.menu(showSearchBox: true),
                      items: (filter, loadProps) {
                        if (filter.isEmpty) return provider.areasDisponibles;
                        return provider.areasDisponibles
                            .where(
                              (e) => (e['name'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains(filter.toLowerCase()),
                            )
                            .toList();
                      },
                      compareFn: (a, b) => a['id'] == b['id'],
                      selectedItem: areaSeleccionada,
                      itemAsString: (e) => e['name'] ?? '',
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          hintText: 'Seleccionar área',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      onSelected: (value) {
                        setStateModal(() => areaSeleccionada = value);
                      },
                    ),
                  const SizedBox(height: 16),

                  // ── CULTIVO ──────────────────────────────────
                  const Text(
                    'Cultivo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xff475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 👇 NUEVO: aviso + reintentar si cultivos vino vacío.
                  if (provider.cultivos.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.red.shade50,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade400,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No se pudieron cargar los cultivos. Verifica la conexión con el servidor.',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await provider.cargarCultivosDisponibles();
                              setStateModal(() {});
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownSearch<Map<String, dynamic>>(
                      popupProps: const PopupProps.menu(showSearchBox: true),
                      items: (filter, loadProps) {
                        if (filter.isEmpty) return provider.cultivos;
                        return provider.cultivos
                            .where(
                              (e) => (e['name'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains(filter.toLowerCase()),
                            )
                            .toList();
                      },
                      compareFn: (a, b) => a['id'] == b['id'],
                      selectedItem: cultivoSeleccionado,
                      itemAsString: (e) => e['name'] ?? '',
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          hintText: 'Seleccionar cultivo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      onSelected: (value) {
                        setStateModal(() => cultivoSeleccionado = value);
                      },
                    ),
                  const SizedBox(height: 16),

                  // ── ACTIVIDAD ────────────────────────────────
                  const Text(
                    'Actividad',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xff475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: actividadCtrl,
                    decoration: InputDecoration(
                      hintText: 'Ej: Poda, riego, fertilización...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── ESTADO ───────────────────────────────────
                  const Text(
                    'Estado',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xff475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Pendiente', 'En progreso', 'Completado']
                        .map(
                          (estado) => ChoiceChip(
                            label: Text(estado),
                            selected: estadoSeleccionado == estado,
                            onSelected: (_) {
                              setStateModal(() => estadoSeleccionado = estado);
                            },
                            selectedColor: const Color(0xff1B5E20),
                            labelStyle: TextStyle(
                              color: estadoSeleccionado == estado
                                  ? Colors.white
                                  : const Color(0xff334155),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // ── PROGRESO ─────────────────────────────────
                  StatefulBuilder(
                    builder: (context, setInner) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progreso: ${(progreso * 100).round()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xff475569),
                            ),
                          ),
                          Slider(
                            value: progreso,
                            activeColor: const Color(0xff1B5E20),
                            onChanged: (value) {
                              setStateModal(() => progreso = value);
                              setInner(() {});
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── BOTONES ──────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xff1B5E20)),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Color(0xff1B5E20),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: guardando ? null : guardar,
                          icon: guardando
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(guardando ? 'Guardando...' : 'Guardar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1B5E20),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
