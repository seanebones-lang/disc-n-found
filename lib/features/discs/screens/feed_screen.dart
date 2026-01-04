import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/disc_model.dart';
import '../../../services/disc_service.dart';
import '../../../services/messaging_service.dart';
import '../../../services/analytics_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../messaging/screens/chat_screen.dart';
import 'upload_screen.dart';

final discServiceProvider = Provider<DiscService>((ref) => DiscService());
final messagingServiceProvider = Provider<MessagingService>((ref) => MessagingService());

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<DiscModel> _discs = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadInitialDiscs();
    _scrollController.addListener(_onScroll);
    AnalyticsService.logScreenView('feed');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreDiscs();
    }
  }

  Future<void> _loadInitialDiscs() async {
    try {
      final discService = ref.read(discServiceProvider);
      final discs = await discService.getDiscsFeedPage(limit: _pageSize);
      
      if (mounted) {
        // Get last document for pagination
        DocumentSnapshot? lastDoc;
        if (discs.isNotEmpty) {
          final snapshot = await FirebaseFirestore.instance
              .collection(AppConstants.discsCollection)
              .orderBy('timestamp', descending: true)
              .limit(_pageSize)
              .get();
          if (snapshot.docs.isNotEmpty) {
            lastDoc = snapshot.docs.last;
          }
        }
        
        setState(() {
          _discs.clear();
          _discs.addAll(discs);
          _lastDocument = lastDoc;
          _hasMore = discs.length == _pageSize;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading discs: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreDiscs() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final discService = ref.read(discServiceProvider);
      final discs = await discService.getDiscsFeedPage(
        limit: _pageSize,
        startAfter: _lastDocument,
      );

      if (mounted) {
        // Get last document for next page
        DocumentSnapshot? lastDoc = _lastDocument;
        if (discs.isNotEmpty && _lastDocument != null) {
          final snapshot = await FirebaseFirestore.instance
              .collection(AppConstants.discsCollection)
              .orderBy('timestamp', descending: true)
              .startAfterDocument(_lastDocument!)
              .limit(_pageSize)
              .get();
          if (snapshot.docs.isNotEmpty) {
            lastDoc = snapshot.docs.last;
          }
        }
        
        setState(() {
          _discs.addAll(discs);
          _lastDocument = lastDoc;
          _hasMore = discs.length == _pageSize;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _discs.isEmpty
          ? const Center(
              child: Text('No discs found. Be the first to post!'),
            )
          : RefreshIndicator(
              onRefresh: _loadInitialDiscs,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _discs.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _discs.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final disc = _discs[index];
                  return _DiscCard(
                    disc: disc,
                    currentUser: currentUser.value,
                    onTap: () {
                      AnalyticsService.logDiscView(disc.id);
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _DiscCard extends ConsumerWidget {
  final DiscModel disc;
  final dynamic currentUser;
  final VoidCallback onTap;

  const _DiscCard({
    required this.disc,
    this.currentUser,
    required this.onTap,
  });

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
      child: InkWell(
        onTap: onTap,
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
      ),
    );
  }
}
