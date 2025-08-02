import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/services/cache_manager.dart';

Future<List<Map<String, dynamic>>> fetchZones(String eventId) async {
  final cachedZones = CacheManager().get('zones_$eventId');
  if (cachedZones != null) return List<Map<String, dynamic>>.from(cachedZones);

  final query = await FirebaseFirestore.instance
      .collection('events')
      .doc(eventId)
      .collection('zones')
      .get();

  final fetchedZones = [
    ...query.docs.map((e) => {'id': e.id, 'title': e['title'] ?? 'No Title'}),
    {'id': 'new', 'title': '+ Create New Zone'},
  ];

  CacheManager().save('zones_$eventId', fetchedZones);
  return fetchedZones;
}

Future<List<Map<String, dynamic>>> fetchTracksForZone(String eventId, String zoneId) async {
  final cacheKey = 'tracks_${eventId}_$zoneId';
  final cachedTracks = CacheManager().get(cacheKey);

  if (cachedTracks != null) {
    return [
      ...cachedTracks.where((t) => t['id'] != 'new'),
      {'id': 'new', 'title': '+ Create New Track'},
    ];
  }

  final query = await FirebaseFirestore.instance
      .collection('events')
      .doc(eventId)
      .collection('zones')
      .doc(zoneId)
      .collection('tracks')
      .get();

  final fetchedTracks = [
    ...query.docs.map((e) => {'id': e.id, 'title': e['title'] ?? 'No Title'}),
    {'id': 'new', 'title': '+ Create New Track'},
  ];

  CacheManager().save(cacheKey, fetchedTracks);
  return fetchedTracks;
}

Future<void> saveSession({
  required String eventId,
  required String zoneId,
  required String trackId,
  required String title,
  required String speaker,
  required String description,
  required TimeOfDay startTime,
  required TimeOfDay endTime,
  required BuildContext context,
}) async {
  await FirebaseFirestore.instance
      .collection('events')
      .doc(eventId)
      .collection('zones')
      .doc(zoneId)
      .collection('tracks')
      .doc(trackId)
      .collection('sessions')
      .add({
    'title': title,
    'speakerName': speaker,
    'description': description,
    'startTime': startTime.format(context),
    'endTime': endTime.format(context),
    'createdAt': Timestamp.now(),
  });
}
