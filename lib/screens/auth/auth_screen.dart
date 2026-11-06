import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/auth_service.dart';
import '../../services/session_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_top_bar.dart';
import '../home/home_screen.dart';
import 'otp_screen.dart';

/// Login / Sign Up screen — the website's /auth page (yubko.com),
/// reached from the dashboard's Next button. Integrated with the
/// developer's Authentication API (2026-11-06): login, register +
/// email OTP, forgot-password OTP reset, and Google sign-in are
/// real calls. "Continue as guest" stays in the top bar.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _bioController = TextEditingController();

  bool _obscurePassword = true;
  bool _keepSignedIn = true;
  bool _busy = false;
  String? _signupCity;

  // The sign-up City dropdown on the website has only these cities.
  static const _signupCities = [
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _whatsappController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.error, content: Text(message)),
    );
  }

  void _onPrimaryPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showError('Please enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      _showError('Please enter your password.');
      return;
    }
    if (!_isLogin) {
      if (_nameController.text.trim().isEmpty) {
        _showError('Please enter your full name.');
        return;
      }
      final phone = _normalizePhone(_phoneController.text);
      if (!RegExp(r'^03\d{9}$').hasMatch(phone)) {
        _showError(
          'Please enter a valid mobile number (03XXXXXXXXX, 11 digits).',
        );
        return;
      }
      if (password.length < 8) {
        _showError('Password must be at least 8 characters.');
        return;
      }
      if (_signupCity == null) {
        _showError('Please select your city.');
        return;
      }
    }
    if (_busy) return;
    if (_isLogin) {
      _doLogin(email, password);
    } else {
      _doRegister(email, password);
    }
  }

  /// Continue as guest: enters the app with no account/session.
  void _enterAsGuest() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  void _goHome(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.primary, content: Text(message)),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  /// Normalizes a Pakistani number to the API's 03XXXXXXXXX format.
  String _normalizePhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('92') && digits.length == 12) {
      digits = '0${digits.substring(2)}';
    }
    return digits;
  }

  Future<void> _doLogin(String email, String password) async {
    setState(() => _busy = true);
    try {
      final session = await AuthService.login(email: email, password: password);
      await SessionStore.save(token: session.token, user: session.user);
      if (!mounted) return;
      _goHome(session.message ?? 'Logged in successfully.');
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.requiresOtp) {
        // Unverified email: the API already sent a fresh OTP.
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => OtpScreen(
              email: e.data?['email']?.toString() ?? email,
              purpose: OtpPurpose.register,
            ),
          ),
        );
      } else if (e.isSuspended) {
        _showSuspended(e.message);
      } else {
        _showError(e.message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _doRegister(String email, String password) async {
    setState(() => _busy = true);
    try {
      final whatsapp = _whatsappController.text.trim();
      final registeredEmail = await AuthService.register(
        fullName: _nameController.text.trim(),
        email: email,
        password: password,
        phone: _normalizePhone(_phoneController.text),
        whatsapp: whatsapp.isEmpty ? null : _normalizePhone(whatsapp),
        city: _signupCity,
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(
            'Registration successful! An OTP verification code has been sent to your email.',
          ),
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              OtpScreen(email: registeredEmail, purpose: OtpPurpose.register),
        ),
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onGooglePressed() async {
    setState(() => _busy = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // user cancelled
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        _showError('Google sign-in failed: no ID token was returned.');
        return;
      }
      final session = await AuthService.loginWithGoogle(idToken);
      await SessionStore.save(token: session.token, user: session.user);
      if (!mounted) return;
      _goHome(session.message ?? 'Google authentication successful.');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(
        'Google sign-in is not configured for this app yet. The developer needs to add the Google client configuration (client IDs).',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onFacebookPressed() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Facebook sign-in',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Facebook login needs the Facebook App ID and native setup from the developer before it can return an access token. The app\'s backend call (POST /facebook) is ready — this button will work as soon as that configuration is added.',
          style: TextStyle(fontSize: 13, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuspended(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Account Suspended',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  int get _passwordScore {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    var score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
    return score == 0 ? 1 : score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTopBar(showBack: true),
              const SizedBox(height: 18),
              _buildFormCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isLogin ? 'Welcome back' : 'Create your account',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _isLogin
                ? 'Sign in to continue to GharMarkaz.'
                : "Join Pakistan's transparent property marketplace.",
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          _socialButton(
            letter: 'G',
            letterColor: const Color(0xFFEA4335),
            label: 'Continue with Google',
            onTap: _onGooglePressed,
          ),
          const SizedBox(height: 10),
          _socialButton(
            letter: 'f',
            letterColor: AppColors.facebook,
            label: 'Continue with Facebook',
            onTap: _onFacebookPressed,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _enterAsGuest,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              foregroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.person_outline, size: 19),
            label: const Text(
              'Continue as guest',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'OR CONTINUE WITH EMAIL',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTabs(),
          const SizedBox(height: 18),
          if (!_isLogin) ...[
            _label('Full name *'),
            TextField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                hintText: 'e.g. Muhammad Ali',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
          ],
          _label('Email address *'),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: _isLogin ? 'you@example.com' : 'ali@example.com',
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 14),
          _label('Password *'),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '8+ characters',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          if (!_isLogin) ...[
            const SizedBox(height: 6),
            const Text(
              'Letters and numbers',
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            _buildPasswordStrength(),
            const SizedBox(height: 14),
            _label('Mobile number *'),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '0300 1234567',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 14),
            _label('City *'),
            DropdownButtonFormField<String>(
              initialValue: _signupCity,
              hint: const Text('Select city…'),
              items: [
                for (final city in _signupCities)
                  DropdownMenuItem(value: city, child: Text(city)),
              ],
              onChanged: (value) => setState(() => _signupCity = value),
            ),
            const SizedBox(height: 14),
            _label('WhatsApp number (optional)'),
            TextField(
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Only if different from mobile',
                prefixIcon: Icon(Icons.chat_outlined),
              ),
            ),
            const SizedBox(height: 14),
            _label('Bio / dealer info (optional)'),
            TextField(
              controller: _bioController,
              maxLength: 200,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Agency name or a short bio',
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_isLogin)
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _keepSignedIn,
                    onChanged: (v) =>
                        setState(() => _keepSignedIn = v ?? false),
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Keep me signed in on this device',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showForgotPassword,
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _busy ? null : _onPrimaryPressed,
            child: Text(
              _busy ? 'Please wait…' : (_isLogin ? 'Log in' : 'Create account'),
            ),
          ),
          const SizedBox(height: 14),
          if (!_isLogin)
            const Text(
              'By continuing, you agree to our Terms of Use and Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? 'New to GharMarkaz? ' : 'Already have an account? ',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? 'Create an account' : 'Sign in',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _tabButton('Login', _isLogin),
          _tabButton('Sign Up', !_isLogin),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isLogin = label == 'Login'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton({
    required String letter,
    required Color letterColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        foregroundColor: AppColors.textPrimary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            letter,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: letterColor,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStrength() {
    final score = _passwordScore;
    const labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    const colors = [
      AppColors.border,
      AppColors.error,
      Color(0xFFF59E0B),
      Color(0xFF84CC16),
      AppColors.emerald,
    ];
    return Row(
      children: [
        const Text(
          'Password strength: ',
          style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score == 0 ? 0 : score / 4,
              minHeight: 5,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(colors[score]),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          score == 0 ? '—' : labels[score],
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: colors[score] == AppColors.border
                ? AppColors.textMuted
                : colors[score],
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  void _showForgotPassword() {
    final emailController = TextEditingController(text: _emailController.text);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Forgot password?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email and we will send you a 6-digit reset code.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'name@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 42),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            onPressed: () async {
              final email = emailController.text.trim();
              Navigator.of(dialogContext).pop();
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                _showError('Please enter a valid email address.');
                return;
              }
              try {
                await AuthService.forgotPassword(email: email);
                if (!mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        OtpScreen(email: email, purpose: OtpPurpose.reset),
                  ),
                );
              } on ApiException catch (e) {
                _showError(e.message);
              }
            },
            child: const Text('Send OTP code'),
          ),
        ],
      ),
    );
  }
}
