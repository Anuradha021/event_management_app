import 'package:cloud_firestore/cloud_firestore.dart';

class TicketType {
  final String id;
  final String eventId;
  final String name;
  final String description;
  final double price;
  final int totalQuantity;
  final int soldQuantity;
  final bool isActive;
  final DateTime createdAt;
  final String organizerId;

  const TicketType({
    required this.id,
    required this.eventId,
    required this.name,
    this.description = '',
    required this.price,
    required this.totalQuantity,
    this.soldQuantity = 0,
    this.isActive = true,
    required this.createdAt,
    required this.organizerId,
  });

  int get availableQuantity => totalQuantity - soldQuantity;
  bool get isSoldOut => availableQuantity <= 0;
  double get revenue => soldQuantity * price;

  factory TicketType.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketType(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      totalQuantity: data['totalQuantity'] ?? 0,
      soldQuantity: data['soldQuantity'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      organizerId: data['organizerId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'name': name,
      'description': description,
      'price': price,
      'totalQuantity': totalQuantity,
      'soldQuantity': soldQuantity,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'organizerId': organizerId,
    };
  }
}

// TICKET MODEL
class Ticket {
  final String id;
  final String eventId;
  final String eventTitle;
  final String ticketTypeId;
  final String ticketTypeName;
  final String ticketTypeDescription;
  final String userId;
  final String userEmail;
  final String userName;
  final String userPhone;
  final double price;
  final String qrCode;
  final String status; 
  final DateTime purchaseDate;
  final DateTime? usedAt;
  final String? validatedBy;

  const Ticket({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.ticketTypeId,
    required this.ticketTypeName,
    this.ticketTypeDescription = '',
    required this.userId,
    required this.userEmail,
    required this.userName,
    this.userPhone = '',
    required this.price,
    required this.qrCode,
    this.status = 'active',
    required this.purchaseDate,
    this.usedAt,
    this.validatedBy,
  });

  bool get isActive => status == 'active';
  bool get isUsed => status == 'used';
  bool get isCancelled => status == 'cancelled';

  factory Ticket.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ticket(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      eventTitle: data['eventTitle'] ?? '',
      ticketTypeId: data['ticketTypeId'] ?? '',
      ticketTypeName: data['ticketTypeName'] ?? '',
      ticketTypeDescription: data['ticketTypeDescription'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      qrCode: data['qrCode'] ?? '',
      status: data['status'] ?? 'active',
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      usedAt: (data['usedAt'] as Timestamp?)?.toDate(),
      validatedBy: data['validatedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'eventTitle': eventTitle,
      'ticketTypeId': ticketTypeId,
      'ticketTypeName': ticketTypeName,
      'ticketTypeDescription': ticketTypeDescription,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'userPhone': userPhone,
      'price': price,
      'qrCode': qrCode,
      'status': status,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'usedAt': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
      'validatedBy': validatedBy,
    };
  }
}

//  RESULT MODELS 
class PurchaseResult {
  final bool success;
  final String? ticketId;
  final String? qrCode;
  final String? error;

  const PurchaseResult({
    required this.success,
    this.ticketId,
    this.qrCode,
    this.error,
  });

  factory PurchaseResult.success(String ticketId, String qrCode) {
    return PurchaseResult(success: true, ticketId: ticketId, qrCode: qrCode);
  }

  factory PurchaseResult.failure(String error) {
    return PurchaseResult(success: false, error: error);
  }
}

class ValidationResult {
  final bool success;
  final String message;
  final Ticket? ticket;

  const ValidationResult({
    required this.success,
    required this.message,
    this.ticket,
  });

  factory ValidationResult.valid(Ticket ticket) {
    return ValidationResult(
      success: true,
      message: 'Ticket validated successfully',
      ticket: ticket,
    );
  }

  factory ValidationResult.invalid(String message) {
    return ValidationResult(success: false, message: message);
  }
}
