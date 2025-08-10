import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Single Responsibility: Handle all zone panel data operations via Cloud Functions
class ZonePanelService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Get zones stream for real-time updates
  static Stream<QuerySnapshot> getZonesStream(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .snapshots();
  }

  /// Create a new zone via Cloud Functions
  static Future<void> createZone(String eventId, String name, String description) async {
    try {
      print('🚀 Flutter: About to call Cloud Function testCreateZone');
      print('📝 Flutter: eventId = $eventId');
      print('📝 Flutter: name = $name');
      print('📝 Flutter: description = $description');

      // Use the super simple test function first
      final callable = _functions.httpsCallable('superSimpleTest');
      final result = await callable.call({
        'eventId': eventId,
        'title': name,
        'description': description,
      });

      print('✅ Flutter: Cloud Function call successful');
      print('📦 Flutter: Result = ${result.data}');

    } catch (e) {
      print('❌ Flutter: Cloud Function call failed');
      print('❌ Flutter: Error type = ${e.runtimeType}');
      print('❌ Flutter: Error details = $e');
      throw Exception('Failed to create zone: $e');
    }
  }

  /// Delete a zone via Cloud Functions
  static Future<void> deleteZone(String eventId, String zoneId) async {
    try {
      final callable = _functions.httpsCallable('zones-deleteZone');
      await callable.call({
        'eventId': eventId,
        'zoneId': zoneId,
      });
    } catch (e) {
      throw Exception('Failed to delete zone: $e');
    }
  }
}
