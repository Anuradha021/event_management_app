import 'package:cloud_firestore/cloud_firestore.dart';

class ZonePanelService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<QuerySnapshot> getZonesStream(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .snapshots();
  }

  static Future<void> createZone(String eventId, String name, String description) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .add({
          'title': name,  
          'description': description,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  static Future<void> deleteZone(String eventId, String zoneId) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .doc(zoneId)
        .delete();
  }
}