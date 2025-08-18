import 'package:cloud_firestore/cloud_firestore.dart';

class Moderator {
  final String id;
  final String eventId;
  final String userId;
  final String userEmail;
  final String userName;
  final String organizerId;
  final List<String> permissions;
  final String status; 
  final DateTime createdAt;
  final DateTime? acceptedAt;

  const Moderator({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.organizerId,
    required this.permissions,
    this.status = 'pending',
    required this.createdAt,
    this.acceptedAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  factory Moderator.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Moderator(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      organizerId: data['organizerId'] ?? '',
      permissions: List<String>.from(data['permissions'] ?? []),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'organizerId': organizerId,
      'permissions': permissions,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
    };
  }

  Moderator copyWith({
    String? status,
    DateTime? acceptedAt,
    List<String>? permissions,
  }) {
    return Moderator(
      id: id,
      eventId: eventId,
      userId: userId,
      userEmail: userEmail,
      userName: userName,
      organizerId: organizerId,
      permissions: permissions ?? this.permissions,
      status: status ?? this.status,
      createdAt: createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}

// Available permissions
class ModeratorPermissions {
  static const String manageZones = 'manage_zones';
  static const String manageTracks = 'manage_tracks';
  static const String manageSessions = 'manage_sessions';
  static const String manageStalls = 'manage_stalls';
  static const String manageTickets = 'manage_tickets';
  static const String validateTickets = 'validate_tickets';
  static const String viewAnalytics = 'view_analytics';

  static const List<String> all = [
    manageZones,
    manageTracks,
    manageSessions,
    manageStalls,
    manageTickets,
    validateTickets,
    viewAnalytics,
  ];

  static String getDisplayName(String permission) {
    switch (permission) {
      case manageZones:
        return 'Manage Zones';
      case manageTracks:
        return 'Manage Tracks';
      case manageSessions:
        return 'Manage Sessions';
      case manageStalls:
        return 'Manage Stalls';
      case manageTickets:
        return 'Manage Tickets';
      case validateTickets:
        return 'Validate Tickets';
      case viewAnalytics:
        return 'View event statistics and analytics';
      default:
        return permission;
    }
  }

  static String getDescription(String permission) {
    switch (permission) {
      case manageZones:
        return 'Create, edit, and delete event zones';
      case manageTracks:
        return 'Create, edit, and delete event tracks';
      case manageSessions:
        return 'Create, edit, and delete event sessions';
      case manageStalls:
        return 'Create, edit, and delete event stalls';
      case manageTickets:
        return 'Create and manage ticket types';
      case validateTickets:
        return 'Validate tickets at event entrance';
      case viewAnalytics:
        return 'View event statistics and analytics';
      default:
        return 'Permission: $permission';
    }
  }
}
