import 'dart:async';
import 'package:flutter/material.dart';
import 'package:whatsapp_text_scheduler/dialogs/schedule_dialog.dart';
import 'package:whatsapp_text_scheduler/services/firestore_service.dart';
import 'package:whatsapp_text_scheduler/widgets/chat_app_bar.dart';
import 'package:whatsapp_text_scheduler/widgets/chat_list.dart';
import 'package:whatsapp_text_scheduler/widgets/message_input_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  Timer? _checkerTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _checkerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      FirestoreService.checkScheduledMessages();
    });
    _msgController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _checkerTimer?.cancel();
    _msgController.removeListener(_onTextChanged);
    _msgController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isTyping = _msgController.text.isNotEmpty;
    });
  }

  void _onMicPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Voice recording not implemented.")),
    );
  }

  void _onSendPressed() {
    FirestoreService.sendMessage(_msgController.text.trim());
    _msgController.clear();
  }

  void _onSchedulePressed() {
    openScheduleDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChatAppBar(),
      body: Column(
        children: [
          const Expanded(child: ChatList()),
          MessageInputBar(
            controller: _msgController,
            isTyping: _isTyping,
            onSendPressed: _onSendPressed,
            onMicPressed: _onMicPressed,
            onSchedulePressed: _onSchedulePressed,
          ),
        ],
      ),
    );
  }
}
