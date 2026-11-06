import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Settings — edit profile and notification preferences.
/// Design only; values stay on this screen until Phase 2 APIs.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController(text: 'Marwa');
  final _emailController = TextEditingController(text: 'marwa@example.com');
  final _phoneController = TextEditingController(text: '300 1112233');
  String _accountType = 'Property Owner';
  bool _messageNotifications = true;
  bool _savedAlerts = true;
  bool _newListingAlerts = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );

  void _saved() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.primary,
        content: Text('Settings updated in the design preview.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            _label('Full Name'),
            TextField(controller: _nameController),
            _label('Email Address'),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            _label('Phone Number'),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(prefixText: '+92 '),
            ),
            _label('Account Type'),
            DropdownButtonFormField<String>(
              initialValue: _accountType,
              items: const [
                DropdownMenuItem(
                  value: 'Property Owner',
                  child: Text('Property Owner'),
                ),
                DropdownMenuItem(value: 'Agent', child: Text('Agent')),
                DropdownMenuItem(
                  value: 'Builder / Developer',
                  child: Text('Builder / Developer'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _accountType = value ?? _accountType),
            ),
            const SizedBox(height: 22),
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Chat messages'),
              subtitle: const Text('New messages from buyers and sellers'),
              value: _messageNotifications,
              activeThumbColor: AppColors.emerald,
              onChanged: (value) =>
                  setState(() => _messageNotifications = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Saved homes alerts'),
              subtitle: const Text('Price changes on properties you saved'),
              value: _savedAlerts,
              activeThumbColor: AppColors.emerald,
              onChanged: (value) => setState(() => _savedAlerts = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('New listings'),
              subtitle: const Text('New properties in your saved searches'),
              value: _newListingAlerts,
              activeThumbColor: AppColors.emerald,
              onChanged: (value) => setState(() => _newListingAlerts = value),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _saved,
              child: const Text('Save Settings'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                foregroundColor: AppColors.error,
              ),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Delete account?',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    content: const Text(
                      'This is only a design preview. Account deletion will be confirmed through the API in Phase 2.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Delete Account',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
