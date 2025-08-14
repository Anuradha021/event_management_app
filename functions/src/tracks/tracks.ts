import * as admin from 'firebase-admin';
import { Request, Response } from 'express';
import { CreateTrackData } from '../models';

const db = admin.firestore();

export const createTrack = async (req: Request, res: Response): Promise<void> => {
  try {
    if (!req.user) {
      res.status(403).json({ success: false, error: 'Unauthorized' });
      return;
    }

    const trackData: CreateTrackData = req.body;

    if (!trackData.eventId || !trackData.zoneId || !trackData.title) {
      res.status(400).json({ 
        success: false, 
        error: 'Missing required fields' 
      });
      return;
    }

    const trackRef = await db.collection('tracks').add({
      ...trackData,
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: req.user.uid
    });

    res.status(201).json({
      success: true,
      data: { trackId: trackRef.id }
    });
  } catch (error) {
    console.error('Error creating track:', error);
    res.status(500).json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    });
  }
};

