import 'package:event_management_app1/dashboards/organizer_dashboard/services/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'TrackDetailScreen.dart';
 

class TrackListScreen extends StatefulWidget {
  final String eventId;
  final String zoneId;

  const TrackListScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
  });

  @override
  State<TrackListScreen> createState() => _TrackListScreenState();
}

class _TrackListScreenState extends State<TrackListScreen> {
  final CacheManager _cacheManager = CacheManager();
  late final String _cacheKey;

  @override
  void initState() {
    super.initState();
    _cacheKey = 'tracks_${widget.eventId}_${widget.zoneId}';
  }

  Future<List<Map<String, dynamic>>> _loadTracks() async {
    // Check cache first
    final cached = _cacheManager.get(_cacheKey);
    if (cached != null) return cached;

    final query = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('zones')
        .doc(widget.zoneId)
        .collection('tracks')
        .orderBy('createdAt', descending: true)
        .get();

    final tracks = query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    _cacheManager.save(_cacheKey, tracks);
    return tracks;
  }

  Future<void> _refreshTracks() async {
    final query = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('zones')
        .doc(widget.zoneId)
        .collection('tracks')
        .orderBy('createdAt', descending: true)
        .get();

    final tracks = query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    _cacheManager.save(_cacheKey, tracks);
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tracks"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTracks,
            tooltip: 'Refresh from Firestore',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadTracks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tracks = snapshot.data!;
          if (tracks.isEmpty) {
            return const Center(child: Text("No tracks available."));
          }

          return ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final data = tracks[index];
              final title = data['title'] ?? 'No Title';
              final description = data['description'] ?? 'No Description';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(description),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackDetailScreen(
                          eventId: widget.eventId,
                          zoneId: widget.zoneId,
                          trackId: data['id'],
                          trackData: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
