import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneDetailsScreens.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/services/cache_manager.dart';
import 'package:flutter/material.dart';

class ZoneListScreen extends StatefulWidget {
  final String eventId;

  const ZoneListScreen({super.key, required this.eventId});

  @override
  State<ZoneListScreen> createState() => _ZoneListScreenState();
}

class _ZoneListScreenState extends State<ZoneListScreen> {
  late Future<List<Map<String, dynamic>>> _zonesFuture;

  @override
  void initState() {
    super.initState();
    _zonesFuture = _loadZones();
  }

  Future<List<Map<String, dynamic>>> _loadZones() async {
    final cacheKey = 'zones_${widget.eventId}';
    final cached = CacheManager().get(cacheKey);
    if (cached != null) {
      print('Using cached zones');
      return cached;
    }

    print('Fetching zones from Firestore...');
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('zones')
        .orderBy('createdAt', descending: true)
        .get();

    final zones = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    CacheManager().save(cacheKey, zones);
    return zones;
  }

  void _refreshZones() {
    final cacheKey = 'zones_${widget.eventId}';
    CacheManager().clear(cacheKey); 
    setState(() {
      _zonesFuture = _loadZones(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Zones',
            onPressed: _refreshZones,
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _zonesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final zones = snapshot.data ?? [];
          if (zones.isEmpty) {
            return const Center(child: Text('No Zones found'));
          }

          return ListView.builder(
            itemCount: zones.length,
            itemBuilder: (context, index) {
              final zone = zones[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(zone['title'] ?? 'No Title'),
                  subtitle: zone['description']?.isNotEmpty == true
                      ? Text(zone['description'])
                      : null,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ZoneDetailScreen(
                          eventId: widget.eventId,
                          zoneId: zone['id'],
                          zoneData: zone,
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
