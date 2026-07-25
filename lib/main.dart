import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// 1. URL Corregida con su comilla final
const String serverUrl = 'https://chat-servidor-zer7.onrender.com';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Privado',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB61722),
          surface: const Color(0xFFE0F2FE),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA 1: LOGIN (Contraseña: "feito")
// -----------------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String? _errorMessage;

  void _submit() {
    final inputPassword = _passwordController.text.trim();

    if (inputPassword.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      if (inputPassword == 'feito') {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserSelectionScreen()),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Contraseña incorrecta';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2FE),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFDA3437).withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF506CDB).withOpacity(0.15),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                // 2. Corregido: maxWidth dentro de constraints
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB61722),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB61722).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: const Icon(Icons.lock, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Bienvenido de nuevo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0C1E26),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Introduce tu contraseña para continuar',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        errorText: _errorMessage,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFB61722), width: 1.5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility : Icons.visibility_off,
                            color: Colors.black45,
                          ),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB61722),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'DESBLOQUEAR CUENTA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '¿Has olvidado tu contraseña?',
                        style: TextStyle(color: Color(0xFFB61722), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA 2: SELECCIÓN DE IDENTIDAD
// -----------------------------------------------------------------------------
class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  void _selectUser(BuildContext context, String username, String token, Color userColor) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          username: username,
          token: token,
          userColor: userColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2FE),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  // 3. Corregido: white50 -> white.withOpacity(0.5)
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xFFEF4444), size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Elige tu identidad',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0C1E26)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecciona un usuario para comenzar la conversación.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    // USUARIO ROJO
                    InkWell(
                      onTap: () => _selectUser(context, 'ROJO', 'USER_1_TOKEN', const Color(0xFF1E40AF)),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                              child: const Icon(Icons.person, color: Colors.white, size: 32),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'ROJO',
                              // 4. Corregido: FontWeight.black en lugar de Color
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
                            ),
                            const Text(
                              'USUARIO PRINCIPAL',
                              style: TextStyle(fontSize: 11, color: Colors.white70, letterSpacing: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // USUARIO ROSA
                    InkWell(
                      onTap: () => _selectUser(context, 'ROSA', 'USER_2_TOKEN', const Color(0xFFFBCFE8)),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBCFE8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(color: Colors.black12, shape: BoxShape.circle),
                              child: const Icon(Icons.person_outline, color: Colors.black87, size: 32),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'ROSA',
                              // 4. Corregido: FontWeight.w900 en lugar de FontWeight.black
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 2),
                            ),
                            const Text(
                              'USUARIO SECUNDARIO',
                              style: TextStyle(fontSize: 11, color: Colors.black54, letterSpacing: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA 3: CHAT CON TICS DE ESTADO
// -----------------------------------------------------------------------------
class ChatScreen extends StatefulWidget {
  final String username;
  final String token;
  final Color userColor;

  const ChatScreen({
    super.key,
    required this.username,
    required this.token,
    required this.userColor,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'token': widget.token})
          .build(),
    );

    socket.io.options?['token'] = widget.token;
    socket.connect();

    socket.on('receive_message', (data) {
      if (mounted) {
        final msg = Map<String, dynamic>.from(data);
        setState(() {
          _messages.add(msg);
        });

        socket.emit('mark_as_read', {'id': msg['id']});
      }
    });

    socket.on('message_read', (data) {
      if (mounted) {
        setState(() {
          for (var msg in _messages) {
            if (msg['id'] == data['id']) {
              msg['read'] = true;
            }
          }
        });
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final String msgId = DateTime.now().millisecondsSinceEpoch.toString();
    final String msgText = _messageController.text.trim();
    final String currentTime = '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    final messageData = {
      'id': msgId,
      'sender': widget.token,
      'text': msgText,
      'time': currentTime,
      'read': false,
    };

    setState(() {
      _messages.add(messageData);
    });

    socket.emit('send_message', messageData);
    _messageController.clear();
  }

  @override
  void dispose() {
    socket.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2FE),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB61722)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserSelectionScreen()),
            );
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFB61722).withOpacity(0.2),
              child: Text(
                widget.username[0],
                style: const TextStyle(color: Color(0xFFB61722), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chat Privado',
                  style: TextStyle(color: Color(0xFFB61722), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Conectado como ${widget.username}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg['sender'] == widget.token;
                  final isRosa = msg['sender'] == 'USER_2_TOKEN';
                  final isRead = msg['read'] == true;

                  final bubbleColor = isRosa ? const Color(0xFFFBCFE8) : const Color(0xFF1E40AF);
                  final textColor = isRosa ? Colors.black : Colors.white;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Text(
                              msg['text'] ?? '',
                              style: TextStyle(color: textColor, fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, right: 4, top: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  msg['time'] ?? '',
                                  style: const TextStyle(fontSize: 10, color: Colors.black38),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    isRead ? Icons.done_all : Icons.done,
                                    size: 14,
                                    color: isRead ? const Color(0xFF10B981) : Colors.black38,
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Barra para escribir con clip y micrófono añadidos
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  color: Colors.white.withOpacity(0.8),
  child: Row(
    children: [
      // 📎 Botón para adjuntar archivos
      IconButton(
        icon: const Icon(Icons.attach_file, color: Color(0xFFB61722)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Función de adjuntar archivo próxima...')),
          );
        },
      ),
      
      // Caja de texto
      Expanded(
        child: TextField(
          controller: _messageController,
          decoration: InputDecoration(
            hintText: 'Escribe un mensaje...',
            fillColor: const Color(0xFFE0F2FE).withOpacity(0.5),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) => _sendMessage(),
        ),
      ),
      
      const SizedBox(width: 4),

      // 🎤 Botón para grabar audio
      IconButton(
        icon: const Icon(Icons.mic, color: Color(0xFFB61722)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Función de grabar audio próxima...')),
          );
        },
      ),

      // 🚀 Botón para enviar texto
      CircleAvatar(
        backgroundColor: const Color(0xFFB61722),
        radius: 20,
        child: IconButton(
          icon: const Icon(Icons.send, color: Colors.white, size: 16),
          onPressed: _sendMessage,
        ),
      ),
    ],
  ),
),