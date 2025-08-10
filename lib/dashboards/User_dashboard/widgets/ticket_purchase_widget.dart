import 'package:flutter/material.dart';
import '../../../models/ticket_model.dart';
import '../../../services/ticket_service.dart';

class TicketPurchaseWidget extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final String userId;
  final String userName;
  final String userEmail;

  const TicketPurchaseWidget({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<TicketPurchaseWidget> createState() => _TicketPurchaseWidgetState();
}

class _TicketPurchaseWidgetState extends State<TicketPurchaseWidget> {
  TicketConfig? _ticketConfig;
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadTicketConfig();
  }

  Future<void> _loadTicketConfig() async {
    setState(() => _isLoading = true);
    try {
      final config = await TicketService.getTicketConfig(widget.eventId);
      if (mounted) {
        setState(() => _ticketConfig = config);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tickets: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _purchaseTicket(String ticketType, double price) async {
    setState(() => _isPurchasing = true);

    try {
      final ticketId = await TicketService.purchaseTicket(
        eventId: widget.eventId,
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
        ticketType: ticketType,
        price: price,
      );

      if (ticketId != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ticket purchased successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Refresh config to update remaining tickets
        await _loadTicketConfig();

        // Show success dialog
        if (mounted) {
          _showPurchaseSuccessDialog(ticketId);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to purchase ticket. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  void _showPurchaseSuccessDialog(String ticketId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Purchase Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your ticket for "${widget.eventTitle}" has been purchased successfully.'),
            const SizedBox(height: 12),
            Text('Ticket ID: $ticketId'),
            const SizedBox(height: 8),
            const Text('You can view your ticket with QR code in your profile.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

    if (_ticketConfig == null || !_ticketConfig!.isTicketingEnabled) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Ticketing not available for this event',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              children: [
                Icon(Icons.confirmation_number, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Purchase Tickets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Regular Ticket Option
            if (_ticketConfig!.regularTicket.isEnabled)
              _buildTicketOption(
                title: 'Regular Ticket',
                icon: Icons.local_activity,
                color: Colors.blue,
                price: _ticketConfig!.regularTicket.price,
                remaining: _ticketConfig!.regularTicket.remainingQuantity,
                ticketType: 'regular',
              ),
            
            if (_ticketConfig!.regularTicket.isEnabled && _ticketConfig!.vipTicket.isEnabled)
              const SizedBox(height: 16),
            
            // VIP Ticket Option
            if (_ticketConfig!.vipTicket.isEnabled)
              _buildTicketOption(
                title: 'VIP Ticket',
                icon: Icons.star,
                color: Colors.amber,
                price: _ticketConfig!.vipTicket.price,
                remaining: _ticketConfig!.vipTicket.remainingQuantity,
                ticketType: 'vip',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketOption({
    required String title,
    required IconData icon,
    required Color color,
    required double price,
    required int remaining,
    required String ticketType,
  }) {
    final isAvailable = remaining > 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isAvailable ? color.withValues(alpha: 0.3) : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isAvailable ? color.withValues(alpha: 0.05) : Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                icon,
                color: isAvailable ? color : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isAvailable ? color : Colors.grey,
                ),
              ),
              const Spacer(),
              Text(
                '₹${price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isAvailable ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Availability info
          Row(
            children: [
              Icon(
                isAvailable ? Icons.check_circle : Icons.cancel,
                color: isAvailable ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                isAvailable 
                    ? '$remaining tickets remaining'
                    : 'Sold out',
                style: TextStyle(
                  color: isAvailable ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Purchase button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (isAvailable && !_isPurchasing) 
                  ? () => _purchaseTicket(ticketType, price)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isPurchasing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isAvailable ? 'Purchase Ticket' : 'Sold Out',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
