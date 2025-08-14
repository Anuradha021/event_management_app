// functions/src/admin/admin.service.ts
import * as admin from "firebase-admin";
import { HttpsError } from "firebase-functions/v1/https";

const db = admin.firestore();

interface OrganizerApprovalData {
  requestId: string;
  organizerUid: string;
  organizerEmail: string;
  eventId: string;
}

export const approveOrganizerRequest = async (data: OrganizerApprovalData, context: any) => {
  // Validate input
  if (!context.auth) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }

  const { requestId, organizerUid, organizerEmail, eventId } = data;
  if (!requestId || !organizerUid || !organizerEmail || !eventId) {
    throw new HttpsError("invalid-argument", "Missing required fields");
  }

  // Verify admin privileges
  await verifyAdmin(context.auth.uid);

  // Get the request document
  const requestRef = db.collection("event_requests").doc(requestId);
  const requestDoc = await requestRef.get();

  if (!requestDoc.exists) {
    throw new HttpsError("not-found", "Request not found");
  }

  
  await admin.auth().setCustomUserClaims(organizerUid, {
    organizer: true,
    organizerForEvent: eventId
  });

  // Update request status and create event document
  const batch = db.batch();

  batch.update(requestRef, {
    status: "approved",
    approvedAt: admin.firestore.FieldValue.serverTimestamp(),
    approvedBy: context.auth.uid,
    assignedOrganizerUid: organizerUid,
    assignedOrganizerEmail: organizerEmail
  });

  // Create the event document with initial structure
  const eventRef = db.collection("events").doc(eventId);
  batch.set(eventRef, {
    title: requestDoc.data()?.eventTitle,
    description: requestDoc.data()?.eventDescription,
    status: "draft",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: organizerUid,
    organizerUid,
    organizerEmail
  });

  await batch.commit();

  return {
    success: true,
    message: "Organizer approved and event created",
    eventId
  };
};

const verifyAdmin = async (uid: string) => {
  const user = await admin.auth().getUser(uid);
  if (!user.customClaims?.admin) {
    throw new HttpsError("permission-denied", "Admin privileges required");
  }
};