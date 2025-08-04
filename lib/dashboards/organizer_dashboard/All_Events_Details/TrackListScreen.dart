import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneCreateScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'TrackCreateScreen.dart';
import 'TrackDetailScreen.dart';
import '../services/cache_manager.dart';

class TrackListScreen extends StatefulWidget {
  final String eventId;
  const TrackListScreen({super.key, required this.eventId});

  @override
  State<TrackListScreen> createState() => _TrackListScreenState();
}

class _TrackListScreenState extends State<TrackListScreen> {
  String? _selectedZoneId;
  List<Map<String, dynamic>> _zones = [];
  List<Map<String, dynamic>> _tracks = [];
  bool _loadingZones = true, _loadingTracks = false;

  @override
  void initState() {
    super.initState();
    _fetchZones();
  }

  Future<void> _fetchZones() async {
    final cached = CacheManager().get('zones_${widget.eventId}');
    if (cached != null) {
      _zones = List<Map<String, dynamic>>.from(cached);
    } else {
      final q = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .orderBy('createdAt', descending: true)
          .get();
      _zones = q.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        return m;
      }).toList();
      CacheManager().save('zones_${widget.eventId}', _zones);
    }

    setState(() {
      _loadingZones = false;
    });
  }

  Future<void> _fetchTracks() async {
    if (_selectedZoneId == null) return;
    setState(() => _loadingTracks = true);

    final cacheKey = 'tracks_${widget.eventId}_$_selectedZoneId';
    final cached = CacheManager().get(cacheKey);
    if (cached != null) {
      _tracks = List<Map<String, dynamic>>.from(cached);
    } else {
      final q = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .doc(_selectedZoneId)
          .collection('tracks')
          .orderBy('createdAt', descending: true)
          .get();
      _tracks = q.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        return m;
      }).toList();
      CacheManager().save(cacheKey, _tracks);
    }

    setState(() => _loadingTracks = false);
  }

  void _onZoneChanged(String? id) {
    if (id == 'new') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ZoneCreateScreen(eventId: widget.eventId),
        ),
      ).then((_) => _fetchZones());
    } else {
      setState(() => _selectedZoneId = id);
      _fetchTracks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  backgroundColor: Colors.deepPurple,
  iconTheme: const IconThemeData(color: Colors.white),
  elevation: 0,
  centerTitle: true,
  title: const Text(
    'Tracks',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
),

      body: _loadingZones
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Zone'),
                    value: _selectedZoneId,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('-- Select Zone --'),
                      ),
                      ..._zones.map((z) => DropdownMenuItem(
                            value: z['id'] as String,
                            child: Text(z['title'] ?? 'Unnamed Zone'),
                          )),
                      const DropdownMenuItem(
                        value: 'new',
                        child: Text('+ Create New Zone'),
                      ),
                    ],
                    onChanged: _onZoneChanged,
                  ),
                ),
                Expanded(
                  child: _loadingTracks
                      ? const Center(child: CircularProgressIndicator())
                      : (_tracks.isEmpty
                          ? const Center(child: Text('No tracks found.'))
                          : ListView.builder(
                              itemCount: _tracks.length,
                              itemBuilder: (_, i) {
                                final t = _tracks[i];
                                return ListTile(
                                  title:
                                      Text(t['title'] ?? 'Untitled Track'),
                                  subtitle: Text(t['description'] ?? ''),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TrackDetailScreen(
                                        eventId: widget.eventId,
                                        zoneId: _selectedZoneId!,
                                        trackId: t['id'],
                                        trackData: t,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )),
                ),
              ],
            ),
      floatingActionButton: (_selectedZoneId != null)
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrackCreateScreen(
                    eventId: widget.eventId,
                    zoneId: _selectedZoneId!,
                  ),
                ),
              ).then((_) => _fetchTracks()),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
