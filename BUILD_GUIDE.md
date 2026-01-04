# Disc 'n' Found - Complete Build Guide

**Copyright © 2026 Corby Bibb. All Rights Reserved.**

This comprehensive guide will walk you through building, configuring, and deploying the Disc 'n' Found mobile application from scratch.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Firebase Configuration](#firebase-configuration)
4. [Stripe Configuration](#stripe-configuration)
5. [Google Sign-In Setup](#google-sign-in-setup)
6. [Building for Android](#building-for-android)
7. [Building for iOS](#building-for-ios)
8. [Testing the Application](#testing-the-application)
9. [Deployment](#deployment)
10. [Troubleshooting](#troubleshooting)
11. [Frequently Asked Questions (FAQ)](#frequently-asked-questions-faq)

---

## Prerequisites

### Required Software

1. **Flutter SDK 3.10.4 or higher**
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`
   - Ensure all checks pass

2. **Development Environment**
   - **For Android**: Android Studio with Android SDK
   - **For iOS**: Xcode 14+ (macOS only)
   - **Code Editor**: VS Code or Android Studio with Flutter extensions

3. **Accounts Required**
   - Firebase account (free tier available)
   - Stripe account (for payment processing)
   - Google Play Console account (for Android deployment)
   - Apple Developer account (for iOS deployment - $99/year)

4. **Command Line Tools**
   - Git
   - Node.js 18+ (for Cloud Functions)
   - Firebase CLI

### System Requirements

- **macOS**: 10.14+ (for iOS development)
- **Windows**: Windows 10+ (Android only)
- **Linux**: Ubuntu 18.04+ (Android only)
- **RAM**: 8GB minimum, 16GB recommended
- **Disk Space**: 10GB+ free space

---

## Initial Setup

### Step 1: Clone or Download the Project

```bash
# If using Git
git clone <repository-url>
cd disc-n-found

# Or download and extract the ZIP file
```

### Step 2: Install Flutter Dependencies

```bash
# Navigate to project directory
cd disc-n-found

# Install Flutter packages
flutter pub get

# Verify installation
flutter doctor
```

**Expected Output**: All checks should pass (or show warnings you can address later).

### Step 3: Verify Project Structure

Ensure you have the following key files:
- `pubspec.yaml` - Dependencies configuration
- `lib/main.dart` - Application entry point
- `android/` - Android platform files
- `ios/` - iOS platform files (if on macOS)
- `firestore.rules` - Database security rules
- `storage.rules` - Storage security rules
- `functions/index.js` - Cloud Functions code

### Step 4: Install Additional Tools

```bash
# Install FlutterFire CLI (for Firebase configuration)
dart pub global activate flutterfire_cli

# Install Firebase CLI (for deploying functions and rules)
npm install -g firebase-tools

# Login to Firebase
firebase login
```

---

## Firebase Configuration

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `disc-n-found` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Select or create Analytics account
6. Click "Create project"
7. Wait for project creation to complete

### Step 2: Configure FlutterFire

```bash
# From project root directory
flutterfire configure
```

**Interactive Setup**:
1. Select your Firebase project from the list
2. Select platforms: `android`, `ios` (if on macOS), `web` (optional)
3. Wait for configuration to complete

**What This Does**:
- Generates `lib/core/firebase_options.dart` with your project credentials
- Adds `google-services.json` to `android/app/`
- Adds `GoogleService-Info.plist` to `ios/Runner/`
- Configures platform-specific Firebase settings

### Step 3: Enable Firebase Services

#### 3.1 Authentication

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Email/Password**:
   - Click "Email/Password"
   - Toggle "Enable"
   - Click "Save"
3. Enable **Google Sign-In**:
   - Click "Google"
   - Toggle "Enable"
   - Enter support email
   - Click "Save"

#### 3.2 Cloud Firestore

1. Go to **Firestore Database** in Firebase Console
2. Click "Create database"
3. Choose **Production mode** (or Test mode for development)
4. Select location (choose closest to your users)
5. Click "Enable"
6. **Important**: Deploy security rules (see Step 3.5)

#### 3.3 Firebase Storage

1. Go to **Storage** in Firebase Console
2. Click "Get started"
3. Start in **Production mode**
4. Use default bucket location
5. Click "Next" > "Done"
6. **Important**: Deploy security rules (see Step 3.5)

#### 3.4 Cloud Messaging

1. Go to **Cloud Messaging** in Firebase Console
2. Cloud Messaging is automatically enabled
3. **For iOS**: Configure APNs (see iOS-specific section below)

#### 3.5 Deploy Security Rules

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage
```

**Verify**: Check Firebase Console to ensure rules are deployed.

### Step 4: Configure Cloud Functions

```bash
# Navigate to functions directory
cd functions

# Install dependencies
npm install

# Return to project root
cd ..
```

**Configure Stripe Keys** (see Stripe Configuration section first):

```bash
# Set Stripe secret key
firebase functions:config:set stripe.secret_key="sk_test_YOUR_KEY"

# Set Stripe webhook secret
firebase functions:config:set stripe.webhook_secret="whsec_YOUR_SECRET"

# Deploy functions
firebase deploy --only functions
```

**Verify Functions**:
- Go to Firebase Console > Functions
- You should see: `createPaymentIntent`, `stripeWebhook`, `onDiscClaimed`, `onMessageSent`

---

## Stripe Configuration

### Step 1: Create Stripe Account

1. Go to [Stripe.com](https://stripe.com)
2. Sign up for an account
3. Complete account verification
4. Access the Dashboard

### Step 2: Get API Keys

1. In Stripe Dashboard, go to **Developers** > **API keys**
2. **For Testing**: Use "Test mode" keys (toggle in top right)
   - Publishable key: Starts with `pk_test_...`
   - Secret key: Starts with `sk_test_...`
3. **For Production**: Use "Live mode" keys
   - Publishable key: Starts with `pk_live_...`
   - Secret key: Starts with `sk_live_...`

### Step 3: Update App Code

Edit `lib/services/subscription_service.dart`:

```dart
// Replace these constants with your actual keys
static const String stripePublishableKey = 'pk_test_YOUR_PUBLISHABLE_KEY';
static const String backendUrl = 'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net';
```

**To Find Your Region and Project**:
- Region: Check Firebase Console > Functions (e.g., `us-central1`)
- Project ID: Check Firebase Console > Project Settings > General

**Example**:
```dart
static const String stripePublishableKey = 'pk_test_51AbC123...';
static const String backendUrl = 'https://us-central1-disc-n-found.cloudfunctions.net';
```

### Step 4: Configure Cloud Functions

```bash
# Set Stripe secret key in Firebase Functions
firebase functions:config:set stripe.secret_key="sk_test_YOUR_SECRET_KEY"

# Set webhook secret (get this after setting up webhook)
firebase functions:config:set stripe.webhook_secret="whsec_YOUR_WEBHOOK_SECRET"

# Deploy functions
firebase deploy --only functions
```

### Step 5: Set Up Webhook

1. In Stripe Dashboard, go to **Developers** > **Webhooks**
2. Click "Add endpoint"
3. Enter endpoint URL:
   ```
   https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/stripeWebhook
   ```
4. Select events to listen to:
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
5. Click "Add endpoint"
6. Copy the **Signing secret** (starts with `whsec_`)
7. Add to Firebase Functions config (see Step 4)

### Step 6: Test Payment Flow

**Test Cards** (Stripe Test Mode):
- Success: `4242 4242 4242 4242`
- Decline: `4000 0000 0000 0002`
- Use any future expiry date, any CVC, any ZIP

**Test Steps**:
1. Run the app
2. Navigate to Subscriptions screen
3. Click "Subscribe" on a plan
4. Use test card `4242 4242 4242 4242`
5. Verify payment succeeds
6. Check Stripe Dashboard > Payments to see test payment

---

## Google Sign-In Setup

### Android Configuration

#### Step 1: Get SHA-1 Fingerprint

```bash
# For debug keystore (development)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release keystore (production)
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-alias
```

Copy the **SHA-1** fingerprint (looks like: `AA:BB:CC:DD:...`)

#### Step 2: Add SHA-1 to Firebase

1. Go to Firebase Console > Project Settings
2. Scroll to "Your apps" section
3. Click on your Android app
4. Click "Add fingerprint"
5. Paste SHA-1 fingerprint
6. Click "Save"

#### Step 3: Download Updated google-services.json

1. In Firebase Console > Project Settings
2. Download `google-services.json`
3. Replace `android/app/google-services.json` with the new file

### iOS Configuration

#### Step 1: Configure URL Scheme

1. Open `ios/Runner/Info.plist` in a text editor
2. Find the `REVERSED_CLIENT_ID` in `GoogleService-Info.plist`
3. Add URL scheme to `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

#### Step 2: Verify GoogleService-Info.plist

1. Ensure `ios/Runner/GoogleService-Info.plist` exists
2. Verify it contains your project configuration
3. If missing, download from Firebase Console and add to Xcode project

---

## Building for Android

### Step 1: Configure Android App

#### 1.1 Update Package Name (Optional)

Edit `android/app/build.gradle.kts`:
```kotlin
android {
    namespace = "com.yourcompany.discnfound"  // Change to your package name
    // ...
}
```

#### 1.2 Configure Signing

Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/absolute/path/to/your/keystore.jks
```

**Generate Keystore** (if you don't have one):
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### 1.3 Update build.gradle.kts

Ensure signing config is in `android/app/build.gradle.kts`:
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

### Step 2: Build APK (for Testing)

```bash
flutter build apk --release
```

**Output**: `build/app/outputs/flutter-apk/app-release.apk`

### Step 3: Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

**Output**: `build/app/outputs/bundle/release/app-release.aab`

### Step 4: Test the Build

```bash
# Install on connected device
flutter install

# Or install APK manually
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Building for iOS

### Step 1: Configure Xcode Project

#### 1.1 Open Project in Xcode

```bash
open ios/Runner.xcworkspace
```

**Important**: Open `.xcworkspace`, not `.xcodeproj`

#### 1.2 Configure Signing

1. Select **Runner** project in navigator
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Select your **Team**
5. Enable **Automatically manage signing**
6. Xcode will generate provisioning profiles automatically

#### 1.3 Update Bundle Identifier

1. In Xcode, select **Runner** target
2. Go to **General** tab
3. Update **Bundle Identifier**: `com.yourcompany.discnfound`

#### 1.4 Configure Capabilities

1. Go to **Signing & Capabilities** tab
2. Click **+ Capability**
3. Add **Push Notifications**
4. Add **Background Modes** > Enable **Remote notifications**

### Step 2: Configure Info.plist

Ensure permissions are in `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take photos of discs</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select disc images</string>
```

### Step 3: Install Pods

```bash
cd ios
pod install
cd ..
```

### Step 4: Build for Device

```bash
flutter build ios --release
```

### Step 5: Archive in Xcode

1. Open Xcode
2. Select **Any iOS Device** as target
3. **Product** > **Archive**
4. Wait for archive to complete
5. Click **Distribute App**
6. Choose **App Store Connect**
7. Follow prompts to upload

---

## Testing the Application

### Step 1: Run on Emulator/Simulator

#### Android Emulator

```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>

# Run app
flutter run
```

#### iOS Simulator

```bash
# List available simulators
xcrun simctl list devices

# Run app (will launch simulator automatically)
flutter run
```

### Step 2: Run on Physical Device

#### Android

1. Enable **Developer options** on device
2. Enable **USB debugging**
3. Connect device via USB
4. Run: `flutter run`

#### iOS

1. Connect iPhone/iPad via USB
2. Trust computer on device
3. In Xcode, select your device
4. Run: `flutter run`

### Step 3: Test Core Features

**Authentication**:
- [ ] Email/password sign up
- [ ] Email/password login
- [ ] Google Sign-In (Android & iOS)
- [ ] Sign out

**Disc Management**:
- [ ] Upload disc with photo
- [ ] View feed
- [ ] Claim disc
- [ ] View claimed disc

**Messaging**:
- [ ] Send message
- [ ] Receive message
- [ ] View message history

**Subscriptions**:
- [ ] View subscription plans
- [ ] Test payment flow (use test card)
- [ ] Verify subscription status update

**Notifications**:
- [ ] Receive notification on disc claim
- [ ] Receive notification on new message

### Step 4: Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## Deployment

### Android - Google Play Store

#### Step 1: Create App Listing

1. Go to [Google Play Console](https://play.google.com/console)
2. Click **Create app**
3. Fill in:
   - App name: Disc 'n' Found
   - Default language: English
   - App or game: App
   - Free or paid: Free (with in-app purchases)
4. Click **Create**

#### Step 2: Complete Store Listing

1. **App details**:
   - Short description (80 chars)
   - Full description (4000 chars)
   - App icon (512x512 PNG)
   - Feature graphic (1024x500)

2. **Graphics**:
   - Screenshots (at least 2)
   - Phone screenshots (required)
   - Tablet screenshots (optional)

3. **Categorization**:
   - App category: Sports
   - Tags: disc golf, community, lost and found

4. **Privacy Policy**:
   - Upload privacy policy URL
   - Required for apps with user data

#### Step 3: Upload App Bundle

1. Go to **Production** > **Create new release**
2. Upload `app-release.aab`
3. Add release notes
4. Review and roll out

#### Step 4: Complete Content Rating

1. Complete content rating questionnaire
2. Answer questions about app content
3. Submit for rating

### iOS - App Store

#### Step 1: Create App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** > **+**
3. Select **New App**
4. Fill in:
   - Platform: iOS
   - Name: Disc 'n' Found
   - Primary language: English
   - Bundle ID: Select from dropdown
   - SKU: Unique identifier
5. Click **Create**

#### Step 2: Complete App Information

1. **App Information**:
   - Category: Sports
   - Subtitle
   - Privacy Policy URL

2. **Pricing and Availability**:
   - Price: Free
   - Availability: All countries

3. **App Privacy**:
   - Complete privacy questionnaire
   - Describe data collection

#### Step 3: Upload Build

1. Archive and upload from Xcode (see Building for iOS)
2. Wait for processing (can take 30-60 minutes)
3. Build will appear in **TestFlight** and **App Store** tabs

#### Step 4: Complete Store Listing

1. **App Store** tab > **1.0 Prepare for Submission**
2. Add:
   - Screenshots (all required sizes)
   - App preview (optional)
   - Description
   - Keywords
   - Support URL
   - Marketing URL (optional)

#### Step 5: Submit for Review

1. Complete all required information
2. Answer export compliance questions
3. Click **Submit for Review**

---

## Troubleshooting

### Common Build Issues

#### Issue: "Firebase not initialized"

**Symptoms**: App crashes on startup with Firebase error

**Solutions**:
1. Run `flutterfire configure` again
2. Verify `lib/core/firebase_options.dart` has real values (not placeholders)
3. Check `google-services.json` exists in `android/app/`
4. Check `GoogleService-Info.plist` exists in `ios/Runner/`
5. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

#### Issue: "Package not found" or Dependency Errors

**Symptoms**: Build fails with package errors

**Solutions**:
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# For iOS, update pods
cd ios
pod deintegrate
pod install
cd ..
```

#### Issue: Android Build Fails - Signing Error

**Symptoms**: "Keystore file not found" or signing errors

**Solutions**:
1. Verify `android/key.properties` exists and has correct paths
2. Use absolute paths in `key.properties`
3. Verify keystore file exists at specified path
4. Check passwords are correct

#### Issue: iOS Build Fails - Code Signing

**Symptoms**: "No signing certificate" or provisioning profile errors

**Solutions**:
1. Open project in Xcode
2. Select correct Team in Signing & Capabilities
3. Enable "Automatically manage signing"
4. Clean build folder: **Product** > **Clean Build Folder**
5. Try archiving again

#### Issue: Google Sign-In Not Working

**Symptoms**: Google Sign-In button doesn't work or shows error

**Solutions**:
1. **Android**:
   - Verify SHA-1 fingerprint is added to Firebase
   - Download new `google-services.json`
   - Rebuild app

2. **iOS**:
   - Verify URL scheme in `Info.plist`
   - Check `REVERSED_CLIENT_ID` matches `GoogleService-Info.plist`
   - Ensure `GoogleService-Info.plist` is in Xcode project

#### Issue: Stripe Payment Fails

**Symptoms**: Payment doesn't process or shows error

**Solutions**:
1. Verify publishable key in `subscription_service.dart`
2. Check backend URL is correct (Cloud Function URL)
3. Verify Cloud Functions are deployed
4. Check Stripe Dashboard for error logs
5. Test with Stripe test card: `4242 4242 4242 4242`

#### Issue: Push Notifications Not Working

**Symptoms**: Not receiving notifications

**Solutions**:
1. **Android**:
   - Verify FCM token is registered (check Firebase Console)
   - Check device has Google Play Services
   - Verify notification permissions are granted

2. **iOS**:
   - Verify APNs certificate is uploaded to Firebase
   - Check notification permissions are granted
   - Verify device token is registered

3. **Both**:
   - Check Cloud Functions are deployed
   - Verify notification triggers in Cloud Functions logs

#### Issue: Images Not Uploading

**Symptoms**: Image upload fails or hangs

**Solutions**:
1. Check Firebase Storage rules are deployed
2. Verify user is authenticated
3. Check internet connection
4. Verify Storage bucket exists in Firebase Console
5. Check file size (should be under 10MB)

#### Issue: Feed Not Loading

**Symptoms**: Feed screen is empty or shows error

**Solutions**:
1. Check Firestore rules are deployed
2. Verify database has data
3. Check internet connection
4. Verify user is authenticated
5. Check Firestore indexes (may need to create index for timestamp)

### Performance Issues

#### Issue: App is Slow

**Solutions**:
1. Enable release mode: `flutter run --release`
2. Check image sizes (should be compressed)
3. Verify pagination is working (should load 20 items at a time)
4. Check for memory leaks in Flutter DevTools

#### Issue: Large App Size

**Solutions**:
1. Use App Bundle for Android (smaller than APK)
2. Enable code shrinking in `build.gradle.kts`
3. Remove unused assets
4. Use ProGuard/R8 for Android

### Platform-Specific Issues

#### Android: "INSTALL_FAILED_UPDATE_INCOMPATIBLE"

**Solution**: Uninstall existing app first:
```bash
adb uninstall com.discnfound.disc_n_found
```

#### iOS: "No such module" Errors

**Solution**: Reinstall pods:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

#### iOS: Build Fails with "Command PhaseScriptExecution failed"

**Solution**: Clean and rebuild:
```bash
flutter clean
cd ios
pod deintegrate
pod install
cd ..
flutter pub get
```

---

## Frequently Asked Questions (FAQ)

### General Questions

**Q: Do I need to pay for Firebase?**
A: Firebase has a free tier (Spark plan) that's sufficient for development and small apps. You'll only pay if you exceed free tier limits.

**Q: Do I need to pay for Stripe?**
A: Stripe charges 2.9% + $0.30 per successful transaction. No monthly fees. Test mode is free.

**Q: Can I develop on Windows?**
A: Yes, but you can only build for Android. iOS development requires macOS.

**Q: How long does it take to build the app?**
A: First build: 5-10 minutes. Subsequent builds: 1-3 minutes. Release builds: 3-5 minutes.

### Firebase Questions

**Q: What happens if I exceed Firebase free tier?**
A: Firebase will notify you. You can upgrade to Blaze plan (pay-as-you-go) or optimize usage.

**Q: Can I use a different database instead of Firestore?**
A: The app is designed for Firestore. Switching would require significant code changes.

**Q: How do I backup my Firebase data?**
A: Use Firebase Console > Firestore > Export, or use `gcloud` CLI tools.

**Q: Can I use Firebase Emulator for local development?**
A: Yes, but requires additional setup. See Firebase documentation for emulator suite.

### Stripe Questions

**Q: Can I use a different payment processor?**
A: Yes, but requires modifying `SubscriptionService` and Cloud Functions.

**Q: How do I switch from test to live mode?**
A: Update keys in `subscription_service.dart` and Firebase Functions config to use `pk_live_` and `sk_live_` keys.

**Q: What happens if a payment fails?**
A: Stripe webhook will trigger `payment_intent.payment_failed` event. You can handle this in Cloud Functions.

**Q: Can I offer refunds?**
A: Yes, through Stripe Dashboard or API. You may want to add refund handling to Cloud Functions.

### Development Questions

**Q: How do I add new features?**
A: Follow the existing architecture:
1. Create models in `lib/models/`
2. Create services in `lib/services/`
3. Create screens in `lib/features/`
4. Add providers in `lib/core/providers/`

**Q: How do I update dependencies?**
A: Run `flutter pub upgrade` or edit `pubspec.yaml` and run `flutter pub get`.

**Q: Can I use a different state management?**
A: The app uses Riverpod. Switching would require refactoring all screens and providers.

**Q: How do I debug the app?**
A: Use Flutter DevTools, print statements, or VS Code/Android Studio debugger.

### Deployment Questions

**Q: How long does app review take?**
A: Google Play: 1-3 days. App Store: 1-7 days (can be longer for first submission).

**Q: Can I update the app after deployment?**
A: Yes, build new version, increment version number, upload to stores.

**Q: Do I need to update Cloud Functions when updating app?**
A: Only if you change function code. App updates don't require function updates.

**Q: Can I roll back to a previous version?**
A: Yes, in Google Play Console and App Store Connect you can roll back releases.

### Security Questions

**Q: Are my API keys secure?**
A: Publishable keys in code are safe (they're meant to be public). Secret keys should only be in Cloud Functions config, never in app code.

**Q: How do I protect user data?**
A: Security rules in Firestore and Storage protect data. Review and test rules thoroughly.

**Q: What if someone steals my code?**
A: The code is proprietary and protected by copyright. See LICENSE file for legal protection.

### Support Questions

**Q: Where can I get help?**
A: 
- Flutter documentation: https://flutter.dev/docs
- Firebase documentation: https://firebase.google.com/docs
- Stripe documentation: https://stripe.com/docs
- Stack Overflow for specific issues

**Q: How do I report bugs?**
A: Document the issue with steps to reproduce, screenshots, and error messages. Contact Corby Bibb.

**Q: Can I customize the app design?**
A: Yes, edit `lib/core/theme/app_theme.dart` for colors and styling. Modify screens in `lib/features/` for UI changes.

---

## Additional Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Stripe Documentation](https://stripe.com/docs)
- [Riverpod Documentation](https://riverpod.dev)

### Tools
- [Flutter DevTools](https://flutter.dev/docs/development/tools/devtools)
- [Firebase Console](https://console.firebase.google.com)
- [Stripe Dashboard](https://dashboard.stripe.com)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter Discord](https://discord.gg/flutter)

---

## Support

For additional support or questions not covered in this guide, contact Corby Bibb.

**Copyright © 2026 Corby Bibb. All Rights Reserved.**
**"Disc 'n' Found" is a trademark of Corby Bibb.**

---

## Version History

- **v1.0** - Initial build guide
- Last updated: January 2026
