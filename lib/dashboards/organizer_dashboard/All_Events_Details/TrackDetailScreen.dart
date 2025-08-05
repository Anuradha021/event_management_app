import 'package:flutter/material.dart';
import 'CreateSessionScreen.dart';
import 'SessionListScreen.dart';

class TrackDetailScreen extends StatelessWidget {
  final String eventId;
  final String zoneId;
  final String trackId;
  final Map trackData;

  const TrackDetailScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
    required this.trackData,
  });

  @override
  Widget build(BuildContext context) {
    final title = trackData['title'] ?? 'No Title';
    final description = trackData['description'] ?? 'No Description';

    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), 
      ),
      minimumSize: const Size(double.infinity, 50), 
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Track Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
         
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
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
            const SizedBox(height: 20),
            
          
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create Session'),
                    style: buttonStyle.copyWith(
                      backgroundColor: WidgetStateProperty.all(Colors.deepPurple),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateSessionScreen(
                            eventId: eventId,
                            zoneId: zoneId,
                            trackId: trackId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12), 
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.list, size: 20),
                    label: const Text('View Sessions'),
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
                          builder: (_) => SessionListScreen(
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