import 'package:flutter/material.dart';

class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isTyping;
  final VoidCallback onSendPressed;
  final VoidCallback onMicPressed;
  final VoidCallback onSchedulePressed;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.isTyping,
    required this.onSendPressed,
    required this.onMicPressed,
    required this.onSchedulePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        8.0,
        5.0,
        8.0,
        MediaQuery.of(context).padding.bottom + 5.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              color: const Color(0xFF1F2C34),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    padding: const EdgeInsets.only(left: 8.0),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {},
                  ),
                  Flexible(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Message",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 14.0,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.access_time, color: Colors.grey[400]),
                    onPressed: onSchedulePressed,
                  ),
                  IconButton(
                    padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.camera_alt, color: Colors.grey[400]),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF00A884),
            child: IconButton(
              icon: Icon(
                isTyping ? Icons.send : Icons.mic,
                color: Colors.white,
              ),
              onPressed: isTyping ? onSendPressed : onMicPressed,
            ),
          ),
        ],
      ),
    );
  }
}
