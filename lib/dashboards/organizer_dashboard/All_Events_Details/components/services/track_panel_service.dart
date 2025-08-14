import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';


class TrackPanelService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;


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
          'title': data['name'] ?? 'Unnamed Zone',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to load zones: $e');
    }
  }

 
  static Stream<QuerySnapshot> getTracksStream(String eventId, String zoneId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .doc(zoneId)
        .collection('tracks')
        .snapshots();
  }

  
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
