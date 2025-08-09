import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with TickerProviderStateMixin {
  // Controllers and State
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  // Socket connection
  late IO.Socket socket;
  bool _isConnected = false;

  // Voice recording with native platform channels
  static const platform = MethodChannel('voice_recorder');
  bool _isRecording = false;
  bool _isProcessing = false;
  String _statusMessage = 'Ready to chat';

  // Audio playback
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animations
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSocket();
    _requestPermissions();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_waveController);
  }

  void _initializeSocket() {
    socket = IO.io('https://compass-sarvam-chatbot.onrender.com/',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .build()
    );

    socket.onConnect((_) {
      setState(() {
        _isConnected = true;
        _statusMessage = 'Connected to voice bot';
      });
      print('🔗 Connected to voice bot');
    });

    socket.onDisconnect((_) {
      setState(() {
        _isConnected = false;
        _statusMessage = 'Disconnected from voice bot';
      });
      print('❌ Disconnected from voice bot');
    });

    socket.on('status_update', (data) {
      setState(() {
        _statusMessage = data['message'] ?? 'Processing...';
      });
    });

    socket.on('transcription_received', (data) {
      final transcription = data['transcription'] ?? '';
      final language = data['language'] ?? 'en-IN';

      if (transcription.isNotEmpty) {
        _addMessage(ChatMessage(
          text: transcription,
          isUser: true,
          timestamp: DateTime.now(),
          language: language,
        ));
      }
    });

    socket.on('bot_response', (data) {
      final response = data['response'] ?? '';
      final language = data['language'] ?? 'en-IN';

      if (response.isNotEmpty) {
        _addMessage(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
          language: language,
        ));
      }
    });

    socket.on('audio_response', (data) {
      if (data != null) {
        _playAudioResponse(data);
      }
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Response received';
      });
    });

    socket.on('error', (data) {
      setState(() {
        _isProcessing = false;
        _statusMessage = data['message'] ?? 'An error occurred';
      });
      _showErrorSnackBar(data['message'] ?? 'An error occurred');
    });
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendTextMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || !_isConnected) return;

    _addMessage(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _textController.clear();
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing your message...';
    });

    socket.emit('text_message', {'text': text});
  }

  // Simplified recording using a basic web-based approach for demo
  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          _showErrorSnackBar('Microphone permission denied');
          return;
        }
      }

      setState(() {
        _isRecording = true;
        _statusMessage = 'Listening... Speak now (Demo mode - text only)';
      });

      _pulseController.repeat(reverse: true);
      _waveController.repeat();

      // For demo purposes, we'll show a dialog to enter text
      _showVoiceInputDialog();

    } catch (e) {
      _showErrorSnackBar('Recording not available in demo mode');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
      _statusMessage = 'Ready to chat';
    });

    _pulseController.stop();
    _waveController.stop();
  }

  void _showVoiceInputDialog() {
    final voiceController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Voice Input (Demo Mode)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter text to simulate voice input:'),
            const SizedBox(height: 16),
            TextField(
              controller: voiceController,
              decoration: const InputDecoration(
                hintText: 'Type what you would say...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _stopRecording();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = voiceController.text.trim();
              Navigator.pop(context);
              _stopRecording();

              if (text.isNotEmpty) {
                _simulateVoiceInput(text);
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _simulateVoiceInput(String text) {
    // Add user message
    _addMessage(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing your speech...';
    });

    // Send as voice message to server (it will process the same way)
    socket.emit('text_message', {'text': text});
  }

  Future<void> _playAudioResponse(dynamic audioData) async {
    try {
      Uint8List audioBytes;

      if (audioData is String) {
        // Base64 encoded audio
        audioBytes = base64Decode(audioData);
      } else if (audioData is List<int>) {
        // Raw bytes
        audioBytes = Uint8List.fromList(audioData);
      } else {
        throw Exception('Unsupported audio data format');
      }

      // Create temporary file for playback
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/response_${DateTime.now().millisecondsSinceEpoch}.wav');
      await tempFile.writeAsBytes(audioBytes);

      // Play audio from file
      await _audioPlayer.play(DeviceFileSource(tempFile.path));

      // Clean up after playback
      _audioPlayer.onPlayerComplete.listen((_) {
        tempFile.delete().catchError((e) => print('Error deleting temp file: $e'));
      });

    } catch (e) {
      print('Error playing audio: $e');
      _showErrorSnackBar('Failed to play audio response');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return GestureDetector(
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRecording ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isRecording
                      ? [Colors.red.shade400, Colors.red.shade600]
                      : _isProcessing
                      ? [Colors.orange.shade400, Colors.orange.shade600]
                      : [Colors.blue.shade400, Colors.blue.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : Colors.blue).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isRecording
                    ? Icons.stop
                    : _isProcessing
                    ? Icons.hourglass_empty
                    : Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaveform() {
    if (!_isRecording) return const SizedBox();

    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final animationDelay = index * 0.2;
            final waveHeight = 20.0 *
                (1.0 + 0.5 *
                    ((_waveAnimation.value + animationDelay) % 1.0).clamp(0.0, 1.0));

            return Container(
              width: 4,
              height: waveHeight,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Voice Assistant'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isConnected ? 'CONNECTED' : 'DISCONNECTED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(
                  _isProcessing
                      ? Icons.hourglass_empty
                      : _isRecording
                      ? Icons.mic
                      : Icons.chat_bubble_outline,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (_isRecording) _buildWaveform(),
              ],
            ),
          ),

          // Demo Notice
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.amber.shade50,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo Mode: Voice button opens text dialog. Text chat works normally.',
                    style: TextStyle(
                      color: Colors.amber.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),

          // Voice Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Voice Button
                _buildVoiceButton(),
                const SizedBox(height: 12),
                Text(
                  _isRecording
                      ? 'Recording in demo mode...'
                      : 'Tap to simulate voice input',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),

                // Text Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: (_) => _sendTextMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _isConnected ? _sendTextMessage : null,
                        icon: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? language;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.language,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.blue.shade600,
              radius: 16,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.blue.shade600
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: message.isUser
                              ? Colors.white70
                              : Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                      if (message.language != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? Colors.white.withOpacity(0.2)
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            message.language!.split('-')[0].toUpperCase(),
                            style: TextStyle(
                              color: message.isUser
                                  ? Colors.white
                                  : Colors.blue.shade600,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey.shade400,
              radius: 16,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}