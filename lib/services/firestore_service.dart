import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot> getChatStream() {
    return _db.collection('chats').orderBy('time').snapshots();
  }

  static Future<void> sendMessage(String message) async {
    if (message.isEmpty) return;
    await _db.collection('chats').add({
      'message': message,
      'time': Timestamp.now(),
      'isScheduled': false,
    });
  }

  static Future<void> scheduleMessage(
    String message,
    DateTime scheduledTime,
  ) async {
    await _db.collection('scheduled_messages').add({
      'message': message,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'sent': false,
    });
  }

  static Future<void> checkScheduledMessages() async {
    final now = DateTime.now();
    final snapshot = await _db
        .collection('scheduled_messages')
        .where('sent', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      final time = (doc['scheduledTime'] as Timestamp).toDate();
      if (!time.isAfter(now)) {
        await _db.collection('chats').add({
          'message': doc['message'],
          'time': Timestamp.now(),
          'isScheduled': true,
        });
        await doc.reference.update({'sent': true});
      }
    }
  }
}
