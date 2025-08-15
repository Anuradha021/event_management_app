# Simple Ticket Management System

## 🎯 Overview

A clean, simple ticket management system for both organizer and user dashboards with essential features:

- **Organizer**: Create, manage, and validate tickets
- **User**: Browse and purchase tickets, view QR codes
- **Real-time**: Live updates with Firestore
- **Secure**: Role-based access control

## 📁 Files Created

### Models & Services
- `lib/models/ticket.dart` - Clean ticket models
- `lib/services/ticket_service.dart` - All ticket operations

### UI Screens
- `lib/screens/organizer_tickets_screen.dart` - Organizer interface
- `lib/screens/user_tickets_screen.dart` - User interface

### Security
- `firestore_ticket_rules.rules` - Firestore security rules

## 🚀 Quick Setup

### 1. Add Dependencies

```yaml
dependencies:
  cloud_firestore: ^4.13.0
  firebase_auth: ^4.15.0
  qr_flutter: ^4.1.0
```

### 2. Deploy Security Rules

```bash
# Copy rules to your firestore.rules file
cp firestore_ticket_rules.rules firestore.rules

# Deploy to Firebase
firebase deploy --only firestore:rules
```

### 3. Integration

#### For Organizer Dashboard
Add this button to your event management screen:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrganizerTicketsScreen(
          eventId: widget.eventId,
          eventTitle: widget.eventTitle,
        ),
      ),
    );
  },
  child: const Text('Manage Tickets'),
)
```

#### For User Dashboard
Add this button to your event detail screen:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserTicketsScreen(
          eventId: widget.eventId,
          eventTitle: widget.eventTitle,
        ),
      ),
    );
  },
  child: const Text('View Tickets'),
)
```

## 🎛️ Features

### Organizer Features
- **Create Ticket Types**: Name, price, quantity
- **Edit/Delete**: Manage ticket types
- **View Sales**: See all sold tickets
- **Validate Tickets**: QR code validation
- **Real-time Stats**: Live sales tracking

### User Features
- **Browse Tickets**: Available ticket types
- **Purchase**: One-click buying
- **My Tickets**: View purchased tickets
- **QR Codes**: Display for entry
- **Real-time**: Live availability

## 📊 Data Structure

### Firestore Collections

#### `ticketTypes`
```json
{
  "eventId": "string",
  "name": "string",
  "price": "number",
  "totalQuantity": "number",
  "soldQuantity": "number",
  "isActive": "boolean",
  "createdAt": "timestamp"
}
```

#### `tickets`
```json
{
  "eventId": "string",
  "ticketTypeId": "string",
  "ticketTypeName": "string",
  "userId": "string",
  "userEmail": "string",
  "userName": "string",
  "price": "number",
  "qrCode": "string",
  "status": "string",
  "purchaseDate": "timestamp",
  "usedAt": "timestamp"
}
```

## 🔒 Security

- **Role-based Access**: Organizers manage, users purchase
- **Atomic Operations**: Prevents over-selling
- **QR Validation**: Unique codes for each ticket
- **Data Protection**: Secure Firestore rules

## 💡 Usage Flow

### Organizer Workflow
1. Open event → Manage Tickets
2. Create ticket types (name, price, quantity)
3. Monitor sales in real-time
4. Validate tickets at event entrance

### User Workflow
1. Open event → View Tickets
2. Browse available ticket types
3. Purchase tickets with confirmation
4. Show QR code at event entrance

## 🎨 Customization

### Colors
Uses `AppTheme.primaryColor` - update your theme to match your app.

### UI Elements
- Cards for ticket displays
- Tabs for organization
- Dialogs for confirmations
- SnackBars for feedback

### Business Logic
- Modify `TicketService` for custom rules
- Update models for additional fields
- Extend UI for more features

## 🐛 Troubleshooting

### Common Issues

1. **Permission Denied**
   - Deploy Firestore rules
   - Check user authentication
   - Verify role assignment

2. **QR Code Issues**
   - Add `qr_flutter` dependency
   - Check ticket data loading
   - Verify QR code generation

3. **Purchase Fails**
   - Check ticket availability
   - Verify user authentication
   - Monitor Firestore connection

## 🚀 Next Steps

This simple system can be extended with:
- Payment integration
- Email notifications
- Advanced analytics
- Bulk operations
- Camera QR scanning

The system is clean, simple, and ready to use immediately!
