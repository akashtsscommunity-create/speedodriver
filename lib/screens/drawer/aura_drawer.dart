import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/user_provider.dart';
import '../../app/app_theme.dart';

class AuraDrawer extends ConsumerWidget {
  final String currentRoute;

  const AuraDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final Color greyText = Colors.grey[600]!;
    final Color lightGreyText = Colors.grey[400]!;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            userAsync.when(
              data: (user) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.mobileNumber ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: greyText,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Error loading user'),
              ),
            ),
            
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // SWITCH ROLE Section
                  _buildSectionHeader('SWITCH ROLE', lightGreyText),
                  _buildRoleItem(
                    icon: Icons.local_shipping,
                    title: 'Customer',
                    isActive: false,
                    onTap: () {
                      // Handle switch to Customer role
                    },
                  ),
                  _buildRoleItem(
                    icon: Icons.local_shipping,
                    title: 'Driver',
                    isActive: true,
                    onTap: () {},
                  ),

                  const SizedBox(height: 8),
                  
                  // Menu Items
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () => GoRouter.of(context).push('/profile'),
                  ),
                  _buildMenuItem(
                    icon: Icons.directions_car_outlined,
                    title: 'Add Vehicle',
                    onTap: () {
                      GoRouter.of(context).pop(); // Close drawer
                      GoRouter.of(context).push('/add-vehicle');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => GoRouter.of(context).push('/settings'),
                  ),
                  _buildMenuItem(
                    icon: null,
                    title: 'Support Chat',
                    onTap: () {
                      // Handle Support Chat
                    },
                  ),

                  const SizedBox(height: 8),

                  // EXPAND Section
                  _buildSectionHeader('EXPAND', lightGreyText),
                  _buildMenuItem(
                    icon: Icons.business_outlined,
                    title: 'Become Fleet Owner',
                    onTap: () {
                      // Handle Fleet Owner
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // Footer Section
            _buildFooterItem(
              icon: Icons.info_outline,
              title: 'Version',
              trailing: const Text(
                'v4.1.1',
                style: TextStyle(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {},
            ),
            _buildFooterItem(
              icon: Icons.logout,
              title: 'Sign Out',
              textColor: Colors.red[800],
              iconColor: Colors.red[800],
              onTap: () async {
                await ref.read(authControllerProvider).logout();
                if (context.mounted) GoRouter.of(context).go('/login');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildRoleItem({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF0FAF4) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFF00A651) : Colors.grey[700],
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFF00A651) : Colors.grey[800],
            fontSize: 15,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isActive
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF00A651).withValues(alpha: 0.2)),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Color(0xFF00A651),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildMenuItem({
    IconData? icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon != null 
          ? Icon(icon, color: Colors.grey[500], size: 22) 
          : const SizedBox(width: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Widget _buildFooterItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? textColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey[400], size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.grey[500],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
