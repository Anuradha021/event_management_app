# Ticketing System - Complete Test Checklist

## 🧪 **Pre-Test Setup**

### **✅ Required Dependencies**
```yaml
dependencies:
  cloud_firestore: ^4.13.0
  firebase_auth: ^4.15.0
  qr_flutter: ^4.1.0
```

### **✅ Firebase Setup**
- [ ] Firebase project configured
- [ ] Firestore enabled
- [ ] Authentication enabled
- [ ] Security rules deployed

### **✅ User Accounts**
- [ ] Test organizer account created
- [ ] Test customer account created
- [ ] Both accounts can authenticate

## 🏢 **Organizer Journey Testing**

### **Step 1: Create Event (Existing Functionality)**
- [ ] Login as organizer
- [ ] Create a test event
- [ ] Set status to "published"
- [ ] Verify event appears in system

### **Step 2: Add Ticket Types**
- [ ] Go to Organizer Dashboard
- [ ] Select the test event
- [ ] Click "Tickets" tab (5th tab)
- [ ] Click + button
- [ ] Create "VIP" ticket type:
  - Name: "VIP"
  - Price: "100.00"
  - Quantity: "10"
- [ ] Click "Create Ticket Type"
- [ ] Verify success message appears
- [ ] Verify ticket type appears in list

### **Step 3: Create Multiple Ticket Types**
- [ ] Create "Regular" ticket type:
  - Name: "Regular"
  - Price: "50.00"
  - Quantity: "100"
- [ ] Create "Student" ticket type:
  - Name: "Student"
  - Price: "25.00"
  - Quantity: "50"
- [ ] Verify all 3 ticket types appear

### **Step 4: Monitor Sales (Initially Empty)**
- [ ] Click "Sold Tickets" tab
- [ ] Verify "No tickets sold yet" message
- [ ] Note the interface is ready for sales data

## 👤 **Customer Journey Testing**

### **Step 1: Browse Events**
- [ ] Login as customer
- [ ] Go to User Dashboard → Tickets tab
- [ ] Verify "Events & Tickets" screen appears
- [ ] Verify test event appears in list
- [ ] Verify "Buy Ticket" and "My Tickets" buttons visible

### **Step 2: Select Ticket**
- [ ] Click "Buy Ticket" on test event
- [ ] Verify `CustomerTicketPurchaseScreen` opens
- [ ] Verify event details display correctly
- [ ] Verify all 3 ticket types appear (VIP, Regular, Student)
- [ ] Verify prices and quantities display correctly

### **Step 3: Purchase Ticket**
- [ ] Click "Select Ticket" on VIP ticket
- [ ] Verify snackbar shows "Your ticket is purchased."
- [ ] Verify automatic redirect to ticket details screen
- [ ] Verify no payment processing occurred

### **Step 4: View Ticket Details**
- [ ] Verify `CustomerTicketDetailsScreen` displays
- [ ] Verify ticket details show:
  - Ticket type: "VIP"
  - Event title
  - Location
  - Date
  - Price: "$100.00"
  - Purchase date
  - Status: "ACTIVE"
- [ ] Verify QR code displays
- [ ] Verify QR code is unique
- [ ] Verify "Download as PDF" button appears

### **Step 5: Download PDF (Placeholder)**
- [ ] Click "Download as PDF"
- [ ] Verify snackbar shows "PDF download feature coming soon!"

## 🔄 **Real-Time Updates Testing**

### **Step 1: Organizer Sees Customer Purchase**
- [ ] Switch to organizer account
- [ ] Go to event → Tickets → "Sold Tickets" tab
- [ ] Verify customer's ticket appears
- [ ] Verify customer data displays:
  - Customer name
  - Customer email
  - Ticket type: "VIP"
  - Price: "$100.00"
  - QR code
  - Purchase date
  - Status: "ACTIVE"

### **Step 2: Inventory Updates**
- [ ] Go to "Ticket Types" tab
- [ ] Verify VIP ticket shows:
  - Sold: 1
  - Available: 9
  - Revenue: $100.00

### **Step 3: Multiple Purchases**
- [ ] Switch to customer account
- [ ] Purchase "Regular" ticket
- [ ] Purchase "Student" ticket
- [ ] Switch to organizer account
- [ ] Verify all 3 tickets appear in "Sold Tickets"
- [ ] Verify inventory updates correctly

## 🎫 **Ticket Validation Testing**

### **Step 1: Get QR Code**
- [ ] As customer, view ticket details
- [ ] Note the QR code (e.g., "TKT_1703123456_123456")

### **Step 2: Validate Ticket**
- [ ] Switch to organizer account
- [ ] Go to event → Tickets → "Validate" tab
- [ ] Enter the QR code
- [ ] Click "Validate Ticket"
- [ ] Verify success dialog shows ticket details
- [ ] Verify ticket status changes to "USED"

### **Step 3: Verify Used Status**
- [ ] Check "Sold Tickets" tab
- [ ] Verify ticket status shows "USED"
- [ ] Switch to customer account
- [ ] Verify ticket details show "USED" status
- [ ] Verify "Used At" timestamp appears

## 🚫 **Edge Cases Testing**

### **Test 1: Sold Out Tickets**
- [ ] As organizer, create ticket type with quantity 1
- [ ] As customer, purchase that ticket
- [ ] Verify ticket shows "Sold Out" for other customers
- [ ] Verify "Select Ticket" button is disabled

### **Test 2: No Ticket Types**
- [ ] Create event without any ticket types
- [ ] As customer, click "Buy Ticket"
- [ ] Verify "No tickets available" message appears

### **Test 3: Already Used Ticket**
- [ ] Try to validate the same QR code twice
- [ ] Verify error message appears
- [ ] Verify ticket remains "USED" status

## 📊 **Data Structure Verification**

### **Firestore Collections Check**
- [ ] Open Firebase Console → Firestore
- [ ] Verify `ticketTypes` collection exists
- [ ] Verify `tickets` collection exists
- [ ] Verify data structure matches documentation

### **Sample Data Verification**
```
ticketTypes/[doc-id]/
├── eventId: "your-event-id"
├── name: "VIP"
├── price: 100.0
├── totalQuantity: 10
├── soldQuantity: 1
├── isActive: true
└── organizerId: "organizer-uid"

tickets/[doc-id]/
├── eventId: "your-event-id"
├── eventTitle: "Test Event"
├── ticketTypeName: "VIP"
├── userId: "customer-uid"
├── price: 100.0
├── qrCode: "TKT_1703123456_123456"
├── status: "active" or "used"
└── purchaseDate: [timestamp]
```

## ✅ **Success Criteria**

### **Customer Journey Complete:**
- [x] Browse event → Select ticket → Checkout → Receive ticket → Present at event

### **Organizer Journey Complete:**
- [x] Create event → Add ticket types → Monitor sales → Validate tickets

### **Key Features Working:**
- [x] Dynamic ticket types (only organizer-defined types appear)
- [x] "Your ticket is purchased." snackbar message
- [x] Automatic redirect to ticket details
- [x] QR code generation and display
- [x] "Download as PDF" option (placeholder)
- [x] Real-time sales monitoring
- [x] Ticket validation system
- [x] Proper Firestore data structure

## 🎉 **Test Complete!**

If all checkboxes are marked, your complete ticketing system is working perfectly with separate optimized journeys for customers and organizers!
