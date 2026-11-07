import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../../controllers/saved_controller.dart';
import '../../controllers/session_controller.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';
import 'reset_password_screen.dart';

enum OtpPurpose {
  /// After /register — verifies the email and logs the user in.
  register,

  /// After /forgot-password — verifies identity for a password reset.
  reset,
}

/// OTP verification screen for the Auth API's 6-digit email codes.
/// Used by sign-up verification, unverified-email logins, and the
/// forgot-password flow. Resend has the documented 60-second cooldown.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.email, required this.purpose});

  final String email;
  final OtpPurpose purpose;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 60;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _error(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.error, content: Text(message)),
    );
  }

  Future<void> _resend() async {
    try {
      if (widget.purpose == OtpPurpose.register) {
        await AuthService.resendOtp(email: widget.email);
      } else {
        await AuthService.forgotPassword(email: widget.email);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('A new OTP code has been sent to your email.'),
        ),
      );
      _startCooldown();
    } on ApiException catch (e) {
      _error(e.message);
    }
  }

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      _error('Please enter the 6-digit OTP code.');
      return;
    }
    setState(() => _busy = true);
    try {
      if (widget.purpose == OtpPurpose.register) {
        final session = await AuthService.verifyOtp(
          email: widget.email,
          otpCode: code,
        );
        await SessionController.to.save(
          token: session.token,
          newUser: session.user,
        );
        SavedController.to.syncFromServer();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              session.message ??
                  'Email verified successfully! Welcome to GharMarkaz.',
            ),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const MainShell()),
          (route) => false,
        );
      } else {
        final resetToken = await AuthService.verifyResetOtp(
          email: widget.email,
          otpCode: code,
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => ResetPasswordScreen(resetToken: resetToken),
          ),
        );
      }
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
          'Verify OTP',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.mark_email_read_outlined,
              size: 52,
              color: AppColors.primary,
            ),
            const SizedBox(height: 14),
            const Text(
              'Enter the 6-digit code',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'We sent a verification code to\n${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: 10,
              ),
              decoration: const InputDecoration(
                counterText: '',
                hintText: '••••••',
                hintStyle: TextStyle(color: AppColors.hint, letterSpacing: 10),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _busy ? null : _verify,
              child: Text(_busy ? 'Verifying…' : 'Verify'),
            ),
            const SizedBox(height: 16),
            if (_secondsLeft > 0)
              Text(
                'Resend code in ${_secondsLeft}s',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                ),
              )
            else
              TextButton(onPressed: _resend, child: const Text('Resend Code')),
          ],
        ),
      ),
    );
  }
}
