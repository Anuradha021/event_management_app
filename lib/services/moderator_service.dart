import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/moderator.dart';

class ModeratorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  //  ORGANIZER FUNCTIONS 

  /// Add a moderator to an event
  static Future<String> addModerator({
    required String eventId,
    required String userEmail,
    required List<String> permissions,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Check if user exists
    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception('User with email $userEmail not found');
    }

    final userData = userQuery.docs.first.data();
    final userId = userQuery.docs.first.id;

    // Check if user is already a moderator for this event
    final existingModerator = await _firestore
        .collection('moderators')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingModerator.docs.isNotEmpty) {
      throw Exception('User is already a moderator for this event');
    }

    // Create moderator invitation
    final docRef = await _firestore.collection('moderators').add({
      'eventId': eventId,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userData['name'] ?? userData['displayName'] ?? 'User',
      'organizerId': currentUser.uid,
      'permissions': permissions,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Get moderators for an event
  static Stream<List<Moderator>> getModeratorsForEvent(String eventId) {
    return _firestore
        .collection('moderators')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Moderator.fromFirestore(doc))
            .toList());
  }

  /// Update moderator permissions
  static Future<void> updateModeratorPermissions({
    required String moderatorId,
    required List<String> permissions,
  }) async {
    await _firestore.collection('moderators').doc(moderatorId).update({
      'permissions': permissions,
    });
  }

  /// Remove moderator
  static Future<void> removeModerator(String moderatorId) async {
    await _firestore.collection('moderators').doc(moderatorId).delete();
  }

  // USER FUNCTIONS

  /// Get moderator invitations for current user
  static Stream<List<Moderator>> getModeratorInvitations() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('moderators')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Moderator.fromFirestore(doc))
            .toList());
  }

  /// Accept moderator invitation
  static Future<void> acceptModeratorInvitation(String moderatorId) async {
    await _firestore.collection('moderators').doc(moderatorId).update({
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Decline moderator invitation
  static Future<void> declineModeratorInvitation(String moderatorId) async {
    await _firestore.collection('moderators').doc(moderatorId).update({
      'status': 'declined',
    });
  }

  /// Get events where user is a moderator
  static Stream<List<Moderator>> getUserModeratorRoles() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('moderators')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Moderator.fromFirestore(doc))
            .toList());
  }

  /// Check if user has permission for specific event
  static Future<bool> hasPermission({
    required String eventId,
    required String permission,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    // Check if user is the organizer
    final eventDoc = await _firestore.collection('events').doc(eventId).get();
    if (eventDoc.exists) {
      final eventData = eventDoc.data() as Map<String, dynamic>;
      if (eventData['organizerUid'] == user.uid) {
        return true; // Organizers have all permissions
      }
    }

    // Check if user is a moderator with this permission
    final moderatorQuery = await _firestore
        .collection('moderators')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'accepted')
        .limit(1)
        .get();

    if (moderatorQuery.docs.isNotEmpty) {
      final moderator = Moderator.fromFirestore(moderatorQuery.docs.first);
      return moderator.hasPermission(permission);
    }

    return false;
  }

  /// Get user's role for an event (organizer, moderator, or user)
  static Future<Map<String, dynamic>> getUserRoleForEvent(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'role': 'user', 'permissions': <String>[]};
    }

    // Check if user is the organizer
    final eventDoc = await _firestore.collection('events').doc(eventId).get();
    if (eventDoc.exists) {
      final eventData = eventDoc.data() as Map<String, dynamic>;
      if (eventData['organizerUid'] == user.uid) {
        return {
          'role': 'organizer',
          'permissions': ModeratorPermissions.all,
        };
      }
    }

    // Check if user is a moderator
    final moderatorQuery = await _firestore
        .collection('moderators')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'accepted')
        .limit(1)
        .get();

    if (moderatorQuery.docs.isNotEmpty) {
      final moderator = Moderator.fromFirestore(moderatorQuery.docs.first);
      return {
        'role': 'moderator',
        'permissions': moderator.permissions,
      };
    }

    return {'role': 'user', 'permissions': <String>[]};
  }

  /// Check if current user is organizer of event
  static Future<bool> isOrganizer(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final eventDoc = await _firestore.collection('events').doc(eventId).get();
    if (eventDoc.exists) {
      final eventData = eventDoc.data() as Map<String, dynamic>;
      return eventData['organizerUid'] == user.uid;
    }

    return false;
  }
}
