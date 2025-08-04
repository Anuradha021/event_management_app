import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cache_manager.dart';
import 'StallCreateScreen.dart';
import 'StallDetailScreen.dart';

class StallListScreen extends StatefulWidget {
  final String eventId;

  const StallListScreen({super.key, required this.eventId});

  @override
  State<StallListScreen> createState() => _StallListScreenState();
}

class _StallListScreenState extends State<StallListScreen> {
  String? _selectedZoneId;
  String? _selectedTrackId;

  List<Map<String, dynamic>> _zones = [];
  List<Map<String, dynamic>> _tracks = [];
  List<Map<String, dynamic>> _stalls = [];

  bool _loadingZones = true;
  bool _loadingTracks = false;
  bool _loadingStalls = false;

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
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();

      CacheManager().save('zones_${widget.eventId}', _zones);
    }

    setState(() => _loadingZones = false);
  }

  Future<void> _fetchTracks() async {
    if (_selectedZoneId == null) return;

    setState(() {
      _loadingTracks = true;
      _tracks = [];
      _selectedTrackId = null;
    });

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
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();

      CacheManager().save(cacheKey, _tracks);
    }

    setState(() => _loadingTracks = false);
  }
  Future<void> _fetchStalls() async {
    if (_selectedZoneId == null || _selectedTrackId == null) return;
    setState(() {
      _loadingStalls = true;
      _stalls = [];
    });
    final q = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('zones')
        .doc(_selectedZoneId)
        .collection('tracks')
        .doc(_selectedTrackId)
        .collection('stalls')
        .get();

    print('Fetched ${q.docs.length} stalls');
    _stalls = q.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    setState(() => _loadingStalls = false);
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
    'Stalls',
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
                    value: _selectedZoneId == '' ? null : _selectedZoneId,
items: [
  const DropdownMenuItem(value: '', child: Text('-- Select Zone --')),
  ..._zones.map((z) => DropdownMenuItem(
        value: z['id'],
        child: Text(z['title'] ?? 'Unnamed Zone'),
      )),
],
onChanged: (zoneId) {
  if (zoneId != null && zoneId != '') {
    setState(() {
      _selectedZoneId = zoneId;
      _selectedTrackId = null;
    });
    _fetchTracks();
  }
},

                  ),
                ),
                if (_selectedZoneId != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Select Track'),
                     value: _selectedTrackId == '' ? null : _selectedTrackId,
items: [
  const DropdownMenuItem(value: '', child: Text('-- Select Track --')),
  ..._tracks.map((t) => DropdownMenuItem(
        value: t['id'],
        child: Text(t['title'] ?? 'Unnamed Track'),
      )),
],
onChanged: (trackId) {
  if (trackId != null && trackId != '') {
    setState(() => _selectedTrackId = trackId);
    _fetchStalls();
  }
},
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: _loadingStalls
                      ? const Center(child: CircularProgressIndicator())
                      : (_stalls.isEmpty
                          ? const Center(child: Text('No stalls available.'))
                          : ListView.builder(
                              itemCount: _stalls.length,
                              itemBuilder: (context, index) {
                                final stall = _stalls[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  child: ListTile(
                                    title: Text(
                                      stall['name'] ?? 'Unnamed Stall',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(stall['description'] ?? ''),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => StallDetailScreen(
                                            eventId: widget.eventId,
                                            zoneId: _selectedZoneId!,
                                            trackId: _selectedTrackId!,
                                            stallId: stall['id'],
                                            stallData: stall,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            )),
                ),
              ],
            ),
      floatingActionButton: (_selectedZoneId != null && _selectedTrackId != null)
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StallCreateScreen(
                      eventId: widget.eventId,
                      zoneId: _selectedZoneId!,
                      trackId: _selectedTrackId!,
                    ),
                  ),
                );
                if (result == true) _fetchStalls();
              },
              child: const Icon(Icons.add),
              tooltip: 'Create Stall',
            )
          : null,
    );
  }
}
