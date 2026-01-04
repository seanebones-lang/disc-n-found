import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../core/constants/app_constants.dart';
import 'analytics_service.dart';
import 'notification_service.dart';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? imageUrl,
  }) async {
    try {
      final messageId = _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .collection(AppConstants.messagesCollection)
          .doc()
          .id;

      final message = MessageModel(
        id: messageId,
        chatId: chatId,
        senderId: senderId,
        text: text,
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
      );

      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .collection(AppConstants.messagesCollection)
          .doc(messageId)
          .set(message.toMap());

      // Update chat metadata
      final participants = chatId.split('_');
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .set({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'participants': participants,
      }, SetOptions(merge: true));
      
      // Log analytics
      await AnalyticsService.logMessageSent(chatId: chatId, hasImage: imageUrl != null);
      
      // Send notification to recipient
      final recipientId = participants.firstWhere((id) => id != senderId);
      final senderDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(senderId)
          .get();
      final senderName = senderDoc.data()?['displayName'] ?? 'Someone';
      
      final notificationService = NotificationService();
      await notificationService.sendMessageNotification(
        recipientUserId: recipientId,
        senderName: senderName,
        messageText: text,
        chatId: chatId,
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
