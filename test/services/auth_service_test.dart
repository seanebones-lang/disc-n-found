import 'package:flutter_test/flutter_test.dart';
import 'package:disc_n_found/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('currentUser getter returns null initially', () {
      final service = AuthService();
      expect(service.currentUser, isNull);
    });

    test('authStateChanges returns a stream', () {
      final service = AuthService();
      expect(service.authStateChanges, isA<Stream>());
    });
  });
}
