# Quick Setup Guide

This is a quick reference guide for setting up Disc 'n' Found for development.

## Prerequisites

- Flutter SDK 3.10.4+
- Firebase account
- Stripe account (for payment testing)
- Android Studio / Xcode

## Quick Start

### 1. Clone and Install

```bash
git clone <repository-url>
cd disc-n-found
flutter pub get
```

### 2. Configure Firebase

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will:
- Generate `lib/core/firebase_options.dart`
- Add `google-services.json` (Android)
- Add `GoogleService-Info.plist` (iOS)

### 3. Configure Stripe (Optional for Testing)

Edit `lib/services/subscription_service.dart`:
```dart
static const String stripePublishableKey = 'pk_test_YOUR_TEST_KEY';
static const String backendUrl = 'YOUR_CLOUD_FUNCTION_URL';
```

### 4. Run the App

```bash
flutter run
```

## Firebase Setup Checklist

- [ ] Create Firebase project
- [ ] Enable Authentication (Email/Password, Google)
- [ ] Create Firestore database
- [ ] Enable Firebase Storage
- [ ] Enable Cloud Messaging
- [ ] Run `flutterfire configure`
- [ ] Deploy security rules: `firebase deploy --only firestore:rules,storage`

## Stripe Setup Checklist (For Payment Testing)

- [ ] Create Stripe account
- [ ] Get test API keys from Dashboard
- [ ] Update `subscription_service.dart` with test publishable key
- [ ] Deploy Cloud Functions (optional for local testing)
- [ ] Test payment flow with test card: `4242 4242 4242 4242`

## Google Sign-In Setup

### Android
- [ ] Enable Google Sign-In in Firebase Console
- [ ] Add SHA-1 fingerprint to Firebase project
- [ ] Download updated `google-services.json`

### iOS
- [ ] Enable Google Sign-In in Firebase Console
- [ ] Add URL scheme to `Info.plist`
- [ ] Download updated `GoogleService-Info.plist`

## Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/models/user_model_test.dart
```

## Common Issues

**Firebase not initialized**
```bash
flutterfire configure
```

**Build errors**
```bash
flutter clean
flutter pub get
```

**iOS build issues**
```bash
cd ios
pod install
cd ..
```

**Android build issues**
```bash
cd android
./gradlew clean
cd ..
```

## Next Steps

- See [README.md](README.md) for detailed documentation
- See [DEPLOYMENT.md](DEPLOYMENT.md) for production deployment
- Review `firestore.rules` and `storage.rules` for security
