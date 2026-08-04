import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ibi/data/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ibi/services/maintenance_service.dart';

import '../../widgets/maintenance_requests_widgets/maintenance_header.dart';
import '../../widgets/maintenance_requests_widgets/maintenance_card.dart';
import '../../widgets/maintenance_requests_widgets/maintenance_stats_grid.dart';
import '../../widgets/maintenance_requests_widgets/maintenance_search_filter.dart';
import '../../widgets/maintenance_requests_widgets/create_maintenance_sheet.dart';
import '../../widgets/maintenance_requests_widgets/edit_maintenance_sheet.dart';

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

  final MaintenanceService _service = MaintenanceService();
  List<MaintenanceRequest> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarFiltroGuardado();
    _cargarSolicitudes();
  }

  Future<void> _cargarSolicitudes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final modelos = await _service.fetchMaintenanceTasks();
      setState(() {
        _requests = modelos
            .map((m) => MaintenanceRequest.fromMaintenanceModel(m))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al conectar con el servidor: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cargarFiltroGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    final filtroGuardado = prefs.getString('filtro_mantenimiento') ?? "todas";
    setState(() {
      filter = filtroGuardado;
    });
  }

  Future<void> _guardarFiltro(String nuevoFiltro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('filtro_mantenimiento', nuevoFiltro);
  }

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
    if (_isLoading) {
      return const Column(
        children: [
          MaintenanceHeader(totalRequests: 0),
          Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        children: [
          MaintenanceHeader(totalRequests: 0),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(_errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _cargarSolicitudes,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final filteredRequests = _requests.where((request) {
      final matchesFilter = filter == "todas" || request.status == filter;
      final matchesSearch =
          request.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
          request.id.toLowerCase().contains(searchTerm.toLowerCase()) ||
          request.greenhouse.toLowerCase().contains(searchTerm.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Stack(
      children: [
        Column(
          children: [
            MaintenanceHeader(totalRequests: _requests.length),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MaintenanceStatsGrid(requests: _requests),
                    const SizedBox(height: 12),
                    MaintenanceSearchFilter(
                      searchController: _searchController,
                      currentFilter: filter,
                      onSearchChanged: (val) => setState(() => searchTerm = val),
                      onFilterChanged: (val) {
                        setState(() => filter = val);
                        _guardarFiltro(val);
                      },
                    ),
                    const SizedBox(height: 12),
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
                          onStateUpdated: () => setState(() {}),
                          onEditRequested: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              builder: (ctx) => EditMaintenanceSheet(
                                service: _service,
                                request: req,
                                onSaved: _cargarSolicitudes,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF2E7D32),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (ctx) => CreateMaintenanceSheet(
                  service: _service,
                  onCreated: _cargarSolicitudes,
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
