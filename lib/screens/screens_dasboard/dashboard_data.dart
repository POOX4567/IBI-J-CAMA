import 'package:flutter/material.dart';

class DashboardData {
  // =========================
  // RESUMEN
  // =========================

  static const resumenCards = [
    {
      "title": "Invernaderos",
      "value": "10/12",
      "subtitle": "Activos",
      "icon": Icons.eco,
      "color": Colors.green,
    },
    {
      "title": "Empleados",
      "value": "28/48",
      "subtitle": "En turno",
      "icon": Icons.people,
      "color": Colors.blue,
    },
    {
      "title": "Alertas",
      "value": "5",
      "subtitle": "Activas",
      "icon": Icons.warning,
      "color": Colors.red,
    },
    {
      "title": "Mantenimiento",
      "value": "8",
      "subtitle": "Pendientes",
      "icon": Icons.build,
      "color": Colors.orange,
    },
  ];

  static const alertas = [
    {
      "title": "Temperatura Alta",
      "subtitle": "Invernadero 2",
      "color": Colors.red,
    },
    {
      "title": "Falla de Riego",
      "subtitle": "Zona Norte",
      "color": Colors.orange,
    },
    {
      "title": "Sensor Desconectado",
      "subtitle": "Invernadero 5",
      "color": Colors.blue,
    },
  ];

  static const actividad = [
    {
      "icon": Icons.build,
      "title": "Mantenimiento realizado",
      "time": "Hace 1 hora",
      "color": Colors.blue,
    },
    {
      "icon": Icons.water_drop,
      "title": "Riego automático activado",
      "time": "Hace 3 horas",
      "color": Colors.cyan,
    },
    {
      "icon": Icons.eco,
      "title": "Producción actualizada",
      "time": "Hoy",
      "color": Colors.green,
    },
  ];

  // =========================
  // EMPLEADOS
  // =========================

  static const empleados = [
    {"name": "Juan Pérez", "status": "Presente", "color": Colors.green},
    {"name": "Carlos López", "status": "Ausente", "color": Colors.red},
    {"name": "María Torres", "status": "Retardo", "color": Colors.orange},
    {"name": "Luis Martínez", "status": "Presente", "color": Colors.green},
  ];

  static const horarios = [
    {"title": "Turno Matutino", "subtitle": "06:00 AM - 02:00 PM"},
    {"title": "Turno Vespertino", "subtitle": "02:00 PM - 10:00 PM"},
    {"title": "Turno Nocturno", "subtitle": "10:00 PM - 06:00 AM"},
  ];

  // =========================
  // PRODUCCIÓN
  // =========================

  static const produccion = [
    {"title": "Jícama Agua", "value": "1200 KG", "color": Colors.green},
    {"title": "Jícama Leche", "value": "980 KG", "color": Colors.orange},
    {"title": "Pepino", "value": "640 KG", "color": Colors.blue},
  ];

  static const rendimiento = [
    {"title": "Jícama Agua", "value": "92%", "color": Colors.green},
    {"title": "Jícama Leche", "value": "81%", "color": Colors.orange},
    {"title": "Pepino", "value": "74%", "color": Colors.blue},
  ];

  static const sistema = [
    {"title": "Sensores", "status": "Funcionando", "color": Colors.green},
    {"title": "Servidor", "status": "En línea", "color": Colors.blue},
    {"title": "Riego Automático", "status": "Activo", "color": Colors.cyan},
  ];
}
