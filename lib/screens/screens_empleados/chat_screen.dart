import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatScreen extends StatefulWidget {
  final String nombre;
  final String rol;
  final String fotoUrl;
  final int empleadoId; // ID del empleado con quien se chatea

  const ChatScreen({
    super.key,
    required this.nombre,
    required this.rol,
    required this.fotoUrl,
    required this.empleadoId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final storage = const FlutterSecureStorage();

  static const String _baseUrl = 'https://ibijicama.utptics.com/api';

  List<Map<String, dynamic>> _mensajes = [];
  bool _isLoading = true;
  String? _chatId;
  String? _errorMessage;
  String? _usuarioActualId;

  @override
  void initState() {
    super.initState();
    _inicializarChat();
  }

  Future<String?> _getToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> _inicializarChat() async {
    setState(() => _isLoading = true);

    try {
      final token = await _getToken();

      // 1. Obtener ID del usuario actual (del token o de almacenamiento)
      _usuarioActualId = await storage.read(key: 'userId') ?? '1';

      // 2. Crear o obtener conversación
      await _crearObtenerConversacion(token);

      // 3. Cargar mensajes
      if (_chatId != null) {
        await _cargarMensajes();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar chat: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _crearObtenerConversacion(String? token) async {
    try {
      // Intentar crear conversación
      final response = await http.post(
        Uri.parse('$_baseUrl/chats'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'user_id': widget.empleadoId}),
      );

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          _chatId = data['data']['id']?.toString();
        } else {
          throw Exception(data['message'] ?? 'Error al crear conversación');
        }
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      // Si falla, intentar obtener conversaciones existentes
      await _obtenerConversacionExistente(token);
    }
  }

  Future<void> _obtenerConversacionExistente(String? token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/chats'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final chats = data['data'] as List? ?? [];
          // Buscar chat con el empleado específico
          for (var chat in chats) {
            if (chat['user_id'] == widget.empleadoId) {
              _chatId = chat['id']?.toString();
              break;
            }
          }
        }
      }
    } catch (e) {
      print('Error al obtener conversaciones: $e');
    }
  }

  Future<void> _cargarMensajes() async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/chats/$_chatId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> mensajesData = data['data'] ?? [];
          setState(() {
            _mensajes = mensajesData
                .map(
                  (msg) => {
                    'texto': msg['message'] ?? '',
                    'enviadoPor': msg['sender_id']?.toString() ?? '',
                    'timestamp':
                        msg['created_at'] ?? DateTime.now().toIso8601String(),
                    'leido': msg['read'] ?? false,
                  },
                )
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error al cargar mensajes: $e');
    }
  }

  Future<void> _enviarMensaje() async {
    if (_messageController.text.trim().isEmpty) return;

    final String mensaje = _messageController.text.trim();
    _messageController.clear();

    try {
      final token = await _getToken();

      // Si no hay chatId, intentar crear conversación primero
      if (_chatId == null) {
        await _crearObtenerConversacion(token);
        if (_chatId == null) {
          throw Exception('No se pudo crear la conversación');
        }
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chats/$_chatId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'message': mensaje}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          // Agregar mensaje localmente
          setState(() {
            _mensajes.add({
              'texto': mensaje,
              'enviadoPor': _usuarioActualId ?? '1',
              'timestamp': DateTime.now().toIso8601String(),
              'leido': false,
            });
          });
          _scrollToBottom();
        } else {
          throw Exception(data['message'] ?? 'Error al enviar mensaje');
        }
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar mensaje: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatHora(String? fechaHora) {
    if (fechaHora == null) return '';
    try {
      final DateTime dateTime = DateTime.parse(fechaHora);
      final DateFormat formatter = DateFormat('h:mm a', 'es');
      return formatter.format(dateTime);
    } catch (e) {
      return '';
    }
  }

  String _formatFechaHeader(String? fechaHora) {
    if (fechaHora == null) return '';
    try {
      final DateTime dateTime = DateTime.parse(fechaHora);
      final DateTime now = DateTime.now();
      final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        return 'Hoy';
      } else if (dateTime.year == yesterday.year &&
          dateTime.month == yesterday.month &&
          dateTime.day == yesterday.day) {
        return 'Ayer';
      } else {
        final DateFormat formatter = DateFormat(
          'dd \'de\' MMMM \'de\' yyyy',
          'es',
        );
        return formatter.format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }

  // Agrupar mensajes por fecha
  Map<String, List<Map<String, dynamic>>> _agruparMensajesPorFecha() {
    final Map<String, List<Map<String, dynamic>>> agrupados = {};

    for (var mensaje in _mensajes) {
      final timestamp = mensaje['timestamp'];
      if (timestamp == null) continue;

      try {
        final DateTime dateTime = DateTime.parse(timestamp.toString());
        final String fecha = DateFormat('yyyy-MM-dd').format(dateTime);
        if (!agrupados.containsKey(fecha)) {
          agrupados[fecha] = [];
        }
        agrupados[fecha]!.add(mensaje);
      } catch (e) {
        continue;
      }
    }

    return agrupados;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mensajesAgrupados = _agruparMensajesPorFecha();
    final fechasOrdenadas = mensajesAgrupados.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            ClipOval(
              child: Image.network(
                widget.fotoUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF81C784),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 25,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.rol,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5D4037),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _inicializarChat,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Lista de mensajes
                Expanded(
                  child: _mensajes.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Color(0xFF81C784),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No hay mensajes aún',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Escribe el primer mensaje',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: fechasOrdenadas.length,
                          itemBuilder: (context, index) {
                            final fecha = fechasOrdenadas[index];
                            final mensajesDeFecha = mensajesAgrupados[fecha]!;

                            return Column(
                              children: [
                                // Indicador de fecha
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _formatFechaHeader(
                                          mensajesDeFecha.first['timestamp'],
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF5D4037),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ...mensajesDeFecha.map(
                                  (mensaje) => _buildMessageBubble(mensaje),
                                ),
                              ],
                            );
                          },
                        ),
                ),

                // Campo de entrada de mensaje
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Escribe un mensaje...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _enviarMensaje(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _enviarMensaje,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> mensaje) {
    final esEnviado = mensaje['enviadoPor'] == _usuarioActualId;
    final texto = mensaje['texto'] ?? '';
    final timestamp = mensaje['timestamp'];

    return Align(
      alignment: esEnviado ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: esEnviado
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: esEnviado ? const Color(0xFF2E7D32) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(esEnviado ? 20 : 4),
                  bottomRight: Radius.circular(esEnviado ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 14,
                  color: esEnviado ? Colors.white : const Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatHora(timestamp),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
