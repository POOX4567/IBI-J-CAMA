import 'package:flutter/material.dart';
import './screens_dasboard/reports_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              topSection(),

              Padding(
                padding: const EdgeInsets.all(16),
                child: buildCurrentPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //==================================================
  // HEADER
  //==================================================

  Widget topSection() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: const BoxDecoration(
        color: Color(0xFF00A86B),

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Row(
                children: [
                  Image.asset('assets/logo.png', width: 100, height: 100),

                  const SizedBox(width: 12),

                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "IBI Jícama",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        "Dashboard General",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: const Icon(Icons.notifications, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              buildTab("Resumen", 0),
              buildTab("Empleados", 1),
              buildTab("Producción", 2),
            ],
          ),
        ],
      ),
    );
  }

  //==================================================
  // TABS
  //==================================================

  Widget buildTab(String title, int index) {
    bool active = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },

        child: Container(
          margin: const EdgeInsets.only(right: 10),

          padding: const EdgeInsets.symmetric(vertical: 14),

          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white24,
            borderRadius: BorderRadius.circular(15),
          ),

          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: active ? Colors.green : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  //==================================================
  // PAGE SWITCH
  //==================================================

  Widget buildCurrentPage() {
    if (selectedTab == 0) {
      return resumenPage();
    }

    if (selectedTab == 1) {
      return empleadosPage();
    }

    return produccionPage();
  }

  //==================================================
  // RESUMEN
  //==================================================

  Widget resumenPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          "Estado General",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        GridView.count(
          shrinkWrap: true,

          physics: const NeverScrollableScrollPhysics(),

          crossAxisCount: 2,

          crossAxisSpacing: 15,

          mainAxisSpacing: 15,

          childAspectRatio: 1,

          children: [
            infoCard(
              "Invernaderos",
              "10/12",
              "Activos",
              Icons.eco,
              Colors.green,
            ),

            infoCard(
              "Empleados",
              "28/48",
              "En turno",
              Icons.people,
              Colors.blue,
            ),

            infoCard("Alertas", "5", "Activas", Icons.warning, Colors.red),

            infoCard(
              "Mantenimiento",
              "8",
              "Pendientes",
              Icons.build,
              Colors.orange,
            ),
          ],
        ),

        const SizedBox(height: 30),

        sectionTitle("Alertas Importantes"),

        const SizedBox(height: 15),

        alertCard("Temperatura Alta", "Invernadero 2", Colors.red),

        alertCard("Falla de Riego", "Zona Norte", Colors.orange),

        alertCard("Sensor Desconectado", "Invernadero 5", Colors.blue),

        const SizedBox(height: 30),

        sectionTitle("Resumen de Actividad"),

        const SizedBox(height: 15),

        summaryCard(
          "Actividad Diaria",
          "25 eventos registrados",
          Icons.today,
          Colors.green,
        ),

        summaryCard(
          "Actividad Semanal",
          "148 eventos registrados",
          Icons.calendar_view_week,
          Colors.blue,
        ),

        summaryCard(
          "Actividad Mensual",
          "620 eventos registrados",
          Icons.calendar_month,
          Colors.orange,
        ),

        const SizedBox(height: 30),

        sectionTitle("Actividad Reciente"),

        const SizedBox(height: 15),

        activityCard(
          Icons.build,
          "Mantenimiento realizado",
          "Hace 1 hora",
          Colors.blue,
        ),

        activityCard(
          Icons.water_drop,
          "Riego automático activado",
          "Hace 3 horas",
          Colors.cyan,
        ),

        activityCard(Icons.eco, "Producción actualizada", "Hoy", Colors.green),

        const SizedBox(height: 30),

        reportButton(),
      ],
    );
  }

  //==================================================
  // EMPLEADOS
  //==================================================

  Widget empleadosPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        sectionTitle("Control de Empleados"),

        const SizedBox(height: 20),

        employeeCard("Juan Pérez", "Presente", Colors.green),

        employeeCard("Carlos López", "Ausente", Colors.red),

        employeeCard("María Torres", "Retardo", Colors.orange),

        employeeCard("Luis Martínez", "Presente", Colors.green),

        const SizedBox(height: 30),

        sectionTitle("Horarios Activos"),

        const SizedBox(height: 15),

        scheduleCard("Turno Matutino", "06:00 AM - 02:00 PM"),

        scheduleCard("Turno Vespertino", "02:00 PM - 10:00 PM"),

        scheduleCard("Turno Nocturno", "10:00 PM - 06:00 AM"),

        const SizedBox(height: 30),

        sectionTitle("Asistencia General"),

        const SizedBox(height: 15),

        infoRow("Total empleados", "48"),
        infoRow("Presentes", "40"),
        infoRow("Ausentes", "5"),
        infoRow("Retardos", "3"),

        const SizedBox(height: 30),

        reportButton(),
      ],
    );
  }

  //==================================================
  // PRODUCCION
  //==================================================

  Widget produccionPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        sectionTitle("Producción"),

        const SizedBox(height: 20),

        productionCard("Jícama Agua", "1200 KG", Colors.green),

        productionCard("Jícama Leche", "980 KG", Colors.orange),

        productionCard("Pepino", "640 KG", Colors.blue),

        const SizedBox(height: 30),

        sectionTitle("Rendimiento de Cultivos"),

        const SizedBox(height: 15),

        performanceCard("Jícama Agua", "92%", Colors.green),

        performanceCard("Jícama Leche", "81%", Colors.orange),

        performanceCard("Pepino", "74%", Colors.blue),

        const SizedBox(height: 30),

        sectionTitle("Estado del Sistema"),

        const SizedBox(height: 15),

        systemStatusCard("Sensores", "Funcionando", Colors.green),

        systemStatusCard("Servidor", "En línea", Colors.blue),

        systemStatusCard("Riego Automático", "Activo", Colors.cyan),

        const SizedBox(height: 30),

        sectionTitle("Mantenimiento"),

        const SizedBox(height: 15),

        infoRow("Mantenimientos realizados", "18"),
        infoRow("Pendientes", "8"),
        infoRow("Completados", "10"),

        const SizedBox(height: 30),

        reportButton(),
      ],
    );
  }

  //==================================================
  // TITULOS
  //==================================================

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  //==================================================
  // INFO CARD
  //==================================================

  Widget infoCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),

          const Spacer(),

          Text(title),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          Text(subtitle),
        ],
      ),
    );
  }

  //==================================================
  // ALERT CARD
  //==================================================

  Widget alertCard(String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),

            child: Icon(Icons.warning, color: color),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // SUMMARY CARD
  //==================================================

  Widget summaryCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),

        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  //==================================================
  // ACTIVITY CARD
  //==================================================

  Widget activityCard(IconData icon, String title, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(time),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // EMPLOYEE CARD
  //==================================================

  Widget employeeCard(String name, String status, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),

          child: Icon(Icons.person, color: color),
        ),

        title: Text(name),

        trailing: Text(
          status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  //==================================================
  // SCHEDULE CARD
  //==================================================

  Widget scheduleCard(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),

      child: ListTile(
        leading: const Icon(Icons.access_time, color: Colors.green),

        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  //==================================================
  // PRODUCTION CARD
  //==================================================

  Widget productionCard(String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),

          child: Icon(Icons.eco, color: color),
        ),

        title: Text(title),

        trailing: Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  //==================================================
  // PERFORMANCE CARD
  //==================================================

  Widget performanceCard(String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),

          child: Icon(Icons.bar_chart, color: color),
        ),

        title: Text(title),

        trailing: Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  //==================================================
  // SYSTEM STATUS CARD
  //==================================================

  Widget systemStatusCard(String title, String status, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),

          child: Icon(Icons.settings, color: color),
        ),

        title: Text(title),

        trailing: Text(
          status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  //==================================================
  // INFO ROW
  //==================================================

  Widget infoRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(title, style: const TextStyle(fontSize: 16)),

          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // REPORT BUTTON
  //==================================================

  Widget reportButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportsPage()),
        );
      },

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: const Color(0xFF00A86B),
          borderRadius: BorderRadius.circular(20),
        ),

        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.description, color: Colors.white),

            SizedBox(width: 10),

            Text(
              "Ver Reportes Detallados",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(width: 10),

            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
