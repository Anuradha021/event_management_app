// ticket_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String id;
  final String eventId;
  final String attendeeId;
  final String attendeeName;
  final String status; // 'active', 'used', 'cancelled'
  final DateTime createdAt;
  final String? qrCodeData;

  Ticket({
    required this.id,
    required this.eventId,
    required this.attendeeId,
    required this.attendeeName,
    this.status = 'active',
    required this.createdAt,
    this.qrCodeData,
  });

  factory Ticket.fromMap(Map<String, dynamic> data, String id) {
    return Ticket(
      id: id,
      eventId: data['eventId'],
      attendeeId: data['attendeeId'],
      attendeeName: data['attendeeName'],
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      qrCodeData: data['qrCodeData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'attendeeId': attendeeId,
      'attendeeName': attendeeName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'qrCodeData': qrCodeData,
    };
  }
}