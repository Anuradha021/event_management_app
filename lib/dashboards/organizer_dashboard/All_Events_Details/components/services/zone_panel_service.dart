import 'package:cloud_firestore/cloud_firestore.dart';

/// Single Responsibility: Handle all zone panel data operations
class ZonePanelService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get zones stream for real-time updates
  static Stream<QuerySnapshot> getZonesStream(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .snapshots();
  }

  /// Create a new zone
  static Future<void> createZone(String eventId, String name, String description) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .add({
        'title': name,
        'description': description.isNotEmpty ? description : null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create zone: $e');
    }
  }

  /// Delete a zone
  static Future<void> deleteZone(String eventId, String zoneId) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .doc(zoneId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete zone: $e');
    }
  }
}
