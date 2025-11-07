import 'dart:async';
import 'package:flutter/material.dart';
import 'package:whatsapp_text_scheduler/services/firestore_service.dart';
import 'package:whatsapp_text_scheduler/widgets/chat_list.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _timer;
  
  // --- UI स्टेट वापस जोड़ा गया ---
  bool _isTyping = false; 

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      FirestoreService.checkScheduledMessages();
    });
    
    // --- typing-detection लिस्नर वापस जोड़ा गया ---
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_onTextChanged); // लिस्नर हटाया गया
    _controller.dispose();
    super.dispose();
  }

  // --- 'phele jaysa' UI के लिए फंक्शन्स ---
  void _onTextChanged() {
    setState(() {
      _isTyping = _controller.text.isNotEmpty;
    });
  }

  void _onMicPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Voice recording not implemented.")),
    );
  }
  // --- (end) ---

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    FirestoreService.sendMessage(text);
    _controller.clear();
  }

  Future<void> _pickScheduleTime() async {
    final now = DateTime.now();

    // 1️⃣ Select date
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)), 
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.teal,
            onPrimary: Colors.white,
            surface: Color(0xFF1F2C34),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (selectedDate == null) return;

    // 2️⃣ Select time
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 1))),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: Color(0xFF1F2C34),
            hourMinuteTextColor: Colors.white,
            dialBackgroundColor: Colors.black12,
          ),
        ),
        child: child!,
      ),
    );

    if (selectedTime == null) return;

    // 3️⃣ Combine date & time
    final scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (scheduledDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a future time')),
      );
      return;
    }

    // 4️⃣ Schedule message
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please type a message first')),
      );
      return;
    }

    await FirestoreService.scheduleMessage(text, scheduledDateTime);
    _controller.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Message scheduled for ${scheduledTimeLabel(scheduledDateTime)}',
        ),
      ),
    );
  }

  String scheduledTimeLabel(DateTime dt) {
    final time = TimeOfDay.fromDateTime(dt);
    final formatted =
        "${dt.day}/${dt.month} at ${time.format(context)}"; // eg: 8/11 at 05:00 AM
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    // --- UI को वापस डार्क मोड पर हार्डकोड किया गया ---
    return Scaffold(
      backgroundColor: const Color(0xFF121B22),
      
      // --- 1. AppBar को 'phele jaysa' बनाया गया ---
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2C34),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Row(
          children: const [
            CircleAvatar(
              backgroundColor: Colors.grey,
              child: Text("K", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Krish"),
                Text(
                  "online",
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          const Expanded(child: ChatList()),
          
          // --- 2. Input Bar को 'phele jaysa' बनाया गया ---
          Padding(
            padding: EdgeInsets.fromLTRB(
                8.0, 5.0, 8.0, MediaQuery.of(context).padding.bottom + 5.0),
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
                          icon: Icon(Icons.emoji_emotions_outlined,
                              color: Colors.grey[400]),
                          onPressed: () { /* Emoji */ },
                        ),
                        Flexible(
                          child: TextField(
                            controller: _controller, // आपका कंट्रोलर
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Message",
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], fontSize: 16),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 14.0),
                            ),
                          ),
                        ),
                        IconButton(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.access_time, // क्लॉक आइकॉन
                              color: Colors.grey[400]),
                          onPressed: _pickScheduleTime, // आपका फंक्शन
                        ),
                        IconButton(
                          padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.camera_alt,
                              color: Colors.grey[400]),
                          onPressed: () { /* Camera */ },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // --- 3. Send/Mic बटन को 'phele jaysa' बनाया गया ---
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF00A884),
                  child: IconButton(
                    icon: Icon(
                      _isTyping ? Icons.send : Icons.mic,
                      color: Colors.white,
                    ),
                    onPressed: _isTyping ? _sendMessage : _onMicPressed,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}