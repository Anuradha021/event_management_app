import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ZoneCreateScreen.dart';
import 'ZoneDetailsScreens.dart';

class ZoneListScreen extends StatelessWidget {
  final String eventId;

  const ZoneListScreen({Key? key, required this.eventId}) : super(key: key);

  Stream<QuerySnapshot> _getZones() {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Zones',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getZones(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          final zones = snapshot.data!.docs;

          if (zones.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildZoneList(context, zones);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateZone(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading zones',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'No zones yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first zone to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateZone(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Zone'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneList(BuildContext context, List<QueryDocumentSnapshot> zones) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: zones.length,
      itemBuilder: (context, index) {
        final zone = zones[index];
        final zoneData = zone.data() as Map<String, dynamic>;
        return _buildZoneCard(context, zone.id, zoneData);
      },
    );
  }

  Widget _buildZoneCard(BuildContext context, String zoneId, Map<String, dynamic> zoneData) {
    final title = zoneData['title'] ?? 'Unnamed Zone';
    final description = zoneData['description'] ?? '';
    final initials = title.isNotEmpty ? title[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: () => _navigateToZoneDetails(context, zoneId, zoneData),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCreateZone(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneCreateScreen(eventId: eventId),
      ),
    );
  }

  void _navigateToZoneDetails(
      BuildContext context, String zoneId, Map<String, dynamic> zoneData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneDetailScreen(
          eventId: eventId,
          zoneId: zoneId,
          zoneData: zoneData,
        ),
      ),
    );
  }
}
