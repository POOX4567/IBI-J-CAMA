import 'package:flutter/material.dart';
import 'package:ibi/services/maintenance_service.dart';
import 'package:ibi/models/invernadero_model.dart';

class CreateMaintenanceSheet extends StatefulWidget {
  final MaintenanceService service;
  final VoidCallback onCreated;

  const CreateMaintenanceSheet({
    Key? key,
    required this.service,
    required this.onCreated,
  }) : super(key: key);

  @override
  State<CreateMaintenanceSheet> createState() => _CreateMaintenanceSheetState();
}

class _CreateMaintenanceSheetState extends State<CreateMaintenanceSheet> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _tipo = 'Preventivo';
  int? _invernaderoSeleccionado;
  List<Invernadero> _invernaderos = [];
  bool _isLoading = false;
  bool _cargandoInvernaderos = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cargarInvernaderos();
  }

  Future<void> _cargarInvernaderos() async {
    try {
      final invernaderos = await widget.service.fetchInvernaderos();
      if (mounted) {
        setState(() {
          _invernaderos = invernaderos;
          _cargandoInvernaderos = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _cargandoInvernaderos = false);
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _crearSolicitud() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.service.createMaintenance(
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        tipo: _tipo,
        invernaderoId: _invernaderoSeleccionado!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud creada correctamente'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      widget.onCreated();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red[800],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Nueva Solicitud',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3A4B),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Preventivo', child: Text('Preventivo')),
                  DropdownMenuItem(value: 'Correctivo', child: Text('Correctivo')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _tipo = val);
                },
              ),
              const SizedBox(height: 12),
              _cargandoInvernaderos
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : DropdownButtonFormField<int>(
                      value: _invernaderoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Invernadero',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: _invernaderos.map((inv) {
                        return DropdownMenuItem(
                          value: inv.id,
                          child: Text(inv.nombre),
                        );
                      }).toList(),
                      validator: (v) =>
                          v == null ? 'Selecciona un invernadero' : null,
                      onChanged: (val) {
                        setState(() => _invernaderoSeleccionado = val);
                      },
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _crearSolicitud,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Crear Solicitud',
                        style: TextStyle(fontSize: 15),
                      ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
