const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Firebase Admin SDK
// Note: You'll need to add your Firebase service account key
// For now, using default credentials
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  // Add your Firebase project ID here
  // projectId: 'your-project-id'
});

const db = admin.firestore();

// Approve event endpoint
app.post('/approve-event', async (req, res) => {
  try {
    const { docId } = req.body;
    
    if (!docId) {
      return res.status(400).json({ error: 'docId is required' });
    }

    // Get the event request document
    const eventRequestRef = db.collection('event_requests').doc(docId);
    const eventRequestDoc = await eventRequestRef.get();
    
    if (!eventRequestDoc.exists) {
      return res.status(404).json({ error: 'Event request not found' });
    }

    const eventRequestData = eventRequestDoc.data();
    
    // Create the event in the events collection with proper field mapping
    const eventData = {
      // Map eventTitle -> title, eventDescription -> description for consistency
      title: eventRequestData.eventTitle || 'Untitled Event',
      description: eventRequestData.eventDescription || 'No description provided',
      
      // Keep original fields for backward compatibility
      eventTitle: eventRequestData.eventTitle,
      eventDescription: eventRequestData.eventDescription,
      
      // Copy other fields
      eventDate: eventRequestData.eventDate,
      location: eventRequestData.location,
      organizerEmail: eventRequestData.organizerEmail,
      organizerUid: eventRequestData.organizerUid,
      organizerName: eventRequestData.organizerName,
      category: eventRequestData.category,
      
      // Set status and timestamps
      status: 'approved',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Create the event document
    const eventRef = await db.collection('events').add(eventData);
    
    // Update the event request status
    await eventRequestRef.update({
      status: 'approved',
      eventId: eventRef.id,
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Event approved and created with ID: ${eventRef.id}`);
    res.status(200).json({ 
      success: true, 
      message: 'Event approved successfully',
      eventId: eventRef.id 
    });

  } catch (error) {
    console.error('Error approving event:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Reject event endpoint
app.post('/reject-event', async (req, res) => {
  try {
    const { docId } = req.body;
    
    if (!docId) {
      return res.status(400).json({ error: 'docId is required' });
    }

    // Update the event request status to rejected
    const eventRequestRef = db.collection('event_requests').doc(docId);
    await eventRequestRef.update({
      status: 'rejected',
      rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Event request ${docId} rejected`);
    res.status(200).json({ 
      success: true, 
      message: 'Event rejected successfully' 
    });

  } catch (error) {
    console.error('Error rejecting event:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'Server is running' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Backend server running on http://localhost:${PORT}`);
  console.log('Available endpoints:');
  console.log('  POST /approve-event - Approve an event request');
  console.log('  POST /reject-event - Reject an event request');
  console.log('  GET /health - Health check');
});

module.exports = app;
