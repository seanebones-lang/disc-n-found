import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/disc_model.dart';
import '../../../services/disc_service.dart';
import '../../../services/messaging_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../messaging/screens/chat_screen.dart';
import 'upload_screen.dart';

final discServiceProvider = Provider<DiscService>((ref) => DiscService());
final messagingServiceProvider = Provider<MessagingService>((ref) => MessagingService());

final discsFeedProvider = StreamProvider<List<DiscModel>>((ref) {
  final discService = ref.watch(discServiceProvider);
  return discService.getDiscsFeed();
});

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discsAsync = ref.watch(discsFeedProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disc Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadScreen()),
              );
            },
          ),
        ],
      ),
      body: discsAsync.when(
        data: (discs) {
          if (discs.isEmpty) {
            return const Center(
              child: Text('No discs found. Be the first to post!'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: discs.length,
            itemBuilder: (context, index) {
              final disc = discs[index];
              return _DiscCard(disc: disc, currentUser: currentUser.value);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _DiscCard extends ConsumerWidget {
  final DiscModel disc;
  final dynamic currentUser;

  const _DiscCard({required this.disc, this.currentUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discService = ref.read(discServiceProvider);
    final messagingService = ref.read(messagingServiceProvider);
    final canClaim = !disc.isClaimed && currentUser != null;
    final canMessage = disc.isClaimed && 
        currentUser != null && 
        (disc.claimedBy == currentUser.uid || disc.userId == currentUser.uid);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: disc.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(
                        disc.status.toUpperCase(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: disc.status == AppConstants.statusLost
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                    ),
                    if (disc.isClaimed)
                      const Chip(
                        label: Text('CLAIMED', style: TextStyle(fontSize: 12)),
                        backgroundColor: Colors.grey,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  disc.description,
                  style: const TextStyle(fontSize: 16),
                ),
                if (disc.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        disc.location!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                if (canClaim)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await discService.claimDisc(
                            disc.id,
                            currentUser.uid,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Disc claimed successfully!'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Claim This Disc'),
                    ),
                  ),
                if (canMessage)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final otherUserId = disc.claimedBy == currentUser.uid
                            ? disc.userId
                            : disc.claimedBy!;
                        final chatId = messagingService.getChatId(
                          currentUser.uid,
                          otherUserId,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatId: chatId,
                              otherUserId: otherUserId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('Message'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
