import 'package:flutter/material.dart';
import '../models/invernadero_detail_model.dart';

class InvernaderoDetailSheet extends StatelessWidget {
  final InvernaderoDetail detalle;

  const InvernaderoDetailSheet({
    super.key,
    required this.detalle,
  });

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color brown = Color(0xFF5D4037);
  static const Color background = Color(0xFFF7F8FA);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .92,
      maxChildSize: .96,
      minChildSize: .65,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.zero,
            children: [

              /// HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(24, 25, 24, 30),
                decoration: const BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Center(
                      child: Container(
                        width: 55,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      detalle.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      detalle.descripcion.isEmpty
                          ? "Sin descripción"
                          : detalle.descripcion,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Dimensiones",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: brown,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [

                        _chip(Icons.straighten, "Ancho ${detalle.ancho} m"),
                        _chip(Icons.height, "Alto ${detalle.alto} m"),
                        _chip(Icons.square_foot, "Largo ${detalle.largo} m"),

                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Camas",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: brown,
                      ),
                    ),

                    const SizedBox(height: 15),

                    if (detalle.camas.isEmpty)

                      Container(
                        padding: const EdgeInsets.all(35),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.grass,
                              size: 70,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Este invernadero aún no tiene camas registradas.",
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),

                    ...detalle.camas.map((cama) {

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(.06),
                              offset: const Offset(0,5),
                            )
                          ],
                        ),
                        child: ExpansionTile(

                          leading: CircleAvatar(
                            backgroundColor: primaryGreen.withOpacity(.12),
                            child: const Icon(
                              Icons.grass,
                              color: primaryGreen,
                            ),
                          ),

                          title: Text(
                            cama.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            "${cama.cultivos.length} cultivos • ${cama.sensores.length} sensores",
                          ),

                          childrenPadding: const EdgeInsets.all(18),

                          children: [

                            if(cama.cultivos.isNotEmpty)...[
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Cultivos",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: brown,
                                  ),
                                ),
                              ),

                              const SizedBox(height:10),

                              ...cama.cultivos.map((c){

                                return ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.eco,
                                    color: Colors.green,
                                  ),
                                  title: Text(c.nombre),
                                );

                              }),

                              const Divider(),
                            ],

                            if(cama.sensores.isNotEmpty)...[
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Sensores",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: brown,
                                  ),
                                ),
                              ),

                              const SizedBox(height:10),

                              ...cama.sensores.map((s){

                                return ListTile(
                                  leading: const Icon(
                                    Icons.sensors,
                                    color: primaryGreen,
                                  ),
                                  title: Text(s.nombre),
                                  subtitle: Text(
                                    s.lectura == null
                                        ? "Sin lectura registrada"
                                        : "Última lectura: ${s.lectura}",
                                  ),
                                );

                              }),
                            ]

                          ],
                        ),
                      );

                    })

                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  static Widget _chip(IconData icon, String texto) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: primaryGreen,
      ),
      backgroundColor: Colors.white,
      label: Text(texto),
    );
  }
}