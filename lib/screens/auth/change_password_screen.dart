import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

/// Change password for the logged-in user — PUT /change-password.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _error(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.error, content: Text(message)),
    );
  }

  Future<void> _submit() async {
    if (_currentController.text.isEmpty) {
      _error('Please enter your current password.');
      return;
    }
    if (_newController.text.length < 8) {
      _error('New password must be at least 8 characters.');
      return;
    }
    if (_newController.text != _confirmController.text) {
      _error('Passwords do not match.');
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthService.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Password updated successfully.'),
        ),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      _error(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label('Current Password *'),
            TextField(
              controller: _currentController,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'Your current password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            _label('New Password *'),
            TextField(
              controller: _newController,
              obscureText: _obscure,
              decoration: const InputDecoration(
                hintText: '8+ characters',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            _label('Confirm New Password *'),
            TextField(
              controller: _confirmController,
              obscureText: _obscure,
              decoration: const InputDecoration(
                hintText: 'Re-enter your new password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _busy ? null : _submit,
              child: Text(_busy ? 'Updating…' : 'Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}
