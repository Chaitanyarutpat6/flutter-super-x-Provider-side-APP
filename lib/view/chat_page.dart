import 'dart:ui';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  // This is a dummy list of messages for UI design purposes.
  // In a real app, this will come from a Firestore stream.
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hello, I have a question about the plumbing job at Koregaon Park.', 'isMe': true, 'time': '4:05 PM'},
    {'text': 'Of course, how can I help?', 'isMe': false, 'time': '4:06 PM'},
    {'text': 'The client is asking if I can also check the bathroom faucet, which was not in the original request. Should I proceed?', 'isMe': true, 'time': '4:06 PM'},
    {'text': 'Let me check with the client and confirm. Stand by.', 'isMe': false, 'time': '4:07 PM'},
  ];

  // --- UI Colors ---
  static const Color primaryColor = Color(0xFF1A237E); // Indigo
  static const Color accentColor = Color(0xFF29B6F6); // Light Blue
  
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text,
          'isMe': true,
          'time': TimeOfDay.now().format(context),
        });
        _messageController.clear();
      });
      // TODO: Add logic to send the message to Firestore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(context),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      reverse: true, // To show the latest messages at the bottom
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        // To display messages from bottom to top
                        final message = _messages[_messages.length - 1 - index];
                        return _buildMessageBubble(
                          message['text'],
                          message['isMe'],
                          message['time'],
                        );
                      },
                    ),
                  ),
                ),
              ),
              _buildMessageInputField(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Builders ---
  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            // Placeholder for manager's picture
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=58'),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manager Support',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Online',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMe ? primaryColor : const Color(0xFFF0F0F0);
    final textColor = isMe ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0),
                bottomLeft: Radius.circular(isMe ? 20.0 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 20.0),
              ),
            ),
            child: Text(text, style: TextStyle(color: textColor, fontSize: 16)),
          ),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          color: Colors.black.withOpacity(0.2),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.send, color: primaryColor),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}