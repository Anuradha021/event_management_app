import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme/app_theme.dart';
import '../services/ticket_service.dart';

class DebugTicketScreen extends StatefulWidget {
  const DebugTicketScreen({super.key});

  @override
  State<DebugTicketScreen> createState() => _DebugTicketScreenState();
}

class _DebugTicketScreenState extends State<DebugTicketScreen> {
  String? selectedEventId;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Ticket System'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Selection
            const Text('1. Select Event:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('events').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text('Loading events...');
                }

                final events = snapshot.data!.docs;
                return DropdownButton<String>(
                  value: selectedEventId,
                  hint: const Text('Select an event'),
                  isExpanded: true,
                  items: events.map((event) {
                    final data = event.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: event.id,
                      child: Text(data['eventTitle'] ?? 'Untitled Event'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedEventId = value;
                    });
                  },
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Create Ticket Type
            const Text('2. Create Ticket Type:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ticket Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectedEventId == null ? null : _createTicketType,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: const Text('Create Ticket Type'),
            ),
            
            const SizedBox(height: 24),
            
            // Show Ticket Types
            const Text('3. Existing Ticket Types:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (selectedEventId != null)
              Expanded(
                child: StreamBuilder(
                  stream: TicketService.getTicketTypesForOrganizer(selectedEventId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    
                    final ticketTypes = snapshot.data ?? [];
                    
                    if (ticketTypes.isEmpty) {
                      return const Text('No ticket types found for this event');
                    }
                    
                    return ListView.builder(
                      itemCount: ticketTypes.length,
                      itemBuilder: (context, index) {
                        final ticketType = ticketTypes[index];
                        return Card(
                          child: ListTile(
                            title: Text(ticketType.name),
                            subtitle: Text('Price: \$${ticketType.price} | Quantity: ${ticketType.totalQuantity} | Sold: ${ticketType.soldQuantity}'),
                            trailing: Text('ID: ${ticketType.id}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _createTicketType() async {
    if (_nameController.text.isEmpty || 
        _priceController.text.isEmpty || 
        _quantityController.text.isEmpty ||
        selectedEventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an event')),
      );
      return;
    }

    try {
      await TicketService.createTicketType(
        eventId: selectedEventId!,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        totalQuantity: int.parse(_quantityController.text),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket type created successfully!')),
      );

      // Clear form
      _nameController.clear();
      _priceController.clear();
      _quantityController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
