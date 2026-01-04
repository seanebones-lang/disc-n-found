import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/disc_model.dart';
import '../core/constants/app_constants.dart';
import 'analytics_service.dart';
import 'notification_service.dart';

class DiscService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadDiscImage(File imageFile, String userId) async {
    try {
      final ref = _storage
          .ref()
          .child('${AppConstants.discsPath}/$userId/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> uploadDisc({
    required String userId,
    required String imageUrl,
    required String description,
    required String status,
    String? location,
  }) async {
    try {
      await _firestore.collection(AppConstants.discsCollection).add({
        'userId': userId,
        'imageUrl': imageUrl,
        'description': description,
        'status': status,
        'location': location,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      await AnalyticsService.logDiscUpload(
        status: status,
        hasLocation: location != null && location.isNotEmpty,
      );
    } catch (e) {
      throw Exception('Failed to upload disc: $e');
    }
  }

  Future<void> claimDisc(String discId, String claimerId) async {
    try {
      // Get disc data to find uploader
      final discDoc = await _firestore
          .collection(AppConstants.discsCollection)
          .doc(discId)
          .get();
      
      if (!discDoc.exists) throw Exception('Disc not found');
      
      final discData = discDoc.data()!;
      final uploaderId = discData['userId'] as String;
      final discStatus = discData['status'] as String;
      
      // Update disc status
      await _firestore.collection(AppConstants.discsCollection).doc(discId).update({
        'claimedBy': claimerId,
        'status': AppConstants.statusClaimed,
      });
      
      // Log analytics
      await AnalyticsService.logDiscClaim(
        discId: discId,
        discStatus: discStatus,
      );
      
      // Send notification to uploader
      final notificationService = NotificationService();
      final claimerDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(claimerId)
          .get();
      final claimerName = claimerDoc.data()?['displayName'] ?? 'Someone';
      
      await notificationService.sendClaimNotification(
        recipientUserId: uploaderId,
        discId: discId,
        claimerName: claimerName,
      );
    } catch (e) {
      throw Exception('Failed to claim disc: $e');
    }
  }
  
  // Paginated feed with limit
  Stream<List<DiscModel>> getDiscsFeed({int limit = 20, DocumentSnapshot? startAfter}) {
    Query query = _firestore
        .collection(AppConstants.discsCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => DiscModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
  
  // Get next page for pagination
  Future<List<DiscModel>> getDiscsFeedPage({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _firestore
        .collection(AppConstants.discsCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => DiscModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
