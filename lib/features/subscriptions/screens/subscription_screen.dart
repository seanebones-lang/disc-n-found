import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/subscription_service.dart';
import '../../../services/analytics_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) => SubscriptionService());

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isProcessing = false;

  Future<void> _handleSubscribe(String tier) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      
      // Create payment intent
      final paymentIntent = await subscriptionService.createPaymentIntent(
        tier: tier,
        userId: currentUser.uid,
      );

      // Confirm payment
      await subscriptionService.confirmPayment(
        clientSecret: paymentIntent['clientSecret'] as String,
        tier: tier,
      );

      // Log analytics
      final price = tier == 'basic' 
          ? AppConstants.basicPrice 
          : AppConstants.premiumPrice;
      await AnalyticsService.logSubscriptionStart(tier: tier, price: price);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription activated successfully!')),
        );
        // Refresh user data
        ref.invalidate(currentUserProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock premium features to enhance your disc golf experience',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _SubscriptionCard(
              title: 'Basic',
              price: AppConstants.basicPrice,
              features: const [
                'Priority claims',
                'Ad-free experience',
                'Enhanced profile',
              ],
              isPremium: false,
              currentTier: currentUser?.subscriptionTier ?? 'free',
              onSubscribe: () => _handleSubscribe('basic'),
              isProcessing: _isProcessing,
            ),
            const SizedBox(height: 16),
            _SubscriptionCard(
              title: 'Premium',
              price: AppConstants.premiumPrice,
              features: const [
                'Everything in Basic',
                'Unlimited uploads',
                'Advanced search',
                'Priority support',
                'Exclusive badges',
              ],
              isPremium: true,
              currentTier: currentUser?.subscriptionTier ?? 'free',
              onSubscribe: () => _handleSubscribe('premium'),
              isProcessing: _isProcessing,
            ),
            const SizedBox(height: 32),
            if (currentUser?.subscriptionTier != 'free')
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'Current Plan: ${currentUser!.subscriptionTier.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final String title;
  final double price;
  final List<String> features;
  final bool isPremium;
  final String currentTier;
  final VoidCallback onSubscribe;
  final bool isProcessing;

  const _SubscriptionCard({
    required this.title,
    required this.price,
    required this.features,
    required this.isPremium,
    required this.currentTier,
    required this.onSubscribe,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentPlan = currentTier == title.toLowerCase();
    final isFree = currentTier == 'free';

    return Card(
      elevation: isPremium ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPremium
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('/month'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (isCurrentPlan || !isFree || isProcessing) 
                    ? null 
                    : onSubscribe,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isCurrentPlan ? 'Current Plan' : 'Subscribe',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
