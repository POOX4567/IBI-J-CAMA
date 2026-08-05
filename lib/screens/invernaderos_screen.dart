import 'package:flutter/material.dart';

import '../models/invernadero_model.dart';
import '../services/invernadero_service.dart';
import '../widgets/invernadero_card.dart';
import '../widgets/invernadero_detail_sheet.dart';

class InvernaderosScreen extends StatefulWidget {
  const InvernaderosScreen({super.key});

  @override
  State<InvernaderosScreen> createState() => _InvernaderosScreenState();
}

class _InvernaderosScreenState extends State<InvernaderosScreen> {
  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color brown = Color(0xFF5D4037);
  static const Color primaryGreen = Color(0xFF2E7D32);

  final InvernaderoService _service = InvernaderoService();

  List<Invernadero> _lista = [];
  List<Invernadero> _filtrados = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    cargarInvernaderos();
  }

  Future<void> cargarInvernaderos() async {
    setState(() => _loading = true);

    try {
      final data = await _service.obtenerInvernaderos();

      setState(() {
        _lista = data;
        _filtrados = data;
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  void buscar(String texto) {
    if (texto.isEmpty) {
      setState(() => _filtrados = _lista);
      return;
    }

    setState(() {
      _filtrados = _lista
          .where(
            (i) =>
                i.nombre.toLowerCase().contains(texto.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2E7D32),
                Color(0xFF66BB6A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Catálogo de\nInvernaderos",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${_filtrados.length} invernaderos disponibles",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.9),
                      fontSize: 17,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Icon(
                          Icons.cloud_done,
                          color: Colors.white,
                          size: 18,
                        ),

                        SizedBox(width: 8),

                        Text(
                          "Conectado",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        onPressed: cargarInvernaderos,
        child: const Icon(Icons.refresh),
      ),

      body: RefreshIndicator(
        onRefresh: cargarInvernaderos,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [

              TextField(
                onChanged: buscar,
                decoration: InputDecoration(
                  hintText: "Buscar invernadero...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Expanded(
                                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _filtrados.isEmpty
                        ? const Center(
                            child: Text(
                              "No hay invernaderos disponibles.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _filtrados.length,
                            itemBuilder: (context, index) {
                              final item = _filtrados[index];

                              return InvernaderoCard(
                                invernadero: item,
                                onTap: () async {
                                  try {
                                    final detalle =
                                        await _service.obtenerDetalle(item.id);

                                    if (!context.mounted) return;

                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) =>
                                          InvernaderoDetailSheet(
                                        detalle: detalle,
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          e.toString(),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}