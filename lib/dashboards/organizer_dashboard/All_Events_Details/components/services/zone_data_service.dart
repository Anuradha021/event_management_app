import 'package:cloud_firestore/cloud_firestore.dart';

/// Single Responsibility: Handle all zone-related data operations
class ZoneDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch zone data from Firestore
  static Future<Map<String, dynamic>?> getZoneData(String eventId, String zoneId) async {
    try {
      final doc = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .doc(zoneId)
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to fetch zone data: $e');
    }
  }

  /// Update zone data in Firestore
  static Future<void> updateZoneData(
    String eventId,
    String zoneId,
    String title,
    String description,
  ) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .doc(zoneId)
          .update({
        'title': title.trim(),
        'description': description.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update zone: $e');
    }
  }
}
