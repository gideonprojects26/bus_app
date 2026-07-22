import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import 'edit_profile_screen.dart';
import 'payment_methods_screen.dart';
import 'notification_settings_screen.dart';
import 'help_support_screen.dart';
import 'terms_conditions_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _confirmLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.black2,
        title: const Text('Log Out', style: TextStyle(color: AppColors.white)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: AppColors.grey),
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
            child: const Text('Logout', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.yellow,
                    child: Icon(Icons.person, color: AppColors.black, size: 44),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.fullName ?? 'Rider',
                    style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.phone ?? '',
                    style: const TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _ProfileMenuTile(
              icon: Icons.edit_outlined,
              label: 'Edit Profile',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
            ),
            _ProfileMenuTile(
              icon: Icons.payment_outlined,
              label: 'Payment Methods',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
            ),
            _ProfileMenuTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
            ),
            _ProfileMenuTile(
              icon: Icons.help_outline,
              label: 'Help and Support',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
            ),
            _ProfileMenuTile(
              icon: Icons.description_outlined,
              label: 'Terms and Conditions',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsScreen())),
            ),
            const SizedBox(height: 12),
            _ProfileMenuTile(
              icon: Icons.logout,
              label: 'Logout',
              iconColor: AppColors.red,
              onTap: () => _confirmLogout(context, authProvider),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor ?? AppColors.yellow),
        title: Text(label, style: const TextStyle(color: AppColors.white, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}