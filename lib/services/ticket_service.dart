import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ticket.dart';

class TicketService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== ORGANIZER FUNCTIONS ====================

  /// Create a new ticket type
  static Future<String> createTicketType({
    required String eventId,
    required String name,
    String description = '',
    required double price,
    required int totalQuantity,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final docRef = await _firestore.collection('ticketTypes').add({
        'eventId': eventId,
        'name': name,
        'description': description,
        'price': price,
        'totalQuantity': totalQuantity,
        'soldQuantity': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'organizerId': user.uid,
      });

      print("DEBUG: Created ticket type '$name' for eventId: $eventId");
      return docRef.id;
    } catch (e) {
      print("DEBUG ERROR in createTicketType: $e");
      rethrow;
    }
  }

  /// Get ticket types for organizer
  static Stream<List<TicketType>> getTicketTypesForOrganizer(String eventId) {
    print("DEBUG: Getting ticket types for organizer, eventId: $eventId");
    return _firestore
        .collection('ticketTypes')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      final ticketTypes =
          snapshot.docs.map((doc) => TicketType.fromFirestore(doc)).toList();
      ticketTypes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print(
          "DEBUG: Found ${ticketTypes.length} ticket types for eventId: $eventId");
      return ticketTypes;
    });
  }

  /// Update ticket type
  static Future<void> updateTicketType({
    required String ticketTypeId,
    required String name,
    required double price,
    required int totalQuantity,
  }) async {
    print("DEBUG: Updating ticketTypeId: $ticketTypeId");
    await _firestore.collection('ticketTypes').doc(ticketTypeId).update({
      'name': name,
      'price': price,
      'totalQuantity': totalQuantity,
    });
  }

  /// Delete ticket type
  static Future<void> deleteTicketType(String ticketTypeId) async {
    print("DEBUG: Deleting ticketTypeId: $ticketTypeId");
    await _firestore.collection('ticketTypes').doc(ticketTypeId).delete();
  }

  /// Get sold tickets for event
  static Stream<List<Ticket>> getTicketsForEvent(String eventId) {
    print("DEBUG: Fetching tickets for eventId: $eventId");

    return _firestore
        .collection('tickets')
        .where('eventId', isEqualTo: eventId)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) {
      print("DEBUG: Raw Firestore docs for eventId $eventId:");
      for (var doc in snapshot.docs) {
        print("  🔹 ${doc.id} => ${doc.data()}");
      }

      print(
          "DEBUG: Found ${snapshot.docs.length} tickets for eventId: $eventId");

      final tickets =
          snapshot.docs.map((doc) => Ticket.fromFirestore(doc)).toList();

      for (var ticket in tickets) {
        print(
            "DEBUG Ticket: ID=${ticket.id}, status=${ticket.status}, user=${ticket.userName}");
      }

      return tickets;
    });
  }

  /// Validate ticket
  static Future<ValidationResult> validateTicket(String qrCode) async {
    try {
      final ticketQuery = await _firestore
          .collection('tickets')
          .where('qrCode', isEqualTo: qrCode)
          .limit(1)
          .get();

      if (ticketQuery.docs.isEmpty) {
        print("DEBUG: Ticket not found for QR: $qrCode");
        return ValidationResult.invalid('Ticket not found');
      }

      final ticketDoc = ticketQuery.docs.first;
      final ticket = Ticket.fromFirestore(ticketDoc);

      if (ticket.status != 'active') {
        print("DEBUG: Ticket not active for QR: $qrCode");
        return ValidationResult.invalid('Ticket already used or cancelled');
      }

      await ticketDoc.reference.update({
        'status': 'used',
        'usedAt': FieldValue.serverTimestamp(),
      });

      print("DEBUG: Ticket validated successfully for QR: $qrCode");
      return ValidationResult.valid(ticket);
    } catch (e) {
      print("DEBUG ERROR in validateTicket: $e");
      return ValidationResult.invalid('Validation failed: ${e.toString()}');
    }
  }

  // ==================== USER FUNCTIONS ====================

  /// Get available tickets for users
  static Stream<List<TicketType>> getAvailableTicketTypes(String eventId) {
    print("DEBUG: Getting available tickets for eventId: $eventId");
    return _firestore
        .collection('ticketTypes')
        .where('eventId', isEqualTo: eventId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final ticketTypes = snapshot.docs
          .map((doc) => TicketType.fromFirestore(doc))
          .where((ticketType) => !ticketType.isSoldOut)
          .toList();
      ticketTypes.sort((a, b) => a.price.compareTo(b.price));

      print(
          "DEBUG: Found ${ticketTypes.length} available ticket types for eventId: $eventId");
      return ticketTypes;
    });
  }

  /// Purchase ticket (fixed soldQuantity update)
  static Future<PurchaseResult> purchaseTicket({
    required String ticketTypeId,
    required String eventId,
    required String eventTitle,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      print("DEBUG: Purchase failed - User not authenticated");
      return PurchaseResult.failure('User not authenticated');
    }

    print(
        "DEBUG: Starting ticket purchase for eventId: $eventId, ticketTypeId: $ticketTypeId");

    try {
      return await _firestore
          .runTransaction<PurchaseResult>((transaction) async {
        final ticketTypeRef =
            _firestore.collection('ticketTypes').doc(ticketTypeId);
        final ticketTypeDoc = await transaction.get(ticketTypeRef);

        if (!ticketTypeDoc.exists) {
          throw Exception('Ticket type not found');
        }

        final ticketType = TicketType.fromFirestore(ticketTypeDoc);

        if (ticketType.isSoldOut) {
          throw Exception('Tickets sold out');
        }

        final qrCode = _generateQRCode();

        final ticketRef = _firestore.collection('tickets').doc();
        transaction.set(ticketRef, {
          'eventId': eventId,
          'eventTitle': eventTitle,
          'ticketTypeId': ticketTypeId,
          'ticketTypeName': ticketType.name,
          'ticketTypeDescription': ticketType.description,
          'userId': user.uid,
          'userEmail': user.email ?? '',
          'userName': user.displayName ?? 'User',
          'userPhone': '',
          'price': ticketType.price,
          'qrCode': qrCode,
          'status': 'active',
          'purchaseDate': FieldValue.serverTimestamp(),
        });

        print(
            "DEBUG: Created ticket with ID=${ticketRef.id}, eventId=$eventId, qrCode=$qrCode");

        // Properly increment soldQuantity using transaction-safe approach
        final newSoldQuantity = ticketType.soldQuantity + 1;
        transaction.update(ticketTypeRef, {
          'soldQuantity': newSoldQuantity,
        });

        print(
            "DEBUG: Incremented soldQuantity to $newSoldQuantity for ticketTypeId: $ticketTypeId");

        return PurchaseResult.success(ticketRef.id, qrCode);
      });
    } catch (e) {
      print("DEBUG ERROR in purchaseTicket: $e");
      return PurchaseResult.failure(e.toString());
    }
  }

  /// Get user's tickets for event
  static Stream<List<Ticket>> getUserTicketsForEvent(String eventId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    print("DEBUG: Getting user tickets for eventId: $eventId");

    return _firestore
        .collection('tickets')
        .where('userId', isEqualTo: user.uid)
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      final tickets =
          snapshot.docs.map((doc) => Ticket.fromFirestore(doc)).toList();
      tickets.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

      print(
          "DEBUG: Found ${tickets.length} user tickets for eventId: $eventId");
      return tickets;
    });
  }

  /// Get all user's tickets
  static Stream<List<Ticket>> getUserTickets() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    print("DEBUG: Getting all tickets for current user");

    return _firestore
        .collection('tickets')
        .where('userId', isEqualTo: user.uid)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Ticket.fromFirestore(doc)).toList());
  }

  // ==================== HELPER FUNCTIONS ====================

  /// Generate QR code
  static String _generateQRCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'TKT_${timestamp}_$random';
  }

  /// Get event statistics
  static Future<Map<String, dynamic>> getEventStats(String eventId) async {
    print("DEBUG: Getting stats for eventId: $eventId");

    final ticketTypesSnapshot = await _firestore
        .collection('ticketTypes')
        .where('eventId', isEqualTo: eventId)
        .get();

    final ticketsSnapshot = await _firestore
        .collection('tickets')
        .where('eventId', isEqualTo: eventId)
        .get();

    int totalCapacity = 0;
    int totalSold = 0;
    double totalRevenue = 0;
    int totalUsed = 0;

    for (final doc in ticketTypesSnapshot.docs) {
      final ticketType = TicketType.fromFirestore(doc);
      totalCapacity += ticketType.totalQuantity;
      totalSold += ticketType.soldQuantity;
    }

    for (final doc in ticketsSnapshot.docs) {
      final ticket = Ticket.fromFirestore(doc);
      totalRevenue += ticket.price;
      if (ticket.isUsed) totalUsed++;
    }

    print(
        "DEBUG: Stats - Capacity=$totalCapacity, Sold=$totalSold, Revenue=$totalRevenue, Used=$totalUsed");

    return {
      'totalCapacity': totalCapacity,
      'totalSold': totalSold,
      'totalRevenue': totalRevenue,
      'totalUsed': totalUsed,
      'availableTickets': totalCapacity - totalSold,
    };
  }
}
