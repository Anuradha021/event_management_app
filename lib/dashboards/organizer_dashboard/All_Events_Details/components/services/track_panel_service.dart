import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Single Responsibility: Handle all track panel data operations via Cloud Functions
class TrackPanelService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

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

  /// Create a new track via Cloud Functions
  static Future<void> createTrack(String eventId, String zoneId, String title, String description) async {
    try {
      final callable = _functions.httpsCallable('tracks-createTrack');
      await callable.call({
        'eventId': eventId,
        'zoneId': zoneId,
        'title': title,
        'description': description,
      });
    } catch (e) {
      throw Exception('Failed to create track: $e');
    }
  }

  /// Delete a track via Cloud Functions
  static Future<void> deleteTrack(String eventId, String zoneId, String trackId) async {
    try {
      final callable = _functions.httpsCallable('tracks-deleteTrack');
      await callable.call({
        'eventId': eventId,
        'zoneId': zoneId,
        'trackId': trackId,
      });
    } catch (e) {
      throw Exception('Failed to delete track: $e');
    }
  }
}
