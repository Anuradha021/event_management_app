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
  // Keep all existing state variables
  String? _selectedZoneId;
  List<Map<String, dynamic>> _zones = [];
  List<Map<String, dynamic>> _tracks = [];
  bool _loadingZones = true, _loadingTracks = false;

  // Keep all existing methods exactly the same
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
    setState(() => _loadingZones = false);
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

  // UI Improvements Only Below
  Widget _buildTrackItem(Map<String, dynamic> track) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.timeline, color: Colors.deepPurple),
        ),
        title: Text(
          track['title'] ?? 'Untitled Track',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: track['description'] != null && track['description'].isNotEmpty
            ? Text(
                track['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrackDetailScreen(
              eventId: widget.eventId,
              zoneId: _selectedZoneId!,
              trackId: track['id'],
              trackData: track,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.track_changes,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No tracks available',
            style: TextStyle(fontSize: 18),
          ),
          if (_selectedZoneId != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrackCreateScreen(
                    eventId: widget.eventId,
                    zoneId: _selectedZoneId!,
                  ),
                ),
              ).then((_) => _fetchTracks()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Create First Track',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
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
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Zone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
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
                ),
                Expanded(
                  child: _loadingTracks
                      ? const Center(child: CircularProgressIndicator())
                      : (_tracks.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: _tracks.length,
                              itemBuilder: (_, i) => _buildTrackItem(_tracks[i]),
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
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}