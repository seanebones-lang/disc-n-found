# Deployment Guide

This guide covers deploying Disc 'n' Found to production.

## Prerequisites

1. Firebase project created and configured
2. Stripe account set up
3. Google Play Console account (Android)
4. Apple Developer account (iOS)
5. Flutter SDK installed

## Firebase Setup

### 1. Deploy Security Rules

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage
```

### 2. Deploy Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

### 3. Configure Environment Variables

```bash
# Set Stripe keys
firebase functions:config:set stripe.secret_key="sk_live_..."
firebase functions:config:set stripe.webhook_secret="whsec_..."

# Deploy again to apply config
firebase deploy --only functions
```

## Stripe Configuration

1. **Get API Keys**
   - Publishable key: Add to `lib/services/subscription_service.dart`
   - Secret key: Add to Firebase Functions config
   - Webhook secret: Add to Firebase Functions config

2. **Set up Webhook**
   - In Stripe Dashboard, create webhook endpoint:
     - URL: `https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/stripeWebhook`
     - Events: `payment_intent.succeeded`, `payment_intent.payment_failed`

3. **Update Subscription Service**
   - Replace `YOUR_STRIPE_PUBLISHABLE_KEY` in `subscription_service.dart`
   - Replace `YOUR_BACKEND_URL` with your Cloud Function URL

## Android Deployment

### 1. Configure App

```bash
# Update app version in pubspec.yaml
# Update package name if needed in android/app/build.gradle.kts
```

### 2. Generate Signing Key

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 3. Configure Signing

Create `android/key.properties`:
```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

### 4. Build Release APK

```bash
flutter build apk --release
```

### 5. Build App Bundle (Recommended)

```bash
flutter build appbundle --release
```

### 6. Upload to Google Play

1. Go to Google Play Console
2. Create new app or select existing
3. Upload the `.aab` file
4. Fill in store listing
5. Submit for review

## iOS Deployment

### 1. Configure App

1. Open `ios/Runner.xcworkspace` in Xcode
2. Update bundle identifier
3. Configure signing & capabilities
4. Update version and build number

### 2. Build for Release

```bash
flutter build ios --release
```

### 3. Archive in Xcode

1. Open Xcode
2. Select "Any iOS Device"
3. Product > Archive
4. Distribute App
5. Upload to App Store Connect

### 4. Submit to App Store

1. Go to App Store Connect
2. Create new app or select existing
3. Upload build
4. Fill in app information
5. Submit for review

## Environment Configuration

### Development

- Use Firebase test mode
- Use Stripe test keys
- Enable debug logging

### Production

- Use Firebase production mode
- Use Stripe live keys
- Disable debug logging
- Enable Crashlytics
- Configure analytics

## Post-Deployment Checklist

- [ ] Firebase rules deployed
- [ ] Cloud Functions deployed
- [ ] Stripe webhook configured
- [ ] App icons and splash screens set
- [ ] Privacy policy and terms of service added
- [ ] Analytics configured
- [ ] Crashlytics enabled
- [ ] Push notifications tested
- [ ] Payment flow tested
- [ ] App store listings complete

## Monitoring

- Firebase Console: Monitor usage, errors, performance
- Stripe Dashboard: Monitor payments, subscriptions
- Google Play Console: Monitor app performance, crashes
- App Store Connect: Monitor app performance, crashes

## Updates

To update the app:

1. Update version in `pubspec.yaml`
2. Make code changes
3. Test thoroughly
4. Build release
5. Upload to app stores
6. Submit for review
