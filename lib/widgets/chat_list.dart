import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_text_scheduler/services/firestore_service.dart';
import 'package:whatsapp_text_scheduler/widgets/message_bubble.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 1. Set the dark background color from the screenshot
      color: const Color(0xFF111B21), // WhatsApp dark background
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.getChatStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No messages scheduled',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final msg = data['message'] ?? '';
              final time = (data['time'] as Timestamp).toDate();
              final isScheduled = data['isScheduled'] ?? false;
              final isSent = data['isSent'] ?? false;

              // Pass data to the new dark-mode-aware bubble
              return MessageBubble(
                message: msg,
                time: time,
                isScheduled: isScheduled,
                isSent: isSent,
              );
            },
          );
        },
      ),
    );
  }
}