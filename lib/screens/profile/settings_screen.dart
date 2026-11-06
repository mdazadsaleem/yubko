import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/session_store.dart';
import '../../theme/app_theme.dart';

/// Settings — edit profile (Auth API: PUT /profile) and
/// notification preferences (local only). Email is shown
/// read-only: the API has no email-change endpoint.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _bioController = TextEditingController();
  String? _city;
  bool _messageNotifications = true;
  bool _savedAlerts = true;
  bool _newListingAlerts = false;
  bool _busy = false;

  static const _cities = [
    'Lahore',
    'Karachi',
    'Islamabad',
    'Rawalpindi',
    'Peshawar',
    'Multan',
    'Faisalabad',
    'Gujranwala',
    'Sialkot',
    'Quetta',
  ];

  bool get _loggedIn => SessionStore.isLoggedIn;

  @override
  void initState() {
    super.initState();
    final user = SessionStore.currentUser.value;
    if (user != null) {
      _nameController.text = user.fullName;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _whatsappController.text = user.whatsapp ?? '';
      _bioController.text = user.bio ?? '';
      if (user.city != null && _cities.contains(user.city)) {
        _city = user.city;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );

  String _normalizePhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('92') && digits.length == 12) {
      digits = '0${digits.substring(2)}';
    }
    if (digits.length == 10 && digits.startsWith('3')) {
      digits = '0$digits';
    }
    return digits;
  }

  Future<void> _save() async {
    if (!_loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Please sign in to edit your profile.'),
        ),
      );
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Please enter your full name.'),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final updated = await AuthService.updateProfile(
        fullName: _nameController.text.trim(),
        phone: _normalizePhone(_phoneController.text),
        whatsapp: _whatsappController.text.trim().isEmpty
            ? null
            : _normalizePhone(_whatsappController.text),
        city: _city,
        bio: _bioController.text.trim(),
      );
      await SessionStore.updateUser(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Profile updated successfully.'),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.error, content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
              enabled: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                helperText: 'Email cannot be changed',
              ),
            ),
            _label('Phone Number'),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '0300 1234567'),
            ),
            _label('WhatsApp Number'),
            TextField(
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '0300 1234567'),
            ),
            _label('City'),
            DropdownButtonFormField<String>(
              initialValue: _city,
              hint: const Text('Select your city'),
              items: const [
                DropdownMenuItem(value: 'Lahore', child: Text('Lahore')),
                DropdownMenuItem(value: 'Karachi', child: Text('Karachi')),
                DropdownMenuItem(value: 'Islamabad', child: Text('Islamabad')),
                DropdownMenuItem(
                  value: 'Rawalpindi',
                  child: Text('Rawalpindi'),
                ),
                DropdownMenuItem(value: 'Peshawar', child: Text('Peshawar')),
                DropdownMenuItem(value: 'Multan', child: Text('Multan')),
                DropdownMenuItem(
                  value: 'Faisalabad',
                  child: Text('Faisalabad'),
                ),
                DropdownMenuItem(
                  value: 'Gujranwala',
                  child: Text('Gujranwala'),
                ),
                DropdownMenuItem(value: 'Sialkot', child: Text('Sialkot')),
                DropdownMenuItem(value: 'Quetta', child: Text('Quetta')),
              ],
              onChanged: (value) => setState(() => _city = value),
            ),
            _label('Bio / Dealer Info'),
            TextField(
              controller: _bioController,
              maxLength: 200,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'A short intro about you (optional)',
              ),
            ),
            if (!_loggedIn)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'You are browsing as a guest. Sign in to edit and save your profile.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.primary),
                ),
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
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving…' : 'Save Settings'),
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
                      'Account deletion is not available in the app yet. Please contact us and we will delete your account for you.',
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
