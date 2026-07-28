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
/// Antes de llamarlo, asegúrate de haber cargado los datos del
/// formulario al menos una vez, por ejemplo en initState:
///
///   areaProvider.cargarDatosDeFormulario();
///
void mostrarModalNuevaArea(BuildContext context, AreaProvider provider) {
  Map<String, dynamic>? empleadoSeleccionado;
  Map<String, dynamic>? areaSeleccionada; // antes "invernaderoSeleccionado"
  Map<String, dynamic>? cultivoSeleccionado;
  String actividadTexto = '';
  String estadoSeleccionado = 'Pendiente';
  // El Slider trabaja internamente en 0.0-1.0, pero la base de datos
  // guarda el progreso como ENTERO 0-100. La conversión se hace justo
  // antes de enviar el Area al provider (ver `guardar()` más abajo).
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
              //  CONVERSIÓN: el slider da 0.0-1.0, la BD espera 0-100.
              progreso: (progreso * 100).round().toDouble(),
            );

            final exito = await provider.agregarArea(nuevaArea);

            setStateModal(() => guardando = false);

            if (exito && context.mounted) {
              Navigator.pop(context);
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
void mostrarModalEditarArea(
  BuildContext context,
  AreaProvider provider,
  Area area,
) {
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
  // ── CONVERSIÓN CONSISTENTE DE PROGRESO ─────────────────────────────
  // La base de datos guarda `progreso` como ENTERO 0-100 (por eso aquí
  // dividimos entre 100 para obtener el 0.0-1.0 que necesita el Slider).
  // Al guardar (más abajo, en `guardar()`) se hace la conversión inversa
  // (progreso * 100) para que en la BD siempre quede como entero.
  double progreso = (area.progreso / 100).clamp(0.0, 1.0);
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
              // 👇 CONVERSIÓN: el slider da 0.0-1.0, la BD espera 0-100.
              progreso: (progreso * 100).round().toDouble(),
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
