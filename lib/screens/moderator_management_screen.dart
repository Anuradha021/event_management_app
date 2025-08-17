import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/moderator.dart';
import '../services/moderator_service.dart';

class ModeratorManagementScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const ModeratorManagementScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<ModeratorManagementScreen> createState() => _ModeratorManagementScreenState();
}

class _ModeratorManagementScreenState extends State<ModeratorManagementScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> _selectedPermissions = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moderators - ${widget.eventTitle}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
       
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Moderator',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'User Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Select Permissions:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPermissionsSelector(),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _addModerator,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Add Moderator'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Moderators List
          StreamBuilder<List<Moderator>>(
            stream: ModeratorService.getModeratorsForEvent(widget.eventId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ));
              }

              final moderators = snapshot.data ?? [];

              if (moderators.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No moderators added'),
                        Text('Add moderators to help manage your event'),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: moderators
                    .map((moderator) => _buildModeratorCard(moderator))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsSelector() {
    return Column(
      children: ModeratorPermissions.all.map((permission) {
        return CheckboxListTile(
          title: Text(ModeratorPermissions.getDisplayName(permission)),
          subtitle: Text(
            ModeratorPermissions.getDescription(permission),
            style: const TextStyle(fontSize: 12),
          ),
          value: _selectedPermissions.contains(permission),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedPermissions.add(permission);
              } else {
                _selectedPermissions.remove(permission);
              }
            });
          },
          activeColor: AppTheme.primaryColor,
          dense: true,
        );
      }).toList(),
    );
  }

  Widget _buildModeratorCard(Moderator moderator) {
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
                        moderator.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        moderator.userEmail,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(moderator.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    moderator.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Permissions:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: moderator.permissions.map((permission) {
                return Chip(
                  label: Text(
                    ModeratorPermissions.getDisplayName(permission),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _editModerator(moderator),
                  child: const Text('Edit'),
                ),
                TextButton(
                  onPressed: () => _removeModerator(moderator),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _addModerator() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPermissions.isEmpty) {
      _showSnackBar('Please select at least one permission', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ModeratorService.addModerator(
        eventId: widget.eventId,
        userEmail: _emailController.text.trim(),
        permissions: _selectedPermissions,
      );

      _emailController.clear();
      _selectedPermissions.clear();
      _showSnackBar('Moderator invitation sent successfully');
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _editModerator(Moderator moderator) {
    _showSnackBar('Edit moderator feature coming soon');
  }

  void _removeModerator(Moderator moderator) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Moderator'),
        content: Text('Are you sure you want to remove ${moderator.userName} as a moderator?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ModeratorService.removeModerator(moderator.id);
        _showSnackBar('Moderator removed successfully');
      } catch (e) {
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    }
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
