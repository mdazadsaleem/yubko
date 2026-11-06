import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_top_bar.dart';
import '../home/home_screen.dart';

/// Login / Sign Up screen — design-only replica of the website's
/// /auth page (yubko.com), reached from the dashboard's Next button.
/// "Continue as guest" is kept on this screen too (top bar).
/// No API calls yet: buttons show a "design only" message until
/// the web developer provides the APIs.
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

  void _showDesignOnly(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text('$action — design only. API integration coming soon.'),
      ),
    );
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
      final phoneDigits = _phoneController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      if (phoneDigits.length < 10) {
        _showError('Please enter a valid phone number.');
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
    _enterApp(_isLogin ? 'Log in' : 'Create account');
  }

  /// Design phase only: entering the app shows the design preview.
  /// In Phase 2 this is replaced by the real API login / sign up.
  void _enterApp(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text('$action — design preview (no API yet).'),
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
      (route) => false,
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
              AppTopBar(
                showBack: true,
                onGuestTap: () => _enterApp('Continue as guest'),
              ),
              const SizedBox(height: 18),
              _buildFormCard(),
              const SizedBox(height: 20),
              const Text(
                '© 2026 GharMarkaz. Developed for Pakistan Real Estate Market.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
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
            onTap: () => _enterApp('Google sign-in'),
          ),
          const SizedBox(height: 10),
          _socialButton(
            letter: 'f',
            letterColor: AppColors.facebook,
            label: 'Continue with Facebook',
            onTap: () => _enterApp('Facebook sign-in'),
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
            onPressed: _onPrimaryPressed,
            child: Text(_isLogin ? 'Log in' : 'Create account'),
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
              'Enter your email and we will send you a reset link.',
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
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showDesignOnly('Password reset');
            },
            child: const Text('Send reset link'),
          ),
        ],
      ),
    );
  }
}
