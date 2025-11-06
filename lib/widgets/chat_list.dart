import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_text_scheduler/services/firestore_service.dart';
import 'package:whatsapp_text_scheduler/widgets/message_bubble.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.getChatStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final messages = snapshot.data!.docs;
        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final data = messages[index];
            final msg = data['message'];
            final time = (data['time'] as Timestamp).toDate();
            final isScheduled = data['isScheduled'] ?? false;

            return MessageBubble(
              message: msg,
              time: time,
              isScheduled: isScheduled,
            );
          },
        );
      },
    );
  }
}
