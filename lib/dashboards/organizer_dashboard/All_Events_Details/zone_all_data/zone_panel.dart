import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/zone_all_data/zone_detail_screen.dart';
import 'package:flutter/material.dart';
// import 'ZoneDetailScreen.dart';
import '../components/services/zone_panel_service.dart';
import '../components/widgets/panel_header.dart';
import '../components/widgets/zone_list_view.dart';
import '../components/widgets/create_zone_dialog.dart';
import '../components/widgets/delete_confirmation_dialog.dart';

class ZonePanel extends StatelessWidget {
  final String eventId;

  const ZonePanel({
    super.key,
    required this.eventId,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: PanelHeader(
            title: 'Event Zones',
            onCreatePressed: () => _showCreateZoneDialog(context),
            createTooltip: 'Create Zone',
          ),
        ),
  
        Expanded(
          child: ZoneListView(
            zonesStream: ZonePanelService.getZonesStream(eventId),
            onZoneTap: (zoneId, data) => _showZoneDetails(context, zoneId, data),
            onZoneEdit: (zoneId, data) => _showZoneDetails(context, zoneId, data),
            onZoneDelete: (zoneId) => _handleDeleteZone(context, zoneId),
          ),
        ),
      ],
    );
  }

  void _showZoneDetails(BuildContext context, String zoneId, Map<String, dynamic> zoneData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZoneDetailScreen(
          eventId: eventId,
          zoneId: zoneId,
          zoneData: zoneData,
        ),
      ),
    );
  }

  void _showCreateZoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateZoneDialog(
        onCreate: (name, description) => ZonePanelService.createZone(eventId, name, description),
      ),
    );
  }

  void _handleDeleteZone(BuildContext context, String zoneId) {
   
    final zoneName = 'Zone'; 

    DeleteConfirmationDialog.show(
      context,
      itemType: 'Zone',
      itemName: zoneName,
      onConfirm: () => ZonePanelService.deleteZone(eventId, zoneId),
    );
  }
}