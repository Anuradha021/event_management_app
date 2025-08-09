import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'session_list_item.dart';

/// Single Responsibility: Handle session list display with loading and error states
class SessionListWidget extends StatelessWidget {
  final Stream<QuerySnapshot> sessionsStream;
  final Function(String sessionId, Map<String, dynamic> sessionData, DateTime startTime, DateTime endTime) onSessionTap;
  final Function(String sessionId, Map<String, dynamic> sessionData, DateTime startTime, DateTime endTime) onSessionEdit;
  final Function(String sessionId) onSessionDelete;

  const SessionListWidget({
    super.key,
    required this.sessionsStream,
    required this.onSessionTap,
    required this.onSessionEdit,
    required this.onSessionDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: sessionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No sessions in this track yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to create your first session',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final session = snapshot.data!.docs[index];
            final data = session.data() as Map<String, dynamic>;
            
            final startTime = (data['startTime'] as Timestamp).toDate();
            final endTime = (data['endTime'] as Timestamp).toDate();

            return SessionListItem(
              sessionData: data,
              startTime: startTime,
              endTime: endTime,
              onTap: () => onSessionTap(session.id, data, startTime, endTime),
              onEdit: () => onSessionEdit(session.id, data, startTime, endTime),
              onDelete: () => onSessionDelete(session.id),
            );
          },
        );
      },
    );
  }
}
