import 'package:flutter_test/flutter_test.dart';
import 'package:disc_n_found/models/disc_model.dart';
import 'package:disc_n_found/core/constants/app_constants.dart';

void main() {
  group('DiscModel', () {
    test('fromMap creates DiscModel correctly', () {
      final map = {
        'userId': 'user123',
        'imageUrl': 'https://example.com/image.jpg',
        'description': 'Test disc',
        'status': AppConstants.statusFound,
        'location': 'Test Location',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final disc = DiscModel.fromMap(map, 'disc123');

      expect(disc.id, 'disc123');
      expect(disc.userId, 'user123');
      expect(disc.description, 'Test disc');
      expect(disc.status, AppConstants.statusFound);
      expect(disc.isClaimed, false);
    });

    test('isClaimed returns true when claimedBy is not null', () {
      final map = {
        'userId': 'user123',
        'imageUrl': 'https://example.com/image.jpg',
        'description': 'Test disc',
        'status': AppConstants.statusClaimed,
        'claimedBy': 'claimer123',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final disc = DiscModel.fromMap(map, 'disc123');

      expect(disc.isClaimed, true);
      expect(disc.claimedBy, 'claimer123');
    });
  });
}
