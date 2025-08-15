# Ticket System Testing Guide

## 🧪 How to Test the Complete Flow

### **Prerequisites**
1. Firebase project set up
2. Firestore enabled
3. Authentication enabled
4. Dependencies added to pubspec.yaml

### **Test Flow 1: Organizer Creates Tickets**

1. **Login as Organizer**
2. **Go to Organizer Dashboard**
3. **Select an Event**
4. **Click "Tickets" Tab** (5th tab)
5. **Click + Button**
6. **Create Ticket Type:**
   - Name: "General Admission"
   - Price: 25.00
   - Quantity: 100
7. **Click "Create"**
8. **Verify:** Ticket type appears in list

### **Test Flow 2: User Purchases Ticket**

1. **Login as User**
2. **Go to User Dashboard → Events**
3. **Click "View Tickets" on Event**
4. **Go to "Buy Tickets" Tab**
5. **Click "Buy Ticket" on General Admission**
6. **Confirm Purchase**
7. **Go to "My Tickets" Tab**
8. **Verify:** Ticket appears with QR code

### **Test Flow 3: QR Code Generation**

1. **In "My Tickets" Tab**
2. **Click "Show QR Code"**
3. **Verify:** QR code displays
4. **Note the QR Code:** (e.g., TKT_1703123456_123456)

### **Test Flow 4: Ticket Validation**

1. **Switch to Organizer Account**
2. **Go to Event → Tickets → "Validate" Tab**
3. **Enter QR Code from Step 3**
4. **Click "Validate Ticket"**
5. **Verify:** Success message shows ticket details
6. **Check "Sold Tickets" Tab**
7. **Verify:** Ticket status changed to "USED"

### **Test Flow 5: Real-time Updates**

1. **Open App on Two Devices/Browsers**
2. **Device 1:** Organizer viewing ticket types
3. **Device 2:** User purchasing tickets
4. **Purchase ticket on Device 2**
5. **Verify:** Device 1 shows updated sold count immediately

## 🔍 **Expected Results**

### **Organizer Dashboard:**
- ✅ Tickets tab visible in event management
- ✅ Can create ticket types
- ✅ Can edit/delete ticket types
- ✅ Can view sold tickets
- ✅ Can validate QR codes
- ✅ Real-time sales updates

### **User Dashboard:**
- ✅ "View Tickets" button on events
- ✅ Can see available ticket types
- ✅ Can purchase tickets
- ✅ Can view purchased tickets
- ✅ Can display QR codes

### **Database:**
- ✅ `ticketTypes` collection created
- ✅ `tickets` collection created
- ✅ Real-time updates working
- ✅ Atomic inventory management

## 🐛 **Troubleshooting**

### **Issue: Tickets tab not showing**
- **Solution:** Check import in event_management_screen.dart
- **Verify:** OrganizerTicketsScreen is imported

### **Issue: Permission denied**
- **Solution:** Deploy Firestore security rules
- **Command:** `firebase deploy --only firestore:rules`

### **Issue: QR code not displaying**
- **Solution:** Add qr_flutter dependency
- **Command:** `flutter pub get`

### **Issue: Purchase fails**
- **Solution:** Check user authentication
- **Verify:** User is logged in

### **Issue: Real-time updates not working**
- **Solution:** Check Firestore connection
- **Verify:** Internet connection active

## 📱 **UI Testing Checklist**

### **Organizer Interface:**
- [ ] Tickets tab appears in event management
- [ ] + button creates new ticket type
- [ ] Edit/Delete buttons work
- [ ] Sold tickets list shows purchases
- [ ] Validation tab accepts QR codes
- [ ] Success/error messages display

### **User Interface:**
- [ ] "View Tickets" button on event cards
- [ ] Available tickets display with prices
- [ ] "Buy Ticket" button works
- [ ] Purchase confirmation dialog
- [ ] "My Tickets" shows purchased tickets
- [ ] QR code dialog displays properly

## 🎯 **Success Criteria**

✅ **Complete Flow Working:**
1. Organizer creates ticket types ✅
2. Users browse and purchase tickets ✅
3. System generates unique QR codes ✅
4. Users show QR codes at event ✅
5. Organizer validates QR codes for entry ✅

✅ **Technical Requirements:**
- Real-time updates ✅
- Atomic operations ✅
- Secure access control ✅
- User-friendly interfaces ✅
- Error handling ✅

This testing guide ensures your ticket management system works exactly as requested!
