import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import 'edit_profile_screen.dart';
import 'payment_methods_screen.dart';
import 'notification_settings_screen.dart';
import 'help_support_screen.dart';
import 'terms_conditions_screen.dart';

/// Main profile screen displaying user info, navigation to settings screens,
/// light/dark theme toggle, and logout functionality.
///
/// THEME: Converted to be theme-aware (light/dark). Uses ThemeProvider for
/// surface colors and text colors instead of hardcoded AppColors.black2/white.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Shows a confirmation dialog before logging the user out.
  /// Uses the passed theme for dialog surface and text colors.
  void _confirmLogout(BuildContext context, AuthProvider authProvider, ThemeProvider theme) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.surfaceElevated, // was AppColors.black2 — now theme-aware (dialog = elevated surface)
        title: Text('Log Out', style: TextStyle(color: theme.textPrimary)), // was AppColors.white — now theme-aware
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: AppColors.grey), // grey stays as static accent
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              authProvider.logout();
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)), // red stays as destructive accent
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    // Access theme provider for light/dark mode aware colors
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.background, // now theme-aware
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // --- User Avatar & Info ---
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.yellow, // yellow stays as brand accent
                    child: Icon(Icons.person, color: AppColors.black, size: 44), // black icon on yellow — optimal contrast always
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.fullName ?? 'Rider',
                    style: TextStyle(color: theme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold), // was AppColors.white — now theme-aware
                  ),
                  Text(
                    user?.phone ?? '',
                    style: const TextStyle(color: AppColors.grey, fontSize: 13), // grey stays as static accent
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Profile Menu Items ---
            _ProfileMenuTile(
              icon: Icons.edit_outlined,
              label: 'Edit Profile',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
              theme: theme, // pass theme to menu tile
            ),
            _ProfileMenuTile(
              icon: Icons.payment_outlined,
              label: 'Payment Methods',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
              theme: theme, // pass theme to menu tile
            ),
            _ProfileMenuTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
              theme: theme, // pass theme to menu tile
            ),
            _ProfileMenuTile(
              icon: Icons.help_outline,
              label: 'Help and Support',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
              theme: theme, // pass theme to menu tile
            ),
            _ProfileMenuTile(
              icon: Icons.description_outlined,
              label: 'Terms and Conditions',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsScreen())),
              theme: theme, // pass theme to menu tile
            ),

            // --- Light/Dark Mode Toggle ---
            // Uses Consumer<ThemeProvider> for reactive toggle state,
            // but text colors come from the theme for consistency.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.brightness_6_outlined, color: AppColors.yellow), // yellow stays as brand accent
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Light Mode',
                      style: TextStyle(color: theme.textPrimary, fontSize: 14), // was AppColors.white — now theme-aware
                    ),
                  ),
                  Switch(
                    value: theme.isLightMode,
                    onChanged: (_) => theme.toggleTheme(),
                    activeThumbColor: AppColors.yellow, // yellow stays as brand accent
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- Logout ---
            _ProfileMenuTile(
              icon: Icons.logout,
              label: 'Logout',
              iconColor: AppColors.red, // red stays as destructive accent
              onTap: () => _confirmLogout(context, authProvider, theme), // pass theme to dialog
              theme: theme, // pass theme to menu tile
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual menu tile used in the profile screen for navigation items.
/// Now theme-aware — accepts ThemeProvider for text colors.
class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final ThemeProvider theme; // added for light/dark mode support

  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor ?? AppColors.yellow),
        title: Text(
          label,
          style: TextStyle(color: theme.textPrimary, fontSize: 14), // was AppColors.white — now theme-aware
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.grey), // grey stays as static accent
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}