import 'package:cloud_firestore/cloud_firestore.dart';

/// Ticket model for event tickets
class TicketModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String userEmail;
  final String ticketType; // 'regular' or 'vip'
  final double price;
  final String status; // 'valid', 'used', 'expired', 'cancelled'
  final String qrCode; // QR code data
  final DateTime purchaseDate;
  final DateTime? usedDate;
  final Map<String, dynamic>? metadata;

  TicketModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.ticketType,
    required this.price,
    required this.status,
    required this.qrCode,
    required this.purchaseDate,
    this.usedDate,
    this.metadata,
  });

  /// Create TicketModel from Firestore document
  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      ticketType: data['ticketType'] ?? 'regular',
      price: (data['price'] ?? 0).toDouble(),
      status: data['status'] ?? 'valid',
      qrCode: data['qrCode'] ?? '',
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      usedDate: (data['usedDate'] as Timestamp?)?.toDate(),
      metadata: data['metadata'],
    );
  }

  /// Convert TicketModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'ticketType': ticketType,
      'price': price,
      'status': status,
      'qrCode': qrCode,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'usedDate': usedDate != null ? Timestamp.fromDate(usedDate!) : null,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  TicketModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? userName,
    String? userEmail,
    String? ticketType,
    double? price,
    String? status,
    String? qrCode,
    DateTime? purchaseDate,
    DateTime? usedDate,
    Map<String, dynamic>? metadata,
  }) {
    return TicketModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      ticketType: ticketType ?? this.ticketType,
      price: price ?? this.price,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      usedDate: usedDate ?? this.usedDate,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Ticket configuration model for events
class TicketConfig {
  final String eventId;
  final RegularTicket regularTicket;
  final VipTicket vipTicket;
  final bool isTicketingEnabled;
  final DateTime? salesStartDate;
  final DateTime? salesEndDate;

  TicketConfig({
    required this.eventId,
    required this.regularTicket,
    required this.vipTicket,
    required this.isTicketingEnabled,
    this.salesStartDate,
    this.salesEndDate,
  });

  factory TicketConfig.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketConfig(
      eventId: doc.id,
      regularTicket: RegularTicket.fromMap(data['regularTicket'] ?? {}),
      vipTicket: VipTicket.fromMap(data['vipTicket'] ?? {}),
      isTicketingEnabled: data['isTicketingEnabled'] ?? false,
      salesStartDate: (data['salesStartDate'] as Timestamp?)?.toDate(),
      salesEndDate: (data['salesEndDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'regularTicket': regularTicket.toMap(),
      'vipTicket': vipTicket.toMap(),
      'isTicketingEnabled': isTicketingEnabled,
      'salesStartDate': salesStartDate != null ? Timestamp.fromDate(salesStartDate!) : null,
      'salesEndDate': salesEndDate != null ? Timestamp.fromDate(salesEndDate!) : null,
    };
  }

  TicketConfig copyWith({
    String? eventId,
    RegularTicket? regularTicket,
    VipTicket? vipTicket,
    bool? isTicketingEnabled,
    DateTime? salesStartDate,
    DateTime? salesEndDate,
  }) {
    return TicketConfig(
      eventId: eventId ?? this.eventId,
      regularTicket: regularTicket ?? this.regularTicket,
      vipTicket: vipTicket ?? this.vipTicket,
      isTicketingEnabled: isTicketingEnabled ?? this.isTicketingEnabled,
      salesStartDate: salesStartDate ?? this.salesStartDate,
      salesEndDate: salesEndDate ?? this.salesEndDate,
    );
  }
}

/// Regular ticket configuration
class RegularTicket {
  final double price;
  final int totalQuantity;
  final int soldQuantity;
  final bool isEnabled;

  RegularTicket({
    required this.price,
    required this.totalQuantity,
    this.soldQuantity = 0,
    this.isEnabled = true,
  });

  factory RegularTicket.fromMap(Map<String, dynamic> data) {
    return RegularTicket(
      price: (data['price'] ?? 0).toDouble(),
      totalQuantity: data['totalQuantity'] ?? 0,
      soldQuantity: data['soldQuantity'] ?? 0,
      isEnabled: data['isEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'totalQuantity': totalQuantity,
      'soldQuantity': soldQuantity,
      'isEnabled': isEnabled,
    };
  }

  int get remainingQuantity => totalQuantity - soldQuantity;
  double get revenue => soldQuantity * price;
}

/// VIP ticket configuration
class VipTicket {
  final double price;
  final int totalQuantity;
  final int soldQuantity;
  final bool isEnabled;

  VipTicket({
    required this.price,
    required this.totalQuantity,
    this.soldQuantity = 0,
    this.isEnabled = true,
  });

  factory VipTicket.fromMap(Map<String, dynamic> data) {
    return VipTicket(
      price: (data['price'] ?? 0).toDouble(),
      totalQuantity: data['totalQuantity'] ?? 0,
      soldQuantity: data['soldQuantity'] ?? 0,
      isEnabled: data['isEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'totalQuantity': totalQuantity,
      'soldQuantity': soldQuantity,
      'isEnabled': isEnabled,
    };
  }

  int get remainingQuantity => totalQuantity - soldQuantity;
  double get revenue => soldQuantity * price;
}
