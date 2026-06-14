import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/user_provider.dart';
import '../../app/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A651),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'DRIVER',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: userAsync.when(
        data: (user) => SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildAvatarSection(user?.fullName ?? 'User', user?.mobileNumber ?? ''),
              const SizedBox(height: 24),
              _buildPersonalInfoCard(user),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: OutlinedButton(
                  onPressed: () => GoRouter.of(context).push('/profile/edit'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    side: const BorderSide(color: AppTheme.primaryOrange),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Edit Profile', style: TextStyle(color: AppTheme.primaryOrange)),
                ),
              ),
              const SizedBox(height: 24),
              _buildSecuritySection(user),
              const SizedBox(height: 24),
              _buildPerformanceSection(),
              const SizedBox(height: 24),
              _buildDeliveriesSection(),
              const SizedBox(height: 24),
              _buildFleetSection(),
              const SizedBox(height: 24),
              _buildBottomCards(),
              const SizedBox(height: 24),
              _buildSupportBox(),
              const SizedBox(height: 40),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildAvatarSection(String name, String phone) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF00A651),
              child: Text(
                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF00A651),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          phone,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard(dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem('Full Name', user?.fullName ?? 'Akash Singh'),
          const Divider(),
          _buildInfoItem('Phone Number', user?.mobileNumber ?? '+917880335787', subtitle: 'Contact support to change'),
          const Divider(),
          _buildInfoItem('Email', user?.emailAddress ?? '--', subtitle: 'Add in Security to enable email sign-in'),
          const Divider(),
          _buildInfoItem('Date of Birth', user?.dateOfBirth ?? '27 May 2002'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
        ],
      ],
    );
  }

  Widget _buildSecuritySection(dynamic user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Text('Sign-in & Security', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 20, color: Colors.grey),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Email & Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            Text('Not linked - add an email to sign in without OTP', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                          ],
                        ),
                      ],
                    ),
                    TextButton(onPressed: () {}, child: const Text('Add email', style: TextStyle(color: AppTheme.primaryOrange, fontSize: 13))),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 20, color: Colors.grey),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Phone Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        Text(user?.mobileNumber ?? '+917880335787', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPerformanceItem('Total', '0', const Color(0xFFF0FAF4), const Color(0xFF00A651), Icons.local_shipping),
                _buildPerformanceItem('Completed', '0', const Color(0xFFF0F7FF), const Color(0xFF007AFF), Icons.check_circle),
                _buildPerformanceItem('Rating', '0.0', const Color(0xFFFFFBE6), const Color(0xFFFFCC00), Icons.star),
                _buildPerformanceItem('Earnings', '₹0', const Color(0xFFFFF5F0), const Color(0xFFF05C14), Icons.currency_rupee),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(String label, String value, Color bgColor, Color color, IconData icon) {
    return Container(
      width: 75,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (label == 'Rating') ...[
                const SizedBox(width: 2),
                const Icon(Icons.star, size: 14, color: Color(0xFFFFCC00)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveriesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Completed Deliveries', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Your delivery history', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              TextButton(onPressed: () {}, child: const Text('Refresh', style: TextStyle(color: AppTheme.primaryOrange, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Text('No completed deliveries yet.', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fleet Invitations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Requests to join organizations', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              TextButton(onPressed: () {}, child: const Text('Refresh', style: TextStyle(color: AppTheme.primaryOrange, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Text('No pending fleet invitations.', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildSimpleCard(
              icon: Icons.currency_rupee,
              iconColor: Colors.blue,
              title: 'Wallet',
              subtitle: 'Balance, transactions & top-up',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSimpleCard(
              icon: Icons.card_giftcard,
              iconColor: AppTheme.primaryOrange,
              title: 'Refer & earn',
              subtitle: 'Invite friends, earn rewards',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCard({required IconData icon, required Color iconColor, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildSupportBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need to change your company details or request special updates?',
            style: TextStyle(fontSize: 13, color: Color(0xFF003366)),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {},
            child: const Row(
              children: [
                Text('Contact Support', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold, fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: Color(0xFF007AFF)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
