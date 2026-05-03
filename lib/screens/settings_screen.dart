import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/theme_provider.dart';
import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';

/// Settings Screen
/// Manages app preferences: dark mode, language, and data management
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'DMSerifDisplay',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Dark Mode Toggle
              SwitchListTile(
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppTheme.primary,
                ),
                title: const Text(
                  'Dark mode',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleDarkMode(value);
                },
                activeColor: AppTheme.primary,
              ),

              const Divider(height: 1),

              // List Language
              ListTile(
                leading: const Icon(
                  Icons.language,
                  color: AppTheme.primary,
                ),
                title: const Text(
                  'List language',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      themeProvider.listLanguage,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
                onTap: () => _showLanguagePicker(context, themeProvider),
              ),

              // About Section Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(
                  'About',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // App Version
              ListTile(
                leading: const Icon(
                  Icons.info_outline,
                  color: AppTheme.primary,
                ),
                title: const Text(
                  'Version',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Text(
                  '1.0.0',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),

              // Send Feedback
              ListTile(
                leading: const Icon(
                  Icons.mail_outline,
                  color: AppTheme.primary,
                ),
                title: const Text(
                  'Send feedback',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _sendFeedback(),
              ),

              // Rate This App
              ListTile(
                leading: const Icon(
                  Icons.star_outline,
                  color: AppTheme.primary,
                ),
                title: const Text(
                  'Rate this app',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _rateApp(),
              ),

              const Divider(height: 24),

              // Delete All Data (Danger Zone)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.danger,
                ),
                title: const Text(
                  'Delete all data',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.danger,
                  ),
                ),
                subtitle: const Text(
                  'This will delete all your trips and lists',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                onTap: () => _showDeleteConfirmation(context),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  /// Show language picker bottom sheet
  void _showLanguagePicker(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Language',
                style: TextStyle(
                  fontFamily: 'DMSerifDisplay',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
            ),
            const Divider(height: 1),
            ...ThemeProvider.availableLanguages.map((language) {
              final isSelected = language == themeProvider.listLanguage;
              return ListTile(
                leading: isSelected
                    ? const Icon(Icons.check_circle, color: AppTheme.primary)
                    : const Icon(Icons.circle_outlined),
                title: Text(
                  language,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppTheme.primary : AppTheme.textPrimaryLight,
                  ),
                ),
                onTap: () {
                  themeProvider.setListLanguage(language);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Send feedback via email
  void _sendFeedback() {
    final subject = 'PackRight Feedback — v1.0.0';
    Share.share(
      'PackRight Feedback\n\nPlease share your thoughts about the app:\n\n',
      subject: subject,
    );
  }

  /// Rate the app (placeholder)
  void _rateApp() {
    // TODO: Replace with actual Play Store URL after publishing
    // For now, show a snackbar
    // In production, use: launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.packright.app'))
  }

  /// Show delete all data confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all Data?'),
        content: const Text(
          'This will delete all your trips and lists. This can\'t be undone.',
          style: TextStyle(fontFamily: 'DMSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            onPressed: () async {
              Navigator.pop(context);
              
              // Delete all trips
              final provider = context.read<TripProvider>();
              await provider.deleteAllTrips();
              
              // Navigate back to home
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}