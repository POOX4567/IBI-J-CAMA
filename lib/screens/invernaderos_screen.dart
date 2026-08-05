import 'package:flutter/material.dart';

class InvernaderosScreen extends StatelessWidget {
  const InvernaderosScreen({super.key});

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color brown = Color(0xFF5D4037);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'Invernaderos',
          style: TextStyle(
            color: brown,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        onPressed: () {},
        child: const Icon(Icons.refresh, color: Colors.white),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Catálogo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: brown,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Consulta los invernaderos disponibles.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar invernadero...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.agriculture,
                        size: 90,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Próximamente',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Aquí aparecerán los invernaderos\nobtenidos desde la API.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}