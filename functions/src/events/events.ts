import {
  onCall,
  CallableRequest,
  HttpsError,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { checkAuthentication, checkAuthorization } from "../utils/auth-helpers";
import { validateEventData, EventData } from "../utils/validators";

const db = admin.firestore();

// Interface for event creation data
interface CreateEventData extends EventData {
  organizerId: string;
}

// Interface for event update data
interface UpdateEventData {
  eventId: string;
  data: Partial<EventData>;
}

// Interface for event deletion data
interface DeleteEventData {
  eventId: string;
}


export const createEvent = onCall(
  async (
    request: CallableRequest<CreateEventData>
  ): Promise<{ success: boolean; eventId: string; message: string }> => {
    const context = request.auth;
    const data = request.data;

    // Check authentication
    checkAuthentication(context);

    // Validate input data
    const validationResult = validateEventData(data);
    if (!validationResult.isValid) {
      throw new HttpsError("invalid-argument", validationResult.errors.join(", "));
    }

    try {
      
      await checkAuthorization(context!.uid, ['organizer', 'admin']);

      // Create event document
      const eventRef = await db.collection("events").add({
        ...data,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'draft',
        createdBy: context!.uid,
      });

      console.log("Event created via backend");

      return {
        success: true,
        eventId: eventRef.id,
        message: "Event created successfully"
      };
    } catch (error) {
      console.error("Error creating event:", error);
      throw new HttpsError("internal", "Failed to create event");
    }
  }
);


export const updateEvent = onCall(
  async (
    request: CallableRequest<UpdateEventData>
  ): Promise<{ success: boolean; message: string }> => {
    const context = request.auth;
    const { eventId, data } = request.data;

    // Check authentication
    checkAuthentication(context);

    if (!eventId) {
      throw new HttpsError("invalid-argument", "Event ID is required");
    }

    try {
  
      const eventDoc = await db.collection("events").doc(eventId).get();
      
      if (!eventDoc.exists) {
        throw new HttpsError("not-found", "Event not found");
      }

      const eventData = eventDoc.data();
      
      // Check if user owns the event or is admin
      if (eventData?.createdBy !== context!.uid) {
        await checkAuthorization(context!.uid, ['admin']);
      }

      // Update event document
      await db.collection("events").doc(eventId).update({
        ...data,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("Event updated via backend");

      return {
        success: true,
        message: "Event updated successfully"
      };
    } catch (error) {
      console.error("Error updating event:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Failed to update event");
    }
  }
);

export const deleteEvent = onCall(
  async (
    request: CallableRequest<DeleteEventData>
  ): Promise<{ success: boolean; message: string }> => {
    const context = request.auth;
    const { eventId } = request.data;

    // Check authentication
    checkAuthentication(context);

    if (!eventId) {
      throw new HttpsError("invalid-argument", "Event ID is required");
    }

    try {
     
      const eventDoc = await db.collection("events").doc(eventId).get();
      
      if (!eventDoc.exists) {
        throw new HttpsError("not-found", "Event not found");
      }

      const eventData = eventDoc.data();
      
    
      if (eventData?.createdBy !== context!.uid) {
        await checkAuthorization(context!.uid, ['admin']);
      }

   
      await db.collection("events").doc(eventId).update({
        isDeleted: true,
        deletedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("Event deleted via backend");

      return {
        success: true,
        message: "Event deleted successfully"
      };
    } catch (error) {
      console.error("Error deleting event:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Failed to delete event");
    }
  }
);


export const getOrganizerEvents = onCall(
  async (
    request: CallableRequest<{ organizerId?: string }>
  ): Promise<{ success: boolean; events: any[]; message: string }> => {
    const context = request.auth;
    const { organizerId } = request.data;

    // Check authentication
    checkAuthentication(context);

    try {
      const targetOrganizerId = organizerId || context!.uid;
      
      // Check if user can access these events
      if (targetOrganizerId !== context!.uid) {
        await checkAuthorization(context!.uid, ['admin']);
      }

      // Get events for the organizer
      const eventsSnapshot = await db
        .collection("events")
        .where("createdBy", "==", targetOrganizerId)
        .where("isDeleted", "==", false)
        .orderBy("createdAt", "desc")
        .get();

      const events = eventsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      return {
        success: true,
        events,
        message: "Events retrieved successfully"
      };
    } catch (error) {
      console.error("Error getting organizer events:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Failed to get events");
    }
  }
);


export const publishEvent = onCall(
  async (
    request: CallableRequest<{ eventId: string }>
  ): Promise<{ success: boolean; message: string }> => {
    const context = request.auth;
    const { eventId } = request.data;

    // Check authentication
    checkAuthentication(context);

    if (!eventId) {
      throw new HttpsError("invalid-argument", "Event ID is required");
    }

    try {

      const eventDoc = await db.collection("events").doc(eventId).get();
      
      if (!eventDoc.exists) {
        throw new HttpsError("not-found", "Event not found");
      }

      const eventData = eventDoc.data();
      
    
      if (eventData?.createdBy !== context!.uid) {
        await checkAuthorization(context!.uid, ['admin']);
      }

    
      if (eventData?.status !== 'draft') {
        throw new HttpsError("failed-precondition", "Event is not in draft status");
      }

      
      await db.collection("events").doc(eventId).update({
        status: 'published',
        publishedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        message: "Event published successfully"
      };
    } catch (error) {
      console.error("Error publishing event:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Failed to publish event");
    }
  }
);
