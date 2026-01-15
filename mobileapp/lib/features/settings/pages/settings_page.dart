import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/standard_page_header.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StandardPageHeader(
            title: 'Settings',
          ),
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _buildSettingsList(context, state);
          }
          return const Center(
            child: Text('Please log in to access settings'),
          );
        },
      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, AuthAuthenticated authState) {
    return ListView(
      children: [
        // Profile Section
        _buildSectionHeader('Profile'),
        _buildSettingsTile(
          context,
          'Edit Profile',
          'Update your personal information',
          Icons.person,
          () => context.go('/profile/edit'),
        ),
        _buildSettingsTile(
          context,
          'Change Password',
          'Update your account password',
          Icons.lock,
          () => _showChangePasswordDialog(context),
        ),

        // Notifications Section
        _buildSectionHeader('Notifications'),
        _buildSwitchTile(
          context,
          'Push Notifications',
          'Receive notifications about events',
          Icons.notifications,
          true,
          (value) => _handleNotificationToggle(context, value),
        ),
        _buildSwitchTile(
          context,
          'Email Notifications',
          'Receive email updates',
          Icons.email,
          true,
          (value) => _handleEmailToggle(context, value),
        ),

        // App Settings Section
        _buildSectionHeader('App Settings'),
        _buildSettingsTile(
          context,
          'Theme',
          'Choose your preferred theme',
          Icons.palette,
          () => _showThemeDialog(context),
        ),
        _buildSettingsTile(
          context,
          'Language',
          'Select your preferred language',
          Icons.language,
          () => _showLanguageDialog(context),
        ),
        _buildSettingsTile(
          context,
          'Reset Onboarding',
          'Show onboarding screens again',
          Icons.refresh,
          () => context.go('/reset-onboarding'),
        ),

        // Privacy & Security Section
        _buildSectionHeader('Privacy & Security'),
        _buildSettingsTile(
          context,
          'Privacy Policy',
          'View our privacy policy',
          Icons.privacy_tip,
          () => _showPrivacyPolicy(context),
        ),
        _buildSettingsTile(
          context,
          'Terms of Service',
          'View terms and conditions',
          Icons.description,
          () => _showTermsOfService(context),
        ),

        // Support Section
        _buildSectionHeader('Support'),

        _buildSettingsTile(
          context,
          'Contact Us',
          'Get in touch with our support team',
          Icons.contact_support,
          () => _showContactUs(context),
        ),
        _buildSettingsTile(
          context,
          'About',
          'App version and information',
          Icons.info,
          () => _showAboutDialog(context),
        ),

        // Account Section
        _buildSectionHeader('Account'),
        _buildSettingsTile(
          context,
          'Logout',
          'Sign out of your account',
          Icons.logout,
          () => _showLogoutDialog(context),
          textColor: Colors.red,
        ),
        if (authState.user.role == 'ORGANIZER')
          _buildSettingsTile(
            context,
            'Delete Account',
            'Permanently delete your account',
            Icons.delete_forever,
            () => _showDeleteAccountDialog(context),
            textColor: Colors.red,
          ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppConstants.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.black87),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.black87),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppConstants.primaryColor,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.black),
        ),
        content: const Text(
          'This feature will be available soon.',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationToggle(BuildContext context, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Push notifications ${value ? 'enabled' : 'disabled'}'),
      ),
    );
  }

  void _handleEmailToggle(BuildContext context, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email notifications ${value ? 'enabled' : 'disabled'}'),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Choose Theme',
          style: TextStyle(color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                'Light',
                style: TextStyle(color: Colors.black),
              ),
              leading: const Icon(Icons.light_mode, color: Colors.black),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme changed to Light')),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Dark',
                style: TextStyle(color: Colors.black),
              ),
              leading: const Icon(Icons.dark_mode, color: Colors.black),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme changed to Dark')),
                );
              },
            ),
            ListTile(
              title: const Text(
                'System',
                style: TextStyle(color: Colors.black),
              ),
              leading: const Icon(Icons.settings, color: Colors.black),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme set to System default')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Choose Language',
          style: TextStyle(color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                'English',
                style: TextStyle(color: Colors.black),
              ),
              leading: const Text('🇺🇸'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language changed to English')),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Bahasa Indonesia',
                style: TextStyle(color: Colors.black),
              ),
              leading: const Text('🇮🇩'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bahasa diubah ke Bahasa Indonesia')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.black),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'This is a placeholder for the privacy policy. In a real app, this would contain the actual privacy policy text.',
            style: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Terms of Service',
          style: TextStyle(color: Colors.black),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'This is a placeholder for the terms of service. In a real app, this would contain the actual terms and conditions.',
            style: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Contact Us',
          style: TextStyle(color: Colors.black),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: support@eventmanagement.com',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              'Phone: +62 123 456 7890',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              'Address: Jakarta, Indonesia',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'About',
          style: TextStyle(color: Colors.black),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nusa App',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              'Version: 1.0.0',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              'Build: 2024.01.01',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '© 2024 Nusa Team',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.black),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
              context.go('/login');
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.black),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion feature coming soon')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
