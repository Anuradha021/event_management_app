import 'package:event_management_app1/screens/orgnizer_tickit_all_data/widgets/sold_tickets_tab.dart';
import 'package:event_management_app1/screens/orgnizer_tickit_all_data/widgets/ticket_create_dialog.dart';
import 'package:event_management_app1/screens/orgnizer_tickit_all_data/widgets/ticket_edit_dialog.dart';
import 'package:event_management_app1/screens/orgnizer_tickit_all_data/widgets/ticket_types_tab.dart';
import 'package:event_management_app1/screens/orgnizer_tickit_all_data/widgets/validate_ticket_tab.dart';
import 'package:event_management_app1/services/ticket_service.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ticket.dart';

class OrganizerTicketsScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const OrganizerTicketsScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<OrganizerTicketsScreen> createState() => _OrganizerTicketsScreenState();
}

class _OrganizerTicketsScreenState extends State<OrganizerTicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _qrController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _qrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tickets - ${widget.eventTitle}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Ticket Types'),
            Tab(text: 'Sold Tickets'),
            Tab(text: 'Validate'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TicketTypesTab(
            eventId: widget.eventId,
            onEdit: (ticketType) => _showEditDialog(ticketType),
            onDelete: (id) => _deleteTicketType(id),
          ),
          SoldTicketsTab(eventId: widget.eventId),
          ValidateTicketTab(
            qrController: _qrController,
            isLoading: _isLoading,
            onValidate: _validateTicket,
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showCreateDialog,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => TicketCreateDialog(eventId: widget.eventId),
    );
  }

  void _showEditDialog(TicketType ticketType) {
    showDialog(
      context: context,
      builder: (context) => TicketEditDialog(ticketType: ticketType),
    );
  }

  void _deleteTicketType(String ticketTypeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ticket Type'),
        content: const Text('Are you sure you want to delete this ticket type?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await TicketService.deleteTicketType(ticketTypeId);
        _showSnackBar('Ticket type deleted successfully');
      } catch (e) {
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    }
  }

  void _validateTicket() async {
    if (_qrController.text.isEmpty) {
      _showSnackBar('Please enter QR code', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await TicketService.validateTicket(_qrController.text);

      if (result.success && result.ticket != null) {
        _showValidationDialog(result.ticket!);
        _qrController.clear();
      } else {
        _showSnackBar(result.message, isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showValidationDialog(Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(' Ticket Validated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ticket: ${ticket.ticketTypeName}'),
            Text('Holder: ${ticket.userName}'),
            Text('Email: ${ticket.userEmail}'),
            Text('Price: \$${ticket.price.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
