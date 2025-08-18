import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/orgnizer_dashboard_all_data/moderator.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/moderator_service.dart';
import 'widgets/add_moderator_form.dart';
import 'widgets/moderator_list.dart';

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

  // Add Moderator
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

  // Remove Moderator
  void _removeModerator(Moderator moderator) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Moderator'),
        content: Text('Are you sure you want to remove ${moderator.userName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
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

  void _editModerator(Moderator moderator) {
    _showSnackBar('Edit moderator feature coming soon');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
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
          AddModeratorForm(
            emailController: _emailController,
            formKey: _formKey,
            isLoading: _isLoading,
            selectedPermissions: _selectedPermissions,
            onAddModerator: _addModerator,
          ),
          const SizedBox(height: 16),
          ModeratorList(
            eventId: widget.eventId,
            onEdit: _editModerator,
            onRemove: _removeModerator,
          ),
        ],
      ),
    );
  }
}
