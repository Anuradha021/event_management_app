import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>?> getDocument(String path) async {
    try {
      final doc = await _firestore.doc(path).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

 
  static Future<void> updateDocument(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.doc(path).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

 
  static Future<void> deleteDocument(String path) async {
    try {
      await _firestore.doc(path).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getCollection(String path) async {
    try {
      final snapshot = await _firestore.collection(path).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get collection: $e');
    }
  }

 
  static Stream<List<Map<String, dynamic>>> streamCollection(String path) {
    return _firestore.collection(path).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}


class EventDataService {
  static String _eventPath(String eventId) => 'events/$eventId';
  static String _zonePath(String eventId, String zoneId) => 
      '${_eventPath(eventId)}/zones/$zoneId';
  static String _trackPath(String eventId, String zoneId, String trackId) => 
      '${_zonePath(eventId, zoneId)}/tracks/$trackId';
  static String _sessionPath(String eventId, String zoneId, String trackId, String sessionId) => 
      '${_trackPath(eventId, zoneId, trackId)}/sessions/$sessionId';
  static String _stallPath(String eventId, String zoneId, String trackId, String stallId) => 
      '${_trackPath(eventId, zoneId, trackId)}/stalls/$stallId';

 
  static Future<Map<String, dynamic>?> getZone(String eventId, String zoneId) =>
      FirestoreService.getDocument(_zonePath(eventId, zoneId));

  static Future<void> updateZone(String eventId, String zoneId, Map<String, dynamic> data) =>
      FirestoreService.updateDocument(_zonePath(eventId, zoneId), data);

  static Future<List<Map<String, dynamic>>> getZones(String eventId) =>
      FirestoreService.getCollection('${_eventPath(eventId)}/zones');

 
  static Future<Map<String, dynamic>?> getTrack(String eventId, String zoneId, String trackId) =>
      FirestoreService.getDocument(_trackPath(eventId, zoneId, trackId));

  static Future<void> updateTrack(String eventId, String zoneId, String trackId, Map<String, dynamic> data) =>
      FirestoreService.updateDocument(_trackPath(eventId, zoneId, trackId), data);

  static Future<List<Map<String, dynamic>>> getTracks(String eventId, String zoneId) =>
      FirestoreService.getCollection('${_zonePath(eventId, zoneId)}/tracks');


  static Future<Map<String, dynamic>?> getSession(String eventId, String zoneId, String trackId, String sessionId) =>
      FirestoreService.getDocument(_sessionPath(eventId, zoneId, trackId, sessionId));

  static Future<void> updateSession(String eventId, String zoneId, String trackId, String sessionId, Map<String, dynamic> data) =>
      FirestoreService.updateDocument(_sessionPath(eventId, zoneId, trackId, sessionId), data);


  static Future<Map<String, dynamic>?> getStall(String eventId, String zoneId, String trackId, String stallId) =>
      FirestoreService.getDocument(_stallPath(eventId, zoneId, trackId, stallId));

  static Future<void> updateStall(String eventId, String zoneId, String trackId, String stallId, Map<String, dynamic> data) =>
      FirestoreService.updateDocument(_stallPath(eventId, zoneId, trackId, stallId), data);
}
