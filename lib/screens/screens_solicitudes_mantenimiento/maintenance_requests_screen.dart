import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ibi/data/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importaciones de tus widgets modulares
import '../../widgets/maintenance_requests_widgets/maintenance_header.dart';
import '../../widgets/maintenance_requests_widgets/maintenance_card.dart';
import '../../widgets/maintenance_requests_widgets/maintenance_stats_grid.dart';
import '../../widgets/maintenance_requests_widgets/maintenance_search_filter.dart';

class MaintenanceRequestsScreen extends StatefulWidget {
  const MaintenanceRequestsScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceRequestsScreen> createState() =>
      _MaintenanceRequestsScreenState();
}

class _MaintenanceRequestsScreenState extends State<MaintenanceRequestsScreen> {
  String filter = "todas";
  String searchTerm = "";
  String? expandedCardId;
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final Map<String, File> _requestImages = {};

  @override
  void initState() {
    super.initState();
    _cargarFiltroGuardado(); // Leemos el filtro al abrir la pantalla
  }

  // --- NUEVAS FUNCIONES PARA SHARED PREFERENCES ---

  Future<void> _cargarFiltroGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    // Busca la llave 'filtro_mantenimiento'. Si no existe, usa 'todas' por defecto.
    final filtroGuardado = prefs.getString('filtro_mantenimiento') ?? "todas";

    setState(() {
      filter = filtroGuardado;
    });
  }

  Future<void> _guardarFiltro(String nuevoFiltro) async {
    final prefs = await SharedPreferences.getInstance();
    // Sobrescribe el valor en la memoria del teléfono
    await prefs.setString('filtro_mantenimiento', nuevoFiltro);
  }

  // Método encargado de gestionar la captura/selección de imágenes
  Future<void> _pickImage(MaintenanceRequest req, ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => _requestImages[req.id] = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al acceder a la cámara o galería: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtrado de las solicitudes basado en la barra de búsqueda y el dropdown
    final filteredRequests = mockMaintenanceRequests.where((request) {
      final matchesFilter = filter == "todas" || request.status == filter;
      final matchesSearch =
          request.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
          request.id.toLowerCase().contains(searchTerm.toLowerCase()) ||
          request.greenhouse.toLowerCase().contains(searchTerm.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Column(
      children: [
        // 1. Encabezado estático superior
        MaintenanceHeader(totalRequests: mockMaintenanceRequests.length),

        // 2. Contenido con scroll envuelto en un Expanded
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cuadrícula de estadísticas modularizada
                MaintenanceStatsGrid(requests: mockMaintenanceRequests),
                const SizedBox(height: 12),

                // Barra de búsqueda y filtros modularizada
                MaintenanceSearchFilter(
                  searchController: _searchController,
                  currentFilter: filter,
                  onSearchChanged: (val) => setState(() => searchTerm = val),
                  onFilterChanged: (val) {
                    setState(() => filter = val); // 1. Actualiza la UI
                    _guardarFiltro(val); // 2. Guarda en la memoria del teléfono
                  },
                ),
                const SizedBox(height: 12),

                // Listado de tarjetas de solicitudes o mensaje de lista vacía
                if (filteredRequests.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      "No se encontraron solicitudes",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  )
                else
                  ...filteredRequests.map((req) {
                    return MaintenanceCard(
                      request: req,
                      isExpanded: expandedCardId == req.id,
                      image: _requestImages[req.id],
                      onToggleExpand: () => setState(
                        () => expandedCardId = expandedCardId == req.id
                            ? null
                            : req.id,
                      ),
                      onPickImage: (source) => _pickImage(req, source),
                      onRemoveImage: () =>
                          setState(() => _requestImages.remove(req.id)),
                      onStateUpdated: () => setState(
                        () {},
                      ), // Repinta la pantalla si cambia un estado interno
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
