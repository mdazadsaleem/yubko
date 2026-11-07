import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/api_user.dart';
import '../../data/dummy_data.dart';
import '../../services/auth_service.dart';
import 'package:get/get.dart';

import '../../controllers/catalog_controller.dart';
import '../../controllers/saved_controller.dart';
import '../../services/catalog_service.dart';
import '../../controllers/session_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/property_card.dart';
import '../chat/chats_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../info/contact_screen.dart';
import '../info/info_screen.dart';
import '../properties/property_detail_screen.dart';
import '../roommates/roommates_screen.dart';
import '../saved/saved_screen.dart';
import '../auth/change_password_screen.dart';
import 'settings_screen.dart';

/// Profile tab — the signed-in user's header (Auth API), My Ads,
/// and menu links to the other app sections and the website's
/// static pages. Guests see a guest header.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickAvatar(BuildContext context) async {
    final user = SessionController.to.user.value;
    if (user == null) return;
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text(
          'Profile photo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop('upload'),
            child: const Text('Upload new photo'),
          ),
          if (user.avatarUrl != null)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop('remove'),
              child: const Text('Remove photo'),
            ),
        ],
      ),
    );
    if (action == null || !context.mounted) return;
    try {
      if (action == 'upload') {
        final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
        );
        if (picked == null) return;
        final updated = await AuthService.uploadAvatar(File(picked.path));
        await SessionController.to.updateUser(updated);
      } else {
        final updated = await AuthService.removeAvatar();
        await SessionController.to.updateUser(updated);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Profile photo updated.'),
        ),
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.error, content: Text(e.message)),
      );
    }
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Widget _menuTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppColors.textMuted,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = SessionController.to.user.value;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Profile',
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: user == null ? null : () => _pickAvatar(context),
                      child: CircleAvatar(
                        radius: 27,
                        backgroundColor: Colors.white,
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl != null
                            ? null
                            : Text(
                                user?.initial ?? 'G',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Guest User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            user == null
                                ? 'Browsing as guest'
                                : (user.isEmailVerified
                                      ? 'Verified account'
                                      : 'Account'),
                            style: const TextStyle(
                              color: AppColors.onGreenBody,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            user?.email ??
                                'Sign in to save homes and post properties',
                            style: const TextStyle(
                              color: AppColors.onGreenBody,
                              fontSize: 12,
                            ),
                          ),
                          if (user?.avatarUrl == null && user != null)
                            const Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Text(
                                'Tap the circle to add a photo',
                                style: TextStyle(
                                  color: AppColors.onGreenMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _open(context, const SettingsScreen()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _MyAdsSection(user: user),
              const SizedBox(height: 8),
              const Text(
                'Menu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              _menuTile(
                context,
                Icons.favorite_border,
                'Saved Homes',
                'Your wishlist',
                () => _open(context, const SavedScreen()),
              ),
              _menuTile(
                context,
                Icons.chat_bubble_outline,
                'Chats',
                'Conversations with buyers & sellers',
                () => _open(context, const ChatsScreen()),
              ),
              _menuTile(
                context,
                Icons.group_outlined,
                'Roommates',
                'Find or post a roommate profile',
                () => _open(context, const RoommatesScreen()),
              ),
              _menuTile(
                context,
                Icons.settings_outlined,
                'Settings',
                'Edit profile and notifications',
                () => _open(context, const SettingsScreen()),
              ),
              if (user != null && user.hasPassword)
                _menuTile(
                  context,
                  Icons.lock_outlined,
                  'Change Password',
                  'Update your account password',
                  () => _open(context, const ChangePasswordScreen()),
                ),
              _menuTile(
                context,
                Icons.help_outline,
                'FAQs',
                'Common questions',
                () => _open(context, const InfoScreen(kind: InfoKind.faqs)),
              ),
              _menuTile(
                context,
                Icons.verified_user_outlined,
                'Safety Guidelines',
                'Stay safe when buying or renting',
                () => _open(context, const InfoScreen(kind: InfoKind.safety)),
              ),
              _menuTile(
                context,
                Icons.call_outlined,
                'Contact Us',
                '+92 51 889 4427',
                () => _open(context, const ContactScreen()),
              ),
              _menuTile(
                context,
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                'How your data is used',
                () => _open(context, const InfoScreen(kind: InfoKind.privacy)),
              ),
              _menuTile(
                context,
                Icons.description_outlined,
                'Terms of Service',
                'Rules of the marketplace',
                () => _open(context, const InfoScreen(kind: InfoKind.terms)),
              ),
              const SizedBox(height: 8),
              if (user != null)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    foregroundColor: AppColors.error,
                  ),
                  icon: const Icon(Icons.logout, size: 19),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed: () async {
                    await SessionController.to.clear();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const DashboardScreen(),
                      ),
                      (route) => false,
                    );
                  },
                )
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(Icons.login, size: 19),
                  label: const Text(
                    'Log In / Sign Up',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const DashboardScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
            ],
          ),
        ),
      );
    });
  }
}

/// My Ads — for signed-in users these are the real listings from
/// GET /listings/mine; guests see the labelled design sample.
class _MyAdsSection extends StatefulWidget {
  const _MyAdsSection({required this.user});

  final ApiUser? user;

  @override
  State<_MyAdsSection> createState() => _MyAdsSectionState();
}

class _MyAdsSectionState extends State<_MyAdsSection> {
  List<Property> _ads = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final listings = await CatalogService.fetchMyListings();
      if (!mounted) return;
      final properties = listings.map((l) => l.toProperty()).toList();
      CatalogController.to.register(properties);
      setState(() {
        _ads = properties;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openAd(Property ad) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PropertyDetailScreen(property: ad),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = widget.user != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'My Ads',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          loggedIn
              ? 'Listings you posted'
              : 'Listings you posted (design sample)',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 10),
        if (!loggedIn)
          for (final ad in [dummyProperties[0], dummyProperties[5]])
            PropertyCard(property: ad, onTap: () => _openAd(ad))
        else if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          const Text(
            'Could not load your ads.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
          )
        else if (_ads.isEmpty)
          const Text(
            'You have not posted any property yet.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
          )
        else
          for (final ad in _ads)
            PropertyCard(property: ad, onTap: () => _openAd(ad)),
      ],
    );
  }
}
