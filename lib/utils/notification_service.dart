import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  // Instancia global del plugin
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // 1. Inicialización
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // CORRECCIÓN: Ahora el plugin exige el parámetro nombrado "settings:"
    await _plugin.initialize(settings: initializationSettings);
  }

  // 2. Pedir permiso explícito en Android 13 o superior
  static Future<void> solicitarPermisos() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.requestNotificationsPermission();
  }

  // 3. Función para disparar la alerta
  static Future<void> mostrarAlertaFalla(
    String nombreDispositivo,
    String invernadero,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'canal_fallas_criticas',
          'Fallas Críticas IoT',
          channelDescription:
              'Notificaciones sobre sensores y actuadores caídos',
          importance: Importance.max,
          priority: Priority.high,
          color: Colors.red,
          enableVibration: true,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentSound: true, presentAlert: true),
    );

    // CORRECCIÓN: Ahora el plugin exige escribir id:, title:, body: y notificationDetails:
    await _plugin.show(
      id: DateTime.now().millisecond,
      title: '🚨 ¡Falla Crítica Detectada!',
      body:
          'El dispositivo $nombreDispositivo en $invernadero dejó de responder.',
      notificationDetails: platformDetails,
    );
  }
}
