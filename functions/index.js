/**
 * Firebase Cloud Functions for Disc 'n' Found
 * 
 * To deploy:
 * 1. Install Firebase CLI: npm install -g firebase-tools
 * 2. Login: firebase login
 * 3. Initialize: firebase init functions
 * 4. Deploy: firebase deploy --only functions
 * 
 * Required packages:
 * - firebase-functions
 * - firebase-admin
 * - stripe
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(functions.config().stripe.secret_key);

admin.initializeApp();

/**
 * Create Stripe Payment Intent
 * Called from the Flutter app when user wants to subscribe
 */
exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { amount, currency = 'usd', userId, tier } = data;

  try {
    // Create payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: currency,
      metadata: {
        userId: userId,
        tier: tier,
      },
    });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    };
  } catch (error) {
    throw new functions.https.HttpsError(
      'internal',
      'Failed to create payment intent',
      error.message
    );
  }
});

/**
 * Stripe Webhook Handler
 * Handles subscription events from Stripe
 */
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const webhookSecret = functions.config().stripe.webhook_secret;

  let event;

  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
  } catch (err) {
    console.log(`Webhook signature verification failed.`, err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the event
  switch (event.type) {
    case 'payment_intent.succeeded':
      const paymentIntent = event.data.object;
      const userId = paymentIntent.metadata.userId;
      const tier = paymentIntent.metadata.tier;

      // Update user subscription in Firestore
      await admin.firestore()
        .collection('users')
        .doc(userId)
        .update({
          subscriptionTier: tier,
          subscriptionStatus: 'active',
          subscriptionStartDate: admin.firestore.FieldValue.serverTimestamp(),
        });
      break;

    case 'payment_intent.payment_failed':
      console.log('Payment failed:', event.data.object.id);
      break;

    default:
      console.log(`Unhandled event type ${event.type}`);
  }

  res.json({ received: true });
});

/**
 * Send Push Notification
 * Helper function to send FCM notifications
 */
async function sendNotification(userId, title, body, data) {
  try {
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(userId)
      .get();

    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken) {
      console.log('No FCM token for user:', userId);
      return;
    }

    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: data,
      token: fcmToken,
    };

    await admin.messaging().send(message);
    console.log('Notification sent to user:', userId);
  } catch (error) {
    console.error('Error sending notification:', error);
  }
}

/**
 * Trigger notification when disc is claimed
 */
exports.onDiscClaimed = functions.firestore
  .document('discs/{discId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Check if disc was just claimed
    if (!before.claimedBy && after.claimedBy) {
      const uploaderId = after.userId;
      const claimerId = after.claimedBy;

      // Get claimer's name
      const claimerDoc = await admin.firestore()
        .collection('users')
        .doc(claimerId)
        .get();
      const claimerName = claimerDoc.data()?.displayName || 'Someone';

      // Send notification
      await sendNotification(
        uploaderId,
        'Disc Claimed',
        `${claimerName} claimed your disc`,
        {
          type: 'claim',
          discId: context.params.discId,
        }
      );
    }
  });

/**
 * Trigger notification when new message is sent
 */
exports.onMessageSent = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const chatId = context.params.chatId;

    // Get chat participants
    const chatDoc = await admin.firestore()
      .collection('chats')
      .doc(chatId)
      .get();
    const participants = chatDoc.data()?.participants || [];

    // Find recipient (not the sender)
    const recipientId = participants.find(id => id !== message.senderId);
    if (!recipientId) return;

    // Get sender's name
    const senderDoc = await admin.firestore()
      .collection('users')
      .doc(message.senderId)
      .get();
    const senderName = senderDoc.data()?.displayName || 'Someone';

    // Send notification
    await sendNotification(
      recipientId,
      'New Message',
      `${senderName}: ${message.text}`,
      {
        type: 'message',
        chatId: chatId,
      }
    );
  });
