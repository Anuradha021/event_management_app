
import * as admin from 'firebase-admin';
import { Request, Response, Express } from 'express';
import { 
  //Event, 
  EventStatus, 
  CreateEventRequestData, 
//   UpdateEventStatusData,
//   CreateZoneData,
//   CreateTrackData,
//   CreateSessionData,
  ApiResponse,
  UserRole
} from './models';
import { verifyRole } from './auth';

const firestore = admin.firestore();

// Extend Express Request type
declare global {
  namespace Express {
    interface Request {
      user?: {
        uid: string;
        email: string;
        claims: {
          admin?: boolean;
          organizer?: boolean;
          roles?: UserRole[];
        };
      };
    }
  }
}

const validateEventData = (data: CreateEventRequestData): ApiResponse => {
  if (!data.eventTitle || !data.eventDescription || !data.eventDate || !data.location) {
    return {
      success: false,
      error: 'Missing required fields'
    };
  }
  return { success: true };
};

export const submitEventRequest = async (req: Request, res: Response) => {
  try {
    if (!req.user) {
      return res.status(403).json({ success: false, error: 'Unauthorized' });
    }

    const eventData: CreateEventRequestData = req.body;
    const validation = validateEventData(eventData);
    
    if (!validation.success) {
      return res.status(400).json(validation);
    }

    const eventRef = await firestore.collection('events').add({
      ...eventData,
      organizerUid: req.user.uid,
      status: EventStatus.PENDING_APPROVAL,
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return res.json({
      success: true,
      data: { eventId: eventRef.id }
    });
  } catch (error) {
    console.error('Error submitting event request:', error);
    return res.status(500).json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    });
  }
};

export const setupEventRoutes = (app: Express) => {
  app.post('/events/submit', verifyRole([UserRole.ORGANIZER]), submitEventRequest);
 
};