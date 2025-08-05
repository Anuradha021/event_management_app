import 'package:flutter/material.dart';
import 'TrackListScreen.dart';
import 'TrackCreateScreen.dart';

class ZoneDetailScreen extends StatelessWidget {
  final String eventId;
  final String zoneId;
  final Map<String, dynamic> zoneData;

  const ZoneDetailScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.zoneData,
  });

  @override
  Widget build(BuildContext context) {
    final zoneName = zoneData['title'] ?? 'Untitled Zone';
    final description = zoneData['description'] ?? 'No description provided';

    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), 
      ),
      minimumSize: const Size(double.infinity, 50), 
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Zone: $zoneName',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zoneName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create Track'),
                    style: buttonStyle.copyWith(
                      backgroundColor: WidgetStateProperty.all(Colors.deepPurple),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackCreateScreen(
                            eventId: eventId,
                            zoneId: zoneId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12), 
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.list_alt, size: 20),
                    label: const Text('View Tracks'),
                    style: buttonStyle.copyWith(
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                      foregroundColor: WidgetStateProperty.all(Colors.deepPurple),
                      side: WidgetStateProperty.all(
                        const BorderSide(color: Colors.deepPurple)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackListScreen(
                            eventId: eventId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}