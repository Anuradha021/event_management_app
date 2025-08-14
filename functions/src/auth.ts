import * as admin from 'firebase-admin';
import { Request, Response, NextFunction, Express } from 'express';
import { UserRole, UserClaims } from './models';

const auth = admin.auth();
const firestore = admin.firestore();

// Extend Express Request type
declare global {
  namespace Express {
    interface Request {
      user?: {
        uid: string;
        email: string;
        claims: UserClaims;
      };
    }
  }
}

export const verifyRole = (requiredRoles: UserRole[]) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const authToken = req.headers.authorization?.split('Bearer ')[1];
      if (!authToken) {
        throw new Error('No authorization token provided');
      }

      const decodedToken = await auth.verifyIdToken(authToken);
      const user = await auth.getUser(decodedToken.uid);
      const claims = user.customClaims as UserClaims || {};

      const hasRole = requiredRoles.some(role => 
        claims.roles?.includes(role) || 
        (role === UserRole.ADMIN && claims.admin) ||
        (role === UserRole.ORGANIZER && claims.organizer)
      );

      if (!hasRole) {
        throw new Error('Insufficient permissions');
      }

      req.user = {
        uid: user.uid,
        email: user.email || '',
        claims
      };

      next();
    } catch (error) {
      console.error('Authorization error:', error);
      res.status(403).json({ 
        success: false, 
        error: 'Unauthorized' 
      });
    }
  };
};

export const setUserRole = async (req: Request, res: Response) => {
  try {
    const { userId, role } = req.body;
    
    if (!userId || !role) {
      return res.status(400).json({ 
        success: false, 
        error: 'Missing required fields' 
      });
    }

    const user = await auth.getUser(userId);
    const currentClaims = (user.customClaims || {}) as UserClaims;

    const newClaims: UserClaims = {
      ...currentClaims,
      roles: [...new Set([...(currentClaims.roles || []), role as UserRole])]
    };

    if (role === UserRole.ADMIN) newClaims.admin = true;
    if (role === UserRole.ORGANIZER) newClaims.organizer = true;

    await auth.setCustomUserClaims(userId, newClaims);

    await firestore.collection('users').doc(userId).set({
      roles: newClaims.roles,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    return res.json({ 
      success: true, 
      message: `User role updated to ${role}` 
    });
  } catch (error) {
    console.error('Error setting user role:', error);
    return res.status(500).json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    });
  }
};

export const setupAuthRoutes = (app: Express) => {
  app.post('/auth/set-role', verifyRole([UserRole.ADMIN]), setUserRole);
};