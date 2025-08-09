# Backend Server Setup for Event Management App

## Overview
This backend server handles the event approval process, creating events in the Firebase `events` collection when admin approves event requests.

## Prerequisites
- Node.js (v14 or higher)
- Firebase project with Admin SDK access
- Firebase service account key (optional, can use default credentials)

## Setup Instructions

### 1. Install Dependencies
```bash
# Copy the server-package.json to package.json
cp server-package.json package.json

# Install dependencies
npm install
```

### 2. Firebase Configuration
You have two options for Firebase authentication:

#### Option A: Use Application Default Credentials (Recommended for development)
If you have Firebase CLI installed and are logged in:
```bash
firebase login
```

#### Option B: Use Service Account Key
1. Go to Firebase Console > Project Settings > Service Accounts
2. Generate a new private key
3. Save the JSON file as `firebase-service-account.json` in the project root
4. Update `server.js` to use the service account:

```javascript
admin.initializeApp({
  credential: admin.credential.cert('./firebase-service-account.json'),
  projectId: 'your-project-id'
});
```

### 3. Update Project ID
Edit `server.js` and add your Firebase project ID:
```javascript
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId: 'your-firebase-project-id' // Replace with your actual project ID
});
```

### 4. Start the Server
```bash
# For development (with auto-restart)
npm run dev

# For production
npm start
```

The server will start on `http://localhost:3000`

## API Endpoints

### POST /approve-event
Approves an event request and creates it in the events collection.

**Request Body:**
```json
{
  "docId": "event_request_document_id"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Event approved successfully",
  "eventId": "new_event_document_id"
}
```

### POST /reject-event
Rejects an event request.

**Request Body:**
```json
{
  "docId": "event_request_document_id"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Event rejected successfully"
}
```

### GET /health
Health check endpoint.

**Response:**
```json
{
  "status": "Server is running"
}
```

## Data Flow

1. **Event Request Creation**: Users create event requests in `event_requests` collection
2. **Admin Approval**: Admin approves via Flutter app, which calls `/approve-event`
3. **Event Creation**: Server creates event in `events` collection with proper field mapping:
   - `eventTitle` → `title` (for consistency with other components)
   - `eventDescription` → `description`
   - Keeps original fields for backward compatibility
4. **Event Management**: Organizers can now access and manage the approved event

## Field Mapping
The server ensures compatibility between different field naming conventions:

- **event_requests collection**: `eventTitle`, `eventDescription`
- **events collection**: Both `title`/`description` AND `eventTitle`/`eventDescription`
- **Flutter screens**: Now check both field variations

## Troubleshooting

### Server won't start
- Check if port 3000 is available
- Verify Firebase credentials are properly configured
- Check console for error messages

### Events not appearing in Flutter app
- Verify the event was created in Firebase Console
- Check that the eventId is properly stored in the event_request document
- Ensure Flutter app is querying the correct collection

### Permission errors
- Verify Firebase Admin SDK has proper permissions
- Check that the service account has Firestore read/write access

## Development Notes
- The server includes CORS middleware for cross-origin requests
- All timestamps use Firebase server timestamps
- Error handling includes proper HTTP status codes
- Console logging for debugging purposes
