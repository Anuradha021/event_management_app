import 'package:flutter/material.dart';
import 'components/services/zone_data_service.dart';
import 'components/widgets/zone_detail_app_bar.dart';
import 'components/widgets/zone_info_card.dart';
import 'components/widgets/zone_update_button.dart';
import 'components/widgets/zone_update_dialog.dart';

class ZoneDetailScreen extends StatefulWidget {
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
  State<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends State<ZoneDetailScreen> {
  Map<String, dynamic> _currentZoneData = {};

  @override
  void initState() {
    super.initState();
    _currentZoneData = Map<String, dynamic>.from(widget.zoneData);
  }

  Future<void> _refreshZoneData() async {
    try {
      final data = await ZoneDataService.getZoneData(widget.eventId, widget.zoneId);
      if (data != null && mounted) {
        setState(() {
          _currentZoneData = data;
        });
      }
    } catch (e) {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    final zoneName = _currentZoneData['title'] ??_currentZoneData['name'] ??'Untitled Zone';
    final description = _currentZoneData['description'] ?? 'No description provided';

    return Scaffold(
      appBar: ZoneDetailAppBar(zoneName: zoneName),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ZoneInfoCard(
              zoneName: zoneName,
              description: description,
            ),
            const SizedBox(height: 24),
            ZoneUpdateButton(
              onPressed: () => _showUpdateDialog(zoneName, description),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(String currentName, String currentDescription) {
    showDialog(
      context: context,
      builder: (context) => ZoneUpdateDialog(
        currentName: currentName,
        currentDescription: currentDescription,
        onUpdate: _handleZoneUpdate,
      ),
    );
  }

  Future<void> _handleZoneUpdate(String name, String description) async {
    await ZoneDataService.updateZoneData(
      widget.eventId,
      widget.zoneId,
      name,
      description,
    );
    await _refreshZoneData();
  }
} 