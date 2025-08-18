
import * as admin from "firebase-admin";
import { HttpsError } from "firebase-functions/v1/https";

const db = admin.firestore();

interface PublishEventData {
  eventId: string;
}

export const publishEvent = async (data: PublishEventData, context: any) => {
  
  if (!context.auth) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }

  const { eventId } = data;
  if (!eventId) {
    throw new HttpsError("invalid-argument", "eventId is required");
  }

  
  await verifyOrganizerOrAdmin(context.auth.uid, eventId);

 
  await validateEventStructure(eventId);

  // Update event status
  await db.collection("events").doc(eventId).update({
    status: "published",
    publishedAt: admin.firestore.FieldValue.serverTimestamp()
  });

  return {
    success: true,
    message: "Event published successfully"
  };
};

const validateEventStructure = async (eventId: string) => {
  const eventRef = db.collection("events").doc(eventId);
  const zonesRef = eventRef.collection("zones");

  const [eventDoc, zonesSnapshot] = await Promise.all([
    eventRef.get(),
    zonesRef.get()
  ]);

  if (!eventDoc.exists) {
    throw new HttpsError("not-found", "Event not found");
  }

  // Check if event is already published
  if (eventDoc.data()?.status === "published") {
    throw new HttpsError("failed-precondition", "Event is already published");
  }

  // Minimum requirements validation
  if (zonesSnapshot.empty) {
    throw new HttpsError(
      "failed-precondition",
      "Event must have at least one zone before publishing"
    );
  }

  // Check each zone has at least one track
  const zonesValidation = zonesSnapshot.docs.map(async zoneDoc => {
    const tracksSnapshot = await zoneDoc.ref.collection("tracks").get();
    if (tracksSnapshot.empty) {
      throw new HttpsError(
        "failed-precondition",
        `Zone ${zoneDoc.id} must have at least one track`
      );
    }
  });

  await Promise.all(zonesValidation);
};

const verifyOrganizerOrAdmin = async (uid: string, eventId: string) => {
  const user = await admin.auth().getUser(uid);
  
  // Admins can do anything
  if (user.customClaims?.admin) return true;

  // Check if user is the organizer for this event
  const eventDoc = await db.collection("events").doc(eventId).get();
  if (!eventDoc.exists) {
    throw new HttpsError("not-found", "Event not found");
  }

  if (eventDoc.data()?.organizerUid !== uid) {
    throw new HttpsError(
      "permission-denied",
      "Only the event organizer can perform this action"
    );
  }

  return true;
};