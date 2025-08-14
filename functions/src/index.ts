
import * as admin from 'firebase-admin';

import { onRequest } from 'firebase-functions/v2/https';
import express from 'express';
import cors from 'cors';

// Initialize Firebase Admin
admin.initializeApp();


const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// Import route handlers
import { setupEventRoutes } from './events';
import { setupAuthRoutes } from './auth';


setupEventRoutes(app);
setupAuthRoutes(app);

// Expose Express app as Firebase Functions
export const api = onRequest(app);


export * from './auth';
export * from './events';