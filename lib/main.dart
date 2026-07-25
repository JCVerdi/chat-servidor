import 'dart0:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
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
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bienvenido de nuevo',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0C1E26)),
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
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
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
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('DESBLOQUEAR CUENTA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                const Text(
                  'Elige tu identidad',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0C1E26)),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), minimumSize: const Size.fromHeight(60)),
                  onPressed: () => _selectUser(context, 'ROJO', 'USER_1_TOKEN', const Color(0xFF1E40AF)),
                  child: const Text('USUARIO ROJO', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFBCFE8), minimumSize: const Size.fromHeight(60)),
                  onPressed: () => _selectUser(context, 'ROSA', 'USER_2_TOKEN', const Color(0xFFFBCFE8)),
                  child: const Text('USUARIO ROSA', style: TextStyle(color: Colors.black87, fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA 3: CHAT CON SOPORTE COMPLETO (COMPATIBLE WEB Y MÓVIL)
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

  // Lógica de grabación de voz
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

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

  void _sendMessage({String type = 'text', String? fileData, String? fileName}) {
    if (type == 'text' && _messageController.text.trim().isEmpty) return;

    final String msgId = DateTime.now().millisecondsSinceEpoch.toString();
    final String currentTime = '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    final messageData = {
      'id': msgId,
      'sender': widget.token,
      'type': type, // 'text', 'image', 'file', 'audio'
      'text': type == 'text' ? _messageController.text.trim() : (fileName ?? ''),
      'fileData': fileData,
      'time': currentTime,
      'read': false,
    };

    setState(() {
      _messages.add(messageData);
    });

    socket.emit('send_message', messageData);
    if (type == 'text') _messageController.clear();
  }

  // --- LÓGICA DE GRABACIÓN DE VOZ (MÓVIL Y WEB) ---
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: '',
        );
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });

        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingSeconds++;
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar grabación: $e')),
      );
    }
  }

  Future<void> _stopAndSendRecording() async {
    _recordingTimer?.cancel();
    final path = await _audioRecorder.stop();

    if (path != null) {
      Uint8List? bytes;

      if (kIsWeb) {
        final response = await NetworkAssetBundle(Uri.parse(path)).load("");
        bytes = response.buffer.asUint8List();
      } else {
        final file = io.File(path);
        if (await file.exists()) {
          bytes = await file.readAsBytes();
        }
      }

      if (bytes != null) {
        final base64Audio = base64Encode(bytes);
        final durationText = '${_recordingSeconds ~/ 60}:${(_recordingSeconds % 60).toString().padLeft(2, '0')}';

        _sendMessage(
          type: 'audio',
          fileData: base64Audio,
          fileName: 'Nota de voz ($durationText)',
        );
      }
    }

    setState(() {
      _isRecording = false;
      _recordingSeconds = 0;
    });
  }

  Future<void> _cancelRecording() async {
    _recordingTimer?.cancel();
    await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _recordingSeconds = 0;
    });
  }

  // --- LÓGICA DE SELECCIÓN DE ARCHIVOS E IMÁGENES ---
  Future<void> _pickAndSendFile(FileType type) async {
    // Usamos FilePicker.instance para ser compatible con versiones recientes
    FilePickerResult? result = await FilePicker.instance.pickFiles(
      type: type,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        final base64String = base64Encode(file.bytes!);
        final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(file.extension?.toLowerCase());

        _sendMessage(
          type: isImage ? 'image' : 'file',
          fileData: base64String,
          fileName: file.name,
        );
      }
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
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
        title: Text('Chat Privado (${widget.username})', style: const TextStyle(color: Color(0xFFB61722))),
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
                  final type = msg['type'] ?? 'text';

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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _buildMessageContent(type, msg, textColor),
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
            
            // BARRA DE INGRESO DE TEXTO / GRABACIÓN DE VOZ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.white.withOpacity(0.8),
              child: _isRecording ? _buildRecordingBar() : _buildInputBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingBar() {
    final minutes = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordingSeconds % 60).toString().padLeft(2, '0');

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: _cancelRecording,
        ),
        const Icon(Icons.fiber_manual_record, color: Colors.red, size: 18),
        const SizedBox(width: 8),
        Text(
          'Grabando: $minutes:$seconds',
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        CircleAvatar(
          backgroundColor: const Color(0xFF10B981),
          radius: 20,
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.white, size: 16),
            onPressed: _stopAndSendRecording,
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    return Row(
      children: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.attach_file, color: Color(0xFFB61722)),
          onSelected: (value) {
            if (value == 'image') {
              _pickAndSendFile(FileType.image);
            } else if (value == 'file') {
              _pickAndSendFile(FileType.any);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'image',
              child: Row(
                children: [
                  Icon(Icons.image, color: Color(0xFFB61722)),
                  SizedBox(width: 8),
                  Text('Enviar Imagen'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'file',
              child: Row(
                children: [
                  Icon(Icons.insert_drive_file, color: Color(0xFFB61722)),
                  SizedBox(width: 8),
                  Text('Enviar Documento'),
                ],
              ),
            ),
          ],
        ),
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
        IconButton(
          icon: const Icon(Icons.mic, color: Color(0xFFB61722)),
          onPressed: _startRecording,
        ),
        CircleAvatar(
          backgroundColor: const Color(0xFFB61722),
          radius: 20,
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.white, size: 16),
            onPressed: () => _sendMessage(),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageContent(String type, Map<String, dynamic> msg, Color textColor) {
    if (type == 'image' && msg['fileData'] != null) {
      final bytes = base64Decode(msg['fileData']);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(bytes, fit: BoxFit.cover),
      );
    } else if (type == 'audio') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow, color: textColor, size: 28),
          const SizedBox(width: 8),
          Text(
            msg['text'] ?? 'Nota de voz',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ],
      );
    } else if (type == 'file') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file, color: textColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              msg['text'] ?? 'Archivo adjunto',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        msg['text'] ?? '',
        style: TextStyle(color: textColor, fontSize: 15),
      ),
    );
  }
}