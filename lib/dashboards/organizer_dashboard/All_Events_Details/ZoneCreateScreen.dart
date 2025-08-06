import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cache_manager.dart';

class ZoneCreateScreen extends StatefulWidget {
  final String eventId;
  const ZoneCreateScreen({super.key, required this.eventId});

  @override
  State<ZoneCreateScreen> createState() => _ZoneCreateScreenState();
}

class _ZoneCreateScreenState extends State<ZoneCreateScreen> {
  final TextEditingController _zoneNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CacheManager _cacheManager = CacheManager();
  bool _isLoading = false;

  // Keep all existing methods exactly the same
  Future<void> _createZone() async {
    final zoneName = _zoneNameController.text.trim();
    final description = _descriptionController.text.trim();

    if (zoneName.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter zone name and description")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .doc();

      final zoneData = {
        'title': zoneName,
        'description': description,
        'createdAt': Timestamp.now(),
      };

      await docRef.set(zoneData);

      final newZone = {
        ...zoneData,
        'id': docRef.id,
      };

      final cacheKey = 'zones_${widget.eventId}';
      final existing = _cacheManager.get(cacheKey) ?? [];
      existing.insert(0, newZone);
      _cacheManager.save(cacheKey, existing);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Zone created successfully")),
      );

      _zoneNameController.clear();
      _descriptionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _zoneNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
          'Create Zone',
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
              controller: _zoneNameController,
              decoration: InputDecoration(
                labelText: 'Zone Name',
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
                labelText: 'Description',
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
              label: const Text('CREATE ZONE'),
              style: buttonStyle.copyWith(
                backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: _isLoading ? null : _createZone,
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