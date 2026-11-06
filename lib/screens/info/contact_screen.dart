import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'info_screen.dart';

/// Contact Us — the website's /contact page: Helpline with
/// WhatsApp Support, Email with reply time, View FAQs link, and
/// the Send a Message form (Full Name*, Email Address*, Phone
/// (optional), Topic, Message*). Design only.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  static const _topics = [
    'General Inquiry',
    'Listing Help / Verification',
    'Report Fraud / Fake Listing',
    'Roommate Finder',
    'Agency Partnership',
  ];

  String _topic = _topics.first;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );

  void _soon(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text('$action — design only.'),
      ),
    );
  }

  void _send() {
    String? error;
    if (_nameController.text.trim().isEmpty) {
      error = 'Please enter your full name.';
    } else if (!RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(_emailController.text.trim())) {
      error = 'Please enter a valid email address.';
    } else if (_messageController.text.trim().isEmpty) {
      error = 'Please write your message.';
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.error, content: Text(error)),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Design only',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Your message is ready. It will be sent when the developer APIs are connected. Replies typically arrive within 2–4 hours.',
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

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String value,
    required String note,
    required List<Widget> actions,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 21),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Text(
            note,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 11),
          Row(children: actions),
        ],
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
          'Contact Us',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _contactCard(
              icon: Icons.call_outlined,
              title: 'Helpline',
              value: '+92 51 889 4427',
              note: 'Call us for listing and account help.',
              actions: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      backgroundColor: AppColors.whatsapp,
                    ),
                    onPressed: () => _soon('WhatsApp Support'),
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('WhatsApp Support'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            _contactCard(
              icon: Icons.email_outlined,
              title: 'Email',
              value: 'support@gharmark.pk',
              note: 'Replies typically within 2–4 hours.',
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const InfoScreen(kind: InfoKind.faqs),
                    ),
                  ),
                  child: const Text('Have a general question? View FAQs'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Send a Message',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'Fill out the form below and we will respond via email or phone.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
            _label('Full Name *'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Your full name'),
            ),
            _label('Email Address *'),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'name@example.com'),
            ),
            _label('Phone Number (Optional)'),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '3XX XXXXXXX',
                prefixText: '+92 ',
              ),
            ),
            _label('Topic'),
            DropdownButtonFormField<String>(
              initialValue: _topic,
              items: [
                for (final topic in _topics)
                  DropdownMenuItem(value: topic, child: Text(topic)),
              ],
              onChanged: (value) => setState(() => _topic = value ?? _topic),
            ),
            _label('Message *'),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write your message…',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _send, child: const Text('Send Message')),
          ],
        ),
      ),
    );
  }
}
