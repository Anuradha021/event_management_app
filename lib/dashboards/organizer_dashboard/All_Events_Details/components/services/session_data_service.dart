import 'package:cloud_firestore/cloud_firestore.dart';
class SessionPanelService {
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


  static Stream<QuerySnapshot> getDefaultSessionsStream(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('sessions')
        .orderBy('startTime')
        .snapshots();
  }

  static Stream<QuerySnapshot> getSessionsStream(String eventId, String zoneId, String trackId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .doc(zoneId)
        .collection('tracks')
        .doc(trackId)
        .collection('sessions')
        .orderBy('startTime')
        .snapshots();
  }

  static Future<void> deleteDefaultSession(String eventId, String sessionId) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('sessions')
          .doc(sessionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

 
  static Future<void> deleteSession(String eventId, String zoneId, String trackId, String sessionId) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .doc(zoneId)
          .collection('tracks')
          .doc(trackId)
          .collection('sessions')
          .doc(sessionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }
  static Future<void> createDefaultSession(
    String eventId,
    String title,
    String description,
    String speaker,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('sessions')
          .add({
        'title': title,
        'description': description.isNotEmpty ? description : null,
        'speaker': speaker.isNotEmpty ? speaker : null,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  static Future<void> createSession(
    String eventId,
    String zoneId,
    String trackId,
    String title,
    String description,
    String speaker,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .doc(zoneId)
          .collection('tracks')
          .doc(trackId)
          .collection('sessions')
          .add({
        'title': title,
        'description': description.isNotEmpty ? description : null,
        'speaker': speaker.isNotEmpty ? speaker : null,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }
}
