import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../models/ticket_model.dart';
import '../../../../../services/ticket_service.dart';

class TicketConfigurationWidget extends StatefulWidget {
  final String eventId;
  final VoidCallback? onConfigurationSaved;

  const TicketConfigurationWidget({
    super.key,
    required this.eventId,
    this.onConfigurationSaved,
  });

  @override
  State<TicketConfigurationWidget> createState() => _TicketConfigurationWidgetState();
}

class _TicketConfigurationWidgetState extends State<TicketConfigurationWidget> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _regularPriceController = TextEditingController();
  final _regularQuantityController = TextEditingController();
  final _vipPriceController = TextEditingController();
  final _vipQuantityController = TextEditingController();
  
  // State
  bool _isTicketingEnabled = false;
  bool _isRegularEnabled = true;
  bool _isVipEnabled = true;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingConfiguration();
  }

  @override
  void dispose() {
    _regularPriceController.dispose();
    _regularQuantityController.dispose();
    _vipPriceController.dispose();
    _vipQuantityController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingConfiguration() async {
    setState(() => _isLoading = true);
    
    try {
      final config = await TicketService.getTicketConfig(widget.eventId);
      if (config != null) {
        setState(() {
          _isTicketingEnabled = config.isTicketingEnabled;
          _isRegularEnabled = config.regularTicket.isEnabled;
          _isVipEnabled = config.vipTicket.isEnabled;
          _regularPriceController.text = config.regularTicket.price.toString();
          _regularQuantityController.text = config.regularTicket.totalQuantity.toString();
          _vipPriceController.text = config.vipTicket.price.toString();
          _vipQuantityController.text = config.vipTicket.totalQuantity.toString();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading configuration: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final config = TicketConfig(
        eventId: widget.eventId,
        isTicketingEnabled: _isTicketingEnabled,
        regularTicket: RegularTicket(
          price: double.parse(_regularPriceController.text),
          totalQuantity: int.parse(_regularQuantityController.text),
          isEnabled: _isRegularEnabled,
        ),
        vipTicket: VipTicket(
          price: double.parse(_vipPriceController.text),
          totalQuantity: int.parse(_vipQuantityController.text),
          isEnabled: _isVipEnabled,
        ),
      );

      await TicketService.createTicketConfig(config);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket configuration saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onConfigurationSaved?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving configuration: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.confirmation_number, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Ticket Configuration',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Enable ticketing toggle
              SwitchListTile(
                title: const Text('Enable Ticketing'),
                subtitle: const Text('Allow users to purchase tickets for this event'),
                value: _isTicketingEnabled,
                onChanged: (value) => setState(() => _isTicketingEnabled = value),
              ),
              
              if (_isTicketingEnabled) ...[
                const Divider(),
                
                // Regular Tickets Section
                _buildTicketSection(
                  title: 'Regular Tickets',
                  icon: Icons.local_activity,
                  color: Colors.blue,
                  isEnabled: _isRegularEnabled,
                  onEnabledChanged: (value) => setState(() => _isRegularEnabled = value),
                  priceController: _regularPriceController,
                  quantityController: _regularQuantityController,
                ),
                
                const SizedBox(height: 20),
                
                // VIP Tickets Section
                _buildTicketSection(
                  title: 'VIP Tickets',
                  icon: Icons.star,
                  color: Colors.amber,
                  isEnabled: _isVipEnabled,
                  onEnabledChanged: (value) => setState(() => _isVipEnabled = value),
                  priceController: _vipPriceController,
                  quantityController: _vipQuantityController,
                ),
                
                const SizedBox(height: 30),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveConfiguration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Ticket Configuration',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketSection({
    required String title,
    required IconData icon,
    required Color color,
    required bool isEnabled,
    required ValueChanged<bool> onEnabledChanged,
    required TextEditingController priceController,
    required TextEditingController quantityController,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Switch(
                value: isEnabled,
                onChanged: onEnabledChanged,
              ),
            ],
          ),
          
          if (isEnabled) ...[
            const SizedBox(height: 16),
            
            Row(
              children: [
                // Price field
                Expanded(
                  child: TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price (₹)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Please enter valid price';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Quantity field
                Expanded(
                  child: TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Please enter valid quantity';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
