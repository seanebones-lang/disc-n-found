import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../core/constants/app_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Note: In production, these should be stored securely (e.g., Firebase Remote Config or environment variables)
  // For now, you'll need to set your Stripe publishable key in main.dart
  static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  static const String backendUrl = 'YOUR_BACKEND_URL'; // Your Firebase Cloud Function URL

  Future<void> initializeStripe() async {
    Stripe.publishableKey = stripePublishableKey;
    await Stripe.instance.applySettings();
  }

  Future<Map<String, dynamic>> createPaymentIntent({
    required String tier,
    required String userId,
  }) async {
    try {
      final amount = tier == 'basic' 
          ? (AppConstants.basicPrice * 100).toInt() // Convert to cents
          : (AppConstants.premiumPrice * 100).toInt();

      final response = await http.post(
        Uri.parse('$backendUrl/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': 'usd',
          'userId': userId,
          'tier': tier,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  Future<void> confirmPayment({
    required String clientSecret,
    required String tier,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Disc \'n\' Found',
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment succeeded - update user subscription in Firestore
      // Note: In production, this should be handled by webhook for security
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
        'subscriptionTier': tier,
        'subscriptionStartDate': FieldValue.serverTimestamp(),
        'subscriptionStatus': 'active',
      });
    } catch (e) {
      if (e is StripeException) {
        throw Exception('Payment failed: ${e.error.message}');
      }
      throw Exception('Payment confirmation failed: $e');
    }
  }

  Future<void> cancelSubscription(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'subscriptionTier': 'free',
        'subscriptionStatus': 'cancelled',
        'subscriptionEndDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  Future<Map<String, dynamic>?> getSubscriptionStatus(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return {
          'tier': data['subscriptionTier'] ?? 'free',
          'status': data['subscriptionStatus'] ?? 'inactive',
          'startDate': data['subscriptionStartDate'],
          'endDate': data['subscriptionEndDate'],
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get subscription status: $e');
    }
  }
}
