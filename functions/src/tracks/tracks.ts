import {
  onCall,
  CallableRequest,
  HttpsError,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { checkAuthentication, checkEventOwnership } from "../utils/auth-helpers";
import { validateTrackData, TrackData } from "../utils/validators";

const db = admin.firestore();

// Interface for track creation data
interface CreateTrackData extends TrackData {
  eventId: string;
  zoneId: string;
}

// Interface for track update data
interface UpdateTrackData {
  eventId: string;
  zoneId: string;
  trackId: string;
  data: Partial<TrackData>;
}

// Interface for track deletion data
interface DeleteTrackData {
  eventId: string;
  zoneId: string;
  trackId: string;
}


export const createTrack = onCall(
  async (
    request: CallableRequest<CreateTrackData>
  ): Promise<{ success: boolean; trackId: string; message: string }> => {
    const context = request.auth;
    const data = request.data;

    // Check authentication
    checkAuthentication(context);

    const { eventId, zoneId, ...trackData } = data;

    if (!eventId || !zoneId) {
      throw new HttpsError("invalid-argument", "Event ID and Zone ID are required");
    }

    // Validate track data
    const validationResult = validateTrackData(trackData);
    if (!validationResult.isValid) {
      throw new HttpsError("invalid-argument", validationResult.errors.join(", "));
    }

    try {
 
      const zoneDoc = await db
        .collection("events")
        .doc(eventId)
        .collection("zones")
        .doc(zoneId)
        .get();

      if (!zoneDoc.exists) {
        throw new HttpsError("not-found", "Zone not found");
      }

      // Create track document
      const trackRef = await db
        .collection("events")
        .doc(eventId)
        .collection("zones")
        .doc(zoneId)
        .collection("tracks")
        .add({
          ...trackData,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          createdBy: context!.uid,
        });

      console.log("Track created via backend");

      return {
        success: true,
        trackId: trackRef.id,
        message: "Track created successfully"
      };
    } catch (error) {
      console.error("Error creating track:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Failed to create track");
    }
  }
);


export const updateTrack = onCall(
  async (
    request: CallableRequest<UpdateTrackData>
  ): Promise<{ success: boolean; message: string }> => {
    const context = request.auth;
    const { eventId, zoneId, trackId, data } = request.data;

  
    checkAuthentication(context);

    if (!eventId || !zoneId || !trackId) {
      throw new HttpsError("invalid-argument", "Event ID, Zone ID, and Track ID are required");
    }

    try {
     
      await checkEventOwnership(context!.uid, eventId);

     
      const trackDoc = await db
        .collection("events")
        .doc(eventId)
        .collection("zones")
        .doc(zoneId)
        .collection("tracks")
        .doc(trackId)
        .get();

      if (!trackDoc.exists) {
        throw new HttpsError("not-found", "Track not found");
      }

      
      await db
        .collection("events")
        .doc(eventId)
        .collection("zones")
        .doc(zoneId)
        .collection("tracks")
        .doc(trackId)
        .update({
          ...data,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      console.log("Track updated via backend");

      return {
        success: true,
        message: "Track updated successfully"
      };
    } catch (error) {
      console.error("Error updating track:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Failed to update track");
    }
  }
);

export const deleteTrack = onCall(
  async (
    request: CallableRequest<DeleteTrackData>
  ): Promise<{ success: boolean; message: string }> => {
    const context = request.auth;
    const { eventId, zoneId, trackId } = request.data;

    // Check authentication
    checkAuthentication(context);

    if (!eventId || !zoneId || !trackId) {
      throw new HttpsError("invalid-argument", "Event ID, Zone ID, and Track ID are required");
    }

    try {
     
      await checkEventOwnership(context!.uid, eventId);

      // Check if track exists
      const trackDoc = await db
        .collection("events")
        .doc(eventId)
        .collection("zones")
        .doc(zoneId)
        .collection("tracks")
        .doc(trackId)
        .get();

      if (!trackDoc.exists) {
        throw new HttpsError("not-found", "Track not found");
      }

      const sessionsSnapshot = await db
        .collection("events")
        .doc(eventId)
        .collection("zones")
        .doc(zoneId)
        .collection("tracks")
        .doc(trackId)
        .collection("sessions")
        .limit(1)
        .get();

      if (!sessionsSnapshot.empty) {
        throw new HttpsError(
          "failed-precondition", 
          "Cannot delete track with existing sessions. Delete sessions first."
        );
      }

      // Check if track has stalls
      const stallsSnapshot = await db
        .collection("events")
        .doc(eventId)
        .collection("zones")
        .doc(zoneId)
        .collection("tracks")
        .doc(trackId)
        .collection("stalls")
        .limit(1)
        .get();

      if (!stallsSnapshot.empty) {
        throw new HttpsError(
          "failed-precondition", 
          "Cannot delete track with existing stalls. Delete stalls first."
        );
      }

      // Delete track document
      await db
        .collection("events")
        .doc(eventId)
        .collection("zones")
        .doc(zoneId)
        .collection("tracks")
        .doc(trackId)
        .delete();

      console.log("Track deleted via backend");

      return {
        success: true,
        message: "Track deleted successfully"
      };
    } catch (error) {
      console.error("Error deleting track:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Failed to delete track");
    }
  }
);


export const getZoneTracks = onCall(
  async (
    request: CallableRequest<{ eventId: string; zoneId: string }>
  ): Promise<{ success: boolean; tracks: any[]; message: string }> => {
    const context = request.auth;
    const { eventId, zoneId } = request.data;

    // Check authentication
    checkAuthentication(context);

    if (!eventId || !zoneId) {
      throw new HttpsError("invalid-argument", "Event ID and Zone ID are required");
    }

    try {
      // Check event access
      const eventDoc = await db.collection("events").doc(eventId).get();
      
      if (!eventDoc.exists) {
        throw new HttpsError("not-found", "Event not found");
      }

      const eventData = eventDoc.data();
      
     
      if (eventData?.createdBy !== context!.uid && eventData?.status !== 'published') {
        throw new HttpsError("permission-denied", "Access denied to this event");
      }

    
      const zoneDoc = await db
        .collection("events")
        .doc(eventId)
        .collection("zones")
        .doc(zoneId)
        .get();

      if (!zoneDoc.exists) {
        throw new HttpsError("not-found", "Zone not found");
      }

      const tracksSnapshot = await db
        .collection("events")
        .doc(eventId)
        .collection("zones")
        .doc(zoneId)
        .collection("tracks")
        .orderBy("createdAt", "asc")
        .get();

      const tracks = tracksSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      return {
        success: true,
        tracks,
        message: "Tracks retrieved successfully"
      };
    } catch (error) {
      console.error("Error getting zone tracks:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Failed to get tracks");
    }
  }
);


export const reorderTracks = onCall(
  async (
    request: CallableRequest<{ 
      eventId: string; 
      zoneId: string; 
      trackIds: string[] 
    }>
  ): Promise<{ success: boolean; message: string }> => {
    const context = request.auth;
    const { eventId, zoneId, trackIds } = request.data;

    // Check authentication
    checkAuthentication(context);

    if (!eventId || !zoneId || !Array.isArray(trackIds)) {
      throw new HttpsError("invalid-argument", "Event ID, Zone ID, and track IDs array are required");
    }

    try {
      // Check event ownership
      await checkEventOwnership(context!.uid, eventId);

      const batch = db.batch();
      
      trackIds.forEach((trackId, index) => {
        const trackRef = db
          .collection("events")
          .doc(eventId)
          .collection("zones")
          .doc(zoneId)
          .collection("tracks")
          .doc(trackId);
        
        batch.update(trackRef, {
          order: index,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      await batch.commit();

      return {
        success: true,
        message: "Tracks reordered successfully"
      };
    } catch (error) {
      console.error("Error reordering tracks:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Failed to reorder tracks");
    }
  }
);
