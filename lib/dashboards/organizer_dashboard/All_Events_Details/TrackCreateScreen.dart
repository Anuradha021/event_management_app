import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/services/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TrackCreateScreen extends StatefulWidget {
  final String eventId;
  final String zoneId;

  const TrackCreateScreen({super.key, required this.eventId, required this.zoneId});

  @override
  State<TrackCreateScreen> createState() => _TrackCreateScreenState();
}

class _TrackCreateScreenState extends State<TrackCreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CacheManager _cacheManager = CacheManager();
  bool _isLoading = false;

  Future<void> _createTrack() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final String trackId = const Uuid().v4();
      final trackRef = FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .doc(widget.zoneId)
          .collection('tracks')
          .doc(trackId);

    await trackRef.set({
  'title': _titleController.text.trim(),
  'description': _descriptionController.text.trim(),
  'id': trackId,
  'eventId': widget.eventId,
  'zoneId': widget.zoneId,
  'createdAt': FieldValue.serverTimestamp(),
});
final newTrack = {
  'title': _titleController.text.trim(),
  'description': _descriptionController.text.trim(),
  'id': trackId,
  'eventId': widget.eventId,
  'zoneId': widget.zoneId,
};

final cacheKey = 'tracks_${widget.eventId}_${widget.zoneId}';
final existing = _cacheManager.get(cacheKey) ?? [];
existing.insert(0, newTrack); 
_cacheManager.save(cacheKey, existing);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Track created successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error creating track: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
    'Create Track',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Track Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Track Description'),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createTrack,
                    child: const Text('Create Track'),
                  )
          ],
        ),
      ),
    );
  }
}