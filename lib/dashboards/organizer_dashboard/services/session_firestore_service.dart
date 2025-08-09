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

// Function to get or create default zone
Future<String> getOrCreateDefaultZone(String eventId) async {
  try {
    // First, try to find an existing zone
    final zonesQuery = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .limit(1)
        .get();

    if (zonesQuery.docs.isNotEmpty) {
      return zonesQuery.docs.first.id;
    }

    // If no zones exist, create a default zone
    final defaultZoneRef = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .add({
      'title': 'Default Zone',
      'description': 'Default zone for sessions without specific zone assignment',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return defaultZoneRef.id;
  } catch (e) {
    throw Exception('Failed to get or create default zone: $e');
  }
}

// Function to get or create default track
Future<String> getOrCreateDefaultTrack(String eventId, String zoneId) async {
  try {
    // First, try to find an existing track in the zone
    final tracksQuery = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .doc(zoneId)
        .collection('tracks')
        .limit(1)
        .get();

    if (tracksQuery.docs.isNotEmpty) {
      return tracksQuery.docs.first.id;
    }

    // If no tracks exist, create a default track
    final defaultTrackRef = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .doc(zoneId)
        .collection('tracks')
        .add({
      'title': 'Default Track',
      'description': 'Default track for sessions without specific track assignment',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return defaultTrackRef.id;
  } catch (e) {
    throw Exception('Failed to get or create default track: $e');
  }
}

Future<void> saveSession({
  required String eventId,
  String? zoneId,
  String? trackId,
  required String title,
  required String speaker,
  required String description,
  required TimeOfDay startTime,
  required TimeOfDay endTime,
  required BuildContext context,
}) async {
  try {
    // If zoneId is not provided, get or create default zone
    String finalZoneId = zoneId ?? await getOrCreateDefaultZone(eventId);
    
    // If trackId is not provided, get or create default track
    String finalTrackId = trackId ?? await getOrCreateDefaultTrack(eventId, finalZoneId);

    // Convert TimeOfDay to DateTime (using today's date as default)
    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      endTime.hour,
      endTime.minute,
    );

    // Validate that end time is after start time
    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      throw Exception('End time must be after start time');
    }

    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .doc(finalZoneId)
        .collection('tracks')
        .doc(finalTrackId)
        .collection('sessions')
        .add({
      'title': title,
      'speakerName': speaker,
      'description': description,
      'startTime': Timestamp.fromDate(startDateTime),
      'endTime': Timestamp.fromDate(endDateTime),
      'createdAt': FieldValue.serverTimestamp(),
      'zoneId': finalZoneId,
      'trackId': finalTrackId,
    });
  } catch (e) {
    throw Exception('Failed to save session: $e');
  }
}
