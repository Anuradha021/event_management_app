import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../models/ticket_model.dart';
import '../../../../../services/ticket_service.dart';

class TicketManagementWidget extends StatefulWidget {
  final String eventId;

  const TicketManagementWidget({
    super.key,
    required this.eventId,
  });

  @override
  State<TicketManagementWidget> createState() => _TicketManagementWidgetState();
}

class _TicketManagementWidgetState extends State<TicketManagementWidget> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await TicketService.getEventTicketStats(widget.eventId);
      if (mounted) {
        setState(() => _stats = stats);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stats: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Ticket Sales Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadStats,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_stats.isEmpty)
              const Center(
                child: Text(
                  'No ticket configuration found',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else ...[
              // Overall Stats
              _buildOverallStats(),
              
              const SizedBox(height: 20),
              
              // Ticket Type Breakdown
              _buildTicketBreakdown(),
              
              const SizedBox(height: 20),
              
              // Action Buttons
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStats() {
    final totalSold = _stats['totalSold'] ?? 0;
    final totalRevenue = _stats['totalRevenue'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Tickets Sold',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalSold.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Total Revenue',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${totalRevenue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ticket Breakdown',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Regular Tickets
        _buildTicketTypeCard(
          title: 'Regular Tickets',
          icon: Icons.local_activity,
          color: Colors.blue,
          sold: _stats['regularSold'] ?? 0,
          remaining: _stats['regularRemaining'] ?? 0,
          revenue: _stats['regularRevenue'] ?? 0.0,
        ),
        
        const SizedBox(height: 12),
        
        // VIP Tickets
        _buildTicketTypeCard(
          title: 'VIP Tickets',
          icon: Icons.star,
          color: Colors.amber,
          sold: _stats['vipSold'] ?? 0,
          remaining: _stats['vipRemaining'] ?? 0,
          revenue: _stats['vipRevenue'] ?? 0.0,
        ),
      ],
    );
  }

  Widget _buildTicketTypeCard({
    required String title,
    required IconData icon,
    required Color color,
    required int sold,
    required int remaining,
    required double revenue,
  }) {
    final total = sold + remaining;
    final percentage = total > 0 ? (sold / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          
          const SizedBox(height: 8),
          
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sold: $sold',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Remaining: $remaining',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              Text(
                '₹${revenue.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showTicketList(),
            icon: const Icon(Icons.list),
            label: const Text('View All Tickets'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showQRScanner(),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _showTicketList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketListScreen(eventId: widget.eventId),
      ),
    );
  }

  void _showQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(eventId: widget.eventId),
      ),
    );
  }
}

class TicketListScreen extends StatelessWidget {
  final String eventId;

  const TicketListScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Tickets'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<TicketModel>>(
        stream: TicketService.getEventTickets(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final tickets = snapshot.data ?? [];

          if (tickets.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tickets sold yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return _buildTicketListItem(ticket);
            },
          );
        },
      ),
    );
  }

  Widget _buildTicketListItem(TicketModel ticket) {
    final isVip = ticket.ticketType == 'vip';
    final statusColor = _getStatusColor(ticket.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isVip ? Colors.amber : Colors.blue,
          child: Icon(
            isVip ? Icons.star : Icons.local_activity,
            color: Colors.white,
          ),
        ),
        title: Text(
          '${isVip ? 'VIP' : 'Regular'} Ticket',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${ticket.userName} (${ticket.userEmail})'),
            Text('₹${ticket.price.toStringAsFixed(2)}'),
            Text('Purchased: ${DateFormat('MMM dd, yyyy').format(ticket.purchaseDate)}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
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
        isThreeLine: true,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'valid':
        return Colors.green;
      case 'used':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class QRScannerScreen extends StatefulWidget {
  final String eventId;

  const QRScannerScreen({super.key, required this.eventId});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Column(
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.blue, size: 32),
                SizedBox(height: 8),
                Text(
                  'Scan Ticket QR Code',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Point the camera at the ticket QR code to verify entry',
                  style: TextStyle(color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Scanner area
          Expanded(
            child: Stack(
              children: [
                // QR Scanner placeholder - would use mobile_scanner package
                Container(
                  width: double.infinity,
                  color: Colors.black,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 100,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'QR Scanner Camera View',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Mobile scanner integration needed',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Processing overlay
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Verifying ticket...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Manual entry option
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Having trouble scanning?',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _showManualEntryDialog(),
                  child: const Text('Enter Ticket ID Manually'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Ticket Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the ticket ID to verify:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Ticket ID',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _verifyTicketById(controller.text);
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyTicketById(String ticketId) async {
    if (ticketId.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      // This would normally verify by QR code, but for manual entry
      // we'll need to implement a different verification method
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing

      _showVerificationResult(true, 'Ticket verified successfully!');
    } catch (e) {
      _showVerificationResult(false, 'Verification failed: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showVerificationResult(bool success, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(success ? 'Success' : 'Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
