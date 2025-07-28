import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'TrackListScreen.dart';
import 'SessionListScreen.dart';
import 'StallListScreen.dart';

class ZoneSelectorScreen extends StatefulWidget {
  final String eventId;
  final String type; 

  const ZoneSelectorScreen({
    super.key,
    required this.eventId,
    required this.type,
  });

  @override
  State<ZoneSelectorScreen> createState() => _ZoneSelectorScreenState();
}

class _ZoneSelectorScreenState extends State<ZoneSelectorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Zone')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .collection('zones')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No zones found'));
          }

          final zones = snapshot.data!.docs;

          return ListView.builder(
            itemCount: zones.length,
            itemBuilder: (context, index) {
              final zone = zones[index];
              final data = zone.data() as Map<String, dynamic>;
              final zoneId = zone.id;
              final zoneName = data['title'] ?? 'Unnamed Zone';
              final zoneDesc = data['description'] ?? 'No description';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(zoneName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(zoneDesc),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _navigateBasedOnType(zoneId),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateBasedOnType(String zoneId) {
    if (widget.type == 'track') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrackListScreen(eventId: widget.eventId, zoneId: zoneId),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrackSelectorScreen(
            eventId: widget.eventId,
            zoneId: zoneId,
            type: widget.type,
          ),
        ),
      );
    }
  }
}

class TrackSelectorScreen extends StatelessWidget {
  final String eventId;
  final String zoneId;
  final String type;

  const TrackSelectorScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Track')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .collection('zones')
            .doc(zoneId)
            .collection('tracks')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tracks found'));
          }

          final tracks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              final data = track.data() as Map<String, dynamic>;
              final trackName = data['title'] ?? 'Unnamed Track';
              final trackDesc = data['description'] ?? 'No description';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(trackName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(trackDesc),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    if (type == 'session') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SessionListScreen(
                            eventId: eventId,
                            zoneId: zoneId,
                            trackId: track.id,
                          ),
                        ),
                      );
                    } else if (type == 'stall') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StallListScreen(
                            eventId: eventId,
                            zoneId: zoneId,
                            trackId: track.id,
                          ),
                        ),
                      );
                    }
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
