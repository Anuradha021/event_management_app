// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class FirestoreHierarchyHelper {
//   static Future<List<Map<String, dynamic>>> fetchStalls(
//   String eventId, 
//   String zoneId, 
//   String trackId,
// ) async {
//   try {
//     final querySnapshot = await FirebaseFirestore.instance
//         .collection('events')
//         .doc(eventId)
//         .collection('zones')
//         .doc(zoneId)
//         .collection('tracks')
//         .doc(trackId)
//         .collection('stalls')
//         .get();

//     return querySnapshot.docs.map((doc) {
//       return {
//         'id': doc.id,
//         'name': doc['name'],
//         'number': doc['number'],
//       };
//     }).toList();
//   } catch (e) {
//     debugPrint('Error fetching stalls: $e');
//     return [];
//   }
// }

// static Future<void> addStall(
//   String eventId,
//   String zoneId,
//   String trackId,
//   String name,
//   String number,
// ) async {
//   await FirebaseFirestore.instance
//       .collection('events')
//       .doc(eventId)
//       .collection('zones')
//       .doc(zoneId)
//       .collection('tracks')
//       .doc(trackId)
//       .collection('stalls')
//       .add({
//     'name': name,
//     'number': number,
//     'createdAt': FieldValue.serverTimestamp(),
//   });
// }

// static Future<void> deleteStall(
//   String eventId,
//   String zoneId,
//   String trackId,
//   String stallId,
// ) async {
//   await FirebaseFirestore.instance
//       .collection('events')
//       .doc(eventId)
//       .collection('zones')
//       .doc(zoneId)
//       .collection('tracks')
//       .doc(trackId)
//       .collection('stalls')
//       .doc(stallId)
//       .delete();
// }
//   static Future<Map<String, String>> ensureHierarchy({
//     required String eventId,
//     String? zoneId,
//     String? trackId,
//   }) async {
//     final result = <String, dynamic>{};
//     final eventRef = FirebaseFirestore.instance.collection('events').doc(eventId);

//     // Zone handling
//     if (zoneId == null) {
//       final zoneDoc = await eventRef.collection('zones').add({
//         'name': 'Default Zone',
//         'isAutoCreated': true,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//       result['zoneId'] = zoneDoc.id;
//     } else {
//       result['zoneId'] = zoneId;
//     }

//     // Track handling (nested under zone)
//     final zoneRef = eventRef.collection('zones').doc(result['zoneId']);
//     if (trackId == null) {
//       final trackDoc = await zoneRef.collection('tracks').add({
//         'name': 'Default Track',
//         'isAutoCreated': true,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//       result['trackId'] = trackDoc.id;
//     } else {
//       result['trackId'] = trackId;
//     }

//     return result.cast<String, String>();
//   }

//   static Future<List<Map<String, dynamic>>> fetchZones(String eventId) async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('events')
//         .doc(eventId)
//         .collection('zones')
//         .get();
//     return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
//   }

//   static Future<List<Map<String, dynamic>>> fetchTracks(
//       String eventId, String zoneId) async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('events')
//         .doc(eventId)
//         .collection('zones')
//         .doc(zoneId)
//         .collection('tracks')
//         .get();
//     return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
//   }
// }
