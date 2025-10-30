const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

// Initialize Firebase Admin
initializeApp();

// eslint-disable-next-line max-len
// Function to send push notification when a new notification document is created
exports.sendPushOnLike = onDocumentCreated(
    {
      document: "notifications/{notificationId}",
      region: "us-central1", // Explicitly set the region
    },
    async (event) => {
      const data = event.data.data();

      // Check if data and toUserId exist
      if (!data || !data.toUserId) {
        console.log("Missing data or toUserId");
        return;
      }

      try {
      // Get target user’s OneSignal ID
        const userDoc = await getFirestore()
            .collection("users")
            .doc(data.toUserId)
            .get();

        if (!userDoc.exists) {
          console.log(`User document ${data.toUserId} does not exist`);
          return;
        }

        const playerId = userDoc.data().oneSignalId;
        if (!playerId) {
          console.log(`No OneSignal ID found for user ${data.toUserId}`);
          return;
        }

        // Construct OneSignal notification payload
        const message = {
          // eslint-disable-next-line max-len
          app_id: "71fc2c4f-dd2d-4556-8d41-830298f312b7", // Replace with your actual OneSignal App ID
          include_player_ids: [playerId],
          headings: {en: "New Like ❤"},
          contents: {en: `${data.fromName} liked your post`},
          data: {postId: data.postId, type: "like"},
        };

        // Send notification via OneSignal API
        const response = await fetch("https://onesignal.com/api/v1/notifications", {
          method: "POST",
          headers: {
            "Content-Type": "application/json; charset=utf-8",
            // eslint-disable-next-line max-len
            "Authorization": "Basic 71fc2c4f-dd2d-4556-8d41-830298f312b7", // Replace with your REST API key
          },
          body: JSON.stringify(message),
        });

        if (!response.ok) {
          console.error(`Failed to send notification: ${response.statusText}`);
          return;
        }

        console.log("Notification sent successfully");
      } catch (error) {
        console.error("Error in sendPushOnLike:", error);
      }
    },
);
