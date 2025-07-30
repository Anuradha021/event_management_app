import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CreateSessionScreen.dart';
import 'SessionDetailScreen.dart';
import '../services/cache_manager.dart';

class SessionListScreen extends StatefulWidget {
  final String eventId;
  const SessionListScreen({super.key, required this.eventId});

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  String? _selectedZoneId;
  String? _selectedTrackId;

  List<Map<String, dynamic>> _zones = [];
  List<Map<String, dynamic>> _tracks = [];
  List<Map<String, dynamic>> _sessions = [];

  bool _loadingZones = true;
  bool _loadingTracks = false;
  bool _loadingSessions = false;

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
        final m = d.data();
        m['id'] = d.id;
        return m;
      }).toList();
      CacheManager().save(cacheKey, _tracks);
    }

    setState(() => _loadingTracks = false);
  }

  Future<void> _fetchSessions() async {
    if (_selectedZoneId == null || _selectedTrackId == null) return;

    setState(() {
      _loadingSessions = true;
      _sessions = [];
    });

    final q = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('zones')
        .doc(_selectedZoneId)
        .collection('tracks')
        .doc(_selectedTrackId)
        .collection('sessions')
        .get();

    _sessions = q.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    setState(() => _loadingSessions = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
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
                      const DropdownMenuItem(value: null, child: Text('-- Select Zone --')),
                      ..._zones.map((z) => DropdownMenuItem(
                            value: z['id'],
                            child: Text(z['title'] ?? 'Unnamed Zone'),
                          )),
                    ],
                    onChanged: (zoneId) {
                      setState(() {
                        _selectedZoneId = zoneId;
                        _selectedTrackId = null;
                      });
                      _fetchTracks();
                    },
                  ),
                ),
                if (_selectedZoneId != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Select Track'),
                      value: _selectedTrackId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('-- Select Track --')),
                        ..._tracks.map((t) => DropdownMenuItem(
                              value: t['id'],
                              child: Text(t['title'] ?? 'Unnamed Track'),
                            )),
                      ],
                      onChanged: (trackId) {
                        setState(() => _selectedTrackId = trackId);
                        _fetchSessions();
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: _loadingSessions
                      ? const Center(child: CircularProgressIndicator())
                      : (_sessions.isEmpty
                          ? const Center(child: Text('No sessions found.'))
                          : ListView.builder(
                              itemCount: _sessions.length,
                              itemBuilder: (context, index) {
                                final session = _sessions[index];
                                return ListTile(
                                  title: Text(session['title'] ?? 'Untitled Session'),
                                  subtitle: Text('Speaker: ${session['speakerName'] ?? 'N/A'}'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SessionDetailScreen(
                                          eventId: widget.eventId,
                                          zoneId: _selectedZoneId!,
                                          trackId: _selectedTrackId!,
                                          sessionId: session['id'],
                                          sessionData: session,
                                        ),
                                      ),
                                    );
                                  },
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
                    builder: (_) => CreateSessionScreen(
                      eventId: widget.eventId,
                      zoneId: _selectedZoneId!,
                      trackId: _selectedTrackId!,
                    ),
                  ),
                );
                if (result == true) {
                  _fetchSessions();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session added')),
                  );
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
