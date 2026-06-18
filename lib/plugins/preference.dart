import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {

  Future<void> guardarZona(String zona) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ultima_zona', zona);
  }

  Future<String> obtenerZona() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('ultima_zona') ??
        'Sin zona registrada';
  }
}