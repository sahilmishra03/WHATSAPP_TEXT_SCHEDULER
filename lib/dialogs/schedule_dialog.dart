import 'package:flutter/material.dart';
import 'package:whatsapp_text_scheduler/services/firestore_service.dart';

Future<void> openScheduleDialog(BuildContext context) async {
  final TextEditingController messageCtrl = TextEditingController();
  DateTime? selectedDate;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Schedule Message"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageCtrl,
              decoration: const InputDecoration(
                labelText: "Enter your message",
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.access_time),
              label: const Text("Pick Time"),
              onPressed: () async {
                final now = DateTime.now();
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 7)),
                );
                if (pickedDate == null) return;
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(now),
                );
                if (pickedTime == null) return;
                selectedDate = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (messageCtrl.text.trim().isEmpty || selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please add message & pick time"),
                  ),
                );
                return;
              }
              await FirestoreService.scheduleMessage(
                messageCtrl.text.trim(),
                selectedDate!,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Message Scheduled Successfully")),
              );
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}
