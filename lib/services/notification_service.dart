import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      String? token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveTokenToFirestore);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages (when app is in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': token});
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Handle message when app is in foreground
    // You can show an in-app notification here
    print('Foreground message: ${message.notification?.title}');
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // Handle message when app is opened from background
    print('Background message: ${message.notification?.title}');
  }

  Future<void> sendClaimNotification({
    required String recipientUserId,
    required String discId,
    required String claimerName,
  }) async {
    try {
      // Get recipient's FCM token
      final recipientDoc = await _firestore
          .collection('users')
          .doc(recipientUserId)
          .get();

      final fcmToken = recipientDoc.data()?['fcmToken'];
      if (fcmToken == null) return;

      // In production, send via Firebase Cloud Functions or your backend
      // For now, we'll store the notification in Firestore
      await _firestore.collection('notifications').add({
        'userId': recipientUserId,
        'type': 'claim',
        'title': 'Disc Claimed',
        'body': '$claimerName claimed your disc',
        'discId': discId,
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Note: Actual push notification sending should be done via Cloud Functions
      // This is a placeholder that stores the notification
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> sendMessageNotification({
    required String recipientUserId,
    required String senderName,
    required String messageText,
    required String chatId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': recipientUserId,
        'type': 'message',
        'title': 'New Message',
        'body': '$senderName: $messageText',
        'chatId': chatId,
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending message notification: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}
