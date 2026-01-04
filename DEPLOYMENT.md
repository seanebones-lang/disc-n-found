# Deployment Guide

This guide covers deploying Disc 'n' Found to production with all features enabled.

## Prerequisites

1. Firebase project created and configured
2. Stripe account set up (with API keys)
3. Google Play Console account (Android)
4. Apple Developer account (iOS)
5. Flutter SDK installed (3.10.4+)
6. Node.js installed (for Cloud Functions)

## Firebase Setup

### 1. Deploy Security Rules

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage
```

**Important**: Review `firestore.rules` and `storage.rules` files before deploying to ensure they match your security requirements.

### 2. Deploy Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

**Functions Deployed**:
- `createPaymentIntent` - Creates Stripe payment intents
- `stripeWebhook` - Handles Stripe webhook events
- `onDiscClaimed` - Sends notifications when discs are claimed
- `onMessageSent` - Sends notifications when messages are sent

### 3. Configure Environment Variables

```bash
# Set Stripe keys (use test keys for development)
firebase functions:config:set stripe.secret_key="sk_test_..."  # or sk_live_... for production
firebase functions:config:set stripe.webhook_secret="whsec_..."

# Deploy again to apply config
firebase deploy --only functions
```

### 4. Enable Required Firebase Services

1. **Authentication**:
   - Enable Email/Password provider
   - Enable Google Sign-In provider
   - Configure OAuth consent screen (for Google Sign-In)

2. **Cloud Firestore**:
   - Create database (start in test mode, then switch to production)
   - Deploy security rules

3. **Firebase Storage**:
   - Create default bucket
   - Deploy security rules

4. **Cloud Messaging**:
   - Enable Cloud Messaging API
   - Configure APNs (iOS): Upload APNs certificate/key
   - Configure FCM (Android): Automatically configured

5. **Analytics**:
   - Automatically enabled
   - No additional configuration needed

## Stripe Configuration

### 1. Get API Keys

1. Go to [Stripe Dashboard](https://dashboard.stripe.com)
2. Navigate to Developers > API keys
3. Copy your **Publishable key** (starts with `pk_`)
4. Copy your **Secret key** (starts with `sk_`)

### 2. Update App Code

Edit `lib/services/subscription_service.dart`:

```dart
static const String stripePublishableKey = 'pk_live_YOUR_KEY_HERE';  // Use pk_test_... for testing
static const String backendUrl = 'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net';
```

Replace:
- `YOUR_KEY_HERE` with your Stripe publishable key
- `YOUR_REGION` with your Firebase region (e.g., `us-central1`)
- `YOUR_PROJECT` with your Firebase project ID

### 3. Set up Webhook

1. In Stripe Dashboard, go to Developers > Webhooks
2. Click "Add endpoint"
3. Enter endpoint URL:
   ```
   https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/stripeWebhook
   ```
4. Select events to listen to:
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
5. Copy the webhook signing secret (starts with `whsec_`)
6. Add to Firebase Functions config:
   ```bash
   firebase functions:config:set stripe.webhook_secret="whsec_..."
   firebase deploy --only functions
   ```

### 4. Test Payment Flow

1. Use Stripe test cards:
   - Success: `4242 4242 4242 4242`
   - Decline: `4000 0000 0000 0002`
2. Test in app with test publishable key (`pk_test_...`)
3. Verify webhook receives events in Stripe Dashboard

## Google Sign-In Configuration

### Android

1. In Firebase Console, go to Authentication > Sign-in method > Google
2. Enable Google Sign-In
3. Download `google-services.json` and place in `android/app/`
4. Get SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
5. Add SHA-1 to Firebase Console > Project Settings > Your apps > Android app

### iOS

1. In Firebase Console, enable Google Sign-In
2. Download `GoogleService-Info.plist` and add to Xcode project
3. In Xcode, add URL scheme:
   - Open `ios/Runner/Info.plist`
   - Add `REVERSED_CLIENT_ID` from `GoogleService-Info.plist` as URL scheme

## Android Deployment

### 1. Configure App

```bash
# Update app version in pubspec.yaml
version: 1.0.0+1  # Format: major.minor.patch+build
```

Update `android/app/build.gradle.kts` if needed:
- `applicationId`: Your package name
- `minSdkVersion`: Minimum Android version (recommended: 21+)

### 2. Generate Signing Key

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Important**: Store the keystore file and passwords securely!

### 3. Configure Signing

Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

**Important**: Add `key.properties` to `.gitignore` - never commit this file!

### 4. Update build.gradle.kts

Ensure signing config is set up in `android/app/build.gradle.kts`:

```kotlin
android {
    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            val keystoreProperties = Properties()
            keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### 5. Build Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### 6. Build App Bundle (Recommended for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 7. Upload to Google Play

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app or select existing
3. Go to Production > Create new release
4. Upload the `.aab` file
5. Fill in release notes
6. Review and roll out

**Store Listing Requirements**:
- App icon (512x512)
- Feature graphic (1024x500)
- Screenshots (at least 2)
- Privacy policy URL
- Content rating questionnaire

## iOS Deployment

### 1. Configure App in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project in navigator
3. Update bundle identifier (e.g., `com.yourcompany.discnfound`)
4. Update version and build number
5. Configure signing:
   - Select your team
   - Enable "Automatically manage signing"
   - Or manually configure provisioning profiles

### 2. Configure Capabilities

In Xcode, add capabilities:
- Push Notifications
- Background Modes (Remote notifications)

### 3. Update Info.plist

Ensure required permissions are in `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take photos of discs</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select disc images</string>
```

### 4. Build for Release

```bash
flutter build ios --release
```

### 5. Archive in Xcode

1. Open Xcode
2. Select "Any iOS Device" as target
3. Product > Archive
4. Wait for archive to complete
5. Click "Distribute App"
6. Choose distribution method:
   - App Store Connect (for App Store)
   - Ad Hoc (for testing)
   - Enterprise (for enterprise distribution)
7. Follow prompts to upload

### 6. Submit to App Store

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app or select existing
3. Upload build (or wait for processing)
4. Fill in app information:
   - App name, subtitle, description
   - Keywords
   - Screenshots (required for all device sizes)
   - App icon (1024x1024)
   - Privacy policy URL
5. Submit for review

## Environment Configuration

### Development

- Use Firebase test mode
- Use Stripe test keys (`pk_test_...`, `sk_test_...`)
- Enable debug logging
- Use test devices for push notifications

### Production

- Use Firebase production mode
- Use Stripe live keys (`pk_live_...`, `sk_live_...`)
- Disable debug logging
- Enable Crashlytics
- Configure analytics
- Test on production Firebase project

## Post-Deployment Checklist

### Firebase
- [ ] Firestore rules deployed and tested
- [ ] Storage rules deployed and tested
- [ ] Cloud Functions deployed
- [ ] Stripe webhook configured and tested
- [ ] Push notifications tested (Android & iOS)
- [ ] Analytics events verified in Firebase Console

### Stripe
- [ ] Publishable key updated in app code
- [ ] Secret key configured in Cloud Functions
- [ ] Webhook endpoint configured
- [ ] Test payment flow successful
- [ ] Webhook events received and processed

### App Configuration
- [ ] App icons set (all required sizes)
- [ ] Splash screens configured
- [ ] Privacy policy URL added
- [ ] Terms of service URL added
- [ ] App version updated
- [ ] Build number incremented

### Testing
- [ ] Authentication flow tested (email, Google)
- [ ] Disc upload tested
- [ ] Feed pagination tested
- [ ] Claiming mechanism tested
- [ ] Messaging tested
- [ ] Payment flow tested (test mode)
- [ ] Push notifications tested
- [ ] Analytics events verified

### App Stores
- [ ] Google Play listing complete
- [ ] App Store listing complete
- [ ] Screenshots uploaded
- [ ] Store descriptions written
- [ ] Privacy policy published
- [ ] App submitted for review

## Monitoring

### Firebase Console
- Monitor Firestore usage and costs
- Check Storage usage
- Review Cloud Functions logs
- Monitor Analytics events
- Check Crashlytics reports

### Stripe Dashboard
- Monitor payment intents
- Review webhook events
- Check payment success/failure rates
- Monitor subscription status

### App Store Analytics
- **Google Play Console**: Monitor installs, crashes, ANRs, ratings
- **App Store Connect**: Monitor downloads, crashes, ratings, reviews

## Troubleshooting

### Payment Issues
- **Payment fails**: Check Stripe publishable key and Cloud Function URL
- **Webhook not receiving events**: Verify webhook URL and secret in Stripe Dashboard
- **Subscription not updating**: Check Cloud Functions logs for errors

### Push Notification Issues
- **Android**: Verify FCM token registration, check Firebase Console
- **iOS**: Verify APNs certificate, check device token registration
- **Not receiving notifications**: Check notification permissions, verify FCM token

### Build Issues
- **Android signing errors**: Verify `key.properties` file and keystore path
- **iOS code signing errors**: Check team selection and provisioning profiles
- **Dependency errors**: Run `flutter clean` then `flutter pub get`

## Updates

To update the app:

1. **Update version** in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # Increment version and build number
   ```

2. **Make code changes** and test thoroughly

3. **Update changelog** in app stores

4. **Build release**:
   ```bash
   flutter build appbundle --release  # Android
   flutter build ios --release        # iOS
   ```

5. **Upload to app stores**

6. **Submit for review**

## Security Best Practices

1. **Never commit**:
   - API keys
   - Keystore files
   - `key.properties`
   - `.env` files with secrets

2. **Use environment variables** for sensitive data in Cloud Functions

3. **Review security rules** regularly

4. **Keep dependencies updated**:
   ```bash
   flutter pub outdated
   flutter pub upgrade
   ```

5. **Monitor for security vulnerabilities**

## Support

For deployment issues:
- Check Firebase Console logs
- Review Cloud Functions logs
- Check Stripe Dashboard webhook logs
- Review app store review guidelines

**Last Updated**: January 2026
