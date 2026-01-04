import 'package:flutter_test/flutter_test.dart';
import 'package:disc_n_found/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromMap creates UserModel correctly', () {
      final map = {
        'uid': 'test123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'photoUrl': 'https://example.com/photo.jpg',
        'location': 'Test Location',
        'favoriteDiscs': 'Disc1, Disc2',
        'subscriptionTier': 'premium',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final user = UserModel.fromMap(map);

      expect(user.uid, 'test123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.subscriptionTier, 'premium');
    });

    test('toMap converts UserModel to map correctly', () {
      final user = UserModel(
        uid: 'test123',
        email: 'test@example.com',
        displayName: 'Test User',
        subscriptionTier: 'basic',
        createdAt: DateTime.now(),
      );

      final map = user.toMap();

      expect(map['uid'], 'test123');
      expect(map['email'], 'test@example.com');
      expect(map['displayName'], 'Test User');
      expect(map['subscriptionTier'], 'basic');
    });
  });
}
