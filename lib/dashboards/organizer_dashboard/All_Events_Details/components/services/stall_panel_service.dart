import 'package:cloud_firestore/cloud_firestore.dart';


class StallPanelService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;


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

  static Future<List<Map<String, dynamic>>> loadTracks(String eventId, String zoneId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .doc(zoneId)
          .collection('tracks')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Unnamed Track',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to load tracks: $e');
    }
  }


  static Stream<QuerySnapshot> getStallsStream(String eventId, String zoneId, String trackId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .doc(zoneId)
        .collection('tracks')
        .doc(trackId)
        .collection('stalls')
        .snapshots();
  }

  static Future<void> createStall(String eventId, String zoneId, String trackId, String name, String description) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .doc(zoneId)
          .collection('tracks')
          .doc(trackId)
          .collection('stalls')
          .add({
        'name': name,
        'description': description.isNotEmpty ? description : null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create stall: $e');
    }
  }

 
  static Future<void> deleteStall(String eventId, String zoneId, String trackId, String stallId) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .doc(zoneId)
          .collection('tracks')
          .doc(trackId)
          .collection('stalls')
          .doc(stallId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete stall: $e');
    }
  }
}
