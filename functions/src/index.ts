import {
  onCall,
  CallableRequest,
  HttpsError,
  onRequest,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

// Utility to check if the user is admin
const checkAdmin = async (uid: string) => {
  const user = await admin.auth().getUser(uid);
  if (!user.customClaims?.admin) {
    throw new HttpsError(
      "permission-denied",
      "Only admin can perform this action",
    );
  }
};

interface UpdateStatusData {
  docId: string;
  status: string;
}

export const updateEventRequestStatus = onCall(
  async (
    request: CallableRequest<UpdateStatusData>,
  ): Promise<{ success: boolean; message: string }> => {
    const context = request.auth;
    const data = request.data;

    if (!context) {
      throw new HttpsError("unauthenticated", "User not authenticated");
    }

    const {docId, status} = data;
    if (!docId || !status) {
      throw new HttpsError("invalid-argument", "docId and status are required");
    }

    await checkAdmin(context.uid);

    await db.collection("event_requests").doc(docId).update({
      status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {success: true, message: `Status updated to ${status}`};
  },
);

interface AssignData {
  docId: string;
  organizerUid: string;
  organizerEmail: string;
}

export const assignOrganizerAndApprove = onCall(
  async (
    request: CallableRequest<AssignData>,
  ): Promise<{ success: boolean; message: string }> => {
    const context = request.auth;
    const data = request.data;

    if (!context) {
      throw new HttpsError("unauthenticated", "User not authenticated");
    }

    const {docId, organizerUid, organizerEmail} = data;
    if (!docId || !organizerUid || !organizerEmail) {
      throw new HttpsError("invalid-argument", "Missing required fields");
    }

    await checkAdmin(context.uid);

    await db.collection("event_requests").doc(docId).update({
      status: "approved",
      assignedOrganizerUid: organizerUid,
      assignedOrganizerEmail: organizerEmail,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      message: "Organizer assigned and request approved",
    };
  },
);

export const createDefaultAdmin = onRequest(async (req, res) => {
  const email = "admin@unite.com";
  const password = "admin123";

  try {
    const existing = await admin.auth().getUserByEmail(email);
    await admin.auth().setCustomUserClaims(existing.uid, {admin: true});
    return res.status(200).send("Admin already existed. Claims updated.");
  } catch (error) {
    try {
      const newUser = await admin.auth().createUser({
        email,
        password,
        displayName: "Default Admin",
      });
      await admin.auth().setCustomUserClaims(newUser.uid, {admin: true});
      return res.status(200).send("Admin created and claims assigned.");
    } catch (e) {
      return res.status(500).send(`Failed to create admin: ${e}`);
    }
  }
});
