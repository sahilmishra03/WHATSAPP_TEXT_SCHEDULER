import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final DateTime time;
  final bool isScheduled;
  final bool isSent;

  const MessageBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isScheduled,
    required this.isSent,
  });

  @override
  Widget build(BuildContext context) {
    IconData statusIcon;
    Color iconColor;

    if (isScheduled && !isSent) {
      statusIcon = Icons.schedule;
      iconColor = Colors.grey[400]!;
    } else if (isSent) {
      statusIcon = Icons.done_all;
      iconColor = const Color(0xFF53BDEB); // Blue for 'read' ticks
    } else {
      statusIcon = Icons.check;
      iconColor = Colors.grey[400]!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      // Align the entire bubble to the right
      child: Align(
        alignment: Alignment.centerRight,
        // The message bubble itself
        child: Container(
          // Set a maximum width for the bubble
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF005C4B), // WhatsApp dark mode sent green
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          // Use IntrinsicWidth to make the Column only as wide as its widest child
          child: IntrinsicWidth(
            child: Column(
              // Align everything inside the bubble to the end (right)
              crossAxisAlignment: CrossAxisAlignment.stretch, // Allow children to stretch horizontally
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 4),
                // This row contains time and status, and will align to the right
                // because of the Column's crossAxisAlignment.end
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Align contents of this row to the right
                  mainAxisSize: MainAxisSize.min, // Essential: make the row only as wide as its children
                  children: [
                    Text(
                      DateFormat('h:mm a').format(time),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      statusIcon,
                      size: 16,
                      color: iconColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}