import 'package:flutter/material.dart';
import '../models/invernadero_model.dart';

class InvernaderoCard extends StatelessWidget {
  final Invernadero invernadero;
  final VoidCallback onTap;

  const InvernaderoCard({
    super.key,
    required this.invernadero,
    required this.onTap,
  });

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color brown = Color(0xFF5D4037);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //---------------------------------------
                // Encabezado
                //---------------------------------------
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: primaryGreen,
                      child: Text(
                        invernadero.nombre.isNotEmpty
                            ? invernadero.nombre[0].toUpperCase()
                            : "I",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invernadero.nombre,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.green.shade400,
                              ),
                            ),
                            child: const Text(
                              "Disponible",
                              style: TextStyle(
                                color: primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  invernadero.descripcion.isEmpty
                      ? "Sin descripción disponible."
                      : invernadero.descripcion,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.5,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 18),

                Divider(color: Colors.grey.shade300),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: primaryGreen,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "${invernadero.latitud}, ${invernadero.longitud}",
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.tag,
                      color: brown,
                      size: 21,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "ID ${invernadero.id}",
                      style: const TextStyle(
                        color: brown,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.visibility),
                    label: const Text(
                      "Ver detalles",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}