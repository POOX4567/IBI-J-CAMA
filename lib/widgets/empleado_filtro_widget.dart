import 'package:flutter/material.dart';

class EmpleadoFiltroWidget extends StatelessWidget {
  final String empleadoSeleccionado;
  final ValueChanged<String?> onChanged;

  const EmpleadoFiltroWidget({
    super.key,
    required this.empleadoSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros de Empleados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            value: empleadoSeleccionado,
            decoration: InputDecoration(
              labelText: 'Empleado',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Todos',
                child: Text('Todos los empleados'),
              ),
              DropdownMenuItem(value: 'Juan Pérez', child: Text('Juan Pérez')),
              DropdownMenuItem(
                value: 'María López',
                child: Text('María López'),
              ),
            ],
            onChanged: onChanged,
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xffF4F7FA),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Fecha Inicio',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text('01/06/2026'),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xffF4F7FA),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Fecha Final',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text('30/06/2026'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
