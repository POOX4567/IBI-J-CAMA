import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/horarios_screen.dart';
import '../screens/invernaderos_screen.dart';
import '../screens/empleados_screen.dart';
import '../screens/alertas_screen.dart';
import '../screens/screens_solicitudes_mantenimiento/maintenance_requests_screen.dart';
import '../screens//screens_solicitudes_mantenimiento/technical_supervision_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HorariosScreen(),
    const InvernaderosScreen(),
    const EmpleadosScreen(),
    const AlertasScreen(),
    const MaintenanceRequestsScreen(),
    const TechnicalSupervisionScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: const Color(0xFF5D4037),
        backgroundColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Horarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grass),
            label: 'Invernaderos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Empleados'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handyman),
            label: 'Mant.', // Abreviado por el límite de espacio
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check),
            label: 'Superv.', // Abreviado por el límite de espacio
          ),
        ],
      ),
    );
  }
}
