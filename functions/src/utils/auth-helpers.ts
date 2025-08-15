import { AuthData } from "firebase-functions/v2/https";
import { HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

const db = admin.firestore();


export function checkAuthentication(context: AuthData | undefined): asserts context is AuthData {
  if (!context) {
    throw new HttpsError("unauthenticated", "User not authenticated");
  }
}


export async function checkAuthorization(uid: string, requiredRoles: string[]): Promise<void> {
  try {
    const user = await admin.auth().getUser(uid);
    const userRoles = user.customClaims?.roles || [];
    const isAdmin = user.customClaims?.admin === true;

    // Admin has access to everything
    if (isAdmin) {
      return;
    }

    // Check if user has any of the required roles
    const hasRequiredRole = requiredRoles.some(role => 
      userRoles.includes(role) || (role === 'admin' && isAdmin)
    );

    if (!hasRequiredRole) {
      throw new HttpsError(
        "permission-denied",
        `User does not have required role. Required: ${requiredRoles.join(' or ')}`
      );
    }
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", "Failed to check user authorization");
  }
}


export async function checkAdmin(uid: string): Promise<void> {
  try {
    const user = await admin.auth().getUser(uid);
    if (!user.customClaims?.admin) {
      throw new HttpsError(
        "permission-denied",
        "Only admin can perform this action"
      );
    }
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", "Failed to check admin status");
  }
}


export async function checkEventOwnership(uid: string, eventId: string): Promise<void> {
  try {
    const eventDoc = await db.collection("events").doc(eventId).get();
    
    if (!eventDoc.exists) {
      throw new HttpsError("not-found", "Event not found");
    }

    const eventData = eventDoc.data();
    
    // Check if user owns the event or is admin
    if (eventData?.createdBy !== uid) {
      await checkAdmin(uid);
    }
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", "Failed to check event ownership");
  }
}


export async function checkEventAccess(uid: string, eventId: string): Promise<void> {
  try {
    const eventDoc = await db.collection("events").doc(eventId).get();
    
    if (!eventDoc.exists) {
      throw new HttpsError("not-found", "Event not found");
    }

    const eventData = eventDoc.data();
    
    // Check if user owns the event, is admin, or event is published
    if (eventData?.createdBy !== uid && eventData?.status !== 'published') {
      await checkAdmin(uid);
    }
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", "Failed to check event access");
  }
}


export async function getUserRoles(uid: string): Promise<string[]> {
  try {
    const user = await admin.auth().getUser(uid);
    const roles = user.customClaims?.roles || [];
    
    // Add admin role if user is admin
    if (user.customClaims?.admin) {
      roles.push('admin');
    }
    
    return roles;
  } catch (error) {
    throw new HttpsError("internal", "Failed to get user roles");
  }
}


export async function setUserRoles(adminUid: string, targetUid: string, roles: string[]): Promise<void> {
  try {
    // Check if the requesting user is admin
    await checkAdmin(adminUid);

    // Get current custom claims
    const user = await admin.auth().getUser(targetUid);
    const currentClaims = user.customClaims || {};

  
    await admin.auth().setCustomUserClaims(targetUid, {
      ...currentClaims,
      roles: roles,
    });
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", "Failed to set user roles");
  }
}

/**
 * Check if user can perform action on resource
 * Generic permission checker
 */
export async function checkResourcePermission(
  uid: string,
  resourceType: 'event' | 'zone' | 'track' | 'session' | 'stall',
  resourceId: string,
  action: 'read' | 'write' | 'delete'
): Promise<boolean> {
  try {
    // Get user roles
    const roles = await getUserRoles(uid);
    
    // Admin can do everything
    if (roles.includes('admin')) {
      return true;
    }

    // For now, organizers can manage their own events and all sub-resources
    if (roles.includes('organizer')) {
      // For events, check direct ownership
      if (resourceType === 'event') {
        const eventDoc = await db.collection("events").doc(resourceId).get();
        return eventDoc.exists && eventDoc.data()?.createdBy === uid;
      }
      
     
      return true; // Simplified for now
    }

    // Default deny
    return false;
  } catch (error) {
    console.error("Error checking resource permission:", error);
    return false;
  }
}
