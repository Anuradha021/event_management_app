import 'package:cloud_firestore/cloud_firestore.dart';

/// Single Responsibility: Handle all track panel data operations
class TrackPanelService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Load zones for an event
  static Future<List<Map<String, dynamic>>> loadZones(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Unnamed Zone',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to load zones: $e');
    }
  }

  /// Get tracks stream for a specific zone
  static Stream<QuerySnapshot> getTracksStream(String eventId, String zoneId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .doc(zoneId)
        .collection('tracks')
        .snapshots();
  }

  /// Create a new track
  static Future<void> createTrack(String eventId, String zoneId, String title, String description) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .doc(zoneId)
          .collection('tracks')
          .add({
        'title': title,
        'description': description.isNotEmpty ? description : null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create track: $e');
    }
  }

  /// Delete a track
  static Future<void> deleteTrack(String eventId, String zoneId, String trackId) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .doc(zoneId)
          .collection('tracks')
          .doc(trackId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete track: $e');
    }
  }
}
