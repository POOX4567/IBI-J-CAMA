import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String nombre;
  final String rol;
  final String fotoUrl;

  const ChatScreen({
    super.key,
    required this.nombre,
    required this.rol,
    required this.fotoUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Datos estáticos (simulando los que vendrían de Firestore)
  final List<Map<String, dynamic>> _mensajesEstaticos = [
    {
      'texto':
          'Hola, jefe. Solo quería confirmar que ya terminamos la inspección de humedad en el Sector 4. Los niveles están un poco más altos de lo normal.',
      'enviadoPor': 'empleado',
      'timestamp': Timestamp.fromDate(
        DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      'leido': true,
    },
    {
      'texto':
          'Entendido, Marcus. ¿Qué tanto subieron? ¿Es necesario ajustar el ciclo de riego automático para esta tarde?',
      'enviadoPor': 'supervisor',
      'timestamp': Timestamp.fromDate(
        DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      'leido': true,
    },
    {
      'texto':
          'Subieron un 12%. Recomiendo pausar el riego de las 2:00 PM y volver a medir a las 4:00 PM. Adjunto foto de los sensores.',
      'enviadoPor': 'empleado',
      'timestamp': Timestamp.fromDate(
        DateTime.now().subtract(const Duration(minutes: 22)),
      ),
      'leido': true,
    },
  ];

  // Usuario actual simulado (cuando conectes Firebase, esto vendrá de autenticación)
  final String _usuarioActualId = 'supervisor';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    // Simular agregar mensaje localmente (como si fuera a Firestore)
    setState(() {
      _mensajesEstaticos.add({
        'texto': _messageController.text.trim(),
        'enviadoPor': _usuarioActualId,
        'timestamp': Timestamp.now(),
        'leido': false,
      });
      _messageController.clear();
    });

    _scrollToBottom();
  }

  String _formatHora(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('h:mm a', 'es');
    return formatter.format(dateTime);
  }

  String _formatFechaHeader(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
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
  }

  // Agrupar mensajes por fecha
  Map<String, List<Map<String, dynamic>>> _agruparMensajesPorFecha() {
    final Map<String, List<Map<String, dynamic>>> agrupados = {};

    for (var mensaje in _mensajesEstaticos) {
      final timestamp = mensaje['timestamp'] as Timestamp;
      final fecha = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
      if (!agrupados.containsKey(fecha)) {
        agrupados[fecha] = [];
      }
      agrupados[fecha]!.add(mensaje);
    }

    return agrupados;
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
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: fechasOrdenadas.length,
              itemBuilder: (context, index) {
                final fecha = fechasOrdenadas[index];
                final mensajesDeFecha = mensajesAgrupados[fecha]!;

                // Obtener timestamp para la fecha (primer mensaje del día)
                final primerTimestamp =
                    mensajesDeFecha.first['timestamp'] as Timestamp;

                return Column(
                  children: [
                    // Indicador de fecha
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
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
                            _formatFechaHeader(primerTimestamp),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
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
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
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
    final texto = mensaje['texto'];
    final timestamp = mensaje['timestamp'] as Timestamp;

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
