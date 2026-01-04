import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // User Events
  static Future<void> logSignUp(String method) async {
    await logEvent('sign_up', {'method': method});
  }

  static Future<void> logLogin(String method) async {
    await logEvent('login', {'method': method});
  }

  static Future<void> logProfileUpdate() async {
    await logEvent('profile_update', null);
  }

  // Disc Events
  static Future<void> logDiscUpload({
    required String status,
    bool hasLocation = false,
  }) async {
    await logEvent('disc_upload', {
      'status': status,
      'has_location': hasLocation.toString(),
    } as Map<String, Object>);
  }

  static Future<void> logDiscView(String discId) async {
    await logEvent('disc_view', {'disc_id': discId});
  }

  static Future<void> logDiscClaim({
    required String discId,
    required String discStatus,
  }) async {
    await logEvent('disc_claim', {
      'disc_id': discId,
      'disc_status': discStatus,
    });
  }

  // Messaging Events
  static Future<void> logMessageSent({
    required String chatId,
    bool hasImage = false,
  }) async {
    await logEvent('message_sent', {
      'chat_id': chatId,
      'has_image': hasImage.toString(),
    } as Map<String, Object>);
  }

  static Future<void> logChatOpened(String chatId) async {
    await logEvent('chat_opened', {'chat_id': chatId});
  }

  // Subscription Events
  static Future<void> logSubscriptionStart({
    required String tier,
    required double price,
  }) async {
    await logEvent('subscription_start', {
      'tier': tier,
      'price': price.toString(),
    } as Map<String, Object>);
  }

  static Future<void> logSubscriptionCancel(String tier) async {
    await logEvent('subscription_cancel', {'tier': tier});
  }

  // Screen Views
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // User Properties
  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  static Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }
}
