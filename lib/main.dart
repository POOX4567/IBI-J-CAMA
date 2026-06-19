import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // INTL: soporte de idiomas
import 'package:intl/date_symbol_data_local.dart'; // INTL: inicializar español
import 'package:provider/provider.dart'; // PROVIDER
import 'package:hive_flutter/hive_flutter.dart'; // HIVE

// Tus pantallas y componentes existentes
import 'screens/login_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'package:ibi/utils/notification_service.dart';

// Los nuevos módulos de horarios y áreas
import './screens/screens_horarios/horario_provider.dart';
import './screens/screens_areas/area_provider.dart';
import './screens/screens_areas/area.dart';

void main() async {
  // Asegura que los bindings de Flutter estén listos antes de inicializar plugins asíncronos
  WidgetsFlutterBinding.ensureInitialized();

  // INTL: inicializa los datos de localización en español para fechas y monedas
  await initializeDateFormatting('es', null);

  // Inicializar notificaciones
  await NotificationService.init();

  // HIVE: inicializa el almacenamiento local de datos
  await Hive.initFlutter();
  Hive.registerAdapter(AreaAdapter()); // adaptador generado por hive_generator

  runApp(
    // PROVIDER: Inyección global de tus estados (Horarios y Áreas)
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HorarioProvider()),
        ChangeNotifierProvider(
          create: (_) => AreaProvider()..cargarDesdeHive(),
        ),
      ],
      child: const MyApp(), // Mantenemos el nombre de tu clase original
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IBI-Jícama', // Tu título original
      debugShowCheckedModeBanner: false,

      // Combinamos tu color verde original con el nuevo sistema Material 3
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        fontFamily: 'Roboto', // Tu fuente original
        useMaterial3: true,
      ),

      // INTL: Delegados para que el calendario y textos del sistema salgan en español
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
      locale: const Locale('es', 'ES'),

      // Tu flujo original: Inicia en el Login y respeta tus rutas de navegación
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const BottomNavBar(),
      },
    );
  }
}
