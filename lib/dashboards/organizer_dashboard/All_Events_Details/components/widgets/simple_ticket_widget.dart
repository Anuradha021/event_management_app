import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../models/ticket_model.dart';
import '../../../../../services/ticket_service.dart';

class SimpleTicketWidget extends StatefulWidget {
  final String eventId;

  const SimpleTicketWidget({
    super.key,
    required this.eventId,
  });

  @override
  State<SimpleTicketWidget> createState() => _SimpleTicketWidgetState();
}

class _SimpleTicketWidgetState extends State<SimpleTicketWidget> {
  int _totalSeats = 0;
  List<Map<String, dynamic>> _ticketTypes = [];
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTicketData();
  }

  Future<void> _loadTicketData() async {
    setState(() => _isLoading = true);

    try {
      // Load existing configuration
      final config = await TicketService.getTicketConfig(widget.eventId);
      if (config != null && config.isTicketingEnabled) {
        setState(() {
          _totalSeats = config.regularTicket.totalQuantity;
          if (config.regularTicket.isEnabled) {
            _ticketTypes = [
              {
                'name': 'Regular Ticket',
                'price': config.regularTicket.price,
                'quantity': config.regularTicket.totalQuantity,
              }
            ];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading ticket data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddTicketTypeDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Ticket Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ticket Name',
                hintText: 'e.g., Regular, VIP',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Price (₹)',
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
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
            onPressed: () => _addTicketType(
              nameController.text,
              priceController.text,
              quantityController.text,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addTicketType(String name, String price, String quantity) {
    if (name.isEmpty || price.isEmpty || quantity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final ticketPrice = double.tryParse(price);
    final ticketQuantity = int.tryParse(quantity);

    if (ticketPrice == null || ticketQuantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    setState(() {
      _ticketTypes.add({
        'name': name,
        'price': ticketPrice,
        'quantity': ticketQuantity,
      });
      _totalSeats += ticketQuantity;
    });

    Navigator.pop(context);
    _saveTicketConfig();
  }

  Future<void> _saveTicketConfig() async {
    if (_ticketTypes.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final firstTicket = _ticketTypes.first;
      final config = TicketConfig(
        eventId: widget.eventId,
        isTicketingEnabled: true,
        regularTicket: RegularTicket(
          price: firstTicket['price'],
          totalQuantity: firstTicket['quantity'],
          isEnabled: true,
        ),
        vipTicket: VipTicket(
          price: 0,
          totalQuantity: 0,
          isEnabled: false,
        ),
      );

      await TicketService.createTicketConfig(config);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket configuration saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Ticketing',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 24),

          // Total Seats Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Seats',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _totalSeats.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Ticket Types Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ticket Types',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showAddTicketTypeDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Type'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Ticket Types List or Empty State
          if (_ticketTypes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              child: Text(
                'No ticket types added yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            )
          else
            ..._ticketTypes.map((ticket) => _buildTicketTypeCard(ticket)).toList(),
        ],
      ),
    );
  }

  Widget _buildTicketTypeCard(Map<String, dynamic> ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${ticket['price']} • ${ticket['quantity']} tickets',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeTicketType(ticket),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _removeTicketType(Map<String, dynamic> ticket) {
    setState(() {
      _totalSeats -= ticket['quantity'] as int;
      _ticketTypes.remove(ticket);
    });

    if (_ticketTypes.isEmpty) {
      // Disable ticketing if no ticket types
      _disableTicketing();
    } else {
      _saveTicketConfig();
    }
  }

  Future<void> _disableTicketing() async {
    try {
      final config = TicketConfig(
        eventId: widget.eventId,
        isTicketingEnabled: false,
        regularTicket: RegularTicket(
          price: 0,
          totalQuantity: 0,
          isEnabled: false,
        ),
        vipTicket: VipTicket(
          price: 0,
          totalQuantity: 0,
          isEnabled: false,
        ),
      );

      await TicketService.createTicketConfig(config);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
