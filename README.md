# Disc 'n' Found

A comprehensive mobile application for disc golfers to report lost or found discs by uploading photos, allowing other users to claim their items through a community feed. Built with Flutter for cross-platform Android and iOS support.

---

## 📋 Table of Contents

- [System Overview](#system-overview)
- [Current System State](#current-system-state)
- [Features & Functionality](#features--functionality)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Data Models](#data-models)
- [Services](#services)
- [UI Screens & Navigation](#ui-screens--navigation)
- [Dependencies](#dependencies)
- [Setup & Configuration](#setup--configuration)
- [Firebase Configuration](#firebase-configuration)
- [Known Limitations & TODO](#known-limitations--todo)
- [Development](#development)

---

## System Overview

**Disc 'n' Found** is a community-driven mobile application that connects disc golfers to help recover lost discs. Users can upload photos of found or lost discs, browse a community feed, claim items, and communicate with other users through in-app messaging.

### Tech Stack

- **Frontend Framework**: Flutter 4.0.0 (Dart SDK ^3.10.4)
- **State Management**: Riverpod 2.5.1
- **Backend Services**: Firebase
  - Authentication (Email/Password)
  - Cloud Firestore (Database)
  - Firebase Storage (Image storage)
  - Firebase Messaging (Push notifications - configured but not fully implemented)
  - Firebase Analytics (Configured but not fully implemented)
  - Firebase Crashlytics (Configured but not fully implemented)
- **Payment Processing**: Stripe SDK 11.1.0 (UI implemented, payment flow pending)
- **Image Handling**: 
  - `image_picker` 1.1.2 (Camera/Gallery access)
  - `cached_network_image` 3.4.1 (Optimized image loading)

---

## Current System State

### ✅ Fully Implemented Features

1. **User Authentication System**
   - Email/password registration with validation
   - Email/password login with error handling
   - User session management
   - Automatic user profile creation in Firestore
   - Auth state persistence

2. **User Profile Management**
   - Editable user profiles
   - Profile photo upload to Firebase Storage
   - Name, location, and favorite discs fields
   - Profile data stored in Firestore
   - Real-time profile updates

3. **Disc Upload System**
   - Photo capture from camera or gallery
   - Image compression (85% quality, max 1920x1920)
   - Lost/Found status selection
   - Description and optional location fields
   - Automatic upload to Firebase Storage
   - Firestore document creation with metadata

4. **Community Feed**
   - Real-time disc listings from Firestore
   - Image display with caching
   - Status badges (Lost/Found/Claimed)
   - Location display
   - Chronological ordering (newest first)
   - Empty state handling

5. **Disc Claiming Mechanism**
   - One-click claim functionality
   - Status update to "claimed" in Firestore
   - Claimer ID tracking
   - Visual claim status indicators
   - Message button for claimed discs

6. **In-App Messaging**
   - Real-time chat between users
   - Chat room creation based on user pairs
   - Message history with timestamps
   - Stream-based message updates
   - Chat metadata storage

7. **Subscription UI**
   - Basic ($3.99/month) and Premium ($9.99/month) tier display
   - Feature comparison lists
   - Current plan indicator
   - Subscription screen navigation

### 🚧 Partially Implemented Features

1. **Stripe Payment Integration**
   - UI components complete
   - Payment button handlers show placeholder message
   - No actual payment processing implemented
   - No subscription status updates in Firestore

2. **Push Notifications**
   - Firebase Messaging package installed
   - No notification handlers implemented
   - No claim/message notification triggers

3. **Analytics**
   - Firebase Analytics package installed
   - No event tracking implemented

4. **Google Sign-In**
   - Not implemented (email/password only)

---

## Features & Functionality

### 1. Authentication Flow

**Login Screen** (`lib/features/auth/screens/login_screen.dart`)
- Email and password input fields with validation
- Form validation (email format, password length)
- Error handling with user-friendly messages
- Navigation to sign-up screen
- Automatic navigation to home on successful login

**Sign-Up Screen** (`lib/features/auth/screens/signup_screen.dart`)
- Full name, email, password, and confirm password fields
- Comprehensive form validation
- Password matching verification
- User creation in Firebase Auth
- Automatic profile creation in Firestore
- Navigation to home on successful registration

**Auth State Management** (`lib/core/providers/auth_provider.dart`)
- Riverpod providers for auth state
- Stream-based auth state monitoring
- Current user data provider
- Automatic UI updates on auth changes

### 2. User Profile System

**Profile Screen** (`lib/features/profile/screens/profile_screen.dart`)
- View mode: Display current user information
- Edit mode: Modify name, location, favorite discs
- Profile photo upload with image picker
- Photo storage in Firebase Storage (`profiles/{userId}`)
- Real-time profile updates
- Subscription tier display
- Sign-out functionality

**User Model** (`lib/models/user_model.dart`)
- Fields: `uid`, `email`, `displayName`, `photoUrl`, `location`, `favoriteDiscs`, `subscriptionTier`, `createdAt`
- Firestore serialization/deserialization
- Default subscription tier: "free"

### 3. Disc Management

**Upload Screen** (`lib/features/discs/screens/upload_screen.dart`)
- Image selection (camera or gallery)
- Image preview before upload
- Status selection (Lost/Found) via segmented button
- Description field (required, multi-line)
- Location field (optional)
- Image upload to Firebase Storage (`discs/{userId}/{timestamp}`)
- Firestore document creation with metadata
- Success/error feedback

**Feed Screen** (`lib/features/discs/screens/feed_screen.dart`)
- Real-time stream of all disc listings
- Card-based layout with images
- Status chips (Lost/Found/Claimed)
- Location display with icon
- Claim button (visible for unclaimed discs)
- Message button (visible for claimed discs when user is involved)
- Empty state message
- Loading and error states
- Floating action button for upload

**Disc Model** (`lib/models/disc_model.dart`)
- Fields: `id`, `userId`, `imageUrl`, `description`, `status`, `location`, `claimedBy`, `timestamp`
- Status values: "lost", "found", "claimed"
- Helper method: `isClaimed` getter

### 4. Claiming System

**Claim Functionality**
- One-click claim button on unclaimed discs
- Updates Firestore document with `claimedBy` field
- Sets status to "claimed"
- Triggers UI update via stream
- Success/error notifications

**Message Integration**
- Message button appears when:
  - Disc is claimed
  - Current user is either the uploader or claimer
- Creates chat room between uploader and claimer
- Navigates to chat screen

### 5. Messaging System

**Chat Screen** (`lib/features/messaging/screens/chat_screen.dart`)
- Real-time message stream from Firestore
- Message bubbles (sender on right, receiver on left)
- Message input field with send button
- Auto-scroll to latest message
- Chat ID generation based on user pairs
- Message history persistence

**Messaging Service** (`lib/services/messaging_service.dart`)
- Chat ID generation (sorted user IDs)
- Message sending with timestamps
- Message stream retrieval
- Chat metadata updates (last message, timestamp)

**Message Model** (`lib/models/message_model.dart`)
- Fields: `id`, `chatId`, `senderId`, `text`, `timestamp`, `imageUrl` (optional)
- Firestore serialization/deserialization

### 6. Subscription System

**Subscription Screen** (`lib/features/subscriptions/screens/subscription_screen.dart`)
- Basic tier display ($3.99/month)
  - Priority claims
  - Ad-free experience
  - Enhanced profile
- Premium tier display ($9.99/month)
  - Everything in Basic
  - Unlimited uploads
  - Advanced search
  - Priority support
  - Exclusive badges
- Current plan indicator
- Subscribe buttons (placeholder - no payment processing)

---

## Architecture

### State Management Pattern

The app uses **Riverpod** for state management with the following patterns:

1. **Providers**: Defined in `lib/core/providers/`
   - `authServiceProvider`: Singleton AuthService instance
   - `authStateProvider`: Stream of Firebase Auth user state
   - `currentUserProvider`: Async provider for current user data from Firestore

2. **Feature-Specific Providers**: Defined in feature screens
   - `discServiceProvider`: DiscService instance
   - `discsFeedProvider`: Stream of all disc listings
   - `messagingServiceProvider`: MessagingService instance
   - `messagesProvider`: Stream of messages for a chat

3. **Consumer Widgets**: All screens use `ConsumerWidget` or `ConsumerStatefulWidget` for reactive updates

### Service Layer Pattern

Services encapsulate business logic and Firebase interactions:

- **AuthService** (`lib/services/auth_service.dart`): Authentication operations
- **DiscService** (`lib/services/disc_service.dart`): Disc upload, retrieval, claiming
- **MessagingService** (`lib/services/messaging_service.dart`): Chat and message operations

### Data Flow

1. **User Action** → UI Widget
2. **UI Widget** → Service Method (via Riverpod provider)
3. **Service Method** → Firebase Operation
4. **Firebase Operation** → Stream Update
5. **Stream Update** → Riverpod Provider
6. **Provider Update** → UI Rebuild

---

## Project Structure

```
disc-n-found/
├── lib/
│   ├── main.dart                          # App entry point, routing, auth wrapper
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart         # App-wide constants (prices, collections, paths)
│   │   ├── providers/
│   │   │   └── auth_provider.dart          # Riverpod auth providers
│   │   ├── theme/
│   │   │   └── app_theme.dart              # Material 3 theme with earthy colors
│   │   └── firebase_options.dart           # Firebase configuration (needs setup)
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   └── screens/
│   │   │       ├── login_screen.dart       # Email/password login
│   │   │       └── signup_screen.dart      # User registration
│   │   │
│   │   ├── discs/
│   │   │   └── screens/
│   │   │       ├── feed_screen.dart        # Community disc feed
│   │   │       └── upload_screen.dart      # Disc upload with photo
│   │   │
│   │   ├── profile/
│   │   │   └── screens/
│   │   │       └── profile_screen.dart     # User profile management
│   │   │
│   │   ├── messaging/
│   │   │   └── screens/
│   │   │       └── chat_screen.dart        # Real-time chat interface
│   │   │
│   │   └── subscriptions/
│   │       └── screens/
│   │           └── subscription_screen.dart # Subscription tiers UI
│   │
│   ├── models/
│   │   ├── user_model.dart                 # User data model
│   │   ├── disc_model.dart                 # Disc listing model
│   │   └── message_model.dart               # Chat message model
│   │
│   ├── services/
│   │   ├── auth_service.dart                # Authentication logic
│   │   ├── disc_service.dart                # Disc operations
│   │   └── messaging_service.dart            # Messaging operations
│   │
│   └── widgets/                             # Reusable widgets (currently empty)
│
├── assets/
│   └── images/                              # Image assets directory
│
├── android/                                 # Android platform files
├── ios/                                     # iOS platform files
├── test/
│   └── widget_test.dart                     # Basic widget test
│
├── pubspec.yaml                             # Dependencies and project config
├── analysis_options.yaml                    # Linter configuration
└── README.md                                # This file
```

---

## Data Models

### UserModel

```dart
{
  uid: String (required),
  email: String (required),
  displayName: String? (optional),
  photoUrl: String? (optional),
  location: String? (optional),
  favoriteDiscs: String? (optional),
  subscriptionTier: String (default: "free"),
  createdAt: DateTime (required)
}
```

**Firestore Collection**: `users`
**Document ID**: User's Firebase Auth UID

### DiscModel

```dart
{
  id: String (document ID),
  userId: String (uploader's UID),
  imageUrl: String (Firebase Storage URL),
  description: String (required),
  status: String ("lost" | "found" | "claimed"),
  location: String? (optional),
  claimedBy: String? (claimer's UID, null if unclaimed),
  timestamp: DateTime (server timestamp)
}
```

**Firestore Collection**: `discs`
**Document ID**: Auto-generated by Firestore
**Queries**: Ordered by `timestamp` descending

### MessageModel

```dart
{
  id: String (document ID),
  chatId: String (format: "{userId1}_{userId2}" sorted),
  senderId: String (sender's UID),
  text: String (message content),
  timestamp: DateTime,
  imageUrl: String? (optional, not implemented)
}
```

**Firestore Collection**: `chats/{chatId}/messages`
**Subcollection**: Messages stored as subcollection under chat document
**Chat Document**: Stores `lastMessage`, `lastMessageTime`, `participants[]`

---

## Services

### AuthService (`lib/services/auth_service.dart`)

**Methods:**
- `signUpWithEmail()`: Creates user account, updates display name, creates Firestore profile
- `signInWithEmail()`: Authenticates user, retrieves profile from Firestore
- `signOut()`: Signs out current user
- `getUserData()`: Fetches user profile from Firestore

**Properties:**
- `currentUser`: Getter for Firebase Auth current user
- `authStateChanges`: Stream of auth state changes

### DiscService (`lib/services/disc_service.dart`)

**Methods:**
- `uploadDiscImage()`: Uploads image file to Firebase Storage, returns download URL
- `uploadDisc()`: Creates Firestore document with disc data
- `getDiscsFeed()`: Returns stream of all discs ordered by timestamp
- `claimDisc()`: Updates disc document with claimer ID and status

**Storage Path**: `discs/{userId}/{timestamp}`

### MessagingService (`lib/services/messaging_service.dart`)

**Methods:**
- `getChatId()`: Generates consistent chat ID from two user IDs
- `sendMessage()`: Creates message document, updates chat metadata
- `getMessages()`: Returns stream of messages for a chat, ordered by timestamp

**Chat ID Format**: Sorted user IDs joined with underscore (e.g., "abc123_def456")

---

## UI Screens & Navigation

### Navigation Flow

```
App Start
  ↓
AuthWrapper (checks auth state)
  ├─→ LoginScreen (if not authenticated)
  │     ├─→ SignUpScreen
  │     └─→ HomeScreen (after login)
  │
  └─→ HomeScreen (if authenticated)
        ├─→ FeedScreen (default tab)
        │     ├─→ UploadScreen (FAB)
        │     └─→ ChatScreen (from claimed disc)
        │
        ├─→ SubscriptionScreen (tab)
        │
        └─→ ProfileScreen (tab)
              └─→ LoginScreen (after sign out)
```

### Screen Details

**HomeScreen** (`lib/main.dart`)
- Bottom navigation bar with 3 tabs:
  1. Feed (home icon)
  2. Subscriptions (star icon)
  3. Profile (person icon)
- Tab state management with `_currentIndex`

**FeedScreen**
- App bar with upload FAB
- ListView of disc cards
- Real-time updates via stream
- Empty state handling

**UploadScreen**
- Image picker (camera/gallery buttons)
- Image preview
- Status selector (Lost/Found)
- Form validation
- Upload progress indicator

**ProfileScreen**
- View/Edit mode toggle
- Profile photo with edit overlay
- Form fields for user data
- Subscription tier card
- Sign-out button

**ChatScreen**
- Message list with sender/receiver bubbles
- Input field with send button
- Auto-scroll to bottom
- Real-time message updates

**SubscriptionScreen**
- Two-tier card layout
- Feature lists
- Current plan indicator
- Subscribe buttons (placeholder)

---

## Dependencies

### Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.5.1 | State management |
| `firebase_core` | ^3.6.0 | Firebase initialization |
| `firebase_auth` | ^5.3.1 | User authentication |
| `cloud_firestore` | ^5.4.4 | NoSQL database |
| `firebase_storage` | ^12.3.4 | File storage |
| `firebase_messaging` | ^15.0.0 | Push notifications (configured, not used) |
| `firebase_analytics` | ^11.3.3 | Analytics (configured, not used) |
| `firebase_crashlytics` | ^4.1.3 | Crash reporting (configured, not used) |
| `image_picker` | ^1.1.2 | Camera/gallery access |
| `cached_network_image` | ^3.4.1 | Optimized image loading |
| `flutter_stripe` | ^11.1.0 | Payment processing (UI only) |
| `intl` | ^0.19.0 | Internationalization utilities |
| `uuid` | ^4.5.1 | UUID generation |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Unit/widget testing |
| `flutter_lints` | ^6.0.0 | Linting rules |

---

## Setup & Configuration

### Prerequisites

1. **Flutter SDK**: Version 3.10.4 or higher
   ```bash
   flutter --version
   ```

2. **Development Environment**:
   - Android Studio / VS Code with Flutter extensions
   - Xcode (for iOS development on macOS)
   - Android SDK (for Android development)

3. **Firebase Account**: Create account at [firebase.google.com](https://firebase.google.com)

### Installation Steps

1. **Clone/Download the project**

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (see [Firebase Configuration](#firebase-configuration) below)

4. **Run the app**:
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android

- Minimum SDK: Configured in `android/app/build.gradle.kts`
- Permissions: Camera and storage permissions handled by `image_picker`
- Google Services: Add `google-services.json` after Firebase configuration

#### iOS

- Minimum iOS version: Configured in `ios/Podfile`
- Permissions: Camera and photo library permissions in `Info.plist`
- Google Services: Add `GoogleService-Info.plist` after Firebase configuration

---

## Firebase Configuration

### Required Firebase Services

1. **Authentication**
   - Enable Email/Password provider
   - Optional: Enable Google Sign-In (not implemented in app)

2. **Cloud Firestore**
   - Create database in production mode (or test mode for development)
   - Security rules: Configure based on your requirements
   - Collections: `users`, `discs`, `chats`

3. **Firebase Storage**
   - Create default bucket
   - Security rules: Allow authenticated users to read/write
   - Storage paths: `profiles/`, `discs/`

4. **Firebase Messaging** (for future push notifications)
   - Enable Cloud Messaging API
   - Configure APNs (iOS) and FCM (Android)

### FlutterFire CLI Setup

1. **Install FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Configure Firebase for Flutter**:
   ```bash
   flutterfire configure
   ```
   
   This command will:
   - Detect your Firebase projects
   - Generate `lib/core/firebase_options.dart` with your credentials
   - Update platform-specific configuration files

4. **Verify Configuration**:
   - Check that `lib/core/firebase_options.dart` has real values (not placeholders)
   - Ensure `android/app/google-services.json` exists (Android)
   - Ensure `ios/Runner/GoogleService-Info.plist` exists (iOS)

### Firestore Security Rules (Example)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read any user, but only update their own
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Discs: anyone can read, authenticated users can create, only uploader can update
    match /discs/{discId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.uid == request.resource.data.claimedBy);
    }
    
    // Chats: only participants can read/write
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read, write: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
      }
    }
  }
}
```

### Storage Security Rules (Example)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images: users can upload/read their own
    match /profiles/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Disc images: authenticated users can upload, anyone can read
    match /discs/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## Known Limitations & TODO

### Critical TODOs

1. **Stripe Payment Integration**
   - [ ] Implement payment intent creation
   - [ ] Handle payment confirmation
   - [ ] Update user subscription tier in Firestore
   - [ ] Set up webhook handlers in Firebase Cloud Functions
   - [ ] Handle subscription status changes

2. **Push Notifications**
   - [ ] Implement FCM token registration
   - [ ] Handle foreground/background notifications
   - [ ] Send notifications on disc claims
   - [ ] Send notifications on new messages
   - [ ] Configure notification payloads

3. **Analytics Events**
   - [ ] Track disc uploads
   - [ ] Track claims
   - [ ] Track messages sent
   - [ ] Track subscription conversions
   - [ ] Track user engagement metrics

### Enhancement TODOs

4. **Google Sign-In**
   - [ ] Add Google Sign-In button to login screen
   - [ ] Implement Google authentication flow
   - [ ] Handle Google user profile creation

5. **Search & Filters**
   - [ ] Add search functionality for disc descriptions
   - [ ] Filter by status (lost/found)
   - [ ] Filter by location
   - [ ] Sort options (newest, oldest, location-based)

6. **Image Features**
   - [ ] Multiple image upload per disc
   - [ ] Image editing/cropping before upload
   - [ ] Image compression optimization

7. **User Features**
   - [ ] User ratings/reviews
   - [ ] User statistics (discs found/lost)
   - [ ] Badge system for active users

8. **Messaging Enhancements**
   - [ ] Image sharing in messages
   - [ ] Typing indicators
   - [ ] Message read receipts
   - [ ] Chat list screen

9. **Premium Features**
   - [ ] Priority claim implementation
   - [ ] Ad-free experience (remove placeholder ads)
   - [ ] Advanced search for premium users
   - [ ] Unlimited uploads enforcement

10. **Performance**
    - [ ] Implement pagination for feed
    - [ ] Image lazy loading optimization
    - [ ] Cache management for offline support

11. **Testing**
    - [ ] Unit tests for services
    - [ ] Widget tests for screens
    - [ ] Integration tests for user flows

12. **Deployment**
    - [ ] App icons and splash screens
    - [ ] App store listings
    - [ ] Privacy policy and terms of service
    - [ ] Beta testing setup

---

## Development

### Running the App

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Build for release
flutter build apk  # Android
flutter build ios  # iOS
```

### Code Analysis

```bash
# Run linter
flutter analyze

# Format code
dart format lib/

# Check for outdated packages
flutter pub outdated
```

### Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

### Debugging

- Use Flutter DevTools for performance profiling
- Firebase Console for database/storage inspection
- Check `lib/core/firebase_options.dart` for configuration issues

### Common Issues

1. **Firebase not initialized**: Run `flutterfire configure`
2. **Image picker permissions**: Check platform-specific permission settings
3. **Build errors**: Run `flutter clean` then `flutter pub get`
4. **Firestore rules**: Ensure security rules allow your operations

---

## License

See LICENSE file for details.

---

## Support & Contribution

For issues, questions, or contributions, please refer to the project repository.

**Last Updated**: January 2026
**Version**: 1.0.0+1
**Status**: Core features complete, payment integration and notifications pending
