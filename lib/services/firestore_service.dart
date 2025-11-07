import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot> getChatStream() {
    return _db.collection('chats').orderBy('time', descending: true).snapshots();
  }

  static Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    await _db.collection('chats').add({
      'message': message.trim(),
      'time': Timestamp.now(),
      'isScheduled': false,
      'isSent': true,
    });
  }

  static Future<void> scheduleMessage(String message, DateTime scheduledTime) async {
    if (message.trim().isEmpty) return;

    final scheduledRef = await _db.collection('scheduled_messages').add({
      'message': message.trim(),
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'sent': false,
    });

    await _db.collection('chats').add({
      'message': message.trim(),
      'time': Timestamp.fromDate(scheduledTime),
      'isScheduled': true,
      'isSent': false,
      'scheduledId': scheduledRef.id,
    });
  }

  static Future<void> checkScheduledMessages() async {
    final now = DateTime.now();
    final snapshot = await _db
        .collection('scheduled_messages')
        .where('sent', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final scheduledTime = (data['scheduledTime'] as Timestamp).toDate();

      if (!scheduledTime.isAfter(now)) {
        await doc.reference.update({'sent': true});

        final chatQuery = await _db
            .collection('chats')
            .where('scheduledId', isEqualTo: doc.id)
            .limit(1)
            .get();

        if (chatQuery.docs.isNotEmpty) {
          await chatQuery.docs.first.reference.update({
            'isScheduled': false,
            'isSent': true,
            'time': Timestamp.now(),
          });
        }
      }
    }
  }
}
