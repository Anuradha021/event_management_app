import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import '../models/ticket_model.dart';

class TicketService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  static CollectionReference get _ticketsCollection => _firestore.collection('tickets');
  static CollectionReference get _ticketConfigsCollection => _firestore.collection('ticketConfigs');
  static CollectionReference get _eventsCollection => _firestore.collection('events');

  /// Generate unique QR code data for ticket
  static String generateQRCode(String ticketId, String userId, String eventId, String ticketType) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    final data = {
      'ticketId': ticketId,
      'userId': userId,
      'eventId': eventId,
      'ticketType': ticketType,
      'timestamp': timestamp,
      'random': random,
    };
    
    // Create a hash for security
    final jsonData = jsonEncode(data);
    final bytes = utf8.encode(jsonData);
    final hash = sha256.convert(bytes);
    
    return base64Encode(utf8.encode(jsonData + hash.toString()));
  }

  /// Verify QR code data
  static Map<String, dynamic>? verifyQRCode(String qrCode) {
    try {
      final decoded = utf8.decode(base64Decode(qrCode));
      // Extract JSON part (before hash)
      final jsonPart = decoded.substring(0, decoded.length - 64); // SHA256 hash is 64 chars
      final data = jsonDecode(jsonPart) as Map<String, dynamic>;
      return data;
    } catch (e) {
      return null;
    }
  }

  /// Create ticket configuration for an event
  static Future<void> createTicketConfig(TicketConfig config) async {
    await _ticketConfigsCollection.doc(config.eventId).set(config.toFirestore());
  }

  /// Get ticket configuration for an event
  static Future<TicketConfig?> getTicketConfig(String eventId) async {
    final doc = await _ticketConfigsCollection.doc(eventId).get();
    if (doc.exists) {
      return TicketConfig.fromFirestore(doc);
    }
    return null;
  }

  /// Update ticket configuration
  static Future<void> updateTicketConfig(TicketConfig config) async {
    await _ticketConfigsCollection.doc(config.eventId).update(config.toFirestore());
  }

  /// Purchase a ticket
  static Future<String?> purchaseTicket({
    required String eventId,
    required String userId,
    required String userName,
    required String userEmail,
    required String ticketType,
    required double price,
  }) async {
    try {
      // Start a transaction to ensure data consistency
      return await _firestore.runTransaction<String?>((transaction) async {
        // Get current ticket config
        final configDoc = await transaction.get(_ticketConfigsCollection.doc(eventId));
        if (!configDoc.exists) {
          throw Exception('Ticket configuration not found');
        }

        final config = TicketConfig.fromFirestore(configDoc);
        
        // Check if ticket type is available
        if (ticketType == 'regular') {
          if (!config.regularTicket.isEnabled || config.regularTicket.remainingQuantity <= 0) {
            throw Exception('Regular tickets not available');
          }
        } else if (ticketType == 'vip') {
          if (!config.vipTicket.isEnabled || config.vipTicket.remainingQuantity <= 0) {
            throw Exception('VIP tickets not available');
          }
        }

        // Create ticket document
        final ticketRef = _ticketsCollection.doc();
        final qrCode = generateQRCode(ticketRef.id, userId, eventId, ticketType);
        
        final ticket = TicketModel(
          id: ticketRef.id,
          eventId: eventId,
          userId: userId,
          userName: userName,
          userEmail: userEmail,
          ticketType: ticketType,
          price: price,
          status: 'valid',
          qrCode: qrCode,
          purchaseDate: DateTime.now(),
        );

        // Save ticket
        transaction.set(ticketRef, ticket.toFirestore());

        // Update sold quantity in config
        final updatedConfig = ticketType == 'regular'
            ? config.copyWith(
                regularTicket: RegularTicket(
                  price: config.regularTicket.price,
                  totalQuantity: config.regularTicket.totalQuantity,
                  soldQuantity: config.regularTicket.soldQuantity + 1,
                  isEnabled: config.regularTicket.isEnabled,
                ),
              )
            : config.copyWith(
                vipTicket: VipTicket(
                  price: config.vipTicket.price,
                  totalQuantity: config.vipTicket.totalQuantity,
                  soldQuantity: config.vipTicket.soldQuantity + 1,
                  isEnabled: config.vipTicket.isEnabled,
                ),
              );

        transaction.update(_ticketConfigsCollection.doc(eventId), updatedConfig.toFirestore());

        return ticketRef.id;
      });
    } catch (e) {
      print('Error purchasing ticket: $e');
      return null;
    }
  }

  /// Get user's tickets
  static Stream<List<TicketModel>> getUserTickets(String userId) {
    return _ticketsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final tickets = snapshot.docs
              .map((doc) => TicketModel.fromFirestore(doc))
              .toList();

          // Sort in memory to avoid Firestore composite index requirement
          tickets.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
          return tickets;
        });
  }

  /// Get event tickets (for organizers)
  static Stream<List<TicketModel>> getEventTickets(String eventId) {
    return _ticketsCollection
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
          final tickets = snapshot.docs
              .map((doc) => TicketModel.fromFirestore(doc))
              .toList();

          // Sort in memory to avoid Firestore composite index requirement
          tickets.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
          return tickets;
        });
  }

  /// Verify and use ticket (for entry scanning)
  static Future<bool> verifyAndUseTicket(String qrCode) async {
    try {
      final qrData = verifyQRCode(qrCode);
      if (qrData == null) return false;

      final ticketId = qrData['ticketId'];
      if (ticketId == null) return false;

      return await _firestore.runTransaction<bool>((transaction) async {
        final ticketDoc = await transaction.get(_ticketsCollection.doc(ticketId));
        if (!ticketDoc.exists) return false;

        final ticket = TicketModel.fromFirestore(ticketDoc);
        
        // Check if ticket is valid
        if (ticket.status != 'valid') return false;
        if (ticket.qrCode != qrCode) return false;

        // Mark ticket as used
        transaction.update(_ticketsCollection.doc(ticketId), {
          'status': 'used',
          'usedDate': Timestamp.fromDate(DateTime.now()),
        });

        return true;
      });
    } catch (e) {
      print('Error verifying ticket: $e');
      return false;
    }
  }

  /// Get ticket statistics for an event
  static Future<Map<String, dynamic>> getEventTicketStats(String eventId) async {
    try {
      final config = await getTicketConfig(eventId);
      if (config == null) {
        return {
          'totalSold': 0,
          'totalRevenue': 0.0,
          'regularSold': 0,
          'vipSold': 0,
          'regularRevenue': 0.0,
          'vipRevenue': 0.0,
        };
      }

      return {
        'totalSold': config.regularTicket.soldQuantity + config.vipTicket.soldQuantity,
        'totalRevenue': config.regularTicket.revenue + config.vipTicket.revenue,
        'regularSold': config.regularTicket.soldQuantity,
        'vipSold': config.vipTicket.soldQuantity,
        'regularRevenue': config.regularTicket.revenue,
        'vipRevenue': config.vipTicket.revenue,
        'regularRemaining': config.regularTicket.remainingQuantity,
        'vipRemaining': config.vipTicket.remainingQuantity,
      };
    } catch (e) {
      print('Error getting ticket stats: $e');
      return {};
    }
  }
}
