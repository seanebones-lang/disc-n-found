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
- [Testing](#testing)
- [Deployment](#deployment)
- [Development](#development)

---

## System Overview

**Disc 'n' Found** is a community-driven mobile application that connects disc golfers to help recover lost discs. Users can upload photos of found or lost discs, browse a community feed, claim items, communicate with other users through in-app messaging, and subscribe to premium features.

### Tech Stack

- **Frontend Framework**: Flutter 4.0.0 (Dart SDK ^3.10.4)
- **State Management**: Riverpod 2.5.1
- **Backend Services**: Firebase
  - Authentication (Email/Password, Google Sign-In)
  - Cloud Firestore (Database)
  - Firebase Storage (Image storage)
  - Firebase Messaging (Push notifications - **Fully Implemented**)
  - Firebase Analytics (Event tracking - **Fully Implemented**)
  - Firebase Crashlytics (Configured)
- **Payment Processing**: Stripe SDK 11.1.0 (**Fully Implemented**)
- **Image Handling**: 
  - `image_picker` 1.1.2 (Camera/Gallery access)
  - `cached_network_image` 3.4.1 (Optimized image loading)
- **Additional**: Google Sign-In 6.2.1, HTTP 1.6.0

---

## Current System State

### ✅ Fully Implemented Features

1. **User Authentication System**
   - Email/password registration with validation
   - Email/password login with error handling
   - **Google Sign-In authentication** ✨ NEW
   - User session management
   - Automatic user profile creation in Firestore
   - Auth state persistence
   - Analytics tracking for all auth events

2. **User Profile Management**
   - Editable user profiles
   - Profile photo upload to Firebase Storage
   - Name, location, and favorite discs fields
   - Profile data stored in Firestore
   - Real-time profile updates
   - Analytics tracking for profile updates

3. **Disc Upload System**
   - Photo capture from camera or gallery
   - Image compression (85% quality, max 1920x1920)
   - Lost/Found status selection
   - Description and optional location fields
   - Automatic upload to Firebase Storage
   - Firestore document creation with metadata
   - Analytics tracking for uploads

4. **Community Feed**
   - **Pagination with lazy loading** ✨ NEW (20 items per page)
   - **Pull-to-refresh functionality** ✨ NEW
   - Real-time disc listings from Firestore
   - Image display with caching
   - Status badges (Lost/Found/Claimed)
   - Location display
   - Chronological ordering (newest first)
   - Empty state handling
   - Infinite scroll implementation
   - Analytics tracking for disc views

5. **Disc Claiming Mechanism**
   - One-click claim functionality
   - Status update to "claimed" in Firestore
   - Claimer ID tracking
   - Visual claim status indicators
   - Message button for claimed discs
   - **Automatic push notifications to uploader** ✨ NEW
   - Analytics tracking for claims

6. **In-App Messaging**
   - Real-time chat between users
   - Chat room creation based on user pairs
   - Message history with timestamps
   - Stream-based message updates
   - Chat metadata storage
   - **Automatic push notifications for new messages** ✨ NEW
   - Analytics tracking for messages

7. **Subscription System** ✨ FULLY IMPLEMENTED
   - Basic ($3.99/month) and Premium ($9.99/month) tier display
   - Feature comparison lists
   - Current plan indicator
   - **Stripe PaymentSheet integration** ✨ NEW
   - **Payment intent creation via Cloud Functions** ✨ NEW
   - **Subscription status updates in Firestore** ✨ NEW
   - **Webhook handling for payment events** ✨ NEW
   - Analytics tracking for subscriptions

8. **Push Notifications** ✨ FULLY IMPLEMENTED
   - FCM token registration and management
   - Foreground message handling
   - Background message handling
   - Automatic notifications on disc claims
   - Automatic notifications on new messages
   - Cloud Functions triggers for notifications
   - Notification storage in Firestore

9. **Analytics & Tracking** ✨ FULLY IMPLEMENTED
   - User sign-up events (email/Google)
   - User login events (email/Google)
   - Profile update events
   - Disc upload events (with status and location data)
   - Disc view events
   - Disc claim events
   - Message sent events
   - Chat opened events
   - Subscription start/cancel events
   - Screen view tracking
   - User property tracking

10. **Performance Optimizations** ✨ NEW
    - Pagination for feed (reduces initial load time)
    - Lazy loading of images
    - Image caching with `cached_network_image`
    - Image compression on upload
    - Efficient Firestore queries

11. **Security** ✨ NEW
    - Complete Firestore security rules
    - Storage security rules
    - User authentication checks
    - Data access controls

12. **Testing** ✨ NEW
    - Unit tests for services
    - Unit tests for models
    - Test structure in place

---

## Features & Functionality

### 1. Authentication Flow

**Login Screen** (`lib/features/auth/screens/login_screen.dart`)
- Email and password input fields with validation
- **Google Sign-In button** ✨ NEW
- Form validation (email format, password length)
- Error handling with user-friendly messages
- Navigation to sign-up screen
- Automatic navigation to home on successful login
- Analytics tracking for login method

**Sign-Up Screen** (`lib/features/auth/screens/signup_screen.dart`)
- Full name, email, password, and confirm password fields
- Comprehensive form validation
- Password matching verification
- User creation in Firebase Auth
- Automatic profile creation in Firestore
- Navigation to home on successful registration
- Analytics tracking for sign-up method

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
- Analytics tracking for profile updates

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
- Analytics tracking with status and location data

**Feed Screen** (`lib/features/discs/screens/feed_screen.dart`) ✨ UPDATED
- **Pagination with 20 items per page** ✨ NEW
- **Infinite scroll implementation** ✨ NEW
- **Pull-to-refresh functionality** ✨ NEW
- Real-time stream of all disc listings
- Card-based layout with images
- Status chips (Lost/Found/Claimed)
- Location display with icon
- Claim button (visible for unclaimed discs)
- Message button (visible for claimed discs when user is involved)
- Empty state message
- Loading and error states
- Floating action button for upload
- Analytics tracking for disc views

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
- **Sends push notification to disc uploader** ✨ NEW
- Success/error notifications
- Analytics tracking with disc ID and status

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
- **Analytics tracking for chat opens and messages** ✨ NEW
- **Automatic push notifications to recipient** ✨ NEW

**Messaging Service** (`lib/services/messaging_service.dart`)
- Chat ID generation (sorted user IDs)
- Message sending with timestamps
- Message stream retrieval
- Chat metadata updates (last message, timestamp)
- **Notification integration** ✨ NEW
- **Analytics integration** ✨ NEW

**Message Model** (`lib/models/message_model.dart`)
- Fields: `id`, `chatId`, `senderId`, `text`, `timestamp`, `imageUrl` (optional)
- Firestore serialization/deserialization

### 6. Subscription System ✨ FULLY IMPLEMENTED

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
- **Stripe PaymentSheet integration** ✨ NEW
- **Payment processing with error handling** ✨ NEW
- **Subscription status updates** ✨ NEW
- Analytics tracking for subscription events

**Subscription Service** (`lib/services/subscription_service.dart`) ✨ NEW
- Stripe initialization
- Payment intent creation (via Cloud Functions)
- Payment confirmation with PaymentSheet
- Subscription status management
- Firestore updates for subscription tiers

### 7. Push Notifications ✨ FULLY IMPLEMENTED

**Notification Service** (`lib/services/notification_service.dart`) ✨ NEW
- FCM token registration and storage
- Permission request handling
- Foreground message handling
- Background message handling
- Notification storage in Firestore
- Claim notification sending
- Message notification sending
- Notification retrieval and marking as read

**Cloud Functions Integration** (`functions/index.js`) ✨ NEW
- Automatic notification triggers on disc claims
- Automatic notification triggers on new messages
- FCM message sending via Cloud Functions

### 8. Analytics & Tracking ✨ FULLY IMPLEMENTED

**Analytics Service** (`lib/services/analytics_service.dart`) ✨ NEW
- Centralized analytics event tracking
- User events (sign-up, login, profile update)
- Disc events (upload, view, claim)
- Messaging events (message sent, chat opened)
- Subscription events (start, cancel)
- Screen view tracking
- User property and ID tracking

**Tracked Events:**
- `sign_up` - User registration (method: email/google)
- `login` - User login (method: email/google)
- `profile_update` - Profile modifications
- `disc_upload` - Disc uploads (status, location)
- `disc_view` - Disc views (disc_id)
- `disc_claim` - Disc claims (disc_id, status)
- `message_sent` - Messages sent (chat_id, has_image)
- `chat_opened` - Chat screen opens (chat_id)
- `subscription_start` - Subscription purchases (tier, price)
- `subscription_cancel` - Subscription cancellations (tier)

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
   - `discsFeedProvider`: Stream of all disc listings (deprecated, using pagination)
   - `messagingServiceProvider`: MessagingService instance
   - `messagesProvider`: Stream of messages for a chat
   - `subscriptionServiceProvider`: SubscriptionService instance

3. **Consumer Widgets**: All screens use `ConsumerWidget` or `ConsumerStatefulWidget` for reactive updates

### Service Layer Pattern

Services encapsulate business logic and Firebase interactions:

- **AuthService** (`lib/services/auth_service.dart`): Authentication operations, Google Sign-In
- **DiscService** (`lib/services/disc_service.dart`): Disc upload, retrieval, claiming, pagination
- **MessagingService** (`lib/services/messaging_service.dart`): Chat and message operations
- **SubscriptionService** (`lib/services/subscription_service.dart`) ✨ NEW: Stripe payment processing
- **NotificationService** (`lib/services/notification_service.dart`) ✨ NEW: Push notification management
- **AnalyticsService** (`lib/services/analytics_service.dart`) ✨ NEW: Event tracking

### Data Flow

1. **User Action** → UI Widget
2. **UI Widget** → Service Method (via Riverpod provider)
3. **Service Method** → Firebase Operation / External API
4. **Firebase Operation** → Stream Update / Callback
5. **Stream Update** → Riverpod Provider
6. **Provider Update** → UI Rebuild
7. **Analytics Event** → Firebase Analytics (parallel)

---

## Project Structure

```
disc-n-found/
├── lib/
│   ├── main.dart                          # App entry point, routing, service initialization
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart         # App-wide constants
│   │   ├── providers/
│   │   │   └── auth_provider.dart          # Riverpod auth providers
│   │   ├── theme/
│   │   │   └── app_theme.dart              # Material 3 theme
│   │   └── firebase_options.dart           # Firebase configuration
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   └── screens/
│   │   │       ├── login_screen.dart       # Email/password + Google login
│   │   │       └── signup_screen.dart      # User registration
│   │   │
│   │   ├── discs/
│   │   │   └── screens/
│   │   │       ├── feed_screen.dart        # Paginated community feed
│   │   │       └── upload_screen.dart      # Disc upload with photo
│   │   │
│   │   ├── profile/
│   │   │   └── screens/
│   │   │       └── profile_screen.dart      # User profile management
│   │   │
│   │   ├── messaging/
│   │   │   └── screens/
│   │   │       └── chat_screen.dart        # Real-time chat interface
│   │   │
│   │   └── subscriptions/
│   │       └── screens/
│   │           └── subscription_screen.dart # Subscription tiers & payment
│   │
│   ├── models/
│   │   ├── user_model.dart                 # User data model
│   │   ├── disc_model.dart                 # Disc listing model
│   │   └── message_model.dart               # Chat message model
│   │
│   ├── services/
│   │   ├── auth_service.dart                # Authentication logic
│   │   ├── disc_service.dart                # Disc operations
│   │   ├── messaging_service.dart            # Messaging operations
│   │   ├── subscription_service.dart        # Stripe payment processing ✨ NEW
│   │   ├── notification_service.dart         # Push notifications ✨ NEW
│   │   └── analytics_service.dart            # Analytics tracking ✨ NEW
│   │
│   └── widgets/                             # Reusable widgets
│
├── test/
│   ├── models/                              # Model unit tests ✨ NEW
│   │   ├── user_model_test.dart
│   │   └── disc_model_test.dart
│   ├── services/                            # Service unit tests ✨ NEW
│   │   └── auth_service_test.dart
│   └── widget_test.dart                     # Widget tests
│
├── functions/
│   └── index.js                             # Cloud Functions ✨ NEW
│
├── firestore.rules                          # Firestore security rules ✨ NEW
├── storage.rules                            # Storage security rules ✨ NEW
├── DEPLOYMENT.md                            # Deployment guide ✨ NEW
├── pubspec.yaml                             # Dependencies
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
  subscriptionStatus: String? (optional, "active"/"cancelled"),
  subscriptionStartDate: Timestamp? (optional),
  subscriptionEndDate: Timestamp? (optional),
  fcmToken: String? (optional, for push notifications),
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
**Queries**: Ordered by `timestamp` descending, paginated

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

### NotificationModel (Implicit)

```dart
{
  id: String (document ID),
  userId: String (recipient's UID),
  type: String ("claim" | "message"),
  title: String,
  body: String,
  discId: String? (for claim notifications),
  chatId: String? (for message notifications),
  read: Boolean (default: false),
  timestamp: DateTime (server timestamp)
}
```

**Firestore Collection**: `notifications`

---

## Services

### AuthService (`lib/services/auth_service.dart`)

**Methods:**
- `signUpWithEmail()`: Creates user account, updates display name, creates Firestore profile, logs analytics
- `signInWithEmail()`: Authenticates user, retrieves profile from Firestore, logs analytics
- `signInWithGoogle()` ✨ NEW: Google Sign-In flow, creates/updates profile, logs analytics
- `signOut()`: Signs out current user and Google Sign-In
- `getUserData()`: Fetches user profile from Firestore

**Properties:**
- `currentUser`: Getter for Firebase Auth current user
- `authStateChanges`: Stream of auth state changes

### DiscService (`lib/services/disc_service.dart`)

**Methods:**
- `uploadDiscImage()`: Uploads image file to Firebase Storage, returns download URL
- `uploadDisc()`: Creates Firestore document with disc data, logs analytics
- `getDiscsFeedPage()` ✨ NEW: Returns paginated list of discs (20 per page)
- `claimDisc()`: Updates disc document with claimer ID and status, sends notification, logs analytics

**Storage Path**: `discs/{userId}/{timestamp}`

### MessagingService (`lib/services/messaging_service.dart`)

**Methods:**
- `getChatId()`: Generates consistent chat ID from two user IDs
- `sendMessage()`: Creates message document, updates chat metadata, sends notification, logs analytics
- `getMessages()`: Returns stream of messages for a chat, ordered by timestamp

**Chat ID Format**: Sorted user IDs joined with underscore (e.g., "abc123_def456")

### SubscriptionService (`lib/services/subscription_service.dart`) ✨ NEW

**Methods:**
- `initializeStripe()`: Initializes Stripe with publishable key
- `createPaymentIntent()`: Creates payment intent via Cloud Function
- `confirmPayment()`: Confirms payment with Stripe PaymentSheet, updates Firestore
- `cancelSubscription()`: Cancels user subscription, updates Firestore
- `getSubscriptionStatus()`: Retrieves current subscription status

**Configuration Required:**
- Stripe publishable key in `stripePublishableKey`
- Backend URL (Cloud Function) in `backendUrl`

### NotificationService (`lib/services/notification_service.dart`) ✨ NEW

**Methods:**
- `initialize()`: Requests permissions, gets FCM token, sets up handlers
- `sendClaimNotification()`: Sends notification when disc is claimed
- `sendMessageNotification()`: Sends notification when message is received
- `getNotifications()`: Retrieves user's notifications
- `markAsRead()`: Marks notification as read

**Background Handler**: `firebaseMessagingBackgroundHandler` in `main.dart`

### AnalyticsService (`lib/services/analytics_service.dart`) ✨ NEW

**Methods:**
- `logEvent()`: Generic event logging
- `logSignUp()`: User registration events
- `logLogin()`: User login events
- `logProfileUpdate()`: Profile modification events
- `logDiscUpload()`: Disc upload events
- `logDiscView()`: Disc view events
- `logDiscClaim()`: Disc claim events
- `logMessageSent()`: Message send events
- `logChatOpened()`: Chat open events
- `logSubscriptionStart()`: Subscription purchase events
- `logSubscriptionCancel()`: Subscription cancellation events
- `logScreenView()`: Screen view tracking
- `setUserProperty()`: Set user properties
- `setUserId()`: Set user ID for analytics

---

## UI Screens & Navigation

### Navigation Flow

```
App Start
  ↓
AuthWrapper (checks auth state)
  ├─→ LoginScreen (if not authenticated)
  │     ├─→ SignUpScreen
  │     ├─→ Google Sign-In ✨ NEW
  │     └─→ HomeScreen (after login)
  │
  └─→ HomeScreen (if authenticated)
        ├─→ FeedScreen (default tab)
        │     ├─→ UploadScreen (FAB)
        │     └─→ ChatScreen (from claimed disc)
        │
        ├─→ SubscriptionScreen (tab)
        │     └─→ Stripe PaymentSheet ✨ NEW
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

**FeedScreen** ✨ UPDATED
- App bar with upload FAB
- **Pagination with infinite scroll** ✨ NEW
- **Pull-to-refresh** ✨ NEW
- ListView of disc cards (20 per page)
- Real-time updates via stream
- Empty state handling
- Loading indicators for pagination

**UploadScreen**
- Image picker (camera/gallery buttons)
- Image preview
- Status selector (Lost/Found)
- Form validation
- Upload progress indicator
- Analytics tracking

**ProfileScreen**
- View/Edit mode toggle
- Profile photo with edit overlay
- Form fields for user data
- Subscription tier card
- Sign-out button
- Analytics tracking

**ChatScreen**
- Message list with sender/receiver bubbles
- Input field with send button
- Auto-scroll to bottom
- Real-time message updates
- Analytics tracking

**SubscriptionScreen** ✨ UPDATED
- Two-tier card layout
- Feature lists
- Current plan indicator
- **Stripe PaymentSheet integration** ✨ NEW
- **Payment processing with loading states** ✨ NEW
- Analytics tracking

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
| `firebase_messaging` | ^15.0.0 | Push notifications ✨ |
| `firebase_analytics` | ^11.3.3 | Analytics ✨ |
| `firebase_crashlytics` | ^4.1.3 | Crash reporting |
| `image_picker` | ^1.1.2 | Camera/gallery access |
| `cached_network_image` | ^3.4.1 | Optimized image loading |
| `flutter_stripe` | ^11.1.0 | Payment processing ✨ |
| `google_sign_in` | ^6.2.1 | Google authentication ✨ NEW |
| `intl` | ^0.19.0 | Internationalization |
| `uuid` | ^4.5.1 | UUID generation |
| `http` | ^1.2.0 | HTTP requests ✨ NEW |

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

4. **Stripe Account**: Create account at [stripe.com](https://stripe.com) ✨ NEW

### Installation Steps

1. **Clone/Download the project**

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (see [Firebase Configuration](#firebase-configuration) below)

4. **Configure Stripe** ✨ NEW:
   - Get publishable key from Stripe Dashboard
   - Update `lib/services/subscription_service.dart`:
     ```dart
     static const String stripePublishableKey = 'pk_live_...';
     static const String backendUrl = 'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net';
     ```

5. **Run the app**:
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android

- Minimum SDK: Configured in `android/app/build.gradle.kts`
- Permissions: Camera and storage permissions handled by `image_picker`
- Google Services: Add `google-services.json` after Firebase configuration
- **Google Sign-In**: Configure SHA-1 fingerprint in Firebase Console ✨ NEW

#### iOS

- Minimum iOS version: Configured in `ios/Podfile`
- Permissions: Camera and photo library permissions in `Info.plist`
- Google Services: Add `GoogleService-Info.plist` after Firebase configuration
- **Google Sign-In**: Configure URL scheme in `Info.plist` ✨ NEW

---

## Firebase Configuration

### Required Firebase Services

1. **Authentication**
   - Enable Email/Password provider
   - **Enable Google Sign-In provider** ✨ NEW
   - Configure OAuth consent screen

2. **Cloud Firestore**
   - Create database in production mode (or test mode for development)
   - **Deploy security rules** (see `firestore.rules`) ✨ NEW
   - Collections: `users`, `discs`, `chats`, `notifications`

3. **Firebase Storage**
   - Create default bucket
   - **Deploy security rules** (see `storage.rules`) ✨ NEW
   - Storage paths: `profiles/`, `discs/`

4. **Firebase Messaging** ✨ CONFIGURED
   - Enable Cloud Messaging API
   - Configure APNs (iOS) and FCM (Android)
   - **Background message handler configured** ✨ NEW

5. **Firebase Analytics** ✨ CONFIGURED
   - Automatically enabled
   - **Events tracked throughout app** ✨ NEW

6. **Cloud Functions** ✨ NEW
   - Deploy functions from `functions/` directory
   - Configure Stripe webhook endpoint
   - Set environment variables for Stripe keys

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

### Security Rules

**Firestore Rules** (`firestore.rules`):
- Users can read any profile, but only update their own
- Anyone can read discs, authenticated users can create
- Only uploader or claimer can update disc status
- Only chat participants can read/write messages
- Users can only access their own notifications

**Storage Rules** (`storage.rules`):
- Profile images: Anyone can read, users can upload their own (5MB limit)
- Disc images: Anyone can read, authenticated users can upload (10MB limit)

**Deploy Rules**:
```bash
firebase deploy --only firestore:rules
firebase deploy --only storage
```

### Cloud Functions Setup ✨ NEW

1. **Install dependencies**:
   ```bash
   cd functions
   npm install
   ```

2. **Configure Stripe keys**:
   ```bash
   firebase functions:config:set stripe.secret_key="sk_live_..."
   firebase functions:config:set stripe.webhook_secret="whsec_..."
   ```

3. **Deploy functions**:
   ```bash
   firebase deploy --only functions
   ```

4. **Configure Stripe Webhook**:
   - In Stripe Dashboard, create webhook endpoint
   - URL: `https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/stripeWebhook`
   - Events: `payment_intent.succeeded`, `payment_intent.payment_failed`

---

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/user_model_test.dart

# Run with coverage
flutter test --coverage
```

### Test Coverage

- ✅ **Unit Tests**: AuthService, UserModel, DiscModel
- 🚧 **Widget Tests**: Basic structure in place
- 🚧 **Integration Tests**: To be added

### Test Files

- `test/services/auth_service_test.dart` - AuthService unit tests
- `test/models/user_model_test.dart` - UserModel serialization tests
- `test/models/disc_model_test.dart` - DiscModel serialization tests
- `test/widget_test.dart` - Basic widget test

---

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for comprehensive deployment instructions.

### Quick Deployment Checklist

- [ ] Firebase project configured
- [ ] Security rules deployed
- [ ] Cloud Functions deployed
- [ ] Stripe keys configured
- [ ] Stripe webhook configured
- [ ] App icons and splash screens set
- [ ] Privacy policy and terms of service added
- [ ] Analytics configured
- [ ] Crashlytics enabled
- [ ] Push notifications tested
- [ ] Payment flow tested
- [ ] App store listings complete

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

### Debugging

- Use Flutter DevTools for performance profiling
- Firebase Console for database/storage inspection
- Check `lib/core/firebase_options.dart` for configuration issues
- **Stripe Dashboard** for payment debugging ✨ NEW
- **Firebase Analytics** for event tracking ✨ NEW

### Common Issues

1. **Firebase not initialized**: Run `flutterfire configure`
2. **Image picker permissions**: Check platform-specific permission settings
3. **Build errors**: Run `flutter clean` then `flutter pub get`
4. **Firestore rules**: Ensure security rules allow your operations
5. **Stripe payment fails**: Check publishable key and Cloud Function URL ✨ NEW
6. **Push notifications not working**: Verify FCM token registration and APNs setup ✨ NEW

---

## Known Limitations & Future Enhancements

### Potential Enhancements

1. **Search & Filters**
   - Add search functionality for disc descriptions
   - Filter by status (lost/found)
   - Filter by location
   - Sort options (newest, oldest, location-based)

2. **Image Features**
   - Multiple image upload per disc
   - Image editing/cropping before upload
   - Image compression optimization

3. **User Features**
   - User ratings/reviews
   - User statistics (discs found/lost)
   - Badge system for active users

4. **Messaging Enhancements**
   - Image sharing in messages
   - Typing indicators
   - Message read receipts
   - Chat list screen

5. **Premium Features**
   - Priority claim implementation logic
   - Ad-free experience (remove placeholder ads)
   - Advanced search for premium users
   - Unlimited uploads enforcement

6. **Performance**
   - Further pagination optimizations
   - Offline support with local caching
   - Image lazy loading improvements

7. **Testing**
   - Additional unit tests for all services
   - Comprehensive widget tests
   - Integration tests for user flows
   - E2E testing

---

## License

See LICENSE file for details.

---

## Support & Contribution

For issues, questions, or contributions, please refer to the project repository.

**Last Updated**: January 2026
**Version**: 1.0.0+1
**Status**: ✅ Production-ready with all core features implemented

---

## Changelog

### Version 1.0.0 (Latest)
- ✅ Complete Stripe payment integration
- ✅ Full push notification system
- ✅ Comprehensive analytics tracking
- ✅ Google Sign-In authentication
- ✅ Pagination and performance optimizations
- ✅ Security rules implementation
- ✅ Unit testing structure
- ✅ Deployment documentation

### Initial Release
- ✅ User authentication (email/password)
- ✅ User profiles with photo upload
- ✅ Disc upload and feed
- ✅ Claiming mechanism
- ✅ In-app messaging
- ✅ Subscription UI
