import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';

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
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
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
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
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
          _buildTicketTypesTab(),
          _buildSoldTicketsTab(),
          _buildValidateTab(),
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

  Widget _buildTicketTypesTab() {
    return StreamBuilder<List<TicketType>>(
      stream: TicketService.getTicketTypesForOrganizer(widget.eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final ticketTypes = snapshot.data ?? [];

        if (ticketTypes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.confirmation_number, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No ticket types created'),
                Text('Tap + to create your first ticket type'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ticketTypes.length,
          itemBuilder: (context, index) {
            final ticketType = ticketTypes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ticketType.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '\$${ticketType.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${ticketType.soldQuantity}/${ticketType.totalQuantity} sold'),
                    Text('Revenue: \$${ticketType.revenue.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: ticketType.totalQuantity > 0 
                          ? ticketType.soldQuantity / ticketType.totalQuantity 
                          : 0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _showEditDialog(ticketType),
                          child: const Text('Edit'),
                        ),
                        TextButton(
                          onPressed: () => _deleteTicketType(ticketType.id),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSoldTicketsTab() {
    return StreamBuilder<List<Ticket>>(
      stream: TicketService.getTicketsForEvent(widget.eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

           final tickets = (snapshot.data ?? []);
         

        if (tickets.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No tickets sold yet'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.ticketTypeName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(ticket.userName),
                              Text(ticket.userEmail),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ticket.isUsed ? Colors.green : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                ticket.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${ticket.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('QR: ${ticket.qrCode}'),
                    Text('Purchased: ${_formatDate(ticket.purchaseDate)}'),
                    if (ticket.usedAt != null)
                      Text('Used: ${_formatDate(ticket.usedAt!)}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildValidateTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _qrController,
            decoration: const InputDecoration(
              labelText: 'Enter QR Code',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.qr_code),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _validateTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Validate Ticket'),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    _nameController.clear();
    _priceController.clear();
    _quantityController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Ticket Type'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ticket Name (e.g., VIP, Regular)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter ticket type name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                  hintText: '0.00',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Total Quantity',
                  border: OutlineInputBorder(),
                  hintText: 'Number of tickets available',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: Once created, customers will be able to purchase this ticket type for your event.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _createTicketType,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Create Ticket Type'),
          ),
        ],
      ),
    );
  }

  void _createTicketType() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      _showSnackBar('Please fill all fields', isError: true);
      return;
    }

    try {
      await TicketService.createTicketType(
        eventId: widget.eventId,
        name: _nameController.text,
        description: '', // Can be added later if needed
        price: double.parse(_priceController.text),
        totalQuantity: int.parse(_quantityController.text),
      );

      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Ticket type "${_nameController.text}" created successfully!');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  void _showEditDialog(TicketType ticketType) {
    _nameController.text = ticketType.name;
    _priceController.text = ticketType.price.toString();
    _quantityController.text = ticketType.totalQuantity.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Ticket Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ticket Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price (\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Total Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateTicketType(ticketType.id),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _updateTicketType(String ticketTypeId) async {
    try {
      await TicketService.updateTicketType(
        ticketTypeId: ticketTypeId,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        totalQuantity: int.parse(_quantityController.text),
      );

      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Ticket type updated successfully');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
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
        title: const Text('✅ Ticket Validated'),
        contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
        content: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ticket: ${ticket.ticketTypeName}'),
              const SizedBox(height: 8),
              Text('Holder: ${ticket.userName}'),
              const SizedBox(height: 8),
              Text('Email: ${ticket.userEmail}'),
              const SizedBox(height: 8),
              Text('Price: \$${ticket.price.toStringAsFixed(2)}'),
            ],
          ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
