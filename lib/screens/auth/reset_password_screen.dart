import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'auth_screen.dart';

/// Set a new password after the reset OTP has been verified.
/// Calls POST /reset-password with the 15-minute resetToken.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.resetToken});

  final String resetToken;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _error(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.error, content: Text(message)),
    );
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    if (password.length < 8) {
      _error('Password must be at least 8 characters.');
      return;
    }
    if (password != _confirmController.text) {
      _error('Passwords do not match.');
      return;
    }
    setState(() => _busy = true);
    try {
      final message = await AuthService.resetPassword(
        resetToken: widget.resetToken,
        newPassword: password,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.primary, content: Text(message)),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    } on ApiException catch (e) {
      _error(e.message);
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
          'Reset Password',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose a new password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            const Text(
              'Your OTP is verified. Set a new password for your account.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 18),
            const Text(
              'New Password *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: '8+ characters',
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
            const SizedBox(height: 14),
            const Text(
              'Confirm New Password *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _confirmController,
              obscureText: _obscure,
              decoration: const InputDecoration(
                hintText: 'Re-enter your new password',
                prefixIcon: Icon(Icons.lock_outlined),
              ),
            ),
            const SizedBox(height: 22),
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
