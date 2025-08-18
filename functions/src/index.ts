import {
  onCall,
  CallableRequest,
  HttpsError,
  onRequest,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
admin.initializeApp();
const db = admin.firestore();


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
      return res.status(200).send("Admin created");
    } catch (e) {
      return res.status(500).send(`Failed to create admin: ${e}`);
    }
  }
});



// Health check function
export const healthCheck = onRequest(async (req, res) => {
  console.log(" Health check called from:", req.ip);
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    services: {
      events: 'active',
      zones: 'active',
      tracks: 'active',
      sessions: 'active',
      stalls: 'active',
    }
  });
});

// Test function to verify Cloud Functions are working
export const testCloudFunction = onCall(
  async (request: CallableRequest<{ message?: string }>) => {
    const userMessage = request.data?.message || "Hello from Flutter!";
    const userId = request.auth?.uid || "anonymous";

    console.log(" TEST FUNCTION CALLED!");
    console.log(" User ID:", userId);
    console.log(" Message:", userMessage);
    console.log(" Timestamp:", new Date().toISOString());

    return {
      success: true,
      message: `Cloud Function received: "${userMessage}"`,
      userId: userId,
      timestamp: new Date().toISOString(),
      source: "Firebase Cloud Functions"
    };
  }
);

// Super simple test - just return success without doing anything
export const superSimpleTest = onCall(
  async (request: CallableRequest<any>) => {
    console.log("SUPER SIMPLE TEST CALLED - NO DATABASE OPERATIONS");
    console.log(" Data received:", JSON.stringify(request.data));

    return {
      success: true,
      message: "Super simple test successful - no database operations performed",
      receivedData: request.data
    };
  }
);

// Simple zone creation test without authentication
export const testCreateZone = onCall(
  async (request: CallableRequest<{ eventId: string; title: string; description?: string }>) => {
    console.log(" Simple zone creation test called");
    console.log(" Request data:", JSON.stringify(request.data));
    console.log(" User auth:", request.auth?.uid || "No auth");

    try {
      const { eventId, title, description } = request.data;

      console.log(" Extracted data - eventId:", eventId, "title:", title, "description:", description);

      if (!eventId || !title) {
        console.error(" Missing required fields - eventId:", eventId, "title:", title);
        throw new Error("Missing required fields: eventId and title are required");
      }

      console.log("About to write to Firestore...");

      const zoneRef = await db.collection("events")
        .doc(eventId)
        .collection("zones")
        .add({
          title: title,
          description: description || '',
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          createdBy: request.auth?.uid || 'test-user',
        });

      console.log(" Zone created via backend (test function) - ID:", zoneRef.id);

      return {
        success: true,
        zoneId: zoneRef.id,
        message: "Zone created successfully via test function"
      };
    } catch (error) {
      console.error(" DETAILED ERROR in test zone creation:");
      console.error("Error type:", typeof error);
      console.error("Error message:", error instanceof Error ? error.message : String(error));
      console.error("Full error object:", error);

      throw new HttpsError("internal", `Zone creation failed: ${error instanceof Error ? error.message : String(error)}`);
    }
  }
);
