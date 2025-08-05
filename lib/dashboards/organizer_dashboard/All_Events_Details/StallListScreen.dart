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
  // Keep all existing state variables
  String? _selectedZoneId;
  String? _selectedTrackId;
  List<Map<String, dynamic>> _zones = [];
  List<Map<String, dynamic>> _tracks = [];
  List<Map<String, dynamic>> _stalls = [];
  bool _loadingZones = true;
  bool _loadingTracks = false;
  bool _loadingStalls = false;

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

    _stalls = q.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    setState(() => _loadingStalls = false);
  }

  // UI Improvements Only Below
  Widget _buildStallItem(Map<String, dynamic> stall) {
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
          child: const Icon(Icons.storefront, color: Colors.deepPurple),
        ),
        title: Text(
          stall['name'] ?? 'Unnamed Stall',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: stall['description'] != null && stall['description'].isNotEmpty
            ? Text(stall['description'])
            : null,
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
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_mall_directory,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No stalls available',
            style: TextStyle(fontSize: 18),
          ),
          if (_selectedZoneId != null && _selectedTrackId != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Create First Stall',
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
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Select Zone',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          value: _selectedZoneId == '' ? null : _selectedZoneId,
                          items: [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('-- Select Zone --'),
                            ),
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
                        if (_selectedZoneId != null) ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Select Track',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            value: _selectedTrackId == '' ? null : _selectedTrackId,
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('-- Select Track --'),
                              ),
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
                        ],
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _loadingStalls
                      ? const Center(child: CircularProgressIndicator())
                      : (_stalls.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: _stalls.length,
                              itemBuilder: (context, index) =>
                                  _buildStallItem(_stalls[index]),
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
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}