import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/services.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  late IO.Socket socket;
  bool _isConnected = false;

  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isRecorderInitialized = false;
  String _statusMessage = 'Ready to chat';
  DateTime? _recordingStartTime;

  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSocket();
    _initializeRecorder();
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

  Future<void> _initializeRecorder() async {
    try {
      _recorder = FlutterSoundRecorder();
      _player = FlutterSoundPlayer();
      await _recorder!.openRecorder();
      await _player!.openPlayer();

      setState(() {
        _isRecorderInitialized = true;
        _statusMessage = 'Voice recorder initialized';
      });
    } catch (e) {
      setState(() {
        _isRecorderInitialized = false;
        _statusMessage = 'Voice recorder initialization failed';
      });
    }
  }

  void _initializeSocket() {
    socket = IO.io('https://compass-sarvam-chatbot.onrender.com/',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .build());

    socket.onConnect((_) {
      setState(() {
        _isConnected = true;
        _statusMessage = 'Connected to voice bot';
      });
    });

    socket.onDisconnect((_) {
      setState(() {
        _isConnected = false;
        _statusMessage = 'Disconnected from voice bot';
      });
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
    final microphoneStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();
    if (!microphoneStatus.isGranted) {
      _showErrorSnackBar('Microphone permission is required for voice input');
    }
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

  Future<void> _startRecording() async {
    if (!_isRecorderInitialized) {
      _showErrorSnackBar('Voice recorder not initialized');
      return;
    }

    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        _showErrorSnackBar('Microphone permission denied');
        return;
      }
    }

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String tempPath = '${tempDir.path}/recording_$timestamp.aac';

    setState(() {
      _isRecording = true;
      _statusMessage = 'Listening... Speak now';
      _recordingStartTime = DateTime.now();
    });

    _pulseController.repeat(reverse: true);
    _waveController.repeat();

    await _recorder!.startRecorder(
      toFile: tempPath,
      codec: Codec.aacADTS,
      sampleRate: 16000,
      numChannels: 1,
      audioSource: AudioSource.microphone,
    );
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _recorder == null) return;

    setState(() {
      _isRecording = false;
      _isProcessing = true;
      _statusMessage = 'Processing your speech...';
    });

    _pulseController.stop();
    _waveController.stop();

    final recordingPath = await _recorder!.stopRecorder();
    if (recordingPath != null) {
      await _sendAudioToServer(recordingPath);
    }
  }

  Future<void> _sendAudioToServer(String audioPath) async {
    try {
      final audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        throw Exception('Audio file does not exist');
      }

      final audioBytes = await audioFile.readAsBytes();
      if (audioBytes.isEmpty) {
        _showErrorSnackBar('Empty audio file');
        setState(() => _isProcessing = false);
        return;
      }

      final audioBase64 = base64Encode(audioBytes);

      // ✅ Changed: Send ONLY base64 string, no dictionary
      socket.emit('audio_stream', audioBase64);

      Future.delayed(const Duration(seconds: 2), () async {
        if (await audioFile.exists()) {
          await audioFile.delete();
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to send audio: $e');
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _playAudioResponse(dynamic audioData) async {
    try {
      Uint8List audioBytes;
      if (audioData is String) {
        audioBytes = base64Decode(audioData);
      } else if (audioData is List<int>) {
        audioBytes = Uint8List.fromList(audioData);
      } else {
        throw Exception('Unsupported audio data format');
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/response_${DateTime.now().millisecondsSinceEpoch}.wav');
      await tempFile.writeAsBytes(audioBytes);

      await _audioPlayer.play(DeviceFileSource(tempFile.path));
      _audioPlayer.onPlayerComplete.listen((_) {
        tempFile.delete().catchError((_) {});
      });
    } catch (e) {
      _showErrorSnackBar('Failed to play audio response');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
                      : !_isRecorderInitialized
                      ? [Colors.grey.shade400, Colors.grey.shade600]
                      : [Colors.blue.shade400, Colors.blue.shade600],
                ),
              ),
              child: Icon(
                _isRecording
                    ? Icons.stop
                    : _isProcessing
                    ? Icons.hourglass_empty
                    : !_isRecorderInitialized
                    ? Icons.mic_off
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Text(_statusMessage),
          ),
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
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                _buildVoiceButton(),
                const SizedBox(height: 16),
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
                        ),
                        onSubmitted: (_) => _sendTextMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade600,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _isConnected ? _sendTextMessage : null,
                      ),
                    )
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
    _recorder?.closeRecorder();
    _player?.closePlayer();
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
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue.shade600 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
