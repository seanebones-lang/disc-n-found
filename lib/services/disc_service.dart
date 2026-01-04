import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/disc_model.dart';
import '../core/constants/app_constants.dart';

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
    } catch (e) {
      throw Exception('Failed to upload disc: $e');
    }
  }

  Stream<List<DiscModel>> getDiscsFeed() {
    return _firestore
        .collection(AppConstants.discsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DiscModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> claimDisc(String discId, String claimerId) async {
    try {
      await _firestore.collection(AppConstants.discsCollection).doc(discId).update({
        'claimedBy': claimerId,
        'status': AppConstants.statusClaimed,
      });
    } catch (e) {
      throw Exception('Failed to claim disc: $e');
    }
  }
}
