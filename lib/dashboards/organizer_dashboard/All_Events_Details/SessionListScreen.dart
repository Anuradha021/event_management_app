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

  
  Widget _buildSessionItem(Map<String, dynamic> session) {
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
          child: const Icon(Icons.schedule, color: Colors.deepPurple),
        ),
        title: Text(
          session['title'] ?? 'Untitled Session',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Speaker: ${session['speakerName'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${session['startTime'] ?? ''} - ${session['endTime'] ?? ''}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No sessions available',
            style: TextStyle(fontSize: 18),
          ),
          if (_selectedZoneId != null && _selectedTrackId != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
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
                if (result == true) _fetchSessions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Create First Session',
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
          'Sessions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
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
                    value: _selectedZoneId,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('-- Select Zone --'),
                      ),
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
                      value: _selectedTrackId,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('-- Select Track --'),
                        ),
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
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: _loadingSessions
                ? const Center(child: CircularProgressIndicator())
                : _sessions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) {
                          return _buildSessionItem(_sessions[index]);
                        },
                      ),
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
                if (result == true) _fetchSessions();
              },
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}