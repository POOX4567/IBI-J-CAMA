import 'package:dio/dio.dart';

class DashboardService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.100:8000/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await dio.get('/dashboard');

    return response.data;
  }
}
