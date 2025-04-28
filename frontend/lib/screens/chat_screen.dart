import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pregnancy_app/services/api_service.dart';
import 'package:pregnancy_app/theme/app_theme.dart';
import 'package:pregnancy_app/utils/constants.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _showSuggestions = true;
  late AnimationController _typingAnimController;

  // Warna gradient untuk bubble chat
  final List<Color> _userGradient = [
    AppTheme.primaryColor,
    AppTheme.primaryColor.withOpacity(0.7),
  ];

  final List<Color> _botGradient = [
    Colors.white,
    Colors.grey.shade50,
  ];

  @override
  void initState() {
    super.initState();
    _typingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    // Tambahkan pesan sambutan
    _fetchInitialSuggestions();
  }

  void _fetchInitialSuggestions() async {
    try {
      final response = await _apiService.sendChatMessage(
          "Berikan saran pertanyaan untuk ibu hamil", "user123");

      // Konversi List<dynamic> ke List<String>
      List<String> suggestionsList = [];
      if (response['suggestions'] != null) {
        suggestionsList = List<String>.from(
            response['suggestions'].map((item) => item.toString()));
      }

      setState(() {
        _messages.add({
          'text':
              'Halo! Saya asisten nutrisi kehamilan Anda. Apa yang ingin Anda tanyakan tentang nutrisi selama kehamilan?',
          'isUser': false,
          'timestamp': DateTime.now(),
          'suggestions': suggestionsList,
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'text':
              'Halo! Saya asisten nutrisi kehamilan Anda. Apa yang ingin Anda tanyakan tentang nutrisi selama kehamilan?',
          'isUser': false,
          'timestamp': DateTime.now(),
          'suggestions': [
            'Bagaimana mengatasi morning sickness?',
            'Makanan apa yang kaya folat?',
            'Berapa banyak air yang harus diminum setiap hari?',
            'Apakah aman makan ikan selama kehamilan?',
          ],
        });
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Hapus suggestions setelah user mengirim pesan
    setState(() {
      _showSuggestions = false;
    });

    // Tambahkan pesan user
    final userMessage = {
      'text': text,
      'isUser': true,
      'timestamp': DateTime.now(),
    };

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();

    // Auto scroll ke pesan terbaru
    _scrollToBottom();

    // Tambahkan haptic feedback
    HapticFeedback.lightImpact();

    try {
      final response = await _apiService.sendChatMessage(text, 'user123');

      if (mounted) {
        setState(() {
          _isLoading = false;

          // Konversi List<dynamic> ke List<String>
          List<String> suggestionsList = [];
          if (response['suggestions'] != null) {
            suggestionsList = List<String>.from(
                response['suggestions'].map((item) => item.toString()));
          }

          _messages.add({
            'text': response['response'],
            'isUser': false,
            'timestamp': DateTime.now(),
            'suggestions': suggestionsList,
          });
        });

        // Auto scroll ke pesan terbaru
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.add({
            'text': 'Maaf, terjadi kesalahan. Silakan coba lagi nanti.',
            'isUser': false,
            'timestamp': DateTime.now(),
          });
        });

        _scrollToBottom();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    // Delay sedikit untuk memastikan UI sudah diupdate
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Assistant'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show info about the assistant
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                image: DecorationImage(
                  image: const AssetImage('assets/images/chat_bg.png'),
                  fit: BoxFit.cover,
                  opacity: 0.5,
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return _buildLoadingBubble();
                  }

                  final message = _messages[index];
                  return _buildMessageBubble(
                    message['text'],
                    message['isUser'],
                    message['timestamp'],
                    suggestions: message['suggestions'],
                    isFirstMessage: index == 0,
                  );
                },
              ),
            ),
          ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                // Mic button
                IconButton(
                  icon: const Icon(Icons.mic_none_rounded),
                  onPressed: _isLoading
                      ? null
                      : () {
                          // Voice input functionality
                        },
                  color: AppTheme.primaryColor,
                ),

                // Text input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ketik pertanyaan Anda...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        suffixIcon: _messageController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _messageController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (text) {
                        setState(() {});
                      },
                      onSubmitted: _isLoading ? null : _sendMessage,
                      enabled: !_isLoading,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: _messageController.text.isNotEmpty
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    boxShadow: _messageController.text.isNotEmpty
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    color: Colors.white,
                    onPressed: _isLoading || _messageController.text.isEmpty
                        ? null
                        : () => _sendMessage(_messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 60),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              radius: 18,
              child: const Icon(
                Icons.health_and_safety,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),

            // Bubble
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _typingAnimController,
                      builder: (context, child) {
                        return Row(
                          children: [
                            _buildDot(_typingAnimController.value > 0.3),
                            const SizedBox(width: 4),
                            _buildDot(_typingAnimController.value > 0.5),
                            const SizedBox(width: 4),
                            _buildDot(_typingAnimController.value > 0.7),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMessageBubble(
    String message,
    bool isUser,
    DateTime timestamp, {
    List<String>? suggestions,
    bool isFirstMessage = false,
  }) {
    // Process the message text to remove markdown symbols and format properly
    final formattedMessage = _processMessageText(message);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 18,
                  child: const Icon(
                    Icons.health_and_safety,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isUser ? _userGradient : _botGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 0),
                      bottomRight: Radius.circular(isUser ? 0 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormattedMessageContent(formattedMessage, isUser),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(timestamp),
                        style: TextStyle(
                          color: isUser
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  radius: 18,
                  child: const Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),

          // Show suggestions if available
          if (suggestions != null && suggestions.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                top: 8,
                left: isUser ? 0 : 44,
                right: isUser ? 44 : 0,
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: isUser ? WrapAlignment.end : WrapAlignment.start,
                children: suggestions.map((suggestion) {
                  return InkWell(
                    onTap: () => _sendMessage(suggestion),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to build formatted message content
  Widget _buildFormattedMessageContent(
      Map<String, dynamic> formattedMessage, bool isUser) {
    if (formattedMessage['sections'].isEmpty) {
      // Regular text message
      return Text(
        formattedMessage['plainText'],
        style: TextStyle(
          color: isUser ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      );
    } else {
      // Structured nutrition message
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (formattedMessage['hasTitle'])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                formattedMessage['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: isUser ? Colors.white : AppTheme.primaryColor,
                ),
              ),
            ),
          ...formattedMessage['sections'].map<Widget>((section) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (section['key'].isNotEmpty) ...[
                    Text(
                      section['key'] + ': ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isUser ? Colors.white : AppTheme.primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        section['value'],
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ] else
                    Expanded(
                      child: Text(
                        section['value'],
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      );
    }
  }

  // Process message text to handle formatting
  Map<String, dynamic> _processMessageText(String message) {
    Map<String, dynamic> result = {
      'hasTitle': false,
      'title': '',
      'sections': <Map<String, String>>[],
      'plainText': '',
    };

    // Remove markdown symbols
    String processedText = message.replaceAll('**', '');

    // Set plain text for simple messages
    result['plainText'] = processedText;

    // Split into sections
    List<String> paragraphs = processedText.split('\n\n');

    // Check if message has a title (like "Kebutuhan Nutrisi Penting")
    if (paragraphs.isNotEmpty &&
        (paragraphs[0].contains('Kebutuhan Nutrisi Penting') ||
            paragraphs[0].contains('Selamat!'))) {
      result['hasTitle'] = true;
      result['title'] = paragraphs[0];
      paragraphs = paragraphs.sublist(1);
    }

    // Process nutrition sections
    for (String paragraph in paragraphs) {
      if (paragraph.contains('Kalori:') ||
          paragraph.contains('Protein:') ||
          paragraph.contains('Folat:')) {
        // Handle bullet points
        if (paragraph.startsWith('* ')) {
          paragraph = paragraph.substring(2);
        }

        // Split into key-value pairs for nutrition info
        List<String> parts = paragraph.split(':');
        if (parts.length > 1) {
          result['sections'].add({
            'key': parts[0].trim(),
            'value': parts.sublist(1).join(':').trim(),
          });
        } else {
          result['sections'].add({
            'key': '',
            'value': paragraph.trim(),
          });
        }
      } else if (paragraph.trim().isNotEmpty) {
        // Regular paragraph
        result['sections'].add({
          'key': '',
          'value': paragraph.trim(),
        });
      }
    }

    return result;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
