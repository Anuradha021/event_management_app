import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../services/cache_manager.dart';

class TrackCreateScreen extends StatefulWidget {
  final String eventId;
  final String zoneId;
  const TrackCreateScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
  });

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
          'Create Track',
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
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Track Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Track Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 20),
              label: const Text('CREATE TRACK'),
              style: buttonStyle.copyWith(
                backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: _isLoading ? null : _createTrack,
            ),
            if (_isLoading) const SizedBox(height: 10),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                ),
              ),
          ],
        ),
      ),
    );
  }
}