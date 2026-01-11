/**
 * Cloud Functions for Firebase - Message Notifications
 *
 * This function triggers when a new message is added to Firestore
 * and sends a push notification to the receiver via FCM.
 */

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

// Initialize Firebase Admin
initializeApp();

/**
 * Sends FCM notification when a new message is created
 *
 * Triggered on: /chat_rooms/{chatRoomId}/messages/{messageId}
 */
exports.sendMessageNotification = onDocumentCreated(
    "chat_rooms/{chatRoomId}/messages/{messageId}",
    async (event) => {
      try {
        // Get the message data
        const messageData = event.data.data();
        const senderId = messageData.senderId;
        const senderEmail = messageData.senderEmail;
        const receiverId = messageData.receiverId;
        const messageText = messageData.message;

        console.log(`📨 New message from ${senderEmail} to ${receiverId}`);

        // Get receiver's FCM token from Users collection
        const db = getFirestore();
        const userDoc = await db.collection("Users").doc(receiverId).get();

        if (!userDoc.exists) {
          console.log(`⚠️ User document not found for receiverId: ${receiverId}`);
          return;
        }

        const fcmToken = userDoc.data().fcmToken;

        if (!fcmToken) {
          console.log(`⚠️ No FCM token found for user: ${receiverId}`);
          return;
        }

        console.log(`🔔 Sending notification to token: ${fcmToken.substring(0, 20)}...`);

        // Prepare the notification message
        const notificationMessage = {
          token: fcmToken,
          notification: {
            title: `New message from ${senderEmail}`,
            body: messageText.length > 100 ?
              `${messageText.substring(0, 100)}...` :
              messageText,
          },
          android: {
            priority: "high",
            notification: {
              channelId: "high_importance_channel",
              sound: "default",
              priority: "high",
              defaultVibrateTimings: true,
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              },
            },
          },
          data: {
            chatRoomId: event.params.chatRoomId,
            senderId: senderId,
            senderEmail: senderEmail,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        };

        // Send the notification
        const response = await getMessaging().send(notificationMessage);
        console.log(`✅ Notification sent successfully: ${response}`);
      } catch (error) {
        console.error(`❌ Error sending notification: ${error.message}`);
        console.error(error);
      }
    },
);

/**
 * Optional: Clean up old typing status
 * Runs every 5 minutes to clear stale typing indicators
 */
exports.cleanUpTypingStatus = onDocumentCreated(
    "chat_rooms/{chatRoomId}",
    async (event) => {
      try {
        const db = getFirestore();
        const chatRoomRef = db.collection("chat_rooms").doc(event.params.chatRoomId);
        const chatRoomData = (await chatRoomRef.get()).data();

        if (!chatRoomData) return;

        const updates = {};
        let hasUpdates = false;

        // Check all typing fields
        Object.keys(chatRoomData).forEach((key) => {
          if (key.startsWith("typing_")) {
            const userId = key.replace("typing_", "");
            const timestampKey = `typingTimestamp_${userId}`;
            const timestamp = chatRoomData[timestampKey];

            if (timestamp) {
              const now = new Date();
              const typingTime = timestamp.toDate();
              const diffInSeconds = (now - typingTime) / 1000;

              // If typing status is older than 10 seconds, clear it
              if (diffInSeconds > 10) {
                updates[key] = false;
                hasUpdates = true;
              }
            }
          }
        });

        if (hasUpdates) {
          await chatRoomRef.update(updates);
          console.log(`🧹 Cleaned up stale typing status`);
        }
      } catch (error) {
        console.error(`❌ Error cleaning typing status: ${error.message}`);
      }
    },
);
